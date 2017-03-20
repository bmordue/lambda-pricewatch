source ./test.env

mkdir -p tmp
for f in $(ls ../src/*.js)
do
  filename=${f##*/}
  function_name=${filename%.js}
  echo "Manually invoke $function_name"
  aws lambda invoke \
    --invocation-type RequestResponse \
    --function-name $function_name \
    --region $AWS_REGION \
    --payload file://./input/${function_name}.test.json \
    tmp/${function_name}.output.json
done
