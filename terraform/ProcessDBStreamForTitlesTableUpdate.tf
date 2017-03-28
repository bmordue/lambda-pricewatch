resource "aws_lambda_function" "ProcessDBStreamForTitlesTableUpdate" {
  filename         = "../target/ProcessDBStreamForTitlesTableUpdate.zip"
  function_name    = "ProcessDBStreamForTitlesTableUpdate"
  role             = "${aws_iam_role.lambda-basic-execution-role.arn}"
  handler          = "exports.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/ProcessDBStreamForTitlesTableUpdate.zip"))}"

  environment {
    variables = {
      TITLE_REFRESH_TOPIC_ARN = "${aws_sns_topic.title_refresh.arn}"
    }
  }
}
