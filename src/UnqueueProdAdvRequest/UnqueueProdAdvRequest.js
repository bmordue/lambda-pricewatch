var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");

exports.lambda_handler = function(event, context, callback) {
    // take a message from the ProdAdv request queue
    // make the request; wait for response
    // publish the response to the response queue
    // publish a notification on the ProdAdv response topic
    console.log(util.format("DEBUG: function received event:  %j", event));
    callback(new Error('UnqueueProdAdvRequest is not yet implemented'));
};
