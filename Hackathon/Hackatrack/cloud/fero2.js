var _ = require('underscore');
var moment = require('moment');

Parse.Cloud.job("tryMeCloudCode", function(request, status) {
   Parse.Cloud.useMasterKey();

   var eventsArray = [];
   var List = Parse.Object.extend("List");
   var list = new List;
   var promises = [];
   var cities = ["San Francisco", "London"];
   var searchKeyword = "hackathon";
   var searchURL = 'https://www.eventbriteapi.com/v3/events/search/';
   var token = "FWMDQSTTDTI5EJRD6VUH";

   _.each(cities, function(city){

      Parse.Cloud.httpRequest({
           url: searchURL
           params: {
             q : searchKeyword,
             "venue.city" : city,
             token : token,
             expand : "ticket_classes",
             expand : "logo"
           }
         }).then(function(httpResponse) {

            eventsArray = JSON.parse(httpResponse.text)["events"];
            for (j=0; j<eventsArray.length;j++) {
               var hackathon = eventsArray[j];

               list.set("uri",  hackathon["resource_uri"]);
               list.set("url",  hackathon["url"]);
               list.set("id",  hackathon["id"]);
               list.set("name",  hackathon["name"]["text"]);
               list.set("description",  hackathon["description"]["text"] || "None provided.");
               list.set("status",  hackathon["status"]);
               list.set("capacity",  String(hackathon["capacity"]));
               list.set("logo",  (hackathon["logo"] != undefined || hackathon["logo"] != null) ? hackathon["logo"]["url"] : "http://www.ecolabelindex.com/files/ecolabel-logos-sized/no-logo-provided.png");
               list.set("start",  moment(hackathon["start"]["utc"]));
               list.set("end",   moment(hackathon["end"]["utc"]));
               list.set("online",  hackathon["online_hackathon"]);
               list.set("currency",  hackathon["currency"]);
               list.set("ticketClassesNames",  assignTicketClassProperties(hackathon, ["name"]));
               list.set("ticketClassesCosts",  assignTicketClassProperties(hackathon, ["cost"]["display"]));
               list.set("ticketClassesFees",  assignTicketClassProperties(hackathon, ["fee"]["display"]));
               list.set("ticketClassesDescriptions", assignTicketClassProperties(hackathon, ["description"]));
               list.set("ticketClassesOnSaleStatuses",  assignTicketClassProperties(hackathon, ["on_sale_status"]));
               list.set("ticketClassesTaxes",  assignTicketClassProperties(hackathon, ["tax"]["display"]));
               list.set("ticketClassesDonations",  Boolean(assignTicketClassProperties(hackathon, ["donation"])));
               list.set("ticketClassesFree", Boolean(assignTicketClassProperties(hackathon, ["free"])));
               promises.push(list.save());
            }
           console.log(httpResponse.text);
         }, function(httpResponse) {
           console.error('Request failed with response code ' + httpResponse.status);
         });
      });

   return Parse.Promise.when(promises).then(function(){
      request.success("nice.");
   });
});


function assignTicketClassProperties(hackathon, propertyName) {
   var ticketClassesArray = [];
   if (hackathon["ticket_classes"] != undefined) {
      for (var l = 0; l < hackathon["ticket_classes"].length; l++)
      {
         ticketClassesArray.push(String(hackathon["ticket_classes"][l][propertyName]) || null);
      }
   } else {
      return ticketClassesArray.push("No ticket classes.");
   }
   return ticketClassesArray;
}
