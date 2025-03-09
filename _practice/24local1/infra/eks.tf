module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  # control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    "${var.project_name}-eks-addon-nodegroup" = {
      ami_type       = "BOTTLEROCKET_ARM_64"
      instance_types = ["t4g.small"]
      iam_role_name = "${var.project_name}-eks-addon-nodegroup"

      min_size     = 2
      max_size     = 24
      desired_size = 2

      launch_template_tags = {
        Name = "${var.project_name}-addon-node"
      }
    }

    "${var.project_name}-eks-app-nodegroup" = {
      ami_type       = "BOTTLEROCKET_ARM_64"
      instance_types = ["t4g.small"]
      iam_role_name = "${var.project_name}-eks-app-nodegroup"

      min_size     = 2
      max_size     = 24
      desired_size = 2

      launch_template_tags = {
        Name = "${var.project_name}-skills-app-node"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "app"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  cluster_security_group_additional_rules = {
    bastion = {
      protocol                 = "tcp"
      from_port                = "443"
      to_port                  = "443"
      # source_security_group_id = aws_security_group.bastion.id
      source_node_security_group = false
      cidr_blocks = ["0.0.0.0/0"]
      type                     = "ingress"
    }
  }

  enable_cluster_creator_admin_permissions = true
  access_entries = {
    example = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.bastion.arn

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
}

module "fargate_profile" {
  source = "terraform-aws-modules/eks/aws//modules/fargate-profile"

  name         = "${var.project_name}-eks-app-profile"
  cluster_name = module.eks.cluster_name

  subnet_ids = module.vpc.private_subnets
  selectors = [{
    namespace = "skills"
    labels = {
      fargate = "app"
    }
  }]
}