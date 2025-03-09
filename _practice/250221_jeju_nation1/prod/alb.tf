module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${var.project_name}-ingress-lb"
  vpc_id  = "vpc-04176c3cf2d4fd42a"
  subnets = ["subnet-097623ec4c7ea797c", "subnet-06d4e6f2d5717465b"]

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # listeners = {
  #   http = {
  #     port            = 80
  #     protocol        = "HTTP"
  #     forward = {
  #       target_group_key = "prod"
  #     }
  #   }
  # }

  # target_groups = {
  #   prod = {
  #     name      = "${var.project_name}-prod"
  #     create_attachment = false
  #     protocol         = "HTTP"
  #     port             = 80
  #     target_type      = "ip"

  #     health_check = {
  #       enabled             = false
  #       interval            = 5
  #       path                = "/healthcheck"
  #       port                = 80
  #       healthy_threshold   = 2
  #       unhealthy_threshold = 2
  #       timeout             = 2
  #       protocol            = "HTTP"
  #       matcher             = "200-399"
  #     }
  #   }
  # }
}
