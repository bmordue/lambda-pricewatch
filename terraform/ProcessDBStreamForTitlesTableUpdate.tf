resource "aws_lambda_function" "ProcessDBStreamForTitlesTableUpdate" {
  filename         = "../target/ProcessDBStreamForTitlesTableUpdate.zip"
  function_name    = "ProcessDBStreamForTitlesTableUpdate"
  role             = "${aws_iam_role.lambda-with-full-sns-and-dynamodb.arn}"
  handler          = "exports.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/ProcessDBStreamForTitlesTableUpdate.zip"))}"

  environment {
    variables = {
      TITLE_REFRESH_TOPIC_ARN = "${aws_sns_topic.title_refresh.arn}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "titles_event_source_mapping" {
  event_source_arn  = "${aws_dynamodb_table.pricewatch_titles.stream_arn}"
  function_name     = "${aws_lambda_function.ProcessDBStreamForTitlesTableUpdate.arn}"
  starting_position = "TRIM_HORIZON"
}
