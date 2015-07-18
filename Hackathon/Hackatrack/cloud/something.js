
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
           loopCities(city);
        });
   });
   promise = promise.then (function() {
       response.success("HEEEELL YEAAA!");
   });
   return promise;
});

// HELPER FUNCTIONS
function loopCities(city) {

   Parse.Cloud.httpRequest({ // CORE SEARCH FUNCTION
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

      loopEvents(eventsArray);

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

   var promise = Parse.Promise.as()

   _.each(events, function(event1) {
      promise = promise.then( function() {
         var list = new List();
         // console.log("assigning properties for " + city.text + ".");
         list.save(
         {
            uri:                         event1["resource_uri"],
            url:                         event1["url"],
            id:                          event1["id"],
            name:                        event1["name"]["text"],
            description:                 event1["description"]["text"] || "None provided.",
            status:                      event1["status"],
            capacity:                    String(event1["capacity"]),
            logo:                        (event1["logo"] != undefined || event1["logo"] != null) ? event1["logo"]["url"] : "http://www.ecolabelindex.com/files/ecolabel-logos-sized/no-logo-provided.png",
            start:                       moment(event1["start"]["utc"]),
            end:                         moment(event1["end"]["utc"]),
            online:                      event1["online_event"],
            currency:                    event1["currency"],
            ticketClassesNames:          assignTicketClassProperties(event1, ["name"]),
            ticketClassesCosts:          assignTicketClassProperties(event1, ["cost"]["display"]),
            ticketClassesFees:           assignTicketClassProperties(event1, ["fee"]["display"]),
            ticketClassesDescriptions:   assignTicketClassProperties(event1, ["description"]),
            ticketClassesOnSaleStatuses: assignTicketClassProperties(event1, ["on_sale_status"]),
            ticketClassesTaxes:          assignTicketClassProperties(event1, ["tax"]["display"]),
            ticketClassesDonations:      Boolean(assignTicketClassProperties(event1, ["donation"])),
            ticketClassesFree:           Boolean(assignTicketClassProperties(event1, ["free"]))
         }, {
            success: function(list) {
               console.log("Successsss!");
            },
            error: function(list, error) {
               console.log(error.message + " - " + list["name"]);
            }
         });
      });
   })

   return promise
}

function assignTicketClassProperties(events, propertyName) {
   console.log("assigning " + String(propertyName));
   if (events["ticket_classes"] != undefined) {
      for (var l = 0; l < events["ticket_classes"].length; l++)
      {
         ticketClassesArray.push(String(events["ticket_classes"][l][propertyName]) || null);
      }
   } else {
      return "No ticket classes.";
   }
   console.log("meh --- "+ticketClassesArray["name"]);
   return ticketClassesArray;
}
