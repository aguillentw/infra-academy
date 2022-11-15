resource "aws_vpc" "aa_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name="aa_vpc"
  }
}

resource "aws_subnet" "aa_west_1a" {
  vpc_id = aws_vpc.aa_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    name="aa_west_1a"
  }
}

resource "aws_subnet" "aa_west_1b" {
  vpc_id = aws_vpc.aa_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    name="aa_west_1b"
  }
}
