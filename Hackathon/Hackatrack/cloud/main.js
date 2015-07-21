var _ = require('underscore');
var moment = require('moment');

// variables

// var eventsArray = [];
// var Hackathon = Parse.Object.extend("Hackathon");
// var hackathon = new hackathon;
// var promises = [];
var cities = ["San Francisco", "London"];
var searchKeyword = "hackathon";
var searchURL = 'https://www.eventbriteapi.com/v3/events/search/';
var token = "FWMDQSTTDTI5EJRD6VUH";
// var promises = [];


Parse.Cloud.job("hopeThisWorks", function(request, status) {
   // var H = Parse.Object.extend("Hackathon");
   // var h = new H;
   // h.set("name","asd");
   // h.destroy();

   // var hackathon = new Parse.Object("Hackathon");
   // hackathon.destroy();

   var promises = _.map(cities, function (city, index) {

      var promise = new Parse.Promise();

      getHTTPResponseForCity(city)
      .then(function(httpResponse) {
         var items = _.map(JSON.parse(httpResponse.text)["events"], function (item, index) {
            return hackathonForEvent(item);
         });

         Parse.Object.saveAll(items, {
            success: function () {
               // console.log(city + " saved all");
               promise.resolve("is saved " + items.length)
            },
            error: function (error) {
               console.log(error.message);
            }
         });

         // for (var i; i<items.length; i++) {
         //    var a = items[i].save();
         //    console.log("i:" + i);
         //    console.log(Parse.Promise.is(a));
         //    promise.resolve();
         //    // if (i == items.length - 1) {promise.resolve()};
         // }
         // promise.resolve();
         // _.each(items, function(hackathon){
         //    hackathon.save();
         // });

      });
      return promise;
   }); // [promise, promise]

   Parse.Promise.when(promises).then(function (p1, p2) {
      status.success("all is good " + promises.length + " p1: " + p1 + " p2: " + p2 );
   });

});

function getHTTPResponseForCity(city) {
   // console.log("getHTTPResponseForCity city:" + city);

   return Parse.Cloud.httpRequest({
      url : searchURL,
      params : {
         q : searchKeyword,
         "venue.city" : city,
         token : token,
         expand : "ticket_classes",
         expand : "logo"
      }
   });
}

function hackathonForEvent(theEvent) {
   //console.log(theEvent);
   Parse.Cloud.useMasterKey();
   var hackathon = new Parse.Object("Hackathon");

   hackathon.set("uri",  theEvent["resource_uri"]);
   hackathon.set("url",  theEvent["url"]);
   hackathon.set("uniqueID",  theEvent["id"]);
   hackathon.set("name",  theEvent["name"]["text"]);
   // hackathon.set("description",  theEvent["description"]["text"] || "None provided.");
   // hackathon.set("status",  theEvent["status"]);
   // hackathon.set("capacity",  String(theEvent["capacity"]));
   // hackathon.set("logo",  (theEvent["logo"] != undefined || theEvent["logo"] != null) ? theEvent["logo"]["url"] : "http://www.ecolabelindex.com/files/ecolabel-logos-sized/no-logo-provided.png");
   // hackathon.set("start",  moment(theEvent["start"]["utc"]));
   // hackathon.set("end",   moment(theEvent["end"]["utc"]));
   // hackathon.set("online",  theEvent["online_theEvent"]);
   // hackathon.set("currency",  theEvent["currency"]);
   // hackathon.set("ticketClassesNames",  assignTicketClassProperties(theEvent, ["name"]));
   // hackathon.set("ticketClassesCosts",  assignTicketClassProperties(theEvent, ["cost"]["display"]));
   // hackathon.set("ticketClassesFees",  assignTicketClassProperties(theEvent, ["fee"]["display"]));
   // hackathon.set("ticketClassesDescriptions", assignTicketClassProperties(theEvent, ["description"]));
   // hackathon.set("ticketClassesOnSaleStatuses",  assignTicketClassProperties(theEvent, ["on_sale_status"]));
   // hackathon.set("ticketClassesTaxes",  assignTicketClassProperties(theEvent, ["tax"]["display"]));
   // hackathon.set("ticketClassesDonations",  Boolean(assignTicketClassProperties(theEvent, ["donation"])));
   // hackathon.set("ticketClassesFree", Boolean(assignTicketClassProperties(theEvent, ["free"])));

   // console.log("returning hackathon - " + hackathon.get("name"));
   // console.log(hackathon);
   return hackathon;
}

function assignTicketClassProperties(hackathon, propertyName) {
   var ticketClassesArray = [];
   var tickeClasses = hackathon["ticket_classes"];
   if (tickeClasses != undefined) {
      _.each(tickeClasses, function(ticketClass){

         ticketClassesArray.push(String(ticketClass[propertyName]) || null);
      }).then(function(){

         console.log("returning ticketclassesAray - " + ticketClassesArray);
         return ticketClassesArray;
      });
   } else {
      return ticketClassesArray.push("No ticket classes.");
   }
}
