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
var List = Parse.Object.extend("List");

Parse.Cloud.job("userMigration", function(request, status) {
  // Set up to modify user data
  Parse.Cloud.useMasterKey();

  var promise = Parse.Promise.as();
  _.each(cities, function(city) {
      // Update to plan value passed in
      promise = promise.then( function() {

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
            // var objs = [];
            for (i = 0; i < eventsArray.length; i++) {

               /*Parse.Cloud.useMasterKey();*/
               var event1 = eventsArray[i];

               var list = new List();

               list.set("uri",  event1["resource_uri"]);
               list.set("url",  event1["url"]);
               list.set("id",  event1["id"]);
               list.set("name",  event1["name"]["text"]);
               list.set("description",  event1["description"]["text"] || "None provided.");
               list.set("status",  event1["status"]);
               list.set("capacity",  String(event["capacity"]));
               list.set("logo",  (event["logo"] != undefined || event["logo"] != null) ? event["logo"]["url"] : "http://www.ecolabelindex.com/files/ecolabel-logos-sized/no-logo-provided.png");
               list.set("start",  moment(event["start"]["utc"]));
               list.set("end",   moment(event["end"]["utc"]));
               list.set("online",  event["online_event"]);
               list.set("currency",  event["currency"]);
               list.set("ticketClassesNames",  assignTicketClassProperties(event, ["name"]));
               list.set("ticketClassesCosts",  assignTicketClassProperties(event, ["cost"]["display"]));
               list.set("ticketClassesFees",  assignTicketClassProperties(event, ["fee"]["display"]));
               list.set("ticketClassesDescriptions", assignTicketClassProperties(event, ["description"]));
               list.set("ticketClassesOnSaleStatuses",  assignTicketClassProperties(event, ["on_sale_status"]));
               list.set("ticketClassesTaxes",  assignTicketClassProperties(event, ["tax"]["display"]));
               list.set("ticketClassesDonations",  Boolean(assignTicketClassProperties(event, ["donation"])));
               list.set("ticketClassesFree", Boolean(assignTicketClassProperties(event, ["free"])));
               console.log(list);
               // objs.push(list);
               Parse.Cloud.useMasterKey();
               list.save();
               /*response.success("HEEEELL YEAAA!");*/
            }

         }, function(error) {
            console.log("error = " + error.message);
         });
      })

  }).then(function() {
    // Set the job's success status
    status.success("BURN CLoudcode!!");
  }, function(error) {
    // Set the job's error status
    status.error("Uh oh, something went wrong. --> " + error.message);
  });
  return promise;
});
