module "dynamodb_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "dynamodb"

  attach_custom_policy = true

  policy_statements = [
    {
      sid       = "Dynamodb"
      actions   = [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ]
      resources = ["*"]
    }
  ]

  association_defaults = {
    namespace       = "wsi"
    service_account = "dynamodb"
  }

  associations = {
    eks = {
      cluster_name = module.eks.cluster_name
    }
  }
}