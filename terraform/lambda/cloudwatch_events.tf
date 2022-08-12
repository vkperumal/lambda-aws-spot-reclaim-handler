resource "aws_cloudwatch_event_rule" "spot_reclaim_events" {
  name          = "spot-reclaim-events"
  description   = "Capture Spot interruption events"
  event_pattern = <<EOF
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Spot Instance Interruption Warning"
  ]
}
EOF
  tags = merge(
    local.common_tags,
    {
      Name = "spot-reclaim-events"
    }
  )
}

resource "aws_cloudwatch_event_target" "spot_lambda_target" {
  rule = aws_cloudwatch_event_rule.spot_reclaim_events.name
  arn  = aws_lambda_function.spot_reclaim.arn
}
