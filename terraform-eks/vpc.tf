module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                              = var.availability_zones
  public_subnets                   = var.subnet_cidrs_public
  private_subnets                  = var.subnet_cidrs_private
  enable_nat_gateway               = true
  default_vpc_enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/tf-eks-cluster" = "shared"
  }

}


