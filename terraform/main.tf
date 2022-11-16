resource "aws_vpc" "aa_vpc" {
  cidr_block = "10.0.0.0/16"
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
    Name = "ag_vpc-igw"
  }
}

resource "aws_route" "aa_route" {
  route_table_id         = aws_vpc.aa_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aa_igw.id
}

resource "aws_security_group" "aa_security" {
  name        = "aa_security"
  description = "Allow Http and ssh traffic"
  vpc_id      = aws_vpc.aa_vpc.id
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aa_sg"
  }
}

resource "aws_key_pair" "aa_another_key_pair" {
  key_name   = "ag_another_key_pair"
  public_key = file("~/test.pub")

  tags = {
    name = "aa_ssh_key"
  }
}

resource "aws_launch_configuration" "aa_launch_config" {
  image_id                    = "ami-096f43ef67d75e998"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aa_another_key_pair.key_name
}

resource "aws_autoscaling_group" "aa_scaling_group" {
  max_size             = 4
  min_size             = 2
  launch_configuration = aws_launch_configuration.aa_launch_config.id
  vpc_zone_identifier  = [aws_subnet.aa_west_1a.id, aws_subnet.aa_west_1b.id]
}
