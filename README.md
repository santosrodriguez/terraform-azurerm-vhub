# Azure Virtual Hub

## Overview

This Terraform module creates an Azure Virtual Hub in an existing Azure Virtual WAN.

By default, the module generates the Virtual Hub name using the deployment location, environment, and a random suffix of four numeric digits. Set `virtual_hub_name` to use an explicit name, including the name of an existing Virtual Hub being imported.

## What This Module Deploys

- `azurerm_virtual_hub`
- `random_string`
- Default tags merged with user-provided tags

## Requirements

| Requirement | Details |
|---|---|
| Required Terraform version | Not explicitly defined. |
| Required providers | `hashicorp/azurerm`, `hashicorp/random` |
| Required provider versions | Not explicitly defined. |
| Azure prerequisites | An existing resource group and an existing Azure Virtual WAN are required. |
| Required permissions or role assumptions | Not explicitly defined. The caller must have permissions to create Virtual Hub resources in the target resource group. |

## Required Parameters

| Name | Type | Description |
|---|---|---|
| `virtual_hub_address_prefix` | `string` | Address prefix for the Azure Virtual WAN Hub. Must be a valid CIDR block. |
| `resource_group_name` | `string` | Name of the existing resource group where resources will be deployed. |
| `location` | `string` | Azure region for resource deployment. Only supported US regions are allowed. |
| `virtual_wan_id` | `string` | Resource ID of the existing Azure Virtual WAN to associate with the Virtual Hub. |
| `environment` | `string` | Environment name. Valid values are `prd` and `nonprd`. |
| `solution_name` | `string` | Retained required input. It currently has no effect on the deployed Virtual Hub or its name. |

## Optional Parameters

| Name | Type | Default | Description |
|---|---|---|---|
| `virtual_hub_name` | `string` | `null` | Explicit Virtual Hub name. Omit or set to `null` to preserve the generated naming pattern. |
| `virtual_hub_routing_infrastructure_units` | `number` | `2` | Minimum Virtual Hub routing infrastructure units. Must be a whole number between `2` and `31`. |
| `hub_routing_preference` | `string` | `"ASPath"` | Virtual Hub routing preference. Must be `ASPath` or `ExpressRoute`. |
| `tags` | `map(string)` | `{}` | Tags to apply to all resources. These are merged with the module default tags. |

## Default Parameter Values

| Parameter | Default Value | Purpose |
|---|---|---|
| `virtual_hub_name` | `null` | Uses the generated Virtual Hub name unless an explicit name is provided. |
| `virtual_hub_routing_infrastructure_units` | `2` | Sets the minimum Virtual Hub routing infrastructure capacity. |
| `hub_routing_preference` | `"ASPath"` | Sets the Virtual Hub routing preference. |
| `tags` | `{}` | Allows optional user-defined tags to be merged with module default tags. |

## Minimum Required Example

The examples assume the consuming root configuration is in this repository's root directory, alongside `vhub`. Adjust `source` to the module location or published source used by your deployment.

```hcl
module "virtual_hub_express_route_gateway" {
  source = "./vhub"

  resource_group_name        = "rg-network-nonprd-eastus"
  location                   = "eastus"
  virtual_wan_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-nonprd-eastus/providers/Microsoft.Network/virtualWans/vwan-eastus-nonprd"
  virtual_hub_address_prefix = "10.10.0.0/23"
  environment                = "nonprd"
  solution_name              = "network"
}
```

## Full Example

```hcl
module "virtual_hub_express_route_gateway" {
  source = "./vhub"

  virtual_hub_name                         = null
  resource_group_name                      = "rg-network-prd-eastus"
  location                                 = "eastus"
  virtual_wan_id                           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prd-eastus/providers/Microsoft.Network/virtualWans/vwan-eastus-prd"
  virtual_hub_address_prefix               = "10.20.0.0/23"
  virtual_hub_routing_infrastructure_units = 2
  hub_routing_preference                   = "ASPath"
  environment                              = "prd"
  solution_name                            = "network"

  tags = {
    environment = "prd"
    workload    = "connectivity"
    owner       = "platform"
  }
}
```

## Import an Existing Virtual Hub

With Terraform 1.5 or later, add an import block to the consuming deployment's root configuration alongside its module call. Use the deployment's existing Azure provider configuration, backend, and intended workspace. The module version used by the deployment must support the `virtual_hub_name` input.

The following values are examples. Replace the subscription ID, resource IDs, name, and settings with the existing Virtual Hub's actual values. `virtual_hub_name` must match Azure exactly. Match the resource group, location, Virtual WAN ID, hub address prefix, routing capacity, and routing preference as well. `environment` and `solution_name` remain required inputs even when an explicit hub name is supplied.

```hcl
terraform {
  required_version = ">= 1.5.0"
}

module "virtual_hub_express_route_gateway" {
  source = "./vhub"

  virtual_hub_name                         = "existing-hub"
  resource_group_name                      = "rg-network-prd-eastus"
  location                                 = "eastus"
  virtual_wan_id                           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prd-eastus/providers/Microsoft.Network/virtualWans/existing-vwan"
  virtual_hub_address_prefix               = "10.20.0.0/23"
  virtual_hub_routing_infrastructure_units = 2
  hub_routing_preference                   = "ExpressRoute"
  environment                              = "prd"
  solution_name                            = "network"
}

import {
  to = module.virtual_hub_express_route_gateway.azurerm_virtual_hub.this
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prd-eastus/providers/Microsoft.Network/virtualHubs/existing-hub"
}
```

Run the normal deployment workflow, or run these commands from the consuming root directory:

```shell
terraform init
terraform plan -out=import.tfplan
```

Review the plan before applying. It should import the existing Virtual Hub without unexpected Azure updates, replacements, or deletions. Adjust the configuration to match the existing hub if the plan proposes those changes. The module retains `random_string.this` as a state resource even when an explicit hub name is supplied, so the first plan may also create that random value; this does not create or rename an Azure resource.

After reviewing the plan:

```shell
terraform apply import.tfplan
```

The apply records the hub import in the selected Terraform state. The import block may remain in the root configuration; subsequent runs do not repeat an import already recorded at the same resource address. The module publication workflow does not perform this import: it runs through the consuming deployment's plan/apply workflow. Importing the hub does not import the existing resource group, Virtual WAN, ExpressRoute gateways, circuits, connections, or other routing resources.

## Outputs

| Name | Description |
|---|---|
| `virtual_hub_id` | Resource ID of the created Azure Virtual Hub. |

## Best Practices

- Use consistent values for `environment` and `location` because they are used in resource naming.
- Use `prd` and `nonprd` consistently across environments to match the module validation rules.
- Use separate state files or workspaces for production and non-production deployments.
- Store Terraform state in a remote backend such as Azure Storage for team-based deployments.
- Provide governance tags through `tags` for ownership, workload, cost management, and environment tracking.
- Ensure the `virtual_hub_address_prefix` does not overlap with existing Virtual Hub, virtual network, or on-premises address spaces.
- Confirm that the target Azure Virtual WAN exists before using this module.
- Assign least-privilege permissions to the identity running Terraform.

## Notes

- The module creates a `random_string` resource with:
  - `length = 4`
  - `upper = false`
  - `lower = false`
  - `special = false`
  - `numeric = true`
- The generated random string contains four numeric digits.
- When `virtual_hub_name` is omitted or `null`, the Virtual Hub name is built using the following pattern:

  ```hcl
  vhub-${var.location}-${var.environment}-${random_string.this.result}
  ```

- The module defines the following default tags:

  ```hcl
  {
    managed_by = "terraform"
    platform   = "network"
  }
  ```

- User-provided `tags` are merged with the default tags using `merge(local.default_tags, var.tags)`.
- If a user-provided tag uses the same key as a default tag, the user-provided value takes precedence.
- `azurerm_virtual_hub.this` ignores changes to `tags` through lifecycle configuration.
- The `location` variable is validated against the following allowed values:
  - `eastus`
  - `eastus2`
  - `centralus`
  - `northcentralus`
  - `southcentralus`
  - `westcentralus`
  - `westus`
  - `westus2`
  - `westus3`
- The `environment` variable only supports:
  - `prd`
  - `nonprd`
