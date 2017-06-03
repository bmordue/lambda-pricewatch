var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");
var prodAdvClient;

exports.lambda_handler = function(event, context, callback) {
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
    var params = {
        Author: authorName,
        SearchIndex: "KindleStore",
        ResponseGroup: "ItemIds"
    };
    
    // put request object in SQS queue
    enqueueRequest(params, callback);
}
