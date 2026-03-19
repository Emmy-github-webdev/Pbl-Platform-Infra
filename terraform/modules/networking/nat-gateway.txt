# -------------------
# Elastic IP for NAT
# -------------------
resource "aws_eip" "nat" {
  domain = "vpc"
  count  = length(var.azs)

  tags = {
    Name      = "${var.tags.project}-${var.tags.environment}-nat-eip"
    ManagedBy = "terraform"
  }
}

# -------------------
# NAT Gateway (single AZ for cost)
# -------------------
resource "aws_nat_gateway" "nat" {
  count         = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.igw]
}
