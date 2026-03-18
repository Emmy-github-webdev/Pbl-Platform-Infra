# -------------------
# Public Subnets
# -------------------
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.pbl_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-public-${count.index}"
  }
}

# -------------------
# Private Subnets
# -------------------
resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.pbl_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-private-${count.index}"
  }
}
