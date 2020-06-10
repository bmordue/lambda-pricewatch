var SNS = require('aws-sdk/clients/sns');
var util = require('util');

exports.lambda_handler = function(event, context, callback) {
  var sns = new SNS();
  console.log(util.format("DEBUG: function received event:  %j", event));
  console.log("About to process " + event.Records.length + " events");
  event.Records.forEach(function(record) {
    if (record.eventName == "INSERT") {
      var author;
      try {
        author = record.dynamodb.NewImage.AuthorName.S;
      } catch (e) {
        return callback(e, "Error extracting author name from update stream");
      }
      sns.publish({
          TopicArn: process.env.AUTHOR_REFRESH_TOPIC_ARN,
          Message: author
      }, function(err) {
        if (err) {
          console.log("Error publishing to topic: " + err);
        } else {
          console.log("Published SNS message for author " + author);
        }
      });
    } else {
      console.log("Skipping record -- record.eventName: " + record.eventName);
    }
  });
  callback(null, "done");
};
