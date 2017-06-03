resource "aws_sns_topic" "author_refresh" {
  name = "author_refresh_topic"
}

resource "aws_sns_topic" "title_refresh" {
  name = "title_refresh_topic"
}

resource "aws_sns_topic" "prodadv_response_received" {
  name = "prodadv_response_received_topic"
}
