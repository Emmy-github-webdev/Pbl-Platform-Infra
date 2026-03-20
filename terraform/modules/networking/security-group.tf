# -------------------
# Security Group
# -------------------

# ALB SG (public)
resource "aws_security_group" "alb_sg" {
  description = "Security group for public Application Load Balancer"
  name        = "${var.tags.project}-${var.tags.environment}-alb-sg"
  vpc_id      = aws_vpc.pbl_vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.pbl_vpc.cidr_block]
  }

  tags = merge(var.tags, {
    Name = "${var.tags.project}-${var.tags.environment}-alb-sg"
  })
}

# App SG (private)
# checkov:skip=CKV2_AWS_5: SG is attached dynamically outside Terraform
# resource "aws_security_group" "pbl_app_sg" {
#   description = "Security group for application backend instances"
#   name        = "${var.tags.project}-${var.tags.environment}-app-sg"
#   vpc_id      = aws_vpc.pbl_vpc.id

#   ingress {
#     description     = "Allow traffic from ALB only"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb_sg.id]
#   }

#   egress {
#     description = "Outbound HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(var.tags, {
#     Name = "${var.tags.project}-${var.tags.environment}-app-sg"
#   })
# }


# restrict the default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.pbl_vpc.id

  # No ingress rules

  # Restrict egress (you can make this even stricter if needed)
  egress {
    description = "Allow no outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"]
  }

  tags = {
    Name = "default-restricted"
  }
}