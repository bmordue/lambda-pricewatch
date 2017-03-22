var SNS = require('aws-sdk/clients/sns');

exports.lambda_handler = function(event, context, callback) {
  var sns = new SNS();
  console.log("About to process " + event.Records.length + " events");
  event.Records.forEach(function(record) {
    if (record.eventName == "INSERT") {
      try {
        var author = record.dynamodb.NewImage.name.S;
      } catch (e) {
        return callback(e, "Error extracting author name from update stream");
      }
      sns.publish({
          TopicArn: "arn:aws:sns:eu-west-1:285774518219:author_added",
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
  callback(null, message);
};
