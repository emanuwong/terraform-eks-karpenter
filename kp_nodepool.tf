# EC2NodeClass for x86_64 instances
resource "kubectl_manifest" "nodeclass_x86" {
  yaml_body  = file("${path.module}/manifests/karpenter/ec2-nodeclass-x86.yaml")
  depends_on = [helm_release.karpenter]
}

# NodePool for x86_64 spot instances
resource "kubectl_manifest" "nodepool_spot_x86" {
  yaml_body  = file("${path.module}/manifests/karpenter/nodepool-x86.yaml")
  depends_on = [kubectl_manifest.nodeclass_x86]
}

# EC2NodeClass for ARM64 instances
resource "kubectl_manifest" "nodeclass_arm64" {
  yaml_body  = file("${path.module}/manifests/karpenter/ec2-nodeclass-arm64.yaml")
  depends_on = [helm_release.karpenter]
}

# NodePool for ARM64 spot instances
resource "kubectl_manifest" "nodepool_spot_arm64" {
  yaml_body  = file("${path.module}/manifests/karpenter/nodepool-arm64.yaml")
  depends_on = [kubectl_manifest.nodeclass_arm64]
}
