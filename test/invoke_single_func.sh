source ./test.env
set -ex
mkdir -p tmp
rm tmp/*
#for f in $(find ../src/ -name '*js')
#../src/ProcessDBStreamForTitlesTableUpdate/ProcessDBStreamForTitlesTableUpdate.js
#../src/RefreshPriceForTitle/RefreshPriceForTitle.js
#../src/RequestTitlesRefreshForAllAuthors/RequestTitlesRefreshForAllAuthors.js
#../src/ProcessDBStreamForAuthorsTableUpdate/ProcessDBStreamForAuthorsTableUpdate.js
#../src/RequestPriceRefreshForAllTitles/RequestPriceRefreshForAllTitles.js
#../src/RefreshTitlesForAuthor/RefreshTitlesForAuthor.js

#f="../src/RefreshPriceForTitle/RefreshPriceForTitle.js"
f="../src/ProcessDBStreamForTitlesTableUpdate/ProcessDBStreamForTitlesTableUpdate.js"
#do
  filename=${f##*/}
  function_name=${filename%.js}
  echo "Manually invoke $function_name"
  aws lambda invoke \
    --invocation-type RequestResponse \
    --function-name $function_name \
    --payload file://./input/${function_name}.test.json \
    tmp/${function_name}.output.json
#done
set +ex
