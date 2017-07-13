var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");
var SQS = require('aws-sdk/clients/sqs');

var sqs = new SQS();
const queueUrl = process.env.PRODADV_RESPONSE_QUEUE_URL;

exports.lambda_handler = function(event, context, callback) {
    // take a message from the ProdAdv response queue
    // parse
    // later: queue request for the next page of results if it exists
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
    console.log(util.format("DEBUG: received SQS message: %j", data));
    async.each(data.Messages, handleMessage, function(err) {
        var status = err? "Error handling message batch" : "done";
        callback(err, status);
    });
}

function handleMessage(message, callback) {
    var body;
    var items;
    try {
        body = JSON.parse(message.Body);
        items = body.Items.Item;
    } catch (e) {
        return callback(e);
    }
    // deduplicate asins
    var uniqueItems = items.filter(function(item, index, arr) {
        return arr.indexOf(item) === index;
    });
    async.each(uniqueItems, handleItem, callback);
}

function handleItem(item, callback) {
    var asin = item.ASIN;
    console.log(util.format("DEBUG: received ASIN in body: ", asin));
    callback();
}
