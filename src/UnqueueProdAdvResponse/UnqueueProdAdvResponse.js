var async = require("async");
var util = require("util");
var SQS = require('aws-sdk/clients/sqs');

var sqs = new SQS();
const queueUrl = process.env.PRODADV_RESPONSE_QUEUE_URL;

const PRODADV_TITLES_FOR_AUTHOR_REQUEST_TYPE = "PRODADV_TITLES_FOR_AUTHOR";
const PRODADV_PRICE_FOR_TITLE_REQUEST_TYPE = "PRODADV_PRICE_FOR_TITLE_REQUEST";
const PRICE_LOOKUP_NOTIFICATION_MESSAGE = "Queued ProdAdv request for title price lookup";

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
    switch (requestType) {
        case PRODADV_TITLES_FOR_AUTHOR_REQUEST_TYPE:
            return handleTitlesForAuthorResponse(message, callback);
        case PRODADV_PRICE_FOR_TITLE_REQUEST_TYPE:
            return handlePriceForTitleResponse(message, callback);
        default:
            console.log(util.format("Ignoring SQS message of type %s", requestType));
            return callback();
    }
}

function handleTitlesForAuthorResponse(message, callback) {
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
    async.each(uniqueItems, handleAuthorResponseItem, callback);
}

function handleAuthorResponseItem(item, callback) {
    var asin = item.ASIN;
    console.log(util.format("DEBUG: received ASIN in body: %s", asin));
    console.log("WARNING: handleItem is not yet implemented");
    
    // queue ProdAdv request for item details
    console.log("Requested title details for ASIN " + asin);
    var req_params = {
        ItemId: asin,
        ResponseGroup: "Offers"
    };

    // put request object in SQS queue
    enqueueRequest(JSON.stringify(req_params), callback);
}

function handlePriceForTitleResponse(message, callback) {
    console.log("DEBUG: process response to request for title price: %j", message);
    console.log("WARNING: handlePriceForTitleResponse is not yet implemented");
    
    // TODO: make sure item 'path' is correct
    // var item = message.Items.item;
    
    // insert details into db
    // TODO: update if present, insert if not
    // var params = {
    //     TableName: titlesTable,
    //     Item: item
    // };
    // dbDocClient.put(params, callback);
    callback();
}

function enqueueRequest(body, callback) {
    var sqs = new SQS();

    var msg_params = {
        MessageBody: body,
        QueueUrl: process.env.REQUEST_QUEUE_URL,
        MessageAttributes: {
            requestType: { DataType: 'String', StringValue: PRODADV_PRICE_FOR_TITLE_REQUEST_TYPE }
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
        Message: PRICE_LOOKUP_NOTIFICATION_MESSAGE
    }, callback);
}
