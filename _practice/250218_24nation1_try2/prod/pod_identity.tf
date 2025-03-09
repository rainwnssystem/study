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

module "dynamodb_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "dynamodb"

  attach_custom_policy = true

  policy_statements = [
    {
      sid       = "Dynamo"
      actions   = [
				"dynamodb:GetItem",
				"dynamodb:PutItem",
        "dynamodb:Decrypt"
      ]
      resources = ["*"]
    }
  ]

  association_defaults = {
    namespace       = "wsc2024"
    service_account = "dynamodb"
  }

  associations = {
    eks = {
      cluster_name = module.eks.cluster_name
    }
  }
}