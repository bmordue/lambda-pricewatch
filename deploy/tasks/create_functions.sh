#!/bin/sh

set -e

PROJECT_DIR="$(dirname "$(realpath $0)")"/../..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target
DEPLOY_DIR=$PROJECT_DIR/deploy
ORIGINAL_DIR=$(pwd)

echo 'Creating AWS Lambda functions'
set -x
echo 'Create ProcessDBStreamForAuthorsTableUpdate'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name ProcessDBStreamForAuthorsTableUpdate \
  --zip-file fileb://$TARGET_DIR/ProcessDBStreamForAuthorsTableUpdate.zip \
  --role $execution_with_dynamodb_stream_role_AND_SNS_PUBLISH \
  --handler ProcessDBStreamForAuthorsTableUpdate.lambda_handler \
  --runtime nodejs4.3

echo 'Create ProcessDBStreamForTitlesTableUpdate'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name ProcessDBStreamForTitlesTableUpdate \
  --zip-file fileb://$TARGET_DIR/ProcessDBStreamForTitlesTableUpdate.zip \
  --role $execution_with_dynamodb_stream_role_AND_SNS_PUBLISH \
  --handler ProcessDBStreamForTitlesTableUpdate.lambda_handler \
  --runtime nodejs4.3

echo 'Create RefreshPriceForAllTitles'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForAllTitles \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForAllTitles.zip \
  --role $basic_execution_role_AND_SNS_PUBLISH \
  --handler RefreshPriceForAllTitles.lambda_handler \
  --runtime nodejs4.3

echo 'Create RefreshPriceForTitle'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForTitle \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForTitle.zip \
  --role $execution_with_dynamodb_full_access_role_AND_SNS_SUBSCRIBE \
  --handler RefreshPriceForTitle.lambda_handler \
  --runtime nodejs4.3

echo 'Create RefreshPriceForAllAuthors'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForAllAuthors \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForAllTitles.zip \
  --role $basic_execution_role_AND_SNS_PUBLISH \
  --handler RefreshPriceForAllAuthors.lambda_handler \
  --runtime nodejs4.3

echo 'Create RefreshTitlesForAuthor'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshTitlesForAuthor \
  --zip-file fileb://$TARGET_DIR/RefreshTitlesForAuthor.zip \
  --role $execution_with_dynamodb_full_access_role_AND_SNS_SUBSCRIBE \
  --handler RefreshTitlesForAuthor.lambda_handler \
  --runtime nodejs4.3
