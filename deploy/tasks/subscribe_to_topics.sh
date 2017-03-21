author_added_topic_arn="arn:aws:sns:eu-west-1:285774518219:author_added"
title_added_topic_arn="arn:aws:sns:eu-west-1:285774518219:title_added"
refresh_titles_for_author_function_arn="arn:aws:lambda:eu-west-1:285774518219:function:RefreshTitlesForAuthor"
refresh_price_for_title_function_arn="arn:aws:lambda:eu-west-1:285774518219:function:RefreshPriceForTitle"

aws sns subscribe \
  --topic-arn $author_added_topic_arn \
  --protocol lambda \
  --notification-endpoint $refresh_titles_for_author_function_arn

aws sns subscribe \
  --topic-arn $title_added_topic_arn \
  --protocol lambda \
  --notification-endpoint $refresh_price_for_title_function_arn
