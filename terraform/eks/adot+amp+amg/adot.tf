resource "aws_eks_addon" "adot" {
  cluster_name = module.eks.cluster_name
  addon_name   = "adot"

  configuration_values = jsonencode({
    collector = {
      prometheusMetrics = {
        exporters = {
          prometheusremotewrite = {
            endpoint = "${module.prometheus.workspace_prometheus_endpoint}api/v1/remote_write"
          }
        }
        pipelines = {
          metrics = {
            amp = {
              enabled = true
            }
            emf = {
              enabled = false
            }
          }
        }
        resources = {
          limits = {
            cpu    = "300m",
            memory = "512Mi"
          }
          requests = {
            cpu    = "300m",
            memory = "512Mi"
          }
        }
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.caller.account_id}:role/${var.project_name}-role-prometheus"
          }
        }
      }
    }
  })
}

# resource "kubernetes_namespace" "adot" {
#   metadata {
#     name = "opentelemetry-operator-system"
#   }
# }