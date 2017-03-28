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
