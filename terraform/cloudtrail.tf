resource "aws_cloudtrail" "default" {
  name                          = "tf-cloudtrail"
  s3_bucket_name                = "${aws_s3_bucket.lambda-pricewatch-cloudtrail.id}"
  s3_key_prefix                 = "${var.project_name}"
  include_global_service_events = true
}

resource "aws_s3_bucket" "lambda-pricewatch-cloudtrail" {
  bucket        = "lambda-pricewatch-tf-test-trail"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::lambda-pricewatch-tf-test-trail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::lambda-pricewatch-tf-test-trail/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
