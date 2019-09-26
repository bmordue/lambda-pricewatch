var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");
var prodAdvClient;

exports.lambda_handler = async function(event, context, callback) {
    var keyId = process.env.AMZN_ACCESS_KEY_ID;
    var keySecret = process.env.AMZN_ACCESS_KEY_SECRET;
    var associateTag = process.env.AMZN_ASSOCIATE_TAG;
    var amazonServiceHost = process.env.AMZN_SERVICE_HOST;

    prodAdvClient = aws.createProdAdvClient(keyId, keySecret, associateTag, { host: amazonServiceHost});

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
    getSearchResultsPage(params, 1, function(err, resultsPage) {
        if (err) {
            console.log("Error making request to ProdAdv API: " + err);
            return callback(err);
        }
        console.log(util.format("Got %s results for %s", resultsPage.Items.TotalResults, authorName));

        var pages = pageNumbersAsList(resultsPage.Items.TotalPages);

        handleResultsPage(resultsPage, function(err) {
            if (err) {
                console.log(util.format("Error processing results for page 1: %j", err));
            }
            async.each(pages, function(page, each_cb) {
                getSearchResultsPage(params, page, function(err, result) {
                    if (err) {
                        console.log(util.format("Error making request to ProdAdv API: %j", err));
                        return each_cb(); // do not propagate error, to allow other pages to be processed
                    }
                    handleResultsPage(result, function(err) {
                        if (err) {
                            console.log(util.format("Error processing results for page %s: %j", page, err));
                        }
                        each_cb(); // do not propagate error, to allow other pages to be processed
                    });
                });
            }, callback);
        });
    });
}

// http://stackoverflow.com/a/10050831/567039
// ProdAdv results page numbering starts at 1
// page 1 (first) is dealt with separately, so we want [2..maxPage]
function pageNumbersAsList(maxPage) {
    return Array.apply(null, Array(maxPage - 1)).map(function (_, i) {return i + 2;});
}

function getSearchResultsPage(params, page, callback) {
    params.ItemPage = page;
    prodAdvClient.call("ItemSearch", params, callback);
}

function handleResultsPage(resultsPage, callback) {
    async.each(resultsPage.Items.Item, addTitleToDbIfNotPresent, callback);
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
