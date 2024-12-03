resource "aws_launch_template" "main" {
  image_id = var.ami
  instance_type = var.instance_type
  key_name = var.aws_key_name
  user_data = var.user_data
  security_group_names = var.ec2_security_groups

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
}

resource "aws_autoscaling_group" "main" {
  availability_zones = var.availability_zones
  min_size       = var.min_size
  max_size       = var.max_size
  desired_capacity   = var.desired_capacity

  launch_template {
    id = aws_launch_template.main.id
    version = "$Latest"
  }

  vpc_zone_identifier  = var.ec2_subnets
  termination_policies = ["OldestInstance"]
  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 110
  }

  health_check_type = "ELB"
  target_group_arns = [
    aws_lb_target_group.http.arn,
    aws_lb_target_group.https.arn
  ]
  tag {
    key     = "Name"
    value      = var.name
    propagate_at_launch = true
  }
}

resource "aws_lb" "main" {
  name         = var.name
  internal       = false
  load_balancer_type = "network"
  security_groups = var.lb_security_groups
  subnets   = var.lb_subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type       = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port        = "443"
  protocol      = "TCP"

  default_action {
    type       = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_target_group" "http" {
  name   = var.name
  port   = 80
  protocol = "TCP"
  health_check {
    path = "/health"
    protocol = "HTTP"
    port = "traffic-port"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "https" {
  name   = var.name
  port   = 443
  protocol = "TCP"
  health_check {
    path = "/health"
    protocol = "HTTP"
    port = 8404
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
