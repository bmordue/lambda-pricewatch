#!/bin/sh
while read -r AUTHOR
do
  AUTHOR=$AUTHOR sh add_author.sh
done
