resource "aws_vpc" "aa_vpc" {
  cidr_block = var.aws_cidr
  tags       = {
    Name = "aa_vpc"
  }
}

resource "aws_subnet" "aa_west_1a" {
  vpc_id            = aws_vpc.aa_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "aa_west_1a"
  }
}

resource "aws_subnet" "aa_west_1b" {
  vpc_id            = aws_vpc.aa_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "aa_west_1b"
  }
}

resource "aws_internet_gateway" "aa_igw" {
  vpc_id = aws_vpc.aa_vpc.id

  tags = {
    Name = "aa_vpc-igw"
  }
}

resource "aws_route" "aa_route" {
  route_table_id         = aws_vpc.aa_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aa_igw.id
}