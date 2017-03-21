#!/bin/sh
set -e

# One-time only setup steps

# 1. Create IAM roles -- completed manually for now
# 2. Create DynamoDB tables -- completed manually for now
# 3. Create SNS topic

set +x
cd $ORIGINAL_DIR
#!/bin/sh
set -e

# 4. Create Lambda functions

PROJECT_DIR="$(dirname "$(realpath $0)")"/..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target
ORIGINAL_DIR=$(pwd)

echo 'Zipping lambda function source files'
mkdir -p $TARGET_DIR
cd $SRC_DIR
for f in $(ls -1 *.js)
do
  zip $TARGET_DIR/${f%.js}.zip $f
done

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

# 5. Create event stream mappings

set +x
cd $ORIGINAL_DIR
