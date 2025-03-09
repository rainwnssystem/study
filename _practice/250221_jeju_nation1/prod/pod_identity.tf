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

module "dynamo_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "dynamo"

  attach_custom_policy = true

  policy_statements = [
    {
      sid       = "dynamo"
      actions   = [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ]
      resources = ["*"]
    }
  ]

  association_defaults = {
    namespace       = "wsc-prod"
    service_account = "dynamodb"
  }

  associations = {
    eks = {
      cluster_name = module.eks.cluster_name
    }
  }
}