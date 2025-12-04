# AWS Billing Alert with Terraform

This project configures a CloudWatch Billing Alarm in AWS to notify users when account spending exceeds a threshold. It sends email alerts using Amazon SNS.

## Features

- CloudWatch Billing Alarm set at **100 USD**
- SNS Topic and Email subscription for notifications
- Region automatically configured to `us-east-1` (required by AWS for billing metrics)

## Requirements

- Terraform ≥ 1.0
- AWS account with IAM credentials configured
- Billing Alerts enabled in AWS Billing Console
  (Billing dashboard → Billing preferences → Enable Billing & Free Tier alerts)
