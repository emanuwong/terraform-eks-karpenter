# VPC outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

# EKS cluster outputs
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

# Karpenter IAM and instance profile outputs
output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role used by the Karpenter controller"
  value       = module.karpenter_iam.karpenter_controller_role_arn
}

output "karpenter_node_instance_profile_name" {
  description = "Name of the instance profile used by Karpenter-managed EC2 nodes"
  value       = module.karpenter_iam.karpenter_node_instance_profile_name
}

output "karpenter_node_role_arn" {
  description = "ARN of the IAM role used by Karpenter-node"
  value       = module.karpenter_iam.karpenter_node_role_arn
}
