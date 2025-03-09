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
    ma = {
      vpc_id                             = "vpc-049bc5c68dd5a5d1c"
      subnet_ids                         = ["subnet-0c76584f8a2a3ba58", "subnet-06bbcf220c53d685c"]
      security_group_referencing_support = true
      dns_support                        = true
      ipv6_support                       = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          # destination_cidr_block = "172.16.0.0/16"
          destination_cidr_block = "10.0.0.0/16"
        },
        # {
        #   destination_cidr_block = "192.168.0.0/16"
        # }
      ]
    },
    prod = {
      vpc_id     = "vpc-04b72598cfc820e1a"
      subnet_ids = ["subnet-0e43feceb1b630041", "subnet-0b3a9f4a3b1da3e51"]

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          # destination_cidr_block = "10.0.0.0/16"
          destination_cidr_block = "172.16.0.0/16"
        },
        # {
        #   destination_cidr_block = "192.168.0.0/16"
        # }
      ]
    },
    storage = {
      vpc_id     = "vpc-0417c70e2f51bd812"
      subnet_ids = ["subnet-09c877f4f00562ed1", "subnet-0d3df76d7bbbd087b"]

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          # destination_cidr_block = "10.0.0.0/16"
          destination_cidr_block = "192.168.0.0/16"
        },
        # {
        #   destination_cidr_block = "172.16.0.0/16"
        # }
      ]
    }
  }

  ram_allow_external_principals = true  # required for resource share
  ram_principals                = [658986583341]
}
