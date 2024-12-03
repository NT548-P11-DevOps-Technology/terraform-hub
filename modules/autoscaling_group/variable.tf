variable "aws_project" {
    description = "Project name"
    type        = string
}

variable "aws_key_name" {
    description = "AWS key pair name"
    type        = string
}

variable "ami" {
    description = "AMI ID for the EC2 instances"
    type        = string
    default     = ""
}

variable "instance_type" {
    description = "Instance type for the EC2 instances"
    type        = string
    default     = "t2.micro"
}

variable "vpc_id" {
    description = "VPC ID for the EC2 instances"
    type        = string
}

variable "subnets_id" {
    description = "Subnet ID for the EC2 instances"
    type        = list(string)
    default     = []
}