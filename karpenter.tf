resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.5.2"

  set = [
    {
      name  = "settings.clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "settings.clusterEndpoint"
      value = module.eks.cluster_endpoint
    },
    {
      name  = "settings.defaultInstanceProfile"
      value = module.karpenter_iam.karpenter_node_instance_profile_name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.karpenter_iam.karpenter_controller_role_arn
    },
    {
      name  = "nodeSelector.dedicated"
      value = "karpenter"
    }
  ]

  depends_on = [
    module.karpenter_iam
  ]
}
