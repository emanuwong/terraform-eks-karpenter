module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # Tags for private subnets (used by EKS and Karpenter)
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
    "karpenter.sh/discovery"                    = "eks-karpenter-demo"
  }

  # Tags for public subnets (optional, currently empty)
  public_subnet_tags = {
    # Add public subnet tags if needed (e.g. for external ELB)
  }

  tags = {
    "Name" = "${var.cluster_name}-vpc"
  }
}
