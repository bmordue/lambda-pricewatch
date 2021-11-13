var async = require('async');
var SNS = require('aws-sdk/clients/sns');
var SQS = require('aws-sdk/clients/sqs');
var util = require('util');

const PRODADV_TITLES_FOR_AUTHOR_REQUEST_TYPE = "PRODADV_TITLES_FOR_AUTHOR";
const TITLE_REFRESH_NOTIFICATION_MESSAGE = "Queued ProdAdv request for titles by author";

exports.lambda_handler = function(event, context, callback) {
    console.log(util.format("DEBUG: %j", event));
    async.each(event.Records, handleNotification, function(err) {
        callback(err, "done");
    });
};

function handleNotification(record, callback) {
    var authorName;
    try {
        authorName = record.Sns.Message;
    } catch (e) {
        return callback(new Error("Failed to extract author name from SNS message"));
    }
    console.log("Refresh requested for author " + authorName);
    var req_params = {
        Author: authorName,
        SearchIndex: "KindleStore",
        ResponseGroup: "ItemIds,Offers"
    };

    // put request object in SQS queue
    enqueueRequest(JSON.stringify(req_params), callback);
}

function enqueueRequest(body, callback) {
    var sqs = new SQS();

    var msg_params = {
        MessageBody: body,
        QueueUrl: process.env.REQUEST_QUEUE_URL,
        MessageAttributes: {
            requestType: { DataType: 'String', StringValue: PRODADV_TITLES_FOR_AUTHOR_REQUEST_TYPE }
        }
    };
    console.log(util.format("DEBUG - SQS message body: %j", body));
    sqs.sendMessage(msg_params, function(err, data) {
        if (err) {
            console.log("Error sending SQS message");
            console.log(err, err.stack);
            return callback(err);
        } else {
            console.log("Sent message to SQS");
            console.log(data);
            return publishNotification(callback);
        }
    });
}

function publishNotification(callback) {
    var sns = new SNS();
    sns.publish({
        TopicArn: process.env.PRODADV_REQUEST_QUEUED_TOPIC_ARN,
        Message: TITLE_REFRESH_NOTIFICATION_MESSAGE
    }, callback);
}
