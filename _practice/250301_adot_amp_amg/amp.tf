module "prometheus" {
  source = "terraform-aws-modules/managed-service-prometheus/aws"

  workspace_alias = "${var.project_name}-amp"
  logging_configuration = {
    log_group_arn = "${aws_cloudwatch_log_group.amp.arn}:*"
  }
}

resource "aws_cloudwatch_log_group" "amp" {
  name = "amp-logs"
}

# resource "kubernetes_namespace" "prometheus" {
#   metadata {
#     name = "prometheus"
#   }
# }