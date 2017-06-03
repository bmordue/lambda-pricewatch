resource "aws_lambda_function" "UnqueueProdAdvResponse" {
  filename         = "../target/UnqueueProdAdvResponse.zip"
  function_name    = "UnqueueProdAdvResponse"
  role             = "${aws_iam_role.lambda-with-full-sqs.arn}"
  handler          = "UnqueueProdAdvResponse.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/UnqueueProdAdvResponse.zip"))}"
  timeout          = 60

  environment {
    variables = {
      AMZN_SERVICE_HOST = "${var.amzn_service_host}"
      AMZN_ACCESS_KEY_ID = "${var.amzn_access_key_id}"
      AMZN_ACCESS_KEY_SECRET = "${var.amzn_access_key_secret}"
      AMZN_ASSOCIATE_TAG = "${var.amzn_associate_tag}"
      TITLES_TABLE_NAME = "${aws_dynamodb_table.pricewatch_titles.id}"
    }
  }
}
