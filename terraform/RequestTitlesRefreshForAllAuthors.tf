resource "aws_lambda_function" "RequestTitlesRefreshForAllAuthors" {
  filename         = "../target/RequestTitlesRefreshForAllAuthors.zip"
  function_name    = "RequestTitlesRefreshForAllAuthors"
  role             = "${aws_iam_role.lambda-with-full-sns-and-dynamodb.arn}"
  handler          = "RequestTitlesRefreshForAllAuthors.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/RequestTitlesRefreshForAllAuthors.zip"))}"

  environment {
    variables = {
      AUTHORS_TABLE_NAME = "${aws_dynamodb_table.pricewatch_authors.id}"
      AUTHOR_REFRESH_TOPIC_ARN = "${aws_sns_topic.author_refresh.arn}"
    }
  }
}

resource "aws_cloudwatch_event_target" "monthly_title_refresh" {
  rule      = "${aws_cloudwatch_event_rule.monthly.name}"
  arn       = "${aws_lambda_function.RequestTitlesRefreshForAllAuthors.arn}"
}

resource "aws_lambda_permission" "monthly_price_refresh_allow_cloudwatch" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.RequestTitlesRefreshForAllAuthors.arn}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.monthly.arn}"
}

