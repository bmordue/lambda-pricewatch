resource "aws_lambda_function" "RefreshPriceForAllTitles" {
  filename         = "../target/RefreshPriceForAllTitles.zip"
  function_name    = "RefreshPriceForAllTitles"
  role             = "${aws_iam_role.lambda-with-full-sns.arn}"
  handler          = "exports.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/RefreshPriceForAllTitles.zip"))}"

  environment {
    variables = {
      AUTHOR_REFRESH_TOPIC_ARN = "${aws_sns_topic.title_refresh.arn}"
    }
  }
}
