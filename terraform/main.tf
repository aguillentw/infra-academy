resource "aws_vpc" "aa_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name="aa_vpc"
  }
}