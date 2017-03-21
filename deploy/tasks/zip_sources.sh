#!/bin/sh

set -e

PROJECT_DIR="$(dirname "$(realpath $0)")"/../..
SRC_DIR=$PROJECT_DIR/src
TARGET_DIR=$PROJECT_DIR/target

echo 'Zipping lambda function source files'
mkdir -p $TARGET_DIR
cd $SRC_DIR
for f in $(ls -1 *.js)
do
  zip $TARGET_DIR/${f%.js}.zip $f
done

