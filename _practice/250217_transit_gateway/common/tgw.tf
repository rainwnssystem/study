module "tgw" {
  source = "terraform-aws-modules/transit-gateway/aws"

  name            = "${var.project_name}-tgw"
  amazon_side_asn = 64532

  transit_gateway_cidr_blocks = ["0.0.0.0/0"]

  # When "true" there is no need for RAM resources if using multiple AWS accounts
  enable_auto_accept_shared_attachments = true

  # When "true", SG referencing support is enabled at the Transit Gateway level
  enable_sg_referencing_support = true

  # When "true", allows service discovery through IGMP
  enable_multicast_support = false

  vpc_attachments = {
    management = {
      vpc_id                             = "vpc-0b24b3fcfb2f3e5e9"
      subnet_ids                         = ["subnet-019a07028e7291c17", "subnet-088ac458d80f0ca8c"]
      security_group_referencing_support = true
      dns_support                        = true
      ipv6_support                       = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "10.1.0.0/16"
        }
      ]
    },
    prod = {
      vpc_id     = "vpc-048cd5be403a0599a"
      subnet_ids = ["subnet-00c452065d16233f9", "subnet-0124639e13dee8113"]

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "10.0.0.0/16"
        }
      ]
    }
  }

  # ram_allow_external_principals = true
  # ram_principals                = [307990089504]
}
