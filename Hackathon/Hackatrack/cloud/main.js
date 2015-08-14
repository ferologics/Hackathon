/*
Created 20th July 2015 by Fero Hetes with a heavy help of Jay without
whom would my app never see the light of the day...
(also thanks to amazing instructors Abdul, Simon and Warren <3)
                         _________
                        /         \
                       /    <3     \
                       |           |
                       | <0>   <0> |
                       \   _____   /
                        \_________/
                            /|\
                             |
                             |
                            / \
*/

// required libraries
var _ = require('underscore');

// variables
var cities = ["San Francisco", "London", "New York", "Palo Alto","Redwood City",
              "Baltimore", "Boston","Sacramento","Los Angeles","Denver","San Diego",
              "St. Louis","Houston","Austin","Philadelphia","Kansas City","Portland"];

var searchKeyword = "hackathon";
var searchURL = 'https://www.eventbriteapi.com/v3/events/search/';
var venueURL = 'https://www.eventbriteapi.com/v3/venues/';
var token = "FWMDQSTTDTI5EJRD6VUH";

var Hackathon = Parse.Object.extend("Hackathon");
var Watchlist = Parse.Object.extend("Watchlist");
var FBUsers = Parse.Object.extend("FBUser");

// cloud code job
Parse.Cloud.job("hopeThisWorks", function(request, status) {

   /*var query = new Parse.Query("Hackathon");
   var deletionPromise = query.find().then(function(results) {
      _.each(results, function(result) {
         result.destroy();
      })
   })*/

   var promises = _.map(cities, function (city, index) {

      var promise = new Parse.Promise();

      getHTTPResponseForCity(city)
      .then(function(httpResponse) {
         /*var items = */
         Parse.Promise.when(_.map(JSON.parse(httpResponse.text)["events"], function (item, index) {
            return hackathonForEvent(item);
         })).then(function() {
            var hackathons = arguments
            console.log(hackathons.length + " hackathons in - " + city);

            Parse.Object.saveAll(hackathons, {
               success: function () {
                  promise.resolve();
               },
               error: function (error) {
                  console.log(error.message);
               }
            });

         });
      });
      return promise;
   });

   /*promises.unshift(deletionPromise); // add the deletion promise to the 1st place in promises array*/

   Parse.Promise.when(promises).then(function (p1, p2) {
      status.success("all is good");
   });
});

// search code
function getHTTPResponseForCity(city) {

   return Parse.Cloud.httpRequest({
      url : searchURL,
      params : {
         q:            searchKeyword,
         "venue.city": city,
         token:        token,
         expand:       "ticket_classes"
         // expand:    "logo" ---> IDK why this fcks up the ticketclasses and how to make this work
      }
   });
}

function getHTTPResponseForVenueID(venueID) {

   return Parse.Cloud.httpRequest({
      url : venueURL + venueID,
      params : {
         token : token
      },
      followRedirects : true
   });
}

// setting columns in Parse
function hackathonForEvent(theEvent)
{
   Parse.Cloud.useMasterKey(); // not really needed I guess
   var hackathon = new Parse.Object("Hackathon");

   return getHTTPResponseForVenueID(theEvent["venue_id"])
   .then(function(httpResponse)
   {
      /*console.log("Got details for venue " + theEvent["venue_id"]);*/
      var venue = JSON.parse(httpResponse.text);
      /*console.log("httpresponse - " + venue);*/

      hackathon.set("uri",             theEvent["resource_uri"] + "?token=" + token);
      hackathon.set("uriVenue",        venueURL + theEvent["venue_id"] + "?token=" + token);
      hackathon.set("url",             theEvent["url"]);
      hackathon.set("uniqueID",        theEvent["id"]);
      hackathon.set("name",            theEvent["name"]["text"]);

      hackathon.set("venueName",       venue["name"]);
      hackathon.set("city",          ( venue["address"] != null || venue["address"] != undefined )                                          ? venue["address"]["city"]      : "No city" );
      hackathon.set("address_1",     ( venue["address"] != null || venue["address"] != undefined || venue["address"]["address_1"] != null ) ? venue["address"]["address_1"] : "No address" );
      hackathon.set("address_2",     ( venue["address"] != null || venue["address"] != undefined )                                          ? venue["address"]["address_2"] : "No address" );

      hackathon.set("geoPoint",    new Parse.GeoPoint( venue["address"]["latitude"],venue["address"]["longitude"] ) );

      hackathon.set("descript",        theEvent["description"] ? theEvent["description"]["text"] : "None provided.");
      hackathon.set("status",          theEvent["status"]);
      hackathon.set("capacity",        theEvent["capacity"]);
      hackathon.set("logo",          ( theEvent["logo"] != undefined || theEvent["logo"] != null ) ? theEvent["logo"]["url"] : "http://www.ecolabelindex.com/files/ecolabel-logos-sized/no-logo-provided.png");
      hackathon.set("start", new Date( theEvent["start"]["utc"]));
      hackathon.set("end",   new Date( theEvent["end"]["utc"]));
      hackathon.set("online",          theEvent["online_theEvent"]);
      hackathon.set("currency",        theEvent["currency"]);

      var tickets = _.map(theEvent["ticket_classes"], function (item, index) { // creating a JSON object to Parse
         return {
            name:           item["name"],
            cost:         ( item["cost"]        ? item["cost"]["display"] : "$0" ),
            fee:          ( item["fee"]         ? item["fee"]["display"]  : "$0" ),
            tax:          ( item["tax"]         ? item["tax"]["display"]  : "$0" ),
            description:  ( item["description"] ? item["description"]     : "No description" ),
            onSaleStatus:   item["on_sale_status"],
            donations:      item["donation"],
            free:           item["free"]
         };
      });

      hackathon.set("ticketClassesNames",          assignTicketClassesProperties( tickets, ["name"] ));
      hackathon.set("ticketClassesCosts",          assignTicketClassesProperties( tickets, ["cost"] ));
      hackathon.set("ticketClassesFees",           assignTicketClassesProperties( tickets, ["fee"] ));
      hackathon.set("ticketClassesTaxes",          assignTicketClassesProperties( tickets, ["tax"] ));
      hackathon.set("ticketClassesOnSaleStatuses", assignTicketClassesProperties( tickets, ["onSaleStatus"] ));
      hackathon.set("ticketClassesDescriptions",   assignTicketClassesProperties( tickets, ["description"]["text"] )); // TODO might be some kind of problem in here
      hackathon.set("ticketClassesDonations",      assignTicketClassesProperties( tickets, ["donations"] ));
      hackathon.set("ticketClassesFree",           assignTicketClassesProperties( tickets, ["free"] ));

      return hackathon
   });
}

function assignTicketClassesProperties(ticketClasses, property) {
   var propertyArray = [];
   for (i = 0; i < ticketClasses.length; i++ ) {

      var temp = ticketClasses[i][property];

      propertyArray.push(temp);
   }

   return propertyArray;
}

// before save deduplicating for hackathons
Parse.Cloud.beforeSave("Hackathon", function(request, response) {
    if (!request.object.isNew()) {
      // Let existing object updates go through
      response.success();
    }
    var query = new Parse.Query(Hackathon);
    // Add query filters to check for uniqueness
    query.equalTo("uniqueID", request.object.get("uniqueID"));
    query.first().then(function(existingObject) {
      if (existingObject) {
         return Parse.Promise.as(true);
      } else {
        // Pass a flag that this is not an existing object
        return Parse.Promise.as(false);
      }
    }).then(function(existingObject) {
      if (existingObject) {
        // Existing object, stop initial save
        response.error("Existing object");
      } else {
        // New object, let the save go through
        response.success();
      }
    }, function (error) {
      response.error("Error performing checks or saves.");
    });
});

// before save deduplicating for hackathons
Parse.Cloud.beforeSave("Watchlist", function(request, response) {
    if (!request.object.isNew()) {
      // Let existing object updates go through
      response.success();
    }
    var query = new Parse.Query(Watchlist);
    // Add query filters to check for uniqueness
    query.equalTo("toHackathon", request.object.get("toHackathon"));
    query.equalTo("toUser", request.object.get("toUser"));
    query.first().then(function(existingObject) {
      if (existingObject) {
         return Parse.Promise.as(true);
      } else {
        // Pass a flag that this is not an existing object
        return Parse.Promise.as(false);
      }
    }).then(function(existingObject) {
      if (existingObject) {
        // Existing object, stop initial save
        response.error("Existing object");
      } else {
        // New object, let the save go through
        response.success();
      }
    }, function (error) {
      response.error("Error performing checks or saves.");
    });
});

Parse.Cloud.define("getFriendHackathons", function(request,response)
{
   Parse.Cloud.useMasterKey();

   console.log("function trigered.");
   var user = Parse.User.current();
   var relation = user.relation("friends");
   var relationQuery = relation.query();
   relationQuery.exists("fbID");

   // get objects for users friends
   var userQuery = new Parse.Query(Parse.User);
   userQuery.matchesKeyInQuery("fbID","fbID",relationQuery);

   userQuery.find({
      // use the user objects if success
      success: function(friends)
      {
         console.log(friends);
         // get watchlist objects for users friends
         var watchlistQuery = new Parse.Query(Watchlist);
         watchlistQuery.containedIn("toUser", friends);

         watchlistQuery.find({
            // use the watchlist objects if success
            success: function(watchlistObjects)
            {
               console.log(watchlistObjects);
               // get the unique hakcathon ids only
               var uniqueHackathonIDs = [];

               _.each(watchlistObjects, function(object){

                  console.log(object)
                  var toHackathonPointer = object.get("toHackathon");
                  var hackathonID = toHackathonPointer.id;
                  console.log(toHackathonPointer.id);


                  if      ( uniqueHackathonIDs.length == 0 ) // in empty add the firstObject
                     { uniqueHackathonIDs.push(hackathonID) }

                  else if ( !( uniqueHackathonIDs.indexOf(hackathonID) > -1 ) ) // if not contained already add to array
                     { uniqueHackathonIDs.push(hackathonID) };
               });

               console.log(uniqueHackathonIDs);
               // get the hackathons from the unique ids
               var hackathonQuery = new Parse.Query(Hackathon);
               hackathonQuery.containedIn("objectId", uniqueHackathonIDs);

               hackathonQuery.find({
                     // return hackathons if success
                     success: function(hackathons) { console.log(hackathons); response.success(hackathons) },
                     // return error if failed
                     error:   function(error)      { response.error("Error - " + error) }
                  });
            },
            // return error if failed
            error: function(error) { response.error("Error - " + error) }
         });
      },
      // return error if failed
      error: function(error) { response.error("Error - " + error) }
   });
});

/*
Parse.Cloud.beforeSave("User", function(request, response) {

    if (!request.object.isNew()) {
      // Let existing object updates go through
      response.success();
    }

    // query current user for friends

    // if there are any new friends using the app save them, if not dismiss
    var query = new Parse.Query(U);

    // Add query filters to check for uniqueness

    query.equalTo("uniqueID", request.object.get("uniqueID"));
    query.first().then(function(existingObject) {
      if (existingObject)
      {
        return Parse.Promise.as(true);
      } else {

        return Parse.Promise.as(false);
      }
    }).then(function(existingObject) {
      if (existingObject) {
        // Existing object, stop initial save
        response.error("Existing object"); // DOES THIS INTERRUPT THE SAVE OF ALL?
      } else {
        // New object, let the save go through and create a relation to the current user

        response.success();
      }
    }, function (error) {
      response.error("Error performing checks or saves.");
    });
});

Parse.Cloud.afterSave("FBUser", function(request, response) {

   var currentUser = Parse.User.current();
   var relation = currentUser.relation("friends");
   relation.add(request.object);

   currentUser.save().then(function(object)
   {  // relation created successfully
      response.success();
   }, function (error) {
     response.error("Error creating a relation for - " + object);
   });
});*/
