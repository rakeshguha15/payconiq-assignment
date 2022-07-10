aws_region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
subnet_cidrs_private = ["10.0.1.0/24", "10.0.2.0/24"]
subnet_cidrs_public = ["10.0.101.0/24", "10.0.102.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
vpc_name = "EKSVpc"
eks_cluster_name = "tf-eks-cluster"
