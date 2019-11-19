#!/bin/sh

set +x

PROJECT_DIR="$(dirname "$(realpath $0)")"/..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target
DEPLOY_DIR=$PROJECT_DIR/deploy
TF_DIR=$PROJECT_DIR/terraform
CUR_DIR=$(pwd)

echo "Remove built artifacts at $TARGET_DIR"
rm -r $TARGET_DIR

echo 'Clean npm dependencies'
cd $SRC_DIR
for d in *
do
  cd $d && rm -rf node_modules
  cd ..
done

echo 'Done'
cd $CUR_DIR

