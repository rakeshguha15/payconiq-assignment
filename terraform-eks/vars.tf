variable "aws_region" {
  description = "Name of AWS Region to launch resources in"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC for eks"
  default     = "10.0.0.0/16"
  type        = string
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(string)
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  type        = list(string)
}


variable "availability_zones" {
  description = "Subnet Availability Zones"
  default     = ["eu-central-1a", "eu-central-1b"]
  type        = list(string)
}

variable "vpc_name" {
  description = "Name of the Terraform VPC"
  default     = "EKSVpc"
  type        = string
}


variable "egress_rules_default" {
  description = "Egress rules for Default Security Group"
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]
  type = list(map(string))
}

variable "ingress_rules_default" {
  description = "Ingress rules for Default Security Group"
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]
  type = list(map(string))
}


variable "eks_cluster_name" {
  description = "Name Of the EKS Cluster"
  default     = "tf-eks-cluster"
  type        = string
}
