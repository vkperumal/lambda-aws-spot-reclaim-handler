data "archive_file" "lambda_function" {
  type             = "zip"
  source_file      = "${path.module}/../../scripts/main.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/main.py.zip"
}

resource "aws_lambda_function" "spot_reclaim" {
  function_name    = "spot-reclaim-handler"
  description      = "Lambda to handle spot instance termination by detaching instance from ASG"
  role             = aws_iam_role.spot_lambda_role.arn
  runtime          = "python3.9"
  timeout          = "60"
  handler          = "main.lambda_handler"
  memory_size      = 128
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  environment {
    variables = {
      webhook_notification_enabled = "false"
      webhook_url = "" # Add webhook url when slack_notification_enabled is set to true
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "spot-reclaim-handler"
    }
  )
}

resource "aws_lambda_permission" "cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spot_reclaim.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.spot_reclaim_events.arn
}
