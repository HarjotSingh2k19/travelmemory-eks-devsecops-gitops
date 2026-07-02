module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id # nodes go in PRIVATE subnets

  enable_irsa = true # creates the OIDC provider — required for IRSA later

  cluster_endpoint_public_access  = false # we'll flip this to false once the bastion exists
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.large"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
    }
  }

  tags = {
    Project = var.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  # This references the IAM role created by the EKS module for the 'default' node group
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"
}