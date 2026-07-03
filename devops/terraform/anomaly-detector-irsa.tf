resource "aws_iam_policy" "anomaly_detector_cloudwatch" {
  name = "${var.cluster_name}-anomaly-detector-cw"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "anomaly_detector_irsa" {
  name = "${var.cluster_name}-anomaly-detector"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = module.eks.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:anomaly-detector-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "anomaly_detector_cw" {
  role       = aws_iam_role.anomaly_detector_irsa.name
  policy_arn = aws_iam_policy.anomaly_detector_cloudwatch.arn
}
