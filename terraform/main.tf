module "network" {
  source = "./modules/network"
}

resource "aws_security_group" "aa_security" {
  name        = "aa_security"
  description = "Allow Http and ssh traffic"
  vpc_id      = module.network.aws_vpc_id
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
  key_name   = "aa_another_key_pair"
  public_key = file("~/.ssh/test-key.pub")

  tags = {
    name = "aa_ssh_key"
  }
}

resource "aws_launch_configuration" "aa_launch_config" {
  image_id                    = var.aws_image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aa_another_key_pair.key_name
  security_groups             = [aws_security_group.aa_security.id]

  user_data = <<-EOF
#!/bin/bash
sudo yum -y update
sudo yum install -y httpd
sudo service httpd start
echo '<!doctype html><html><head><title>Terraform experts!</title><style>body {background-color: #1c87c9;}</style></head><body>We are now terraform experts</body></html>' | sudo tee /var/www/html/index.html
EOF
}

resource "aws_autoscaling_group" "aa_scaling_group" {
  max_size             = 4
  min_size             = 2
  launch_configuration = aws_launch_configuration.aa_launch_config.id
  vpc_zone_identifier  = [module.network.aws_subnet_1a, module.network.aws_subnet_1b]
  target_group_arns = [aws_lb_target_group.aa_pool.arn]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "aa_instance"
  }
}

resource "aws_lb" "aa_load_balancer" {
  name                             = "aa-nlb"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = [module.network.aws_subnet_1a, module.network.aws_subnet_1b]
}

resource "aws_lb_listener" "aa_frontend" {
  load_balancer_arn = aws_lb.aa_load_balancer.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aa_pool.arn
  }
}

resource "aws_lb_target_group" "aa_pool" {
  name     = "web-services"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.network.aws_vpc_id
}
