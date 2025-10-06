var async = require("async");
var aws = require("../lib/prodadv-client");
var aws_sdk = require("aws-sdk");
var db = new aws_sdk.DynamoDB();
var util = require("util");
var prodAdvClient;

exports.lambda_handler = function(event, context, callback) {
    var keyId = process.env.AMZN_ACCESS_KEY_ID;
    var keySecret = process.env.AMZN_ACCESS_KEY_SECRET;
    var associateTag = process.env.AMZN_ASSOCIATE_TAG;
    var amazonServiceHost = process.env.AMZN_SERVICE_HOST;

    console.log(util.format("DEBUG: function received event:  %j", event));

    prodAdvClient = aws.createProdAdvClient(keyId, keySecret, associateTag, { host: amazonServiceHost});

    async.each(event.Records, handleNotification, function(err) {
        callback(err, "done");
    });
};

function handleNotification(record, callback) {
    var asin;
    try {
        asin = record.Sns.Message;
    } catch (e) {
        return callback(new Error("Failed to extract ASIN from SNS message"));
    }
    console.log("Price lookup requested for ASIN " + asin);
    getPriceForAsin(asin, callback);

}

function getPriceForAsin(asin, callback) {
    prodAdvClient.call("ItemLookup", { ItemId: asin }, function(err, result) {
        if (err) {
            console.log(err, err.stack);
            return callback(); //drop err
        }
        var item = {
            ASIN: asin,
            ListPrice: result.Items.Item.ItemAttributes.ListPrice
        };

        //DEBUG
        console.log("-- UPDATE PRICE FOR ITEM --");
        console.log(JSON.stringify(item, null, 2));
        console.log("--                       --");

        updatePrice(item, callback);
    });
}

function updatePrice(item, callback) {
    var params = prepareDynamoParams(item);
    db.updateItem(params, function(err, data) {
        if (err) {
            console.log("Error updating DB entry");
            console.log(err, err.data);
        } else {
            console.log("Successfully updated DB entry");
            console.log(data);
        }
        callback(); // do not propagate error
    });
}

function prepareDynamoParams(item) {
    var params = {
        ExpressionAttributeNames: {
            "#price": "ListPrice"
        },
        ExpressionAttributeValues: {
            ":P": {
                M: {
                    "Amount": {
                        N: item.ListPrice.Amount
                    },
                    "CurrencyCode": {
                        S: item.ListPrice.CurrencyCode
                    }
                }
            }
        },
        Key: {
            "ASIN": {
                S: item.ASIN
            }
        },
        TableName: process.env.TITLES_TABLE_NAME,
        UpdateExpression: "SET #price = :P"
     };
     return params;
}
