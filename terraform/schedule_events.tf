resource "aws_cloudwatch_event_rule" "daily" {
  name                = "daily"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_rule" "weekly" {
  name                = "weekly"
  schedule_expression = "rate(7 days)"
}

resource "aws_cloudwatch_event_rule" "monthly" {
  name                = "monthly"
  schedule_expression = "rate(30 days)"
}