const SNS = require('aws-sdk/clients/sns');
const util = require('util');

function publishOnInsert(record) {
  return new Promise((resolve, reject) => {
      if (record.eventName != "INSERT") {
        console.log("Skipping record -- record.eventName: " + record.eventName);
        resolve();
      } else {
        console.log("Found INSERT record");
      }
      const asin = record.dynamodb.NewImage.ASIN.S;
      let sns = new SNS();
      sns.publish({
          TopicArn: process.env.TITLE_REFRESH_TOPIC_ARN,
          Message: asin
      }, function(err, data) {
        if (err) { reject(err); }
        console.log("Sent message for ASIN " + asin);
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
