resource "aws_lambda_function" "RefreshTitlesForAuthor" {
  filename         = "../target/RefreshTitlesForAuthor.zip"
  function_name    = "RefreshTitlesForAuthor"
  role             = "${aws_iam_role.lambda-with-full-sqs-and-sns.arn}"
  handler          = "RefreshTitlesForAuthor.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/RefreshTitlesForAuthor.zip"))}"
  timeout          = 60

  environment {
    variables = {
      REQUEST_QUEUE_URL = "${aws_sqs_queue.prodadv_requests.id}"
      PRODADV_REQUEST_QUEUED_TOPIC_ARN = "${aws_sns_topic.prodadv_request_queued.arn}"
    }
  }
}

resource "aws_sns_topic_subscription" "titles_refresh_for_author" {
  topic_arn = "${aws_sns_topic.author_refresh.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.RefreshTitlesForAuthor.arn}"
}

resource "aws_lambda_permission" "titles_refresh_for_author_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.RefreshTitlesForAuthor.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.author_refresh.arn}"
}
