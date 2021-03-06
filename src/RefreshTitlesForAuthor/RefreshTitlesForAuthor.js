var async = require("async");
var aws = require("aws-lib");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");
const prodAdvClient = require("./fake_prodadv");

exports.lambda_handler = async function(event, context, callback) {
//    var keyId = process.env.AMZN_ACCESS_KEY_ID;
//    var keySecret = process.env.AMZN_ACCESS_KEY_SECRET;
//    var associateTag = process.env.AMZN_ASSOCIATE_TAG;
//    var amazonServiceHost = process.env.AMZN_SERVICE_HOST;

//    prodAdvClient = aws.createProdAdvClient(keyId, keySecret, associateTag, { host: amazonServiceHost});

    let authorUpdates = event.Records.map(handleNotification);
    let result = Promise.all(authorUpdates).catch(console.log);
    await result;
};

function handleNotification(record) {
  return new Promise((resolve, reject) => {
    var authorName;
    try {
        authorName = record.Sns.Message;
    } catch (e) {
        console.log("Failed to extract author name from SNS message");
        reject(e);
    }
    console.log("Refresh requested for author " + authorName);
    var params = {
        Author: authorName,
        SearchIndex: "KindleStore",
        ResponseGroup: "ItemIds"
    };
    getSearchResultsPage(params, 1, function(err, resultsPage) {
        if (err) { reject(err); }
//        console.log(util.format("handleNotification, resultsPage: %j", resultsPage));

        handleSearchResultsPage(resultsPage, authorName, function(err) {
            err ? reject(err) : resolve();
        });
    });
  });
}

function handleSearchResultsPage(resultsPage, authorName, callback) {
    console.log(util.format("Got %s results for %s", resultsPage.Items.TotalResults, authorName));

    var pages = pageNumbersAsList(resultsPage.Items.TotalPages);

    handleResultsPage(resultsPage, function(err) {
        if (err) { console.log(util.format("Error processing results for page 1: %j", err)); }

        async.each(pages, handleEachPage, callback);
    });
}

function handleEachPage(page, each_cb) {
    console.log("handleEachPage: " + page);
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
}

// http://stackoverflow.com/a/10050831/567039
// ProdAdv results page numbering starts at 1
// page 1 (first) is dealt with separately, so we want [2..maxPage]
function pageNumbersAsList(maxPage) {
    if (!maxPage || maxPage < 2) { return []; }
    return Array.apply(null, Array(maxPage - 1)).map(function (_, i) {return i + 2;});
}

function getSearchResultsPage(params, page, callback) {
    params.ItemPage = page;
//    callback(null, {Items: {TotalPages: 0, TotalResults: 0, Item: []}});
    prodAdvClient.call(this, "ItemSearch", params, function(err, result) {
//        console.log(util.format("getSearchResultsPage: result: %j", result));
        callback(err, result);
    });
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
                    "Title": {
                        S: item.ItemAttributes.Title
                    }
                }
            }
        }
    };
    if (item.ItemAttributes.Manufacturer) {
        params.Item.ItemAttributes.M.Manufacturer = { S: Item.ItemAttributes.Manufacturer };
    }
    return params;
}

function addTitleToDbIfNotPresent(item, callback) {
    var params = prepareDynamoParams(item);
    db.putItem(params, function(err, data) {
        if (err) {
            console.log("Error putting item in DB");
            console.log(err, err.data);
            console.log("Params for insertion: ");
            console.log(util.inspect(params, null, 4));
        } else {
            console.log("Successfully put item in DB");
            console.log(data);
        }
        callback(); // do not propagate error
    });
}
