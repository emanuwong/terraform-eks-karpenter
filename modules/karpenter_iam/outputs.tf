output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  value = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter_node.name
}
