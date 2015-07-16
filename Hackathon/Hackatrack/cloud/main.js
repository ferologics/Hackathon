
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

// VARUABLES AND SUCH

// search parameters
var searchKeyword = "hackathon";
var searchURL = 'https://www.eventbriteapi.com/v3/events/search/';
var token = "FWMDQSTTDTI5EJRD6VUH";
var cities = ["San Francisco", "London"];

// arrays to store to
var namesArray = [""];
var descriptionsArray = [""];
var capacitiesArray = [""];
var iconsArray = [""];
var idsArray = [""];
var ticketClassesArray = [""];
var isOnlineEventArray = [""];
var statusesArray = [""];
var logoURLsArray = [""];
var resourceURIsArray = [""];
var eventsArray = [""];

// PARSE COUD CODE FUNCTIONS

Parse.Cloud.define("q", function(request, response) {

   loopCities();
   response.success("hell yea!");
   //response.error("RIP");
});
// Parse.Cloud.job("whatever", function (request, status) {
// })

// HELPER FUNCTIONS
function loopCities() {

   for (var i = 0; i <= cities.length; i++) {
      Parse.Cloud.httpRequest({ // CORE SEARCH FUNCTION
         url: searchURL,
           params: {
             q : searchKeyword,
             "venue.city" : cities[i],
             token : token
           }
       }).then(function(httpResponse) {

         console.log(httpResponse.text);

         eventsArray = JSON.parse(httpResponse.text)["events"];

         loopEvents(eventsArray);

         // PREUPLOAD/PRESAVE FUNCTIONS

         // UPLOAD FUNCTIONS

         // POST UPLOAD FUNCTIONS

         //if (i == cities.length) {response.success(resourceURIsArray)};

       },function(httpResponse) {
         // error
       console.error('Request failed with response code ' + httpResponse.status);
       //response.success(httpResponse.text);
     });

   }
}

function loopEvents(events) {
   for (var i = 0; i < events.length; i++) {
      console.log("started assigning properties");
      resourceURIsArray.push(eventsArray[i]["resource_uri"]);
      namesArray.push(eventsArray[i]["name"]["text"]);
   }
}
