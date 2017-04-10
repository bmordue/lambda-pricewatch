var SNS = require('aws-sdk/clients/sns');

exports.lambda_handler = function(event, context, callback) {
  var sns = new SNS();
  console.log("About to process " + event.Records.length + " events");
  event.Records.forEach(function(record) {
    if (record.eventName == "INSERT") {
      try {
        var author = record.dynamodb.NewImage.AuthorName.S;
      } catch (e) {
        return callback(e, "Error extracting author name from update stream");
      }
      sns.publish({
          TopicArn: process.env.AUTHOR_REFRESH_TOPIC_ARN,
          Message: author
      }, function(err, data) {
        if (err) {
          console.log("Error publishing to topic: " + err);
        } else {
          console.log("Sent message for author " + author);
        }
      });
    } else {
      console.log("Skipping record -- record.eventName: " + record.eventName);
    }
  });
  callback(null, "done");
};
