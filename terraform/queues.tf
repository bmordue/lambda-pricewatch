resource "aws_sqs_queue" "prodadv_requests" {
  name = "throttled-requests-to-prodadv-queue"
}

resource "aws_sqs_queue" "prodadv_responses" {
  name = "prodadv-responses-queue"
}

resource "aws_sqs_queue_policy" "prodadv_responses_policy" {
  queue_url = "${aws_sqs_queue.prodadv_responses.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.prodadv_responses.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.prodadv_responses.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "prodadv_requests_policy" {
  queue_url = "${aws_sqs_queue.prodadv_requests.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.prodadv_requests.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.prodadv_requests.arn}"
        }
      }
    }
  ]
}
POLICY
}
