module "karpenter_iam" {
  source            = "./modules/karpenter_iam"
  cluster_name      = module.eks.cluster_name
  region            = var.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
}
