#!/bin/sh
source ./deploy.env

# 1. Create DynamoDB tables -- completed manually for now
# 2. Create IAM roles -- completed manually for now

# 3. Create event stream mappings

# 4. Deploy Lambda functions
SRC_DIR="$(dirname "$(realpath $0)")"/../src
ORIGINAL_DIR=$(pwd)

echo 'Zipping lambda function source files'
cd $SRC_DIR
for f in $(ls -1 *.js)
do
  zip ${f%.js}.zip $f
done

echo 'Deploying lambda functions to AWS'
set -x
echo 'Deploy ProcessDBStreamForAuthorsTableUpdate'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name ProcessDBStreamForAuthorsTableUpdate \
  --zip-file fileb://$SRC_DIR/ProcessDBStreamForAuthorsTableUpdate.zip \
  --role $execution_with_dynamodb_stream_role \
  --handler ProcessDBStreamForAuthorsTableUpdate.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshPriceForAllTitles'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForAllTitles \
  --zip-file fileb://$SRC_DIR/RefreshPriceForAllTitles.zip \
  --role $basic_execution_role \
  --handler RefreshPriceForAllTitles.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshPriceForTitle'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForTitle \
  --zip-file fileb://$SRC_DIR/RefreshPriceForTitle.zip \
  --role $execution_with_dynamodb_full_access_role \
  --handler RefreshPriceForTitle.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshPriceForAllAuthors'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshPriceForAllAuthors \
  --zip-file fileb://$SRC_DIR/RefreshPriceForAllTitles.zip \
  --role $basic_execution_role \
  --handler RefreshPriceForAllAuthors.lambda_handler \
  --runtime nodejs4.3

echo 'Deploy RefreshTitlesForAuthor'
aws lambda create-function \
  --region $AWS_REGION \
  --function-name RefreshTitlesForAuthor \
  --zip-file fileb://$SRC_DIR/RefreshTitlesForAuthor.zip \
  --role $execution_with_dynamodb_full_access_role \
  --handler RefreshTitlesForAuthor.lambda_handler \
  --runtime nodejs4.3

set +x
cd $ORIGINAL_DIR
