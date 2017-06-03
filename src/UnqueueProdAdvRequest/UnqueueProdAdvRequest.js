var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");

exports.lambda_handler = function(event, context, callback) {
    // take a message from the ProdAdv response queue, make the request, and publish the response to the response topic

    callback(new Error('UnqueueProdAdvRequest is not yet implemented'));
};
