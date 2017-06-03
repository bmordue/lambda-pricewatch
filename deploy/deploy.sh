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

echo 'Install npm dependencies'
cd $SRC_DIR
for d in $(ls -1)
do
  cd $d
  if [ -z package.json]
  then
    npm install
  fi
  cd $SRC_DIR
done

echo 'Zip sources'
cd $DEPLOY_DIR
sh ./zip_sources.sh

echo 'Terraform apply'
cd $TF_DIR
terraform apply

echo 'Done'
cd $CUR_DIR

