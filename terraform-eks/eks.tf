#Using Public EKS Module

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }

  }

  cluster_encryption_config = [{
    provider_key_arn = "${aws_kms_key.eks-encryption-key.arn}"
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 20
    instance_types = ["t3.medium"]
    name           = "eks-worker-nodes"
    subnet_ids     = module.vpc.private_subnets
  }

  manage_aws_auth_configmap = true
  #This part adds current AWS User to system Masters Group
  aws_auth_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = split("/", "${data.aws_caller_identity.current.arn}")[1]
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 5
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }
  tags = {
    Environment = "Staging"
    Terraform   = "true"
  }
}




