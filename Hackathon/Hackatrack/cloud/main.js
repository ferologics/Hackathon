
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

var cities = ["San Francisco, CA, United States", "London, United Kingdom"];


Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("q", function(request, response) {

for (var j = 0; j <= cities.length; j++) {

  Parse.Cloud.httpRequest({
      url: 'https://www.eventbriteapi.com/v3/events/search/',
        params: {
          q : "hackathon",
          "venue.city" : cities[j],
          token : "FWMDQSTTDTI5EJRD6VUH"
        }
    }).then(function(httpResponse) {
      //
      var array = JSON.parse(httpResponse.text)["events"];
      var uriArray = [""];
      var nameArray = [""];
      //var item = JSON.parse(httpResponse.text)["events"][0]["resource_uri"];

      for (var i = 0; i < array.length; i++) {
        console.log(array[i]["name"]["text"]);
        uriArray.push(array[i]["resource_uri"]);
        nameArray.push(array[i]["name"]["text"]);
      }

      //console.log(item);
      if (j === 0) {response.success(uriArray)};
      // MARK : here I'll upload to Parse
    },function(httpResponse) {
      // error
    console.error('Request failed with response code ' + httpResponse.status);
    response.success(httpResponse.text);
  });

//   Parse.Cloud.beforeSave("Review", function(request, response) {
//   var comment = request.object.get("comment");
//   if (comment.length > 140) {
//     // Truncate and add a ...
//     request.object.set("comment", comment.substring(0, 137) + "...");
//   }
//   response.success();
// });

// Parse.Cloud.afterSave("Comment", function(request) {
//   query = new Parse.Query("Post");
//   query.get(request.object.get("post").id, {
//     success: function(post) {
//       post.increment("comments");
//       post.save();
//     },
//     error: function(error) {
//       console.error("Got an error " + error.code + " : " + error.message);
//     }
//   });
// });

}
});
