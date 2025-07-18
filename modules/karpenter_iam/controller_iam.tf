# IAM trust policy for Karpenter controller

resource "aws_iam_role" "karpenter_controller" {
  name = "karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
        }
      }
    }]
  })
}

data "aws_iam_policy_document" "karpenter_controller_policy" {
  statement {
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
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeSpotPriceHistory", "ec2:DescribeInstanceTypeOfferings"]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["eks:DescribeCluster", "eks:AccessKubernetesApi"]
    resources = [
      "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
    ]
  }
}

resource "aws_iam_policy" "karpenter_controller" {
  name   = "karpenter-controller-policy"
  policy = data.aws_iam_policy_document.karpenter_controller_policy.json
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}
