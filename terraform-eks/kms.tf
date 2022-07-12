resource "aws_kms_key" "eks-encryption-key" {
  description = "KMS Encryption key for EKS Cluster Encryption"
}