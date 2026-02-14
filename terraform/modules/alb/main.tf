# 1. Target Group
resource "aws_lb_target_group" "project_alb" {
  name        = "tg-project-alb"
  target_type = "ip"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "project_alb_tg"
  }
}

# 2. Security Group
resource "aws_security_group" "sg_alb" {
  name        = "project-alb-sg"
  description = "Allow incoming traffic on ports 443 and 80"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.http_listener_port
    to_port     = var.http_listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.https_listener_port
    to_port     = var.https_listener_port
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

# 3. Application Load Balancer
resource "aws_lb" "application_lb" {
  name               = var.name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = var.name
  }
}

# 4. HTTP Listener
resource "aws_lb_listener" "project_alb_listeners" {
  load_balancer_arn = aws_lb.application_lb.arn
  protocol          = "HTTP"
  port              = var.http_listener_port

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = var.https_listener_port
      status_code = "HTTP_301"
    }
  }
}

# 5. HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = var.https_listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_alb.arn
  }
}