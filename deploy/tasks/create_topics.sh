#!/bin/sh
set -ex

PROJECT_DIR="$(dirname "$(realpath $0)")"/../..
CONFIG_DIR=$PROJECT_DIR/deploy/aws_config

AUTHOR_ADDED_TOPIC_ARN=$(aws sns create-topic --name author_added | jq .TopicArn)
echo "topic.author_added.arn=$AUTHOR_ADDED_TOPIC_ARN" >> $CONFIG_DIR/sns.config

TITLE_ADDED_TOPIC_ARN=$(aws sns create-topic --name title_added | jq .TopicArn)
echo "topic.title_added.arn=$TITLE_ADDED_TOPIC_ARN" >> $CONFIG_DIR/sns.config

set +x
