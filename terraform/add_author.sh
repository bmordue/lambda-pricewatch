#!/bin/sh
aws dynamodb put-item --table-name pricewatch_authors --item file://item.json
