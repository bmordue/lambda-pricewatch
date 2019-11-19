resource "aws_lambda_function" "RequestPriceRefreshForAllTitles" {
  filename         = "../target/RequestPriceRefreshForAllTitles.zip"
  function_name    = "RequestPriceRefreshForAllTitles"
  role             = aws_iam_role.lambda-with-full-sns-and-dynamodb.arn
  handler          = "RequestPriceRefreshForAllTitles.lambda_handler"
  runtime          = var.node_runtime
  source_code_hash = filebase64sha256("../target/RequestPriceRefreshForAllTitles.zip")

  environment {
    variables = {
      TITLES_TABLE_NAME       = aws_dynamodb_table.pricewatch_titles.id
      TITLE_REFRESH_TOPIC_ARN = aws_sns_topic.title_refresh.arn
    }
  }
}

resource "aws_cloudwatch_event_target" "daily_price_refresh" {
  rule = aws_cloudwatch_event_rule.daily.name
  arn  = aws_lambda_function.RequestPriceRefreshForAllTitles.arn
}

resource "aws_lambda_permission" "daily_price_refresh_allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.RequestPriceRefreshForAllTitles.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
}

