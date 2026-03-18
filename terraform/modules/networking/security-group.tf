# -------------------
# Security Group
# -------------------
# ALB SG (public)
resource "aws_security_group" "pbl_alb" {
  name   = "${var.tags.project}-${var.tags.environment}-alb-sg"
  vpc_id = aws_vpc.pbl_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.tags.project}-${var.tags.environment}-alb-sg"
  })
}

# App SG (private)
resource "aws_security_group" "pbl_app" {
  name   = "${var.tags.project}-${var.tags.environment}-app-sg"
  vpc_id = aws_vpc.pbl_vpc.id

  ingress {
    description     = "Allow from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.pbl_alb.id]
  }

  egress {
    description = "Outbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.tags.project}-${var.tags.environment}-app-sg"
  })
}