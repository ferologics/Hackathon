/*
Created 20th July 2015 by Fero Hetes with a heavy help of Jay without
       whom would my app never see the light ofthe day...
(also thanks to amazing instructors Abdul and Warren <3)
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
var moment = require('moment');

// variables
var cities = ["San Francisco", "London"];
var searchKeyword = "hackathon";
var searchURL = 'https://www.eventbriteapi.com/v3/events/search/';
var venueURL = 'https://www.eventbriteapi.com/v3//venues/';
var token = "FWMDQSTTDTI5EJRD6VUH";

// cloud code job
Parse.Cloud.job("hopeThisWorks", function(request, status) {

   var query = new Parse.Query("Hackathon");
   var deletionPromise = query.find().then(function(results) {
      _.each(results, function(result) {
         result.destroy();
      })
   })

   var promises = _.map(cities, function (city, index) {

      var promise = new Parse.Promise();

      getHTTPResponseForCity(city)
      .then(function(httpResponse) {
         var items = _.map(JSON.parse(httpResponse.text)["events"], function (item, index) {
            return hackathonForEvent(item);
         });

         Parse.Object.saveAll(items, {
            success: function () {
               promise.resolve();
            },
            error: function (error) {
               console.log(error.message);
            }
         });
      });
      return promise;
   });

   promises.unshift(deletionPromise); // add the deletion promise to the 1st place in promises array

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
      url : venueURL,
      params : {
         ":id": venueID,
         token: token
         // expand: "logo" ---> IDK why this fcks up the ticketclasses and how to make this work
      }
   });
}

// setting columns in Parse
function hackathonForEvent(theEvent) {

   Parse.Cloud.useMasterKey(); // not really needed I guess
   var hackathon = new Parse.Object("Hackathon");
   var responseForVenueID = getHTTPResponseForVenueID(theEvent["venue_id"])
/*

MIGHT NEED TO USE PROMISES MOST LIKELY AS HTTPRESPONSE IS ASYNCH, NO IDEA HOW TO RESTRUCTURE THIS, FUCK.

*/
   hackathon.set("uri",           ( theEvent["resource_uri"] + "?token=" + token));
   hackathon.set("url",             theEvent["url"]);
   hackathon.set("uniqueID",        theEvent["id"]);
   hackathon.set("name",            theEvent["name"]["text"]);
   hackathon.set("city",            responseForVenueID["adress"]["city"]);
   hackathon.set("adres_1",         responseForVenueID["adresss"]["address_1"]);
   hackathon.set("adress_2",        responseForVenueID["adresss"]["address_2"]);
   hackathon.set("latitude",        responseForVenueID["adresss"]["latitude"]);
   hackathon.set("longitude",       responseForVenueID["adresss"]["longitude"]);
   hackathon.set("description",     theEvent["description"] ? theEvent["description"]["text"] : "None provided.");
   hackathon.set("status",          theEvent["status"]);
   hackathon.set("capacity",        theEvent["capacity"]);
   hackathon.set("logo",          ( theEvent["logo"] != undefined || theEvent["logo"] != null) ? theEvent["logo"]["url"] : "http://www.ecolabelindex.com/files/ecolabel-logos-sized/no-logo-provided.png");
   hackathon.set("start", new Date( theEvent["start"]["utc"]));
   hackathon.set("end",   new Date( theEvent["end"]["utc"]));
   hackathon.set("online",          theEvent["online_theEvent"]);
   hackathon.set("currency",        theEvent["currency"]);

   var tickets = _.map(theEvent["ticket_classes"], function (item, index) { // creating a JSON object to Parse
      return {
         name:           item["name"],
         cost:         ( item["cost"]        ? item["cost"]["display"] : 0.00 ),
         fee:          ( item["fee"]         ? item["fee"]["display"]  : 0.00 ),
         tax:          ( item["tax"]         ? item["tax"]["display"]  : 0.00 ),
         description:  ( item["description"] ? item["description"]     : "No description" ),
         onSaleStatus:   item["on_sale_status"],
         donations:      item["donation"],
         free:           item["free"]
      };
   });

   hackathon.set("ticketClassesNames",          assignTicketClassesProperties( tickets, ["name"] );
   hackathon.set("ticketClassesCosts",          assignTicketClassesProperties( tickets, ["cost"] );
   hackathon.set("ticketClassesFees",           assignTicketClassesProperties( tickets, ["fee"] );
   hackathon.set("ticketClassesTaxes",          assignTicketClassesProperties( tickets, ["tax"] );
   hackathon.set("ticketClassesOnSaleStatuses", assignTicketClassesProperties( tickets, ["onSaleStatus"] );
   hackathon.set("ticketClassesDescriptions",   assignTicketClassesProperties( tickets, ["description"]["text"] );
   hackathon.set("ticketClassesDonations",      assignTicketClassesProperties( tickets, ["donations"] );
   hackathon.set("ticketClassesFree",           assignTicketClassesProperties( tickets, ["free"] );

   return hackathon;
}

function assignTicketClassesProperties(ticketClasses, property) {
   var propertyArray = []
   for (i = 0; i < ticketClasses.length; i++ ) {
      propertyArray.pop(ticketClasses[i][property]);
   }
   return propertyArray
}
