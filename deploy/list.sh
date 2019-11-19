#!/bin/sh

set +x

PROJECT_DIR="$(dirname "$(realpath $0)")"/..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target
DEPLOY_DIR=$PROJECT_DIR/deploy
TF_DIR=$PROJECT_DIR/terraform
CUR_DIR=$(pwd)

echo 'Terraform show'
cd $TF_DIR
terraform show

echo 'Done'
cd $CUR_DIR

