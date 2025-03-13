module "aws_cloudwatch_observability_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "aws-cloudwatch-observability"

  attach_aws_cloudwatch_observability_policy = true

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "fluentd"
  }
}