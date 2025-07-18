############################################################################
# Old test example code can be found in the Manifest/deployments folder.
############################################################################

/* # EC2NodeClass for x86_64 instances
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
 */

####################################################
# New example for both architectures: x86 and ARM64.
####################################################

# EC2NodeClass for al2023@v20250627 AMIs
resource "kubectl_manifest" "nodeclass_x86_arm64" {
  yaml_body  = file("${path.module}/manifests/karpenter/ec2-nodeclass-x86-arm64.yaml")
  depends_on = [helm_release.karpenter]
}

# NodePool for ARM64 and AMD64 spot instances
resource "kubectl_manifest" "nodepool_spot_x86_arm64" {
  yaml_body  = file("${path.module}/manifests/karpenter/nodepool-x86-arm64.yaml")
  depends_on = [kubectl_manifest.nodeclass_x86_arm64]

}
