#!/bin/sh

set -e

PROJECT_DIR="$(dirname "$(realpath $0)")"/../..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target
DEPLOY_DIR=$PROJECT_DIR/deploy
ORIGINAL_DIR=$(pwd)

echo 'Deploying lambda functions to AWS'
set -x
echo 'Deploy ProcessDBStreamForAuthorsTableUpdate'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name ProcessDBStreamForAuthorsTableUpdate \
  --zip-file fileb://$TARGET_DIR/ProcessDBStreamForAuthorsTableUpdate.zip \
  --role $execution_with_dynamodb_stream_role \
  --handler ProcessDBStreamForAuthorsTableUpdate.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshPriceForAllTitles'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForAllTitles \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForAllTitles.zip \
  --role $basic_execution_role \
  --handler RefreshPriceForAllTitles.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshPriceForTitle'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForTitle \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForTitle.zip \
  --role $execution_with_dynamodb_full_access_role \
  --handler RefreshPriceForTitle.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshPriceForAllAuthors'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForAllAuthors \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForAllTitles.zip \
  --role $basic_execution_role \
  --handler RefreshPriceForAllAuthors.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshTitlesForAuthor'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshTitlesForAuthor \
  --zip-file fileb://$TARGET_DIR/RefreshTitlesForAuthor.zip \
  --role $execution_with_dynamodb_full_access_role \
  --handler RefreshTitlesForAuthor.lambda_handler \
  --runtime nodejs4.3
