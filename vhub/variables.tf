
variable "virtual_hub_name" {
  description = "Optional explicit name for the Virtual Hub. When null, the module generates a name."
  type        = string
  default     = null
}
 

variable "virtual_hub_address_prefix" {
  description = "Address prefix for the Azure Virtual WAN Hub."
  type        = string

  validation {
    condition     = can(cidrhost(var.virtual_hub_address_prefix, 0))
    error_message = "virtual_hub_address_prefix must be a valid CIDR block."
  }
}

variable "virtual_hub_routing_infrastructure_units" {
  description = "Minimum vHub routing infrastructure units. Default Azure value is 2."
  type        = number
  default     = 2
  validation {
    condition = (
      var.virtual_hub_routing_infrastructure_units >= 2 &&
      var.virtual_hub_routing_infrastructure_units <= 31 &&
      floor(var.virtual_hub_routing_infrastructure_units) == var.virtual_hub_routing_infrastructure_units
    )

    error_message = "virtual_hub_routing_infrastructure_units must be a whole number between 2 and 31."
  }
}

 

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment. Only US regions are allowed."

  validation {
    condition = contains([
      "eastus",
      "eastus2",
      "centralus",
      "northcentralus",
      "southcentralus",
      "westcentralus",
      "westus",
      "westus2",
      "westus3"
    ], lower(var.location))

    error_message = "Location must be a valid Azure US region: eastus, eastus2, centralus, northcentralus, southcentralus, westcentralus, westus, westus2, or westus3."
  }
}

variable "virtual_wan_id" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition = contains(
      ["prd", "nonprd"], var.environment
    )
    error_message = "Error: Valid environments are prd and nonprd"
  }
}

variable "solution_name" {
  type = string
}
variable "hub_routing_preference" {
  type        = string
  description = "The routing preference for the Virtual Hub. Valid values are 'ASPath' or 'ExpressRoute'."
  default     = "ASPath"

  validation {
    condition     = contains(["ASPath", "ExpressRoute"], var.hub_routing_preference)
    error_message = "hub_routing_preference must be either 'ASPath' or 'ExpressRoute'."
  }
}
