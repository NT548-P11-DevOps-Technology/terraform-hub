# module "keypair" {
#   source = "./modules/keypair"
#   name   = var.aws_profile
# }

# Create VPC with public and private subnets
module "vpc" {
  source = "./modules/vpc"

  name = var.aws_project

  cidr                 = var.aws_vpc_config.cidr_block
  enable_dns_hostnames = var.aws_vpc_config.enable_dns_hostnames
  enable_dns_support   = var.aws_vpc_config.enable_dns_support
  public_subnets       = var.aws_vpc_config.public_subnets_cidr
  private_subnets      = var.aws_vpc_config.private_subnets_cidr
  azs                  = local.selected_azs
  gateway_instance     = module.instances.network_interfaces["gateway"]
}

# Create security group for gateway instance
module "gateway_sg" {
  source      = "./modules/security_group"
  name        = "${var.aws_project}-gateway-sg"
  description = "Security group for gateway instance"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Allow OpenVPN Access"
      from_port   = 1194
      to_port     = 1194
      protocol    = "udp"
      ip          = "0.0.0.0/0"
    },
    {
      description = "Allow SSH Access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      ip          = "0.0.0.0/0"
    },
    {
      description = "Allow All Traffic from VPC"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      ip          = "0.0.0.0/0"
    },
    {
      description      = "Allow all traffic from servers"
      from_port        = -1
      to_port          = -1
      protocol         = "-1"
      security_group_id = module.servers_sg.id
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      ip          = "0.0.0.0/0"
    }
  ]
}

# Create security group for load balancer
module "load_balancer_sg" {
  source      = "./modules/security_group"
  name        = "${var.aws_project}-load-balancer-sg"
  description = "Security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Allow HTTP Access"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      ip          = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS Access"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      ip          = "0.0.0.0/0"
    }
  ]
  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      ip          = "0.0.0.0/0"
    }
  ]
}

module "servers_sg" {
  source      = "./modules/security_group"
  name        = "${var.aws_project}-servers-sg"
  description = "Security group for servers"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description      = "Allow ssh from gateway"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      security_group_id = module.gateway_sg.id
    },
    {
      description      = "Allow all ticmp from gateway"
      from_port        = -1
      to_port          = -1
      protocol         = "icmp"
      security_group_id = module.gateway_sg.id
    },
    {
      description = "Allow traffic http from load balancer"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      security_group_id = module.load_balancer_sg.id
    },
    {
      description = "Allow https traffic from load balancer"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      security_group_id = module.load_balancer_sg.id
    }
  ]
  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      security_group_id = module.gateway_sg.id
    }
  ]
}

resource "aws_instance" "public" {
  ami           = local.ec2_ami
  instance_type = "t2.micro"
  key_name      = var.aws_keyname
  subnet_id     = module.vpc.public_subnets_id[0]
  security_groups = [module.load_balancer_sg.id]
  iam_instance_profile = "LabInstanceProfile"

  tags = {
    Name = "${var.aws_project}-public"
  }
}

module "instances" {
  source = "./modules/instance"

  subnet_id = module.vpc.private_subnets_id[0]
  security_groups = [module.servers_sg.id]
  key_name = var.aws_keyname
  ami = local.ec2_ami
  instance_type = "t2.micro"
  ebs_size = 10
  instances = [
    {
      name = "gateway"
      subnet_id = module.vpc.public_subnets_id[0]
      private_ips = local.gateway_private_ips
      source_dest_check = false
      instance_type = "t2.small"
      security_groups = [module.gateway_sg.id]
      user_data = file("./scripts/bastion-init.sh")
    },
    {
      name = "server1"
      private_ips = local.server1_private_ips
    },
    {
      name = "server2"
      private_ips = local.server2_private_ips
    }
  ]
}

# module "load_balancer" {
#   source = "./modules/autoscaling_group"

#   name = "${var.aws_project}-loadbalancer"
#   aws_key_name = var.aws_keyname
#   ami = local.ec2_ami
#   instance_type = "t2.micro"
#   user_data = base64encode(file("./scripts/nginx_setup.sh"))
#   ec2_subnets = module.vpc.private_subnets_id
#   ec2_security_groups = [module.servers_sg.id]
#   min_size = 1
#   max_size = 3
#   desired_capacity = 1
#   lb_security_groups = [module.load_balancer_sg.id]
#   lb_subnets = module.vpc.public_subnets_id
#   vpc_id = module.vpc.vpc_id
#   health_check = {
#     path = "/"
#     port = 80
#     protocol = "HTTP"
#   }
# }


