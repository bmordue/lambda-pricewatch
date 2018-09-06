resource "aws_iam_role" "lambda-basic-execution" {
  name = "lambda-basic-execution"
  assume_role_policy = "${file("lambda_execution_policy.json")}"
}

resource "aws_iam_role" "lambda-with-full-sns" {
  name = "lambda-with-full-sns"
  assume_role_policy = "${file("lambda_execution_policy.json")}"
}

resource "aws_iam_role" "lambda-with-full-sns-and-dynamodb" {
  name = "lambda-with-full-sns-and-dynamodb"
  assume_role_policy = "${file("lambda_execution_policy.json")}"
}

resource "aws_iam_role" "lambda-with-full-dynamodb" {
  name = "lambda-with-full-dynamodb"
  assume_role_policy = "${file("lambda_execution_policy.json")}"
}

resource "aws_iam_role" "lambda-with-full-sqs" {
  name = "lambda-with-full-sqs"
  assume_role_policy = "${file("lambda_execution_policy.json")}"
}

resource "aws_iam_role" "lambda-with-full-sqs-and-sns" {
  name = "lambda-with-full-sqs-and-sns"
  assume_role_policy = "${file("lambda_execution_policy.json")}"
}

resource "aws_iam_role" "lambda-with-full-sqs-and-sns-and-dynamodb" {
  name = "lambda-with-full-sqs-and-sns-and-dynamodb"
  assume_role_policy = "${file("lambda_execution_policy.json")}"
}

resource "aws_iam_policy_attachment" "CloudWatchLogsFullAccess-attach" {
  name       = "CloudWatchLogsFullAccess-attachment"
  roles      = ["${aws_iam_role.lambda-basic-execution.name}",
                "${aws_iam_role.lambda-with-full-dynamodb.name}",
                "${aws_iam_role.lambda-with-full-sqs.name}",
                "${aws_iam_role.lambda-with-full-sns.name}",
                "${aws_iam_role.lambda-with-full-sns-and-dynamodb.name}",
                "${aws_iam_role.lambda-with-full-sqs-and-sns.name}",
                "${aws_iam_role.lambda-with-full-sqs-and-sns-and-dynamodb.name}"
               ]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonSNSFullAccess-attach" {
  name       = "AmazonSNSFullAccess-attachment"
  roles      = ["${aws_iam_role.lambda-with-full-sns.name}",
                "${aws_iam_role.lambda-with-full-sns-and-dynamodb.name}",
                "${aws_iam_role.lambda-with-full-sqs-and-sns.name}",
                "${aws_iam_role.lambda-with-full-sqs-and-sns-and-dynamodb.name}"
               ]
  groups     = ["deployers"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_policy_attachment" "AmazonDynamoDBFullAccess-attach" {
  name       = "AmazonDynamoDBFullAccess-attachment"
  roles      = ["${aws_iam_role.lambda-with-full-dynamodb.name}",
                "${aws_iam_role.lambda-with-full-sns-and-dynamodb.name}",
                "${aws_iam_role.lambda-with-full-sqs-and-sns-and-dynamodb.name}"
               ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  groups     = ["deployers"]
}

resource "aws_iam_policy_attachment" "AmazonSQSFullAccess-attach" {
  name       = "AmazonSQSFullAccess-attachment"
  roles      = ["${aws_iam_role.lambda-with-full-sqs.name}",
                "${aws_iam_role.lambda-with-full-sqs-and-sns.name}",
                "${aws_iam_role.lambda-with-full-sqs-and-sns-and-dynamodb.name}"
               ]
  groups     = ["deployers"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

# TODO: more granular roles -- nothing should have full access
