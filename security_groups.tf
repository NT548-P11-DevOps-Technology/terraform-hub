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
        description = "Allow Node Exporter Access"
        from_port   = 9100 # Node Exporter
        to_port     = 9100
        protocol    = "tcp"
        security_group_id = module.EKS.cluster_security_group_id
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
        ip               = var.aws_vpc_config.cidr_block
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

module "haproxy_sg" {
    source      = "./modules/security_group"
    name        = "${var.aws_project}-haproxy-sg"
    description = "Security group for haproxy"
    vpc_id      = module.vpc.vpc_id

    ingress_rules = [
    {
        description = "Allow traffic http from load balancer"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_group_id = module.load_balancer.id
    },
    {
        description = "Allow https traffic from load balancer"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_group_id = module.load_balancer_sg.id
    },
    {
        description      = "Allow ssh from gateway"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        security_group_id = module.gateway_sg.id
    },
    {
        description = "Allow Node Exporter Access"
        from_port   = 9100 # Node Exporter
        to_port     = 9100
        protocol    = "tcp"
        security_group_id = module.EKS.cluster_security_group_id
    },
    {
        description      = "Allow all icmp from gateway"
        from_port        = -1
        to_port          = -1
        protocol         = "icmp"
        security_group_id = module.gateway_sg.id
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
        description = "Allow SonarQube Access"
        from_port   = 9000
        to_port     = 9000
        protocol    = "tcp"
        security_group_id = module.haproxy_sg.id
    },
    {
        description = "Allow MinIO API Access"
        from_port   = 9000
        to_port     = 9000
        protocol    = "tcp"
        security_group_id = module.haproxy_sg.id
    },
    {
        description = "Allow MinIO Console Access"
        from_port   = 9001
        to_port     = 9001
        protocol    = "tcp"
        security_group_id = module.haproxy_sg.id
    },
    {
        description = "Allow Vault Access"
        from_port   = 8200
        to_port     = 8200
        protocol    = "tcp"
        security_group_id = module.haproxy_sg.id
    },
    {
        description = "Allow Node Exporter Access"
        from_port   = 9100 # Node Exporter
        to_port     = 9100
        protocol    = "tcp"
        security_group_id = module.EKS.cluster_security_group_id
    },
    {
        description      = "Allow all icmp from gateway"
        from_port        = -1
        to_port          = -1
        protocol         = "icmp"
        security_group_id = module.gateway_sg.id
    },
    {
        description      = "Allow traffic from haproxy"
        from_port        = -1
        to_port          = -1
        protocol         = "icmp"
        security_group_id = module.haproxy_sg.id
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