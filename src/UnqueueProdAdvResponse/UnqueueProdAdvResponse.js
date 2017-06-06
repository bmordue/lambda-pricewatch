var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");

exports.lambda_handler = function(event, context, callback) {
    // take a message from the ProdAdv response queue and pass it on to the appropriate handler queue
    console.log(util.format("DEBUG: function received event:  %j", event);
    callback(new Error('UnqueueProdAdvResponse is not yet implemented'));
};
