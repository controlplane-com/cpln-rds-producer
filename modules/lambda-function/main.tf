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
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/update-ip.zip"
}

resource "aws_lambda_function" "lambda_update_ips" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.cpln_private_link_role.arn
  runtime          = "python3.12"
  handler          = "update-ip.lambda_handler"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 30

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

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }
}

# Security Group for Lambda function
resource "aws_security_group" "lambda" {
  name        = "lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.lambda_function_name}-sg"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# Policy and Role for lambda function
resource "aws_iam_role" "cpln_private_link_role" {
  name_prefix = "cpln_private_link_"

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

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.cpln_private_link_role.id

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
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        "Resource" : "*"
      }
    ]
  })
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