module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    # eks-pod-identity-agent = {
    #   most_recent = true
    # }
    # aws-ebs-csi-driver = {
    #   most_recent = true
    #   # service_account_role_arn = module.irsa_ebs_csi_driver.iam_role_arn
    # }
    # amazon-cloudwatch-observability = {
    #   most_recent = true
    #   # service_account_role_arn = module.irsa_cloudwatchagent.iam_role_arn
    #   configuration_values = jsonencode({
    #     "containerLogs": { "enabled": false }
    #   })
    # }
  }

  # enable_karpenter = true
  # enable_cert_manager = true
  # enable_metrics_server = true
  # enable_aws_load_balancer_controller = true
  # enable_cluster_autoscaler = true
  # enable_external_secrets = true
  # enable_aws_for_fluentbit = true
  # enable_fargate_fluentbit = true

  # karpenter = {
  #   namespace     = "kube-system"
  #   chart_version = "1.2.1"

  #   values = [
  #     <<-EOT
  #     nodeSelector:
  #       karpenter.sh/controller: 'true'
  #     dnsPolicy: Default
  #     settings:
  #       clusterName: ${module.eks.cluster_name}
  #       clusterEndpoint: ${module.eks.cluster_endpoint}
  #     webhook:
  #       enabled: false
  #     EOT
  #   ]
  # }

  # fargate_fluentbit = {
  #   flb_log_cw = true
  # }
  
  # aws_load_balancer_controller = {
  #   set = [
  #     {
  #       name  = "vpcId"
  #       value = module.vpc.vpc_id
  #     }
  #   ]
  # }

  # aws_for_fluentbit = {  
  #   enable_containerinsights = true
  #   kubelet_monitoring       = true
  
  #   set = [
  #     {
  #       name  = "cloudWatchLogs.autoCreateGroup"
  #       value = true
  #     },
  #     {
  #       name  = "hostNetwork"
  #       value = true
  #     },
  #     {
  #       name  = "dnsPolicy"
  #       value = "ClusterFirstWithHostNet"
  #     },
  #     {
  #       name  = "tolerations[0].operator"
  #       value = "Exists"
  #     }
  #   ]
  # }

}