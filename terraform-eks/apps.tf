provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "ghost-blog" {
  name       = "ghost-blog-stateless"
  chart      = "../ghost-blog-stateless"
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = <<-EOT
    echo "The ghost-blog url is: $(kubectl get services --namespace default ghost-blog --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    EOT
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  } 
}

resource "helm_release" "node-red" {
  name       = "node-red-stateful"
  chart      = "../node-red-stateful"
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = <<-EOT
    echo "The node-red url is: $(kubectl get services --namespace default node-red --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    EOT
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }  
}