data "aws_iam_policy_document" "spot_lambda_access" {
  statement {
    sid = "1"

    actions = [
      "ec2:DescribeTags",
      "autoscaling:DetachInstances",
      "ec2:DescribeInstances"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_log_group" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}
