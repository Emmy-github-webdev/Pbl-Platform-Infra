resource "aws_lb" "app_alb" {
  name               = "${var.tags.project}-${var.tags.environment}-app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}