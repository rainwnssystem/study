module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  force_new_deployment = true
  force_delete = true
  deployment_controller = "CODE_DEPLOY"

  name        = "backend"
  cluster_arn = module.ecs.cluster_arn
  requires_compatibilities = ["FARGATE"]

  cpu    = 512
  memory = 1024

  runtime_platform = {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = {
    backend = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = module.ecr[0].repository_url

      health_check = {
        command = ["CMD-SHELL", "curl -f http://localhost:8080/api/health || exit 1"]
      }

      port_mappings = [
        {
          name          = "backend"
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      readonly_root_filesystem = false
      memory_reservation = 1024
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups.backend.arn
      container_name   = "backend"
      container_port   = 8080
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_8080 = {
      type                     = "ingress"
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # ordered_placement_strategy = [
  #   {
  #     field = "memory"
  #     type = "binpack"
  #   }
  # ]

  desired_count = 2
  # autoscaling_max_capacity = 64
  # autoscaling_min_capacity = 2
  # autoscaling_policies = {
  #   cpu = {
  #     policy_type = "TargetTrackingScaling"
  #     target_tracking_scaling_policy_configuration = {
  #       predefined_metric_specification = {
  #         predefined_metric_type = "ECSServiceAverageCPUUtilization"
  #       }
  #       scale_in_cooldown = 60
  #       scale_out_cooldown = 0
  #       target_value=75
  #     }
  #   },
  #   memory = {
  #     policy_type = "TargetTrackingScaling"
  #     target_tracking_scaling_policy_configuration = {
  #       predefined_metric_specification = {
  #         predefined_metric_type = "ECSServiceAverageMemoryUtilization"
  #       }
  #       scale_in_cooldown = 60
  #       scale_out_cooldown = 0
  #       target_value = 75
  #     }
  #   }
  # }
}
