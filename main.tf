locals {
  default_tags = {
    managed_by = "terraform"
    platform   = "network"
  }
  tags = merge(
    local.default_tags,
    var.tags
  )
  vhub_name_suffix = "${var.location}-${var.environment}-${random_string.this.result}"
  ergw_name_suffix = "${var.solution_name}-${var.location}-${var.environment}-${random_string.this.result}"
}

resource "random_string" "this" {
  length  = 4
  upper   = false
  lower   = false
  special = false
  numeric = true
}

resource "azurerm_virtual_hub" "this" {
  name                                   = var.virtual_hub_name != null ? var.virtual_hub_name : "vhub-${local.vhub_name_suffix}"
  resource_group_name                    = var.resource_group_name
  location                               = var.location
  virtual_wan_id                         = var.virtual_wan_id
  address_prefix                         = var.virtual_hub_address_prefix
  virtual_router_auto_scale_min_capacity = var.virtual_hub_routing_infrastructure_units
  hub_routing_preference                 = var.hub_routing_preference
  tags                                   = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
