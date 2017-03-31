resource "aws_lambda_function" "RequestPriceRefreshForAllTitles" {
  filename         = "../target/RequestPriceRefreshForAllTitles.zip"
  function_name    = "RequestPriceRefreshForAllTitles"
  role             = "${aws_iam_role.lambda-with-full-sns-and-dynamodb.arn}"
  handler          = "exports.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/RequestPriceRefreshForAllTitles.zip"))}"

  environment {
    variables = {
      TITLES_TABLE_NAME = "${aws_dynamodb_table.pricewatch_titles.id}"
      TITLE_REFRESH_TOPIC_ARN = "${aws_sns_topic.title_refresh.arn}"
    }
  }
}

resource "aws_cloudwatch_event_target" "daily_price_refresh" {
  rule      = "${aws_cloudwatch_event_rule.daily.name}"
  arn       = "${aws_lambda_function.RequestPriceRefreshForAllTitles.arn}"
}