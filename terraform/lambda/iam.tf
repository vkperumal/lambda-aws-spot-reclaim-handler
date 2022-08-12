locals {
  common_tags = {
    Created_by  = "terraform" # Add additional tag entries below
  }
}

resource "aws_iam_role" "spot_lambda_role" {
  name        = "spot_instance_lambda_role"
  description = "Spot Instance Reclaim Lambda Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(
    local.common_tags,
    {
      Name = "spot_instance_lambda_role"
    }
  )

}

resource "aws_iam_policy" "spot_lambda_policy" {
  name   = "spot-reclaim-lambda-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.spot_lambda_access.json
}

resource "aws_iam_role_policy_attachment" "spot_lambda_policy_attachment" {
  role       = aws_iam_role.spot_lambda_role.name
  policy_arn = aws_iam_policy.spot_lambda_policy.arn
}

resource "aws_iam_policy" "lambda_log_policy" {
  name   = "cloudwatch-logs-lambda-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_log_group.json
}

resource "aws_iam_role_policy_attachment" "logs_lambda_policy_attachment" {
  role       = aws_iam_role.spot_lambda_role.name
  policy_arn = aws_iam_policy.lambda_log_policy.arn
}
