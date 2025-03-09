module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${var.project_name}-backend-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

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

  access_logs = {
    bucket = module.s3_bucket_for_logs.s3_bucket_id
  }

  listeners = {
    http = {
      port            = 80
      protocol        = "HTTP"
      forward = {
        target_group_key = "backend"
      }
    }
  }

  target_groups = {
    backend = {
      name      = "backend"
      create_attachment = false
      protocol         = "HTTP"
      port             = 80
      target_type      = "ip"

      health_check = {
        enabled             = true
        interval            = 5
        path                = "/api/health"
        port                = 8080  # | traffic-port
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 2
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  }
}
