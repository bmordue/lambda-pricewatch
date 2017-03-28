data "aws_sns_topic" "author_refresh" {
  name = "author_refresh_topic"
}

data "aws_sns_topic" "title_refresh" {
  name = "title_refresh_topic"
}
