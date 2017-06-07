var async = require('async');
var SQS = require('aws-sdk/clients/sqs');
var util = require('util');

const PRODADV_TITLES_FOR_AUTHOR_REQUEST_TYPE = "PRODADV_TITLES_FOR_AUTHOR";

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
        ResponseGroup: "ItemIds"
    };

    // put request object in SQS queue
    enqueueRequest(req_params, callback);
}

function enqueueRequest(body, callback) {
    var sqs = new SQS();

    var msg_params = {
        MessageBody: JSON.stringify(body),
        QueueUrl: process.env.REQUEST_QUEUE_URL,
        MessageAttributes: {
            requestType: { DataType: 'String', StringValue: PRODADV_TITLES_FOR_AUTHOR_REQUEST_TYPE }
        }
    };
    sqs.sendMessage(msg_params, function(err, data) {
        if (err) {
            console.log(err, err.stack);
        } else {
            console.log(data);
        }
        callback(err);
    });
}
