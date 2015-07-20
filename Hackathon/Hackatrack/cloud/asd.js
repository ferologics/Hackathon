
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

// REQUIRED
var _ = require('underscore');
var moment = require('moment');

// misc
var j = 0;

// search parameters
var eventsArray = [""];
var ticketClassesArray = [""];
var searchKeyword = "hackathon";
var searchURL = 'https://www.eventbriteapi.com/v3/events/search/';
var token = "FWMDQSTTDTI5EJRD6VUH";
var cities = ["San Francisco", "London"];

// extending List class
var List = Parse.Object.extend("List");

// PARSE COUD CODE FUNCTIONS
Parse.Cloud.define("q", function(request, response) {

   var promise = Parse.Promise.as();
   _.each(cities, function(city) {
       promise = promise.then( function(){
           return loopCities(city);
        });

   });
   promise = promise.then (function() {
       response.success("HEEEELL YEAAA!");
   });
   return promise;
});

// Parse.Cloud.job("whatever", function (request, status) {
// })

// HELPER FUNCTIONS
function loopCities(city) {

   return Parse.Cloud.httpRequest({ // CORE SEARCH FUNCTION
      url: searchURL,
        params: {
          q : searchKeyword,
          "venue.city" : city,
          token : token,
          expand : "ticket_classes",
          expand : "logo"
        }
    }).then(function(httpResponse) {

      console.log("been here, did that");
      eventsArray = JSON.parse(httpResponse.text)["events"];

      return loopEvents(eventsArray);

      // PREUPLOAD/PRESAVE FUNCTIONS

      // UPLOAD FUNCTIONS

      // POST UPLOAD FUNCTIONS

    },function(httpResponse) {
        // success
      console.log(httpResponse.text);
    },function(httpResponse) {
      // error
    console.error('Request failed with response code ' + httpResponse.status);
    //response.success(httpResponse.text);
  });
}

function loopEvents(events) {
   //if  (j == cities.length) {j=0};

   var promise = Parse.Promise.as()

   var i = 0;
   _.each(events, function(event) {
      promise = promise.then( function() {
         var list = new List();
         // console.log("assigning properties for " + city.text + ".");
         , {
            success: function(list) {
               console.log("Successsss!");
            },
            error: function(list, error) {
               console.log("u fcked up! with error: " + error.message + ", son. " + list.text);
            }
         });
      });
   })

   return promise

   // for (var i = 0; i < events.length; i++) {
   //    Parse.Cloud.useMasterKey();
   //    var list = new List();
   //    console.log("assigning properties for " + cities[j] + ".");
   //    list.save(
   //    {
   //       number:                      String(i),
   //       uri:                         events[i]["resource_uri"],
   //       url:                         events[i]["url"],
   //       id:                          events[i]["id"],
   //       name:                        events[i]["name"]["text"],
   //       description:                 events[i]["description"]["text"] || "None provided.",
   //       status:                      events[i]["status"],
   //       capacity:                    String(events[i]["capacity"]),
   //       logo:                        (events[i]["logo"] != undefined || events[i]["logo"] != null) ? events[i]["logo"]["url"] : "http://www.ecolabelindex.com/files/ecolabel-logos-sized/no-logo-provided.png",
   //       start:                       moment(events[i]["start"]["utc"]),
   //       end:                         moment(events[i]["end"]["utc"]),
   //       online:                      events[i]["online_event"],
   //       currency:                    events[i]["currency"],
   //       ticketClassesNames:          assignTicketClassProperties(events[i], ["name"]),
   //       ticketClassesCosts:          assignTicketClassProperties(events[i], ["cost"]["display"]),
   //       ticketClassesFees:           assignTicketClassProperties(events[i], ["fee"]["display"]),
   //       ticketClassesDescriptions:   assignTicketClassProperties(events[i], ["description"]),
   //       ticketClassesOnSaleStatuses: assignTicketClassProperties(events[i], ["on_sale_status"]),
   //       ticketClassesTaxes:          assignTicketClassProperties(events[i], ["tax"]["display"]),
   //       ticketClassesDonations:      Boolean(assignTicketClassProperties(events[i], ["donation"])),
   //       ticketClassesFree:           Boolean(assignTicketClassProperties(events[i], ["free"]))
   //    }, {
   //       success: function(list) {
   //          console.log("Successsss!");
   //       },
   //       error: function(list, error) {
   //          console.log("u fcked up! with error: " + error.text + ", son. " + list.text);
   //       }
   //    });
   // }
   // j++;
}

function assignTicketClassProperties(events, propertyName) {
   if (events["ticket_classes"] != undefined) {
      for (var l = 0; l < events["ticket_classes"].length; l++)
      {
         ticketClassesArray.push(String(events["ticket_classes"][l][propertyName]) || null);
      }
   } else {
      return "No ticket classes.";
   }
   return ticketClassesArray;
}
