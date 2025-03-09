module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  intra_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "karpenter.sh/discovery" = "${var.project_name}-cluster"
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_names = ["${var.project_name}-public-a", "${var.project_name}-public-b", "${var.project_name}-public-c"]
  private_subnet_names = ["${var.project_name}-private-a", "${var.project_name}-private-b", "${var.project_name}-private-c"]
  intra_subnet_names = ["${var.project_name}-data-a", "${var.project_name}-data-b", "${var.project_name}-data-c"]

  # enable_flow_log = true
  # create_flow_log_cloudwatch_iam_role = true
  # create_flow_log_cloudwatch_log_group = true

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = true  
}
