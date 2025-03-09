module "aws_ebs_csi_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "aws-ebs-csi"

  attach_aws_ebs_csi_policy = true
  aws_ebs_csi_kms_arns      = [aws_kms_key.key.arn]

  association_defaults = {
    namespace       = "kube-system"
    service_account = "ebs-csi-controller-sa"
  }

  associations = {
    eks = {
      cluster_name = module.eks.cluster_name
    }
  }
}

# module "aws_cloudwatch_observability_pod_identity" {
#   source = "terraform-aws-modules/eks-pod-identity/aws"

#   name = "aws-cloudwatch-observability"

#   attach_aws_cloudwatch_observability_policy = true

#   association_defaults = {
#     namespace       = "amazon-cloudwatch"
#     service_account = "cloudwatch-agent"
#   }

#   associations = {
#     eks = {
#       cluster_name = module.eks.cluster_name
#     }
#   }
# }

module "prometheus_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "prometheus"

  attach_custom_policy = true

  policy_statements = [
    {
      sid       = "Statement"
      actions   = [
        "aps:RemoteWrite", 
        "aps:GetSeries", 
        "aps:GetLabels",
        "aps:GetMetricMetadata",
        "aps:QueryMetrics"
      ]
      resources = ["*"]
    }
  ]

  # association_defaults = {
  #   namespace       = "monitoring"
  #   service_account = "amp-iamproxy-ingest-service-account"
  # }

  associations = {
    amp = {
      cluster_name = module.eks.cluster_name
      namespace       = "monitoring"
      service_account = "amp-iamproxy-ingest-service-account"
    }
    keda = {
      cluster_name = module.eks.cluster_name
      namespace       = "keda"
      service_account = "keda-operator"
    }
  }
}