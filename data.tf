data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Retrieve ECR Public authorization token for Helm chart pull
data "aws_ecrpublic_authorization_token" "token" {}

data "aws_caller_identity" "current" {}
