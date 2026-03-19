output "vpc_id" {
  value = aws_vpc.pbl_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

# output "app_sg" {
#   value = aws_security_group.pbl_app_sg.id
# }