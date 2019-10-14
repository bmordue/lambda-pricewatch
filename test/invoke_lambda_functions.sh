source ./test.env

mkdir -p tmp
touch tmp/deleteme
rm tmp/*
for f in $(find ../src/ -maxdepth 2 -name '*js')
do
  filename=${f##*/}
  function_name=${filename%.js}
  echo "Manually invoke $function_name"
  aws lambda invoke \
    --invocation-type RequestResponse \
    --function-name $function_name \
    --payload file://./input/${function_name}.test.json \
    tmp/${function_name}.output.json
done
