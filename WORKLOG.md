# WorkLog 

This document represents the tasks performed to build a Kubernetes Cluster on AWS EKS and Deploying a stateless
demo web-service of my own choice and a stateful application.

---
The code contains a terraform module which when applied performs the following tasks -
- Creates a VPC 
- Creates Public and Private Subnets for the VPC andassociates default route tables
- Tags each subnet for EKS Specific Tags
- Creates an EKS Cluster with Load Balancers in Public Subnets and Worker nodes in Private Subnet
- Creates recommended security groups for worker nodes 
- Updates aws_auth configmap and adds current AWS User as an Admin in the cluster (system masters group)
- Configures local Helm and Kubernetes binaries to interact with the remote cluster
- Launches a couple of helm charts to deploy a stateful and a stateless application in default namespace in the cluster :
   - Node Red - A sample Node-red application (https://nodered.org/) which runs in a Statfeul Manner
   - Ghost-Blog - A sample Blog Application (https://ghost.org/) run in a Stateless way
- Helm charts include a PersistentStorage for the statefull application and LoadBalancer type services

##Pre-requisites
To implement this Terraform module the following tools need to be installed at a locl level with paths set to the binary names

- AWS CLI needs to be installed (With `aws configure` already set up)
- Kubectl binary should be installed
- Helm Binary should be installed
- Terraform binary should be installed

This module chooses to not configure AWS credentials inside the module for safety and security purposes. Ideally this module would be run from a pipeline where those secrets would be configured as ENV Variables


###Input Defaults

To re-configure defaults please create new tfvars files. For documentation purposes defaults are mentioned in the table below, these defaults are present in `eu-central.tfvars` file - 

| Parameter | Values |
| ----------- | ----------- |
| aws_region | `eu-central-1` |
| availability_zones | `eu-central-1a, eu-central-1b` |
| vpc_name | `EKSVpc` |
| vpc_cidr | `10.0.0.0/16` |
| subnet_cidrs_public | `10.0.1.0/24, 10.0.2.0/24` |
| subnet_cidrs_private | `10.0.101.0/24, 10.0.102.0/24` |
| eks_cluster_name | `tf-eks-cluster` |


###Outputs
| Parameter | Values |
| ----------- | ----------- |
| account_id | `<aws-cli user_account_id>` |
| caller_arn | `<aws-cli user_caller_arn>` |
| caller_user | `<aws-cli user_caller_user>` |
| cluster_arn | `<EKS-Cluster-ARN>` |
| vpc_id | `<VPC ID For Created EKS Cluster>` |


**NOTE: Please watch out for URL Output for Network Load Balancers for both Node-Red and Ghost-Blog App.
A local Provisioner is configured to get those URLs from the kubectl client and dump it on stdout**

###Known Limitations
Since I could not find any provided URL and I decided to do this over the weekend, I could not request for an SSL Certificate, I would update Service Ports in the helm chart if I had a domain name, and would have created an Ingress resource with the host as the custom domain name. That way we could terminate SSL at the ingress level, and we would be working with a single Application Load Balancer instead of multiple Network Load Balancers. 

Also that would enable the Ghost-blog to have an env variable URL, without which a lot of functionalities don't work there. 

###Architecture
In this cluster I tried to mimic the following Architecture - This is an example diagram for a single node cluster with different IPs, this is used only for demo purposes.

<img src="https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2020/04/10/subnet_pubpri.png"
     alt="Achitecture"
     style="float: left; margin-right: 10px;" />


...
---
###Cleanup:
All the AWS resources created by this module can be easily destroyed by running `terraform destroy` including the helm charts as thse are also using terraform helm providers.

**Exception:** I have manually created an S3 bucket to store terraform state file `terraform-store-payconiq-sample` , this needs to be deleted as this is managed manually.

---
###Task-order:
The development was done in the following order -
1. Terraform module for EKS Cluster
2. Kubernetes Manifest for ghost-blog
3. Kubernetes Manifest for node-red
4. Helm chart for both application
5. Update to EKS Module with Outputs
6. Jenkins Pipeline Script
7. Worklog Document

---
###Credentials
The credentials I used for this should be sent over email, if not please feel free to reach out to me for the credentials

---
###Pipelines
**Jenkinsfile**
- This pipeline creates or destroys the entire Stack
- This pipeline checks if `<aws_region>.tfvars` file is present, if not it fails the pipeline with an ERROR
  
**Jenkinsfile-application.groovy**
- A secondary pipeline for application deployment
- This pipeline takes a lot more inputs but also can deploy, update and delete individual applications
- This pipeline updates kubeconfig with AWS Credentials and uses helm to deploy, update or delete charts(applications)

Note: These are sample pipelines with a lot of assumptions about the runtime environment, obviously this will need some modifications in an actual Jenkins Environment.