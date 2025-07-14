###############################
# EKS Cluster Configuration
###############################

cluster_name                   = "eks-karpenter-demo"
cluster_version                = "1.33"
cluster_endpoint_public_access = true
allowed_cidr                   = ""

###############################
# Access Control
###############################

access_entries = {}

enable_cluster_creator_admin_permissions = true

###############################
# VPC & Subnet Configuration
###############################

vpc_cidr = "10.0.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

private_subnets = [
  "10.0.0.0/22",
  "10.0.4.0/22",
  "10.0.8.0/22"
]

public_subnets = [
  "10.0.100.0/22",
  "10.0.104.0/22",
  "10.0.108.0/22"
]

###############################
# NAT Gateway Configuration
###############################

enable_nat_gateway = true
single_nat_gateway = true

###############################
# EKS Managed Node Groups
###############################

eks_managed_node_groups = {
  bootstrap = {
    # ami_type can be set explicitly if needed
    # ami_type       = "AL2_x86_64"
    instance_types = ["t3.small"]

    desired_size = 2
    min_size     = 1
    max_size     = 2

    labels = {
      "karpenter.sh/discovery" = "eks-karpenter-demo"
      "dedicated"              = "karpenter"
    }

    tags = {
      "karpenter.sh/discovery" = "eks-karpenter-demo"
    }
  }
}
