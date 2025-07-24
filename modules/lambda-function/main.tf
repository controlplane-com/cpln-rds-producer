terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "./src"
  output_path = "./update-ip.zip"
}

resource "aws_lambda_function" "lambda_update_ips" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.cpln_private_link_role.arn
  runtime          = "python3.12"
  handler          = "update-ip.lambda_handler"
  filename         = "update-ip.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      SERVICE_FQDN         = var.rds_proxy_endpoint
      NLB_TARGET_GROUP_ARN = var.target_group_arn
      DNS_NAMESERVER       = var.dns_nameserver
    }
  }

  tags = {
    Name        = var.lambda_function_name
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# Policy and Role for lambda function
resource "aws_iam_role" "cpln_private_link_role" {
  name_prefix = "cpln_private_link_"

  inline_policy {
    name = "lambda_policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "elasticloadbalancing:DescribeTargetHealth",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:DeregisterTargets"
          ],
          "Resource" : [var.target_group_arn]
        },
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : "arn:aws:logs:${var.aws_region}:*:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.lambda_function_name}:*"
          ]
        }
      ]
    })
  }

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

  tags = {
    Name        = "${var.lambda_function_name}-role"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# CloudWatch trigger and permission
resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "${var.lambda_function_name}-trigger"
  description         = "Trigger every minute"
  schedule_expression = "rate(1 minute)"

  tags = {
    Name        = "${var.lambda_function_name}-trigger"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.every_minute.name
  arn  = aws_lambda_function.lambda_update_ips.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_update_ips.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}