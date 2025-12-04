provider "aws" {
  region = "ap-south-1"
}

# -------------------------------
# VPC
# -------------------------------

resource "aws_vpc" "ha_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.ha_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.ha_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.ha_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.ha_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-south-1b"
}

# -------------------------------
# Internet Gateway & Routing
# -------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ha_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ha_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------
# Security Groups
# -------------------------------

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.ha_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.ha_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# Launch Template
# -------------------------------

resource "aws_launch_template" "lt" {
  name_prefix = "ha-lt"

  image_id      = "ami-0f5daaa3a7fb3378b" # replace with your AMI
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from $(hostname)" > /var/www/html/index.html
EOF
  )
}

# -------------------------------
# Target Group & Load Balancer
# -------------------------------

resource "aws_lb_target_group" "tg" {
  name     = "ha-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ha_vpc.id

  health_check {
    path = "/"
  }
}

resource "aws_lb" "alb" {
  name               = "ha-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# -------------------------------
# Auto Scaling Group
# -------------------------------

resource "aws_autoscaling_group" "asg" {
  name                      = "ha-asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  target_group_arns = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}
