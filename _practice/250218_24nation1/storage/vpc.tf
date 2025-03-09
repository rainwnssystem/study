module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-storage-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b"]
  # public_subnets  = ["192.168.0.0/24", "172.16.1.0/24"]
  # private_subnets = ["192.168.2.0/24", "172.16.3.0/24"]
  intra_subnets = ["192.168.0.0/24", "192.168.1.0/24"]

  # public_subnet_tags = {
  #   "kubernetes.io/role/elb" = "1"
  # }

  # private_subnet_tags = {
  #   "karpenter.sh/discovery" = "${var.project_name}-cluster"
  #   "kubernetes.io/role/internal-elb" = "1"
  # }

  # public_subnet_names = ["${var.project_name}-prod-load-sn-a", "${var.project_name}-prod-load-sn-b"]
  # private_subnet_names = ["${var.project_name}-prod-app-a", "${var.project_name}-prod-app-b"]
  intra_subnet_names = ["${var.project_name}-storage-db-sn-a", "${var.project_name}-storage-db-sn-b"]

  # enable_flow_log = true
  # create_flow_log_cloudwatch_iam_role = true
  # create_flow_log_cloudwatch_log_group = true

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false
}
