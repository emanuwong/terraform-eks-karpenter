# IAM trust policy for Karpenter controller (OIDC-based service account)
data "aws_iam_policy_document" "karpenter_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
  }
}

# Karpenter controller IAM role
resource "aws_iam_role" "karpenter_controller" {
  name               = "karpenter-controller-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
}

# IAM policy for Karpenter controller permissions
data "aws_iam_policy_document" "karpenter_controller_policy" {
  statement {
    sid    = "AllowScopedEC2InstanceActions"
    effect = "Allow"
    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:RunInstances",
      "ec2:CreateTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DeleteLaunchTemplate",
      "ec2:TerminateInstances",
      "pricing:GetProducts",
      "ssm:GetParameter",
      "iam:PassRole",
      "iam:GetInstanceProfile",
      "iam:GetRole",
      "iam:CreateInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowScopedSSMAndPricing"
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowScopedInterruptionActions"
    effect = "Allow"
    actions = [
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeInstanceTypeOfferings"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "EKSDescribe"
    effect  = "Allow"
    actions = ["eks:DescribeCluster", "eks:AccessKubernetesApi"]
    resources = [
      "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${module.eks.cluster_name}"
    ]
  }
}

# Create IAM policy and attach to controller role
resource "aws_iam_policy" "karpenter_controller" {
  name   = "karpenter-controller-policy"
  policy = data.aws_iam_policy_document.karpenter_controller_policy.json
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

# IAM trust policy for Karpenter nodes
data "aws_iam_policy_document" "karpenter_node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM role for EC2 instances provisioned by Karpenter
resource "aws_iam_role" "karpenter_node" {
  name               = "karpenter-node-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume_role.json
}

# Attach required managed policies to the Karpenter node role
resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_registry" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ebs" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Instance profile required for EC2 instances
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "karpenter-node-instance-profile"
  role = aws_iam_role.karpenter_node.name
}

# EKS Access entry for Karpenter nodes (new EKS access management)
resource "aws_eks_access_entry" "node" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"
  tags          = {}

  depends_on = [module.eks, aws_iam_role.karpenter_node]
}
