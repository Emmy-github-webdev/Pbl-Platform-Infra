resource "aws_kms_key" "logs" {
  description             = "KMS key for CloudWatch Logs"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "logs" {
  name          = "${var.tags.project}-${var.tags.environment}-cloudwatch-logs"
  target_key_id = aws_kms_key.logs.key_id
}