resource "aws_lambda_function" "RefreshTitlesForAuthor" {
  filename         = "../target/RefreshTitlesForAuthor.zip"
  function_name    = "RefreshTitlesForAuthor"
  role             = aws_iam_role.lambda-with-full-sns-and-dynamodb.arn
  handler          = "RefreshTitlesForAuthor.lambda_handler"
  runtime          = var.node_runtime
  source_code_hash = filebase64sha256("../target/RefreshTitlesForAuthor.zip")

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

resource "aws_sns_topic_subscription" "titles_refresh_for_author" {
  topic_arn = aws_sns_topic.author_refresh.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.RefreshTitlesForAuthor.arn
}

resource "aws_lambda_permission" "titles_refresh_for_author_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.RefreshTitlesForAuthor.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.author_refresh.arn
}

