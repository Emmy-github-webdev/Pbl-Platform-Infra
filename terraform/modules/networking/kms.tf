resource "aws_kms_alias" "logs" {
  name          = "alias/${var.tags.project}-${var.tags.environment}-cloudwatch-logs"
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_kms_key" "logs" {
  description = "KMS key for CloudWatch logs"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "Enable IAM User Permissions",
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource: "*"
      },
      {
        Sid: "Allow CloudWatch Logs",
        Effect: "Allow",
        Principal: {
          Service: "logs.${data.aws_region.current}.amazonaws.com"
        },
        Action: [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource: "*"
      }
    ]
  })
}