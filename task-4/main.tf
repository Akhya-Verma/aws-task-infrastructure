terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # CloudWatch Billing alarms only work in N. Virginia
}

# SNS topic for billing alarm notifications
resource "aws_sns_topic" "billing_alerts" {
  name = "billing-alerts"
}

# Email subscription to SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"   # <-- Put your real email here
}

# CloudWatch Billing Alarm
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "BillingAlarm-100"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600"          # 6 hours
  statistic           = "Maximum"
  threshold           = "100"            # USD threshold (since INR unavailable)
  alarm_description   = "Alarm when AWS billing exceeds 100 USD"
  alarm_actions       = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}
