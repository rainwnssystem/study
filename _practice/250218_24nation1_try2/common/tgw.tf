module "tgw" {
  source = "terraform-aws-modules/transit-gateway/aws"

  name            = "${var.project_name}-vpc-tgw"
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
      vpc_id                             = "vpc-05662aeb7bec8485e"
      subnet_ids                         = ["subnet-0d46913aa96b32f5c", "subnet-0d313fe54e55a0f43"]
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
      vpc_id     = "vpc-09c3825a4b554d296"
      subnet_ids = ["subnet-06dbe5de18910d888", "subnet-093bb17d414e51d20"]

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "172.16.0.0/16"
        }
      ]
    },
    storage = {
      vpc_id     = "vpc-01f74ddc50b808e1f"
      subnet_ids = ["subnet-0b9897d1d4b0186a6", "subnet-0020ac66252109386"]

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "192.168.0.0/16"
        }
      ]
    }
  }

  # ram_allow_external_principals = true
  # ram_principals                = [658986583341]
}
