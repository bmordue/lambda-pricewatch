resource "aws_lambda_function" "RefreshTitlesForAllAuthors" {
  filename         = "../target/RefreshTitlesForAllAuthors.zip"
  function_name    = "RefreshTitlesForAllAuthors"
  role             = "${aws_iam_role.lambda-with-full-sns.arn}"
  handler          = "exports.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/RefreshTitlesForAllAuthors.zip"))}"

  environment {
    variables = {
      AUTHOR_REFRESH_TOPIC_ARN = "${aws_sns_topic.author_refresh.arn}"
    }
  }
}
