var async = require("async");
var aws = require("../lib/prodadv-client");
var SNS = require('aws-sdk/clients/sns');
var SQS = require('aws-sdk/clients/sqs');
var util = require("util");

const queueUrl = process.env.PRODADV_REQUEST_QUEUE_URL;
const PRODADV_TITLES_FOR_AUTHOR_RESPONSE_TYPE = "PRODADV_TITLES_FOR_AUTHOR_RESPONSE_TYPE";
var sns = new SNS();
var sqs = new SQS();

exports.lambda_handler = function(event, context, callback) {
    // take a message from the ProdAdv request queue
    // make the request; wait for response
    // publish the response to the response queue
    // publish a notification on the ProdAdv response topic
    console.log(util.format("DEBUG: function received event:  %j", event));

    var params = {
         AttributeNames: [
             "SentTimestamp"
         ],
         MaxNumberOfMessages: 10,
         MessageAttributeNames: [
             "All"
         ],
         QueueUrl: queueUrl,
         VisibilityTimeout: 0,
         WaitTimeSeconds: 0
    };
    console.log("DEBUG: about to call sqs.receiveMessage");
    sqs.receiveMessage(params, function(err, data) {
        if (err) {
            callback(err, "Error receiving SQS messages");
        }
        handleMessageBatch(data, callback);
    });
};


function handleMessageBatch(data, callback) {
    async.eachOf(data.Messages, handleMessage, function(err) {
        var status = err? "Error handling message batch" : "done";
        callback(err, status);
    });
}

function handleMessage(message, index, callback) {
    async.waterfall([
        function(cb) {
            makeRequest(message, cb);
        },
        function(response, cb) {
            console.log("DEBUG about to call enqueueResponse");
            console.log(JSON.stringify(response));
            enqueueResponse(response, cb);
        },
        function(result, cb) {
            publishNotification(cb);
        },
        function(result, cb) {
            deleteMessage(message.ReceiptHandle, cb);
        }], callback);
}

function makeRequest(message, callback) {
    var keyId = process.env.AMZN_ACCESS_KEY_ID;
    var keySecret = process.env.AMZN_ACCESS_KEY_SECRET;
    var associateTag = process.env.AMZN_ASSOCIATE_TAG;
    var amazonServiceHost = process.env.AMZN_SERVICE_HOST;

    prodAdvClient = aws.createProdAdvClient(keyId, keySecret, associateTag, { host: amazonServiceHost});
    var params = JSON.parse(message.Body);
    console.log(util.format("DEBUG About to make prodAdv ItemSearch request with params: %j", params));
    try {
        return prodAdvClient.call("ItemSearch", params, callback);
    } catch (exc) {
        return callback(exc);
    }
}

function enqueueResponse(body, callback) {
    var msg_params = {
        MessageBody: JSON.stringify(body),
        QueueUrl: process.env.PRODADV_RESPONSE_QUEUE_URL,
        MessageAttributes: {
            requestType: { DataType: 'String', StringValue: PRODADV_TITLES_FOR_AUTHOR_RESPONSE_TYPE }
        }
    };
    console.log("DEBUG: About to send SQS message");
    sqs.sendMessage(msg_params, callback);
}

function deleteMessage(receiptHandle, callback) {
    var deleteParams = {
        QueueUrl: queueUrl,
        ReceiptHandle: receiptHandle
    };
    console.log("DEBUG about to delete SQS message");
    sqs.deleteMessage(deleteParams, function(err, data) {
        if (err) {
            console.log("Error deleting item from queue", err);
        } else {
            console.log("Deleted message from queue", data);
        }
        callback(err);
    });
}

function publishNotification(callback) {
    const GENERIC_NOTIFICATION_MESSAGE = "Queued ProdAdv response";
    console.log("DEBUG About to publish notification to SNS");
    sns.publish({
        TopicArn: process.env.PRODADV_RESPONSE_RECEIVED_TOPIC_ARN,
        Message: GENERIC_NOTIFICATION_MESSAGE
    }, callback);
}
