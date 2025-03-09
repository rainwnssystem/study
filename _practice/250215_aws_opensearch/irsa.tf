# module "irsa_cloudwatchagent" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "${var.project_name}-role-cloudwatchagent"

#   role_policy_arns = {
#     policy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#   }

#   oidc_providers = {
#     cluster-oidc-provider = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         "amazon-cloudwatch:cloudwatch-agent"
#       ]
#     }
#   }
# }

# module "irsa_ebs_csi_driver" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "${var.project_name}-role-ebs-csi-driver"

#   attach_ebs_csi_policy = true

#   oidc_providers = {
#     cluster-oidc-provider = {
#       provider_arn = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         "kube-system:ebs-csi-controller-sa"
#       ]
#     }
#   }
# }

# resource "aws_iam_policy" "secretsmanager" {
#   name = "${var.project_name}-policy-secretsmanager"
#   policy = data.aws_iam_policy_document.secretsmanager.json  
# }

# data "aws_iam_policy_document" "secretsmanager" {
#   statement {
#     actions = [
#       "secretsmanager:*"
#     ]

#     resources = ["*"]
#   }
# }

# module "irsa_secretsmanager" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "${var.project_name}-role-secretsmanager"

#   role_policy_arns = {
#     policy = aws_iam_policy.secretsmanager.arn
#   }

#   oidc_providers = {
#     cluster-oidc-provider = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         "default:secretsmanager"
#       ]
#     }
#   }
# }

# resource "aws_iam_policy" "fluentd" {
#   name = "project-policy-fluentd"
#   policy = data.aws_iam_policy_document.fluentd.json  
# }

# data "aws_iam_policy_document" "fluentd" {
#   statement {
#     actions = [
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup",
#       "logs:PutRetentionPolicy",
#       "logs:CreateLogStream",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams"
#     ]

#     resources = ["*"]
#   }
# }

# module "irsa" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "${var.project_name}-role-fluentd"

#   role_policy_arns = {
#     policy = aws_iam_policy.fluentd.arn
#   }

#   oidc_providers = {
#     cluster-oidc-provider = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         "default:fluentd"
#       ]
#     }
#   }
# }

# resource "aws_iam_policy" "prometheus" {
#   name = "${var.project_name}-policy-prometheus"
#   policy = data.aws_iam_policy_document.prometheus.json  
# }

# data "aws_iam_policy_document" "prometheus" {
#   statement {
#     actions = [
#       "aps:RemoteWrite", 
#       "aps:GetSeries", 
#       "aps:GetLabels",
#       "aps:GetMetricMetadata"
#     ]

#     resources = ["*"]
#   }
# }

# module "prometheus-irsa" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "${var.project_name}-role-prometheus"

#   role_policy_arns = {
#     policy = aws_iam_policy.prometheus.arn
#   }

#   oidc_providers = {
#     cluster-oidc-provider = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         "opentelemetry-operator-system:adot-col-prom-metrics",
#         "prometheus:amp-iamproxy-ingest-service-account"
#       ]
#     }
#   }
# }

# resource "kubernetes_service_account" "adot_irsa" {
#   metadata {
#     name      = "adot-col-prom-metrics"
#     namespace = "opentelemetry-operator-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.prometheus-irsa.iam_role_arn
#     }
#   }
# }

# resource "kubernetes_service_account" "prometheus-irsa" {
#   metadata {
#     name      = "amp-iamproxy-ingest-service-account"
#     namespace = "prometheus"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.prometheus-irsa.iam_role_arn
#     }
#   }
# }

resource "aws_iam_policy" "opensearch" {
  name = "${var.project_name}-policy-opensearch"
  policy = data.aws_iam_policy_document.opensearch.json  
}

data "aws_iam_policy_document" "opensearch" {
  statement {
    actions = [
      "es:*"
    ]

    resources = ["*"]
  }
}

module "opensearch_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.project_name}-role-opensearch"

  role_policy_arns = {
    policy = aws_iam_policy.opensearch.arn
  }

  oidc_providers = {
    cluster-oidc-provider = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:opensearch"
      ]
    }
  }
}

resource "kubernetes_service_account" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.opensearch_irsa.iam_role_arn
    }
  }
}