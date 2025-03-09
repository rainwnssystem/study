resource "aws_iam_policy" "irsa" {
  name = "${var.project_name}-policy-irsa"
  policy = data.aws_iam_policy_document.irsa.json  
}

data "aws_iam_policy_document" "irsa" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }
}

module "irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.project_name}-role-irsa"

  role_policy_arns = {
    policy = aws_iam_policy.irsa.arn
  }

  oidc_providers = {
    cluster-oidc-provider = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "wsi:irsa"
      ]
    }
  }
}

resource "kubernetes_service_account" "irsa" {
  metadata {
    name      = "irsa"
    namespace = "wsi"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa.iam_role_arn
    }
  }
}