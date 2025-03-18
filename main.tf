# main.tf
# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "itss-ojt-DeGuzman-alb-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"] # Replace with your specific IP range
    description = "Allow HTTP traffic from specific IP range"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"] # Replace with your specific IP range
    description = "Allow HTTPS traffic from specific IP range"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"] # Restrict egress traffic
    description = "Allow all outbound traffic to specific IP range"
  }

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "itss-ojt-DeGuzman-ec2-sg"
  vpc_id      = var.vpc_id
  description = "Security group for EC2"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow HTTP traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"] # Restrict egress traffic
    description = "Allow all outbound traffic to specific IP range"
  }

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "itss-ojt-DeGuzman-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true
  drop_invalid_header_fields = true

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "itss-ojt-DeGuzman-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

# ALB HTTP Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

/*# ALB HTTPS Listener
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}*/

# EC2 Instance
resource "aws_instance" "web" {
  ami             = "ami-039454f12c36e7620"  # Replace with a valid AMI ID
  vpc_id          = var.vpc_id
  instance_type   = var.instance_type
  subnet_id       = var.private_subnet_ids[0]
  security_groups = [aws_security_group.ec2_sg.id]

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    prevent_destroy        = true
    create_before_destroy  = true
  }

  tags = {
    Name            = "itss-ojt-DeGuzman-ec2-v2"
    Environment     = "Sandbox"
    backup          = "no"
    Schedule        = "running"
    Patch           = "No"
    Resource_Types  = "Instances Volumes Network_Interfaces"
  }
}

# Register EC2 with Target Group
resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}