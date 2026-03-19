# Cloudwatch log group
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs/${var.tags.project}-${var.tags.environment}"
  retention_in_days = 356
  kms_key_id = aws_kms_key.logs.arn
}

resource "aws_iam_role" "flow_logs_role" {
  name = "${var.tags.project}-${var.tags.environment}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "${var.tags.project}-${var.tags.environment}-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = [
        "${aws_cloudwatch_log_group.vpc_flow_logs.arn}",
        "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      ]
      # Condition = {
      #   ArnLike = {
      #     "aws:SourceArn" = aws_cloudwatch_log_group.vpc_flow_logs.arn
      #   }
      # }
    }]
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  vpc_id               = aws_vpc.pbl_vpc.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
}