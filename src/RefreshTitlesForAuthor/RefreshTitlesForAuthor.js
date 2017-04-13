

exports.lambda_handler = function(event, context, callback) {
    var keyId = process.env.AMZN_ACCESS_KEY_ID;
    var keySecret = process.env.AMZN_ACCESS_KEY_SECRET;
    var associateTag = process.env.AMZN_ASSOCIATE_TAG;
    var amazonServiceHost = process.env.AMZN_SERVICE_HOST;

    var prodAdvClient = aws.createProdAdvClient(keyId, keySecret, associateTag, { host: amazonServiceHost});

    event.Records.forEach(function(record) {
        var authorName;
        try {
            authorName = record.Sns.Message;
        } catch (e) {
            return callback(e, "Error extracting author name from SNS message");
        }
        var params = {
            Author: authorName,
            ItemPage: 1,
            SearchIndex: "KindleStore",
            ResponseGroup: "Small"
        };
        prodAdvClient.call("ItemSearch", params, function(err, result) {
            if (err) {
                return callback(err, "Error making request to ProdAdv API");
            }
            console.log("Got result from ProdAdv for " + authorName);
            console.log(JSON.stringify(result, null, 2));
        });
    });
    callback(null, "success");
};
