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

# module "external_secrets" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                                          = "${var.project_name}-role-externalsecrets"
#   attach_external_secrets_policy                     = true
#   external_secrets_ssm_parameter_arns                = ["arn:aws:ssm:*:*:parameter/*"]
#   external_secrets_secrets_manager_arns              = ["arn:aws:secretsmanager:*:*:secret:*"]
#   external_secrets_kms_key_arns                      = ["arn:aws:kms:*:*:key/*"]
#   external_secrets_secrets_manager_create_permission = false

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["skills:kubernetes-external-secrets"]
#     }
#   }

# }

resource "aws_iam_policy" "elasticache" {
  name = "${var.project_name}-policy-elasticache"
  policy = data.aws_iam_policy_document.elasticache.json
}

data "aws_iam_policy_document" "elasticache" {
  statement {
    actions = [
      "elasticache:CreateServerlessCache",
      "elasticache:CreateCacheCluster",
      "elasticache:DescribeServerlessCaches",
      "elasticache:DescribeReplicationGroups",
      "elasticache:DescribeCacheClusters",
      "elasticache:ModifyServerlessCache",
      "elasticache:ModifyReplicationGroup",
      "elasticache:ModifyCacheCluster"
    ]

    resources = ["*"]
  }
}

module "irsa-elasticache" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.project_name}-role-elasticache"
  role_policy_arns = {
    policy = aws_iam_policy.elasticache.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["skills:elasticache"]
    }
  }
}

resource "kubernetes_service_account" "elasticache" {
  metadata {
    name      = "elasticache"
    namespace = "skills"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa-elasticache.iam_role_arn
    }
  }
}

resource "aws_iam_policy" "secretsmanager" {
  name   = "${var.project_name}-policy-secretsmanager"
  policy = data.aws_iam_policy_document.secretsmanager.json
}

data "aws_iam_policy_document" "secretsmanager" {
  statement {
    actions = [
      "secretsmanager:*"
    ]

    resources = ["*"]
  }
}

module "irsa-secretsmanager" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.project_name}-role-secretsmanager"
  role_policy_arns = {
    policy = aws_iam_policy.secretsmanager.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["skills:secretsmanager"]
    }
  }
}

resource "kubernetes_service_account" "secretsmanager" {
  metadata {
    name      = "secretsmanager"
    namespace = "skills"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa-secretsmanager.iam_role_arn
    }
  }
}

resource "aws_iam_policy" "fluentbit" {
  name   = "${var.project_name}-policy-fluentbit"
  policy = data.aws_iam_policy_document.fluentbit.json
}

data "aws_iam_policy_document" "fluentbit" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

module "irsa-fluentbit" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.project_name}-role-fluentbit"

  role_policy_arns = {
    policy = aws_iam_policy.fluentbit.arn
  }

  oidc_providers = {
    cluster-oidc-provider = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:fluentbit"
      ]
    }
  }
}

resource "kubernetes_service_account" "fluentbit" {
  metadata {
    name      = "fluentbit"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa-fluentbit.iam_role_arn
    }
  }
}

# resource "aws_iam_policy" "fluentd" {
#   name   = "${var.project_name}-policy-fluentd"
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

# module "irsa-fluentd" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "${var.project_name}-role-fluentd"

#   role_policy_arns = {
#     policy = aws_iam_policy.fluentd.arn
#   }

#   oidc_providers = {
#     cluster-oidc-provider = {
#       provider_arn = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         # "logging:fluentd",
#         "${var.project_name}:fluentd"
#       ]
#     }
#   }
# }

# resource "kubernetes_service_account" "fluentd" {
#   metadata {
#     name = "fluentd"
#     namespace = "logging"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.irsa-fluentbit.iam_role_arn
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

# module "irsa2" {
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
