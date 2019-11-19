#!/bin/sh
echo Adding $AUTHOR to authors table
aws dynamodb --region eu-west-2 put-item --table-name pricewatch_authors --item "{ \"AuthorName\": { \"S\": \"$AUTHOR\"}}"
