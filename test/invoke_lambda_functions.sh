#!/bin/bash
source './test.env'
#set -x

mkdir -p tmp
for f in "../src/*"
do
  function_name=$f
  echo "Manually invoke $function_name"
  aws lambda invoke \
    --region $AWS_REGION \
    --invocation-type RequestResponse \
    --function-name $function_name \
    --payload file://./input/${function_name}.test.json \
    tmp/${function_name}.output.json
done
#set +ex
