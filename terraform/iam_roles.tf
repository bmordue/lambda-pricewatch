resource "aws_iam_role" "lambda-basic-execution-role" {
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