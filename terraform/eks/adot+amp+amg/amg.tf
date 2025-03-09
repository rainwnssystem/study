module "managed_grafana" {
  source = "terraform-aws-modules/managed-service-grafana/aws"

  # Workspace
  name                      = "${var.project_name}-grafana"
  associate_license         = false
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]
  grafana_version           = "10.4"

  configuration = jsonencode({
    unifiedAlerting = {
      enabled = false
    },
    plugins = {
      pluginAdminEnabled = false
    }
  })

  # vpc configuration
  vpc_configuration = {
    subnet_ids = module.vpc.public_subnets
  }
  security_group_rules = {
    egress_postgresql = {
      description = "Allow egress to PostgreSQL"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  # Workspace API keys
  workspace_api_keys = {
    admin = {
      key_name        = "admin"
      key_role        = "ADMIN"
      seconds_to_live = 3600
    }
  }

  # Workspace service accounts
  workspace_service_accounts = {
    admin = {
      grafana_role = "ADMIN"
    }
  }

  workspace_service_account_tokens = {
    admin = {
      service_account_key = "admin"
      seconds_to_live     = 3600
    }
  }

  # Workspace IAM role
  create_iam_role                = true
  iam_role_name                  = "${var.project_name}-amg-role"
  use_iam_role_name_prefix       = true
  iam_role_path                  = "/grafana/"
  iam_role_force_detach_policies = true
  iam_role_max_session_duration  = 7200
  iam_role_tags                  = { role = true }

  # # Workspace SAML configuration
  # saml_admin_role_values  = ["admin"]
  # saml_editor_role_values = ["editor"]
  # saml_email_assertion    = "mail"
  # saml_groups_assertion   = "groups"
  # saml_login_assertion    = "mail"
  # saml_name_assertion     = "displayName"
  # saml_org_assertion      = "org"
  # saml_role_assertion     = "role"
  # saml_idp_metadata_url   = "https://my_idp_metadata.url"

  # Role associations
  # Ref: https://github.com/aws/aws-sdk/issues/25
  # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/18812
  # WARNING: https://github.com/hashicorp/terraform-provider-aws/issues/24166
  # role_associations = {
  #   "ADMIN" = {
  #     "group_ids" = ["1111111111-abcdefgh-1234-5678-abcd-999999999999"]
  #   }
  #   "EDITOR" = {
  #     "user_ids" = ["2222222222-abcdefgh-1234-5678-abcd-999999999999"]
  #   }
  # }

  # tags = local.tags
}
