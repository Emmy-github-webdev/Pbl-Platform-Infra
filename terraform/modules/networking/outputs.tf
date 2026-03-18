output "vpc_id" {
  value = aws_vpc.pbl_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "security_group_id" {
  value = aws_security_group.pbl_sg.id
}