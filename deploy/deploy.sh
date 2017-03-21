#!/bin/sh
set -e

# Repeatable deployment steps

# 1. Update Lambda functions

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
aws lambda update-function-code \
  --function-name ProcessDBStreamForAuthorsTableUpdate \
  --zip-file fileb://$TARGET_DIR/ProcessDBStreamForAuthorsTableUpdate.zip \

echo 'Deploy RefreshPriceForAllTitles'
aws lambda update-function-code \
  --function-name RefreshPriceForAllTitles \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForAllTitles.zip \

echo 'Deploy RefreshPriceForTitle'
aws lambda update-function-code \
  --function-name RefreshPriceForTitle \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForTitle.zip \

echo 'Deploy RefreshPriceForAllAuthors'
aws lambda update-function-code \
  --function-name RefreshPriceForAllAuthors \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForAllTitles.zip \

echo 'Deploy RefreshTitlesForAuthor'
aws lambda update-function-code \
  --function-name RefreshTitlesForAuthor \
  --zip-file fileb://$TARGET_DIR/RefreshTitlesForAuthor.zip \

set +x
cd $ORIGINAL_DIR
