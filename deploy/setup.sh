#!/bin/sh

# One-time only setup steps

set -e

PROJECT_DIR="$(dirname "$(realpath $0)")"/..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target
DEPLOY_DIR=$PROJECT_DIR/deploy
ORIGINAL_DIR=$(pwd)

# 1. Create IAM roles -- completed manually for now
# 2. Create DynamoDB tables -- completed manually for now
# 3. Create SNS topic

cd $DEPLOY_DIR/tasks
sh create_topics.sh

# 4. Create Lambda functions
sh zip_sources.sh
sh create_functions.sh

# 5. Create event stream mappings

set +x
cd $ORIGINAL_DIR
