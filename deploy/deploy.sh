#!/bin/sh
set -e

# Repeatable deployment steps

PROJECT_DIR="$(dirname "$(realpath $0)")"/..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target
DEPLOY_DIR=$PROJECT_DIR/deploy
ORIGINAL_DIR=$(pwd)


echo 'Zip sources'
sh $DEPLOY_DIR/tasks/zip_sources.sh

echo 'Deploying lambda functions to AWS'
set -x
echo 'Deploy ProcessDBStreamForAuthorsTableUpdate'
aws lambda update-function-code \
  --function-name ProcessDBStreamForAuthorsTableUpdate \
  --zip-file fileb://$TARGET_DIR/ProcessDBStreamForAuthorsTableUpdate.zip \

echo 'Deploy ProcessDBStreamForTitlesTableUpdate'
aws lambda update-function-code \
  --function-name ProcessDBStreamForTitlesTableUpdate \
  --zip-file fileb://$TARGET_DIR/ProcessDBStreamForTitlesTableUpdate.zip \

echo 'Deploy RefreshPriceForAllTitles'
aws lambda update-function-code \
  --function-name RefreshPriceForAllTitles \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForAllTitles.zip \

echo 'Deploy RefreshPriceForTitle'
aws lambda update-function-code \
  --function-name RefreshPriceForTitle \
  --zip-file fileb://$TARGET_DIR/RefreshPriceForTitle.zip \

echo 'Deploy RefreshTitlesForAllAuthors'
aws lambda update-function-code \
  --function-name RefreshTitlesForAllAuthors \
  --zip-file fileb://$TARGET_DIR/RefreshTitlesForAllAuthors.zip \

echo 'Deploy RefreshTitlesForAuthor'
aws lambda update-function-code \
  --function-name RefreshTitlesForAuthor \
  --zip-file fileb://$TARGET_DIR/RefreshTitlesForAuthor.zip \

set +x
cd $ORIGINAL_DIR
