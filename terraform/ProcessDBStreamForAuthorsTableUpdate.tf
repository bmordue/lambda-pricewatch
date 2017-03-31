resource "aws_lambda_function" "ProcessDBStreamForAuthorsTableUpdate" {
  filename         = "../target/ProcessDBStreamForAuthorsTableUpdate.zip"
  function_name    = "ProcessDBStreamForAuthorsTableUpdate"
  role             = "${aws_iam_role.lambda-with-full-sns.arn}"
  handler          = "exports.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/ProcessDBStreamForAuthorsTableUpdate.zip"))}"

  environment {
    variables = {
      AUTHOR_REFRESH_TOPIC_ARN = "${aws_sns_topic.author_refresh.arn}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "authors_event_source_mapping" {
  event_source_arn  = "${aws_dynamodb_table.pricewatch_authors.stream_arn}"
  function_name     = "${aws_lambda_function.ProcessDBStreamForAuthorsTableUpdate.arn}"
  starting_position = "TRIM_HORIZON"
}