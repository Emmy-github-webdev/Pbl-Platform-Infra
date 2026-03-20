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

output "kms_key" {
  value = aws_kms_alias.logs.arn
}