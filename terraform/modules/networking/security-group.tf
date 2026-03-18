# -------------------
# Security Group
# -------------------
resource "aws_security_group" "pbl_sg" {
  name        = "${var.tag.project}-${var.tag.environment}-sg"
  description = "Baseline security group"
  vpc_id      = aws_vpc.pbl_vpc.id

  # Allow HTTP/HTTPS inbound
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag.project}-${var.tag.environment}-sg"
  }
}