var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");
var prodAdvClient;

exports.lambda_handler = function(event, context, callback) {
    var keyId = process.env.AMZN_ACCESS_KEY_ID;
    var keySecret = process.env.AMZN_ACCESS_KEY_SECRET;
    var associateTag = process.env.AMZN_ASSOCIATE_TAG;
    var amazonServiceHost = process.env.AMZN_SERVICE_HOST;

    prodAdvClient = aws.createProdAdvClient(keyId, keySecret, associateTag, { host: amazonServiceHost});

    // expect a single event, representing a request to ProdAdv API
    var params = event.params;
    getSearchResultsPage(params, function(err, resultsPage) {
        if (err) {
            console.log("Error making request to ProdAdv API: " + err);
            return callback(err);
        }
        console.log(util.format("Got %s results for %s", resultsPage.Items.TotalResults, authorName));
        handleResultsPage(resultsPage, function(err) {
            if (err) {
                console.log(util.format("Error processing results for page 1: %j", err));
            }
            if (params.ItemPage == 1) {
                // queue requests for all other pages
                var pages = pageNumbersAsList(resultsPage.Items.TotalPages);
                return async.each(pages, function(page, each_cb) {
                    params.ItemPage = page;
                    enqueueRequest(params, each_cb);
                }, callback);
            } else {
                return callback();
            }
        });
    });
};

// http://stackoverflow.com/a/10050831/567039
// ProdAdv results page numbering starts at 1
// page 1 (first) is dealt with separately, so we want [2..maxPage]
function pageNumbersAsList(maxPage) {
    return Array.apply(null, Array(maxPage - 1)).map(function (_, i) {return i + 2;});
}

function getSearchResultsPage(params, callback) {
    prodAdvClient.call("ItemSearch", params, callback);
}

function handleResultsPage(resultsPage, callback) {
    async.each(resultsPage.Items.Item, addTitleToDbIfNotPresent, callback);
}

// post request object to SQS
function enqueueRequest(params, callback) {
    throw new Error(util.format("Not implemented yet; params: %j", params));
}

function prepareDynamoParams(item) {
    var params = {
        TableName: process.env.TITLES_TABLE_NAME,
        ConditionExpression: "attribute_not_exists(ASIN)",
        Item: {
            "ASIN": {
                S: item.ASIN
            },
            "DetailPageURL": {
                S: item.DetailPageURL
            },
            "ItemAttributes": {
                M: {
                    "Author": {
                        S: item.ItemAttributes.Author
                    },
                    "Manufacturer": {
                        S: item.ItemAttributes.Manufacturer
                    },
                    "Title": {
                        S: item.ItemAttributes.Title
                    }
                }
            }
        }
    };
    return params;
}

function addTitleToDbIfNotPresent(item, callback) {
    var params = prepareDynamoParams(item);
    db.putItem(params, function(err, data) {
        if (err) {
            console.log("Error putting item in DB");
            console.log(err, err.data);
        } else {
            console.log("Successfully put item in DB");
            console.log(data);
        }
        callback(); // do not propagate error
    });
}
