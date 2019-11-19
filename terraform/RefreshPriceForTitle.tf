resource "aws_lambda_function" "RefreshPriceForTitle" {
  filename         = "../target/RefreshPriceForTitle.zip"
  function_name    = "RefreshPriceForTitle"
  role             = aws_iam_role.lambda-with-full-sns-and-dynamodb.arn
  handler          = "RefreshPriceForTitle.lambda_handler"
  runtime          = var.node_runtime
  source_code_hash = filebase64sha256("../target/RefreshPriceForTitle.zip")

  environment {
    variables = {
      AMZN_SERVICE_HOST      = var.amzn_service_host
      AMZN_ACCESS_KEY_ID     = var.amzn_access_key_id
      AMZN_ACCESS_KEY_SECRET = var.amzn_access_key_secret
      AMZN_ASSOCIATE_TAG     = var.amzn_associate_tag
      TITLES_TABLE_NAME      = aws_dynamodb_table.pricewatch_titles.id
    }
  }
}

resource "aws_sns_topic_subscription" "price_refresh_for_title" {
  topic_arn = aws_sns_topic.title_refresh.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.RefreshPriceForTitle.arn
}

resource "aws_lambda_permission" "price_refresh_for_title_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.RefreshPriceForTitle.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.title_refresh.arn
}

