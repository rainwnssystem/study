locals {
  tgw_name = "${var.project_name}-vpc-tgw"

  # VPCs for which we want TGW attachments
  tgw_target_vpcs = [
    "vpc-02d9a20a8d814595c",  # ingress
    "vpc-0a6b1a609a13a4d58",  # egress
    "vpc-0ab1045fe2fee59fb",  # inspect
    "vpc-0d01a1420789f31a9"   # prod
  ]

  # Corresponding names for each TGW attachment
  # The index here must match the index of the VPC IDs above
  tgw_attachment_names = [
    "${var.project_name}-tgw-attach-ingress",
    "${var.project_name}-tgw-attach-egress",
    "${var.project_name}-tgw-attach-inspect",
    "${var.project_name}-tgw-attach-prod",
  ]

  # Names for TGW route tables
  tgw_route_table_names = [
    "${var.project_name}-tgw-rtb-ingress",
    "${var.project_name}-tgw-rtb-egress",
    "${var.project_name}-tgw-rtb-inspect",
    "${var.project_name}-tgw-rtb-prod",
  ]
}

# -------------------------------------------------------------------
# Data sources to discover VPC details dynamically
# -------------------------------------------------------------------

data "aws_vpc" "target_vpc" {
  for_each = toset(local.tgw_target_vpcs)
  id       = each.value
}

data "aws_subnets" "target_vpc_subnets_private" {
  for_each = data.aws_vpc.target_vpc

  filter {
    name   = "vpc-id"
    values = [each.value.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "target_vpc_subnets_intra" {
  for_each = data.aws_vpc.target_vpc

  filter {
    name   = "vpc-id"
    values = [each.value.id]
  }

  filter {
    name   = "tag:Type"
    values = ["intra"]
  }
}

data "aws_subnets" "target_vpc_subnets_peering" {
  for_each = data.aws_vpc.target_vpc

  filter {
    name   = "vpc-id"
    values = [each.value.id]
  }

  filter {
    name   = "tag:Peer"
    values = ["true"]
  }
}

locals {
  tgw_attachment_subnets = {
    for idx, vpc_id in local.tgw_target_vpcs :
    idx =>

    length(data.aws_subnets.target_vpc_subnets_peering[vpc_id].ids) > 0 ?
    data.aws_subnets.target_vpc_subnets_peering[vpc_id].ids :

    length(data.aws_subnets.target_vpc_subnets_intra[vpc_id].ids) > 0 ?
    data.aws_subnets.target_vpc_subnets_intra[vpc_id].ids :

    data.aws_subnets.target_vpc_subnets_private[vpc_id].ids
  }

  # Turn list of route table names into a map of index => name
  tgw_route_table_names_map = {
    for idx, name in local.tgw_route_table_names :
    idx => name
  }

  tgw_attachments_map = {
    for idx, vpc_id in local.tgw_target_vpcs :
    idx => {
      vpc_id          = vpc_id
      attachment_name = local.tgw_attachment_names[idx]
      # Subnet IDs come from data.aws_subnets
      subnet_ids = local.tgw_attachment_subnets[idx]
      # VPC CIDR from data.aws_vpc
      destination_cidr_block = data.aws_vpc.target_vpc[vpc_id].cidr_block
    }
  }

  # Build a map of VPC attachments dynamically, keyed by VPC ID
  # or by an index if you prefer. Shown here keyed by the actual VPC ID for clarity.
  dynamic_vpc_attachments = {
    for idx, attachment_data in local.tgw_attachments_map :
    idx => {
      vpc_id     = attachment_data.vpc_id
      subnet_ids = attachment_data.subnet_ids

      security_group_referencing_support              = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = attachment_data.destination_cidr_block
        }
      ]

      tags = {
        # Make the Name tag customizable
        Name = attachment_data.attachment_name
      }
    }
  }

  dynamic_vpc_propagations_list = flatten([
    for src_idx, src_attachment_id in module.tgw.ec2_transit_gateway_vpc_attachment_ids : [
      for dst_idx, dst_route_table_id in aws_ec2_transit_gateway_route_table.tgw_route_tables :
      {
        name               = "${src_idx}-${dst_idx}"
        src_attachment_id  = src_attachment_id
        dst_route_table_id = dst_route_table_id.id
      } if src_idx != dst_idx
    ]
  ])

  dynamic_vpc_propagations = {
    for idx, propagation in local.dynamic_vpc_propagations_list :
    propagation.name => propagation
  }
}

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name                                   = local.tgw_name
  transit_gateway_cidr_blocks            = ["10.99.0.0/24"]
  enable_auto_accept_shared_attachments  = false
  enable_multicast_support               = false
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
  enable_sg_referencing_support          = true
  create_tgw_routes                      = false
  enable_dns_support                     = true
  share_tgw                              = false

  # Dynamically built from local.dynamic_vpc_attachments
  vpc_attachments = local.dynamic_vpc_attachments
}

resource "aws_ec2_transit_gateway_route_table" "tgw_route_tables" {
  for_each           = local.tgw_route_table_names_map
  transit_gateway_id = module.tgw.ec2_transit_gateway_id

  tags = {
    Name = each.value
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_tables_association" {
  for_each = local.tgw_route_table_names_map

  transit_gateway_attachment_id  = module.tgw.ec2_transit_gateway_vpc_attachment_ids[tonumber(each.key)]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_tables[each.key].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_tables_propagation" {
  for_each = local.dynamic_vpc_propagations

  transit_gateway_attachment_id  = each.value.src_attachment_id
  transit_gateway_route_table_id = each.value.dst_route_table_id
}
