output "cluster_arn" {
  description = "Kubernetes Cluster Name"
  value       = join(": ", ["The ARN For Created Kubernetes Cluster is ", "${module.eks.cluster_arn}"])
}

output "vpc_id" {
  description = "EKS VPC ID"
  value       = join(": ", ["The VPC ID For Created Kubernetes Cluster is ", "${module.vpc.vpc_id}"])
}

