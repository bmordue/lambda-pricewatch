resource "aws_lambda_function" "RefreshPriceForAllTitles" {
  filename         = "../target/RefreshPriceForAllTitles.zip"
  function_name    = "RefreshPriceForAllTitles"
  role             = "${aws_iam_role.lambda-basic-execution.arn}"
  handler          = "exports.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/RefreshPriceForAllTitles.zip"))}"

  environment {
    variables = {
      AMZN_SERVICE_HOST = "${var.amzn_service_host}"
      AMZN_ACCESS_KEY_ID = "${var.amzn_access_key_id}"
      AMZN_ACCESS_KEY_SECRET = "${var.amzn_access_key_secret}"
      AMZN_ASSOCIATE_TAG = "${var.amzn_associate_tag}"
    }
  }
}
