
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

// VARUABLES AND SUCH

var _ = require('underscore');

// misc
var j = 0;

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

// extending List class
var List = Parse.Object.extend("List");
var list = new List();

// PARSE COUD CODE FUNCTIONS
Parse.Cloud.define("q", function(request, response) {

   var promise = Parse.Promise.as();
   _.each(cities, function(city) {
       promise = promise.then( function(){
           return loopCities(city);
        });

   });//return promise;
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
          token : token
        }
    }).then(function(httpResponse) {

      console.log(httpResponse.text);
      console.log("been here, did that");
      eventsArray = JSON.parse(httpResponse.text)["events"];

      loopEvents(eventsArray);

      // PREUPLOAD/PRESAVE FUNCTIONS

      // UPLOAD FUNCTIONS

      // POST UPLOAD FUNCTIONS

      //if (i == cities.length) {response.success(resourceURIsArray)};
   //if (i == cities.length) {response.success("hell yea!")};

    },function(httpResponse) {
      // error
    console.error('Request failed with response code ' + httpResponse.status);
    //response.success(httpResponse.text);
  });
}

function loopEvents(events) {
   if  (j == cities.length) {j=0};
   for (var i = 0; i < events.length; i++) {
      console.log("assigning properties for " + cities[j] + ".");
      resourceURIsArray.push(eventsArray[i]["resource_uri"]);
      namesArray.push(eventsArray[i]["name"]["text"] || 0);
   }
   j++;
}
