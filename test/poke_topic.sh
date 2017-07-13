#!/bin/sh
set +x
aws --region eu-west-2 sns publish --topic-arn "arn:aws:sns:eu-west-2:285774518219:prodadv_response_received_topic" --message go
set -x
