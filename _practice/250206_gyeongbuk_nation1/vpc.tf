module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b"]
  public_subnets  = ["10.1.2.0/24", "10.1.3.0/24"]
  private_subnets = ["10.1.0.0/24", "10.1.1.0/24"]
  intra_subnets = ["10.1.4.0/24", "10.1.5.0/24"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "karpenter.sh/discovery" = "${var.project_name}-eks-cluster"
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_names = ["${var.project_name}-public-a", "${var.project_name}-public-b"]
  private_subnet_names = ["${var.project_name}-app-a", "${var.project_name}-app-b"]
  intra_subnet_names = ["${var.project_name}-data-a", "${var.project_name}-data-b"]

  # enable_flow_log = true
  # create_flow_log_cloudwatch_iam_role = true
  # create_flow_log_cloudwatch_log_group = true

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = true  
}
