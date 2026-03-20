# -------------------
# Internet Gateway
# -------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pbl_vpc.id

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-igw"
  }
}