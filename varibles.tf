variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "aws_keyname" {
  description = "AWS keypair name"
  type        = string
}

variable "aws_environment" {
  description = "Environment"
  type        = string
}

variable "aws_project" {
  description = "Project"
  type        = string
}

variable "aws_owner" {
  description = "Owner"
  type        = string
}

variable "aws_vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block                   = string,
    enable_dns_support           = bool,
    enable_dns_hostnames         = bool,
    public_subnets_cidr          = list(string),
    private_subnets_cidr         = list(string),
    number_of_availability_zones = number
  })
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = ""
}

variable "bastion_host_instance_type" {
  description = "Bastion host instance type"
  type        = string
  default     = "t2.micro"
}

variable "bastion_host_ebs_size" {
  description = "Bastion host EBS size"
  type        = number
  default     = 8
}

variable "harbor_instance_type" {
  description = "Harbor instance type"
  type        = string
  default     = "t2.micro"
}

variable "harbor_ebs_size" {
  description = "Harbor EBS size"
  type        = number
  default     = 8
}

variable "minio_instance_type" {
  description = "Minio instance type"
  type        = string
  default     = "t2.micro"
}

variable "minio_ebs_size" {
  description = "Minio EBS size"
  type        = number
  default     = 8
}

variable "vault_instance_type" {
  description = "Vault instance type"
  type        = string
  default     = "t2.micro"
}

variable "vault_ebs_size" {
  description = "Vault EBS size"
  type        = number
  default     = 8
}

variable "security_servers_instance_type" {
  description = "Security servers instance type"
  type        = string
  default     = "t2.micro"
}

variable "security_servers_ebs_size" {
  description = "Security servers EBS size"
  type        = number
  default     = 8
}

variable "autoscaling_group_instance_type" {
  description = "Autoscaling group instance type"
  type        = string
  default     = "t2.micro"
}

variable "autoscaling_group_min_size" {
  description = "Autoscaling group minimum size"
  type        = number
  default     = 1
}

variable "autoscaling_group_max_size" {
  description = "Autoscaling group maximum size"
  type        = number
  default     = 1
}

variable "autoscaling_group_desired_capacity" {
  description = "Autoscaling group desired capacity"
  type        = number
  default     = 1
}

variable "autoscaling_group_health_check_path" {
  description = "Autoscaling group health check path"
  type        = string
  default     = "/"
}

variable "autoscaling_group_health_check_port" {
  description = "Autoscaling group health check port"
  type        = number
  default     = 80
}

variable "autoscaling_group_health_check_protocol" {
  description = "Autoscaling group health check protocol"
  type        = string
  default     = "HTTP"
}

variable "service_ipv4_cidr" {
  description = "CIDR block for the service network"
  type        = string
}

variable "node_group_min_size" {
  description = "Node group minimum size"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Node group maximum size"
  type        = number
  default     = 1
}

variable "node_group_desired_size" {
  description = "Node group desired size"
  type        = number
  default     = 1
}
