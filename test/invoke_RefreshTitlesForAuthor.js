var functionName = "RefreshTitlesForAuthor";
var dirName = functionName;
var lambdaFunc = require("../src/" + dirName + "/" + functionName);
var util = require("util");

var testEvent = require("./input/" + functionName + ".test.json");
var testContext = null;

var dummySearchResults = require("./input/ProdAdvSearchResult.json");

var testProdAdvClient = function(dummy, callback) {
    console.log("dummy: " + JSON.stringify(dummy));
    console.log("PROVIDING DUMMY SEARCH RESULTS");
    callback(null, dummySearchResults);
};

console.log("\n");
lambdaFunc.lambda_handler(testEvent, testContext, function(err, msg) {
    console.log("--------");
    console.log(util.format("Lambda function %s exited with message: %s \nerr: %s\n", functionName, msg, err));
    process.exit();
}, testProdAdvClient);
