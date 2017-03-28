resource "aws_iam_role" "lambda-basic-execution" {
  name = "lambda-basic-execution-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda-with-full-sns" {
  name = "lambda-with-full-sns-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "AWSLambdaDynamoDBExecutionRole-attach" {
  name       = "AWSLambdaDynamoDBExecutionRole-attachment"
  roles      = ["{aws_iam_role.lambda-basic-execution.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

resource "aws_iam_policy_attachment" "AmazonSNSFullAccess-attach" {
  name       = "AmazonSNSFullAccess-attachment"
  roles      = ["{aws_iam_role.lambda-basic-execution.name}",
                "{aws_iam_role.lambda-with-full-sns.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
