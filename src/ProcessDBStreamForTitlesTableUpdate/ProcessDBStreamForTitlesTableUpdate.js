exports.lambda_handler = function(event, context, callback) {
    console.log(JSON.stringify(event, null, 2));
    callback(null, "success");
};
