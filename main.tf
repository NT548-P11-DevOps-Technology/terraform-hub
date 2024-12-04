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

module "instances" {
  source = "./modules/instance"

  subnet_id = module.vpc.private_subnets_id[2]
  security_groups = [module.servers_sg.id]
  key_name = var.aws_keyname
  ami = local.ec2_ami
  instance_type = "t2.micro"
  ebs_size = 8
  instances = [
    {
      name = "gateway"
      private_ips = local.gateway_private_ips
      subnet_id = module.vpc.public_subnets_id[0]
      source_dest_check = false
      user_data = file("./scripts/bastion-init.sh")
      instance_type = var.bastion_host_instance_type
      ebs_size = var.bastion_host_ebs_size
      security_groups = [module.gateway_sg.id]
    },
    {
      name = "harbor"
      private_ips = local.harbor_private_ips
      instance_type = var.harbor_instance_type
      ebs_size = var.harbor_ebs_size
    },
    {
      name = "minio"
      private_ips = local.minio_private_ips
      instance_type = var.minio_instance_type
      ebs_size = var.minio_ebs_size
    },
    {
      name = "vault"
      private_ips = local.vault_private_ips
      instance_type = var.vault_instance_type
      ebs_size = var.vault_ebs_size
    },
    {
      name = "security-servers"
      private_ips = local.security_servers_private_ips
      instance_type = var.security_servers_instance_type
      ebs_size = var.security_servers_ebs_size
    }
  ]
}

module "load_balancer" {
  source = "./modules/autoscaling_group"

  name = "${var.aws_project}-haproxy"
  aws_key_name = var.aws_keyname
  ami = local.ec2_ami
  instance_type = var.autoscaling_group_instance_type
  user_data = base64encode(file("./scripts/nginx_setup.sh"))
  ec2_subnets = slice(module.vpc.private_subnets_id, length(module.vpc.private_subnets_id) - 2, length(module.vpc.private_subnets_id))
  ec2_security_groups = [module.haproxy_sg.id]
  min_size = var.autoscaling_group_min_size
  max_size = var.autoscaling_group_max_size
  desired_capacity = var.autoscaling_group_desired_capacity
  lb_security_groups = [module.load_balancer_sg.id]
  lb_subnets = module.vpc.public_subnets_id
  vpc_id = module.vpc.vpc_id
  health_check = {
    path = var.autoscaling_group_health_check_path
    port = var.autoscaling_group_health_check_port
    protocol = var.autoscaling_group_health_check_protocol
  }
  depends_on = [ module.EKS.cluster_security_group_id ]
}

module "EKS" {
  source = "./modules/eks"

  name = var.aws_project
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  k8s_version = "1.29"
  cluster_vpc_cidr = var.aws_vpc_config.cidr_block
  cluster_subnet_ids = module.vpc.private_subnets_id
  service_ipv4_cidr = var.service_ipv4_cidr
  eks_addons = ["vpc-cni", "kube-proxy", "coredns"]
  node_group_subnet_ids = module.vpc.private_subnets_id
  node_group_min_size = var.node_group_min_size
  node_group_max_size = var.node_group_max_size
  node_group_desired_size = var.node_group_desired_size
}
