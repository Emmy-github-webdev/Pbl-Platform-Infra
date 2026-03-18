# Create a VPC
# Create VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# CloudWatch Log Group for flow logs
resource "aws_cloudwatch_log_group" "vpc_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 7
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_logs_role" {
  name = "vpc-flow-logs-role"

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

# IAM Policy attachment
resource "aws_iam_role_policy" "flow_logs_policy" {
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

# Enable VPC Flow Logs
resource "aws_flow_log" "example" {
  vpc_id          = aws_vpc.example.id
  traffic_type    = "ALL"
  log_destination = aws_cloudwatch_log_group.vpc_logs.arn
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
}

# Restrict default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.example.id

  ingress = []
  egress  = []
}
