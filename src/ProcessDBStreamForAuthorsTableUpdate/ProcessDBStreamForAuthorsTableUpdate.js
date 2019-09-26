const SNS = require('aws-sdk/clients/sns');

function publishOnInsert(record) {
  return new Promise((resolve, reject) => {
      if (record.eventName != "INSERT") {
        console.log("Skipping record -- record.eventName: " + record.eventName);
        resolve();
      } else {
        console.log("Found INSERT record");
      }
      const authorName = record.dynamodb.NewImage.AuthorName.S;
      const sns = new SNS();
      sns.publish({
          TopicArn: process.env.AUTHOR_REFRESH_TOPIC_ARN,
          Message: authorName
      }, function(err, data) {
        if (err) { reject(err); }
        console.log("Sent message for Author " + authorName);
        resolve();
      });
  });
}

exports.lambda_handler = async function(event, context) {
  if (event.Records) {
    console.log("About to process " + event.Records.length + " events");
  }
  let publishes = event.Records.map(publishOnInsert);
  let result = await Promise.all(publishes);
};
