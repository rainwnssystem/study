module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = "${var.project_name}-eks-cluster"
  cluster_version = "1.32"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  node_security_group_tags = {
    "karpenter.sh/discovery" = "${var.project_name}-eks-cluster"
  }

  eks_managed_node_groups = {
    addon = {
      name = "${var.project_name}-eks-addon-nodegroup"
      ami_type       = "BOTTLEROCKET_x86_64"  # <-- BOTTLEROCKET_ARM_64 or BOTTLEROCKET_x86_64
      instance_types = ["t3.medium"]
      iam_role_name  = "${var.project_name}-eks-addon-nodegroup"
      use_name_prefix = false

      min_size     = 2
      max_size     = 24
      desired_size = 2

      launch_template_tags = {
        Name = "${var.project_name}-addon-node"
      }

      # metadata_options = {
      #   http_endpoint               = "enabled"
      #   http_put_response_hop_limit = 1
      #   http_tokens                 = "required"
      # }

      labels = {
        "karpenter.sh/controller" : "true"
      }

    }

    app = {
      name = "${var.project_name}-eks-app-nodegroup"
      ami_type       = "BOTTLEROCKET_x86_64"  # <-- BOTTLEROCKET_ARM_64 or BOTTLEROCKET_x86_64
      instance_types = ["t3.small"]
      iam_role_name  = "${var.project_name}-eks-app-nodegroup"
      use_name_prefix = false

      min_size     = 2
      max_size     = 24
      desired_size = 2

      launch_template_tags = {
        Name = "${var.project_name}-app-node"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "app"
          effect = "NO_SCHEDULE"
        }
      }

      # metadata_options = {  # affect for IMDSv2
      #   http_endpoint               = "enabled"
      #   http_put_response_hop_limit = 1
      #   http_tokens                 = "required"
      # }

      labels = {
        dedicated = "app"
        "karpenter.sh/controller" : "true"
      }
    }
  }

  cluster_security_group_additional_rules = {
    bastion = {
      protocol  = "tcp"
      from_port = "443"
      to_port   = "443"
      # source_security_group_id = aws_security_group.bastion.id
      source_node_security_group = false
      cidr_blocks                = ["0.0.0.0/0"]
      type                       = "ingress"
    }
  }

  node_security_group_additional_rules = {
    lattice = {
      protocol                      = "tcp"
      from_port                     = "8080" # application port
      to_port                       = "8080" # 
      source_cluster_security_group = false
      cidr_blocks                   = ["0.0.0.0/0"] # lattice ipv4/6 prefix id
      type                          = "ingress"
    }

    istio = {
      protocol                      = "tcp"
      from_port                     = "15017"
      to_port                       = "15017"
      source_cluster_security_group = true
      type                          = "ingress"
    }
  }

  enable_cluster_creator_admin_permissions = true
  access_entries = {
    example = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::658986583341:role/wsc2024-bastion-role"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    "karpenter.sh/discovery" = "${var.project_name}-eks-cluster"
  }
}

# module "fargate_profile" {
#   source = "terraform-aws-modules/eks/aws//modules/fargate-profile"

#   name         = "${var.project_name}-eks-app-profile"
#   cluster_name = module.eks.cluster_name

#   subnet_ids = module.vpc.private_subnets
#   selectors = [{
#     namespace = "skills"
#     labels = {
#       fargate = "app"
#     }
#   }]
# }

# required for karpenter
# resource "aws_eks_access_entry" "karpenter" {
#   principal_arn = module.eks_blueprints_addons.karpenter.node_iam_role_arn
#   cluster_name = module.eks.cluster_name
#   type = "EC2_LINUX"
# }

# deprecated: aws_auth
# resource "kubernetes_config_map_v1_data" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = yamlencode([
#       {
#         "rolearn" : "${module.eks.eks_managed_node_groups["${var.project_name}-eks-addon-nodegroup"].iam_role_arn}",

#         "username" : "system:node{{EC2PrivateDNSName}}",
#         "groups:" : [
#           "system:bootstrappers",
#           "system:nodes"
#         ]
#       },
#       {
#         "rolearn" : "${module.eks.eks_managed_node_groups["${var.project_name}-eks-app-nodegroup"].iam_role_arn}",
#         "username" : "system:node{{EC2PrivateDNSName}}",
#         "groups:" : [
#           "system:bootstrappers",
#           "system:nodes"
#         ]
#       },
#       {
#         "rolearn" : "${module.karpenter.iam_role_arn}",
#         "username" : "system:node{{EC2PrivateDNSName}}",
#         "groups:" : [
#           "system:bootstrappers",
#           "system:nodes"
#         ]
#       }
#     ])
#   }

#   force = true
# }
