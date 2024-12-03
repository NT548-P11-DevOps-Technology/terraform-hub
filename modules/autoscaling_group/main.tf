resource "aws_launch_template" "this" {
    image_id = var.ami
    instance_type = var.instance_type
    key_name = var.aws_key_name

    block_device_mappings {
        device_name = "/dev/sda1"

        ebs {
            volume_size = 10
            volume_type = "gp3"
            delete_on_termination = true
        }
    }

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "${var.aws_project}-instance-template"
        }
    }
}

resource "aws_lb_target_group" "lb" {
    port = 443
    protocol = "HTTPs"
    vpc_id = var.vpc_id
    target_type = "instance"
    health_check {
        path = "/health"
        protocol = "HTTP"
        port = "traffic-port"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
    tags = {
        Name = "${var.aws_project}-lb-target-group"
    }
}

resource "aws_autoscaling_group" "this" {
    name = "${var.aws_project}-haproxy-asg"
    launch_template {
        id = aws_launch_template.this.id
        version = "$Latest"
    }
    min_size = 1
    max_size = 2
    desired_capacity = 1
    vpc_zone_identifier = var.subnets_id
    target_group_arns = var.target_group_arns
    health_check_type = "ELB"
    health_check_grace_period = 300
    termination_policies = ["OldestInstance"]
    tag {
        key = "Name"
        value = "${var.aws_project}-haproxy-asg"
        propagate_at_launch = true
    }
    tag {
        key = "Environment"
        value = "production"
        propagate_at_launch = true
    }
    tag {
        key = "Project"
        value = var.aws_project
        propagate_at_launch = true
    }
    tag {
        key = "Owner"
        value = "DevOps Team"
        propagate_at_launch = true
    }
    tag {
        key = "Terraform"
        value = "true"
        propagate_at_launch = true
    }
}