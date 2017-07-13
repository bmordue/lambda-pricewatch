var functionName = "UnqueueProdAdvRequest";
var dirName = functionName;
var lambdaFunc = require("../src/" + dirName + "/" + functionName);
var util = require("util");

var testEvent = require("./input/" + functionName + ".test.json");
var testContext = null;

console.log("\n");
lambdaFunc.lambda_handler(testEvent, testContext, function(err, msg) {
    console.log("--------");
    console.log(util.format("Lambda function %s exited with message: %s \nerr: %s\n", functionName, msg, err));
    process.exit();
});
