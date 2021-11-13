var SNS = require('aws-sdk/clients/sns');
var util = require('util');

exports.lambda_handler = function(event, context, callback) {
  var sns = new SNS();
  console.log(util.format("DEBUG: function received event:  %j", event));
  console.log("About to process " + event.Records.length + " events");
  event.Records.forEach(function(record) {
    if (record.eventName == "INSERT") {
      try {
        var asin = record.dynamodb.NewImage.ASIN.S;
      } catch (e) {
        return callback(e, "Error extracting ASIN from update stream");
      }
      sns.publish({
          TopicArn: process.env.TITLE_REFRESH_TOPIC_ARN,
          Message: asin
      }, function(err) {
        if (err) {
          console.log("Error publishing to topic: " + err);
        } else {
          console.log("Sent message for ASIN " + asin);
        }
      });
    } else {
      console.log("Skipping record -- record.eventName: " + record.eventName);
    }
  });
  callback(null, "done");
};
