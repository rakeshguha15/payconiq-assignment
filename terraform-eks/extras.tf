#This file contains extra configurations and add-ons to make the Kubernetes Cluster Persistent Volume Storage, Ingress etc.
#This block below checks where the terraform commands are being un and chooses interpreter accordingly
locals {
  # This tests the path, if running on windows this flags is windows to true
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

#Updating local Kubeconfig to the created cluster after nodes are added
resource "null_resource" "clusterConfig" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.eks_cluster_name}"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }
}

#Installing Metrics Server on EKS
resource "null_resource" "metricsServer" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command     = "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }
}




#The code below represents installing ingress-controller, which can be used along with a Domain name
#Since domain name is not available, this is not being used at the moment
###Downloading recommended policy for eks elb ingress controller
##data "http" "aws-lb-controller-policy" {
##  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.2/docs/install/iam_policy.json"
##
##  request_headers = {
##    Accept = "application/json"
##  }
##}
##resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
##  name        = "AWSLoadBalancerControllerIAMPolicy"
##  path        = "/"
##  description = "AWS ELB Controller Policy"
##  policy = tostring(data.http.aws-lb-controller-policy.body)
##  depends_on = [module.eks]
##  provisioner "local-exec" {
##    command = "eksctl create iamserviceaccount --cluster=${var.eks_cluster_name} --namespace=kube-system  --name=aws-load-balancer-controller --attach-policy-arn=$##{self.arn} --override-existing-serviceaccounts --approve"
##    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
##  }
##
##}
##
###Followed installation instructions from https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/
##
##resource "null_resource" "helm_chart_install" {
##    depends_on = [module.eks,aws_iam_policy.AWSLoadBalancerControllerIAMPolicy]
##  #Downloading Helm chart for AWS Load Balancer Controller 
##  provisioner "local-exec" {
##    
##    command = <<-EOT
##    helm repo add eks https://aws.github.io/eks-charts
##    helm repo update 
##    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
##    helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=${var.eks_cluster_name} --set serviceAccount.##create=false --set serviceAccount.name=aws-load-balancer-controller
##    EOT
##    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
##  }
##}
