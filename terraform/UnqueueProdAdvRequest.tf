resource "aws_lambda_function" "UnqueueProdAdvRequest" {
  filename         = "../target/UnqueueProdAdvRequest.zip"
  function_name    = "UnqueueProdAdvRequest"
  role             = "${aws_iam_role.lambda-with-full-sqs-and-sns.arn}"
  handler          = "UnqueueProdAdvRequest.lambda_handler"
  runtime          = "${var.node_runtime}"
  source_code_hash = "${base64sha256(file("../target/UnqueueProdAdvRequest.zip"))}"
  timeout          = 60

  environment {
    variables = {
      AMZN_SERVICE_HOST = "${var.amzn_service_host}"
      AMZN_ACCESS_KEY_ID = "${var.amzn_access_key_id}"
      AMZN_ACCESS_KEY_SECRET = "${var.amzn_access_key_secret}"
      AMZN_ASSOCIATE_TAG = "${var.amzn_associate_tag}"
      PRODADV_REQUEST_QUEUE_URL = "${aws_sqs_queue.prodadv_requests.id}"
      PRODADV_RESPONSE_RECEIVED_TOPIC_ARN = "${aws_sns_topic.prodadv_response_received.arn}"
      PRODADV_RESPONSE_QUEUE_URL = "${aws_sqs_queue.prodadv_responses.id}"
    }
  }
}

resource "aws_sns_topic_subscription" "prodadv_requests_queued" {
  topic_arn = "${aws_sns_topic.prodadv_request_queued.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.UnqueueProdAdvRequest.arn}"
}

resource "aws_lambda_permission" "unqueue_prodadv_request_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.UnqueueProdAdvRequest.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.prodadv_request_queued.arn}"
}

