## Forest Services Networking Deployment Module v0.0.1
## Author: Stephen Barbour

## Scope: Azure Networking

##Local Variables

locals {
  tags      = var.tags
  purpose   = "net"
  shortname = var.global_settings.app_shortname
  location  = var.global_settings.location
  loc = var.global_settings.loc
  env       = var.global_settings.environment

  vnet_tags = merge(var.tags, {
    resource_category = "Virtual Networking"
    Deployment_Method = "Terraform"
    Resource_Type = "Virtual Network"
  })
  pip_tags = merge(var.tags, {
    resource_category = "Virtual Networking"
    Deployment_Method = "Terraform"
    Resource_Type = "Public Ip Address"
  })

  rt_tags = merge(var.tags, {
    resource_category = "Virtual Networking"
    Deployment_Method = "Terraform"
    Resource_Type = "Route Table"
  })
}

## Networking Resource Group

resource "azurerm_resource_group" "vnet_resource_group" {
  name     = "fs-${local.shortname}-${local.purpose}-${local.loc}-${local.env}-rg"
  location = local.location
  tags     = local.tags
}

# Virtual Networking Resource
resource "azurerm_virtual_network" "default_transit_network" {
  name                = "fs-${local.shortname}-${local.loc}-${local.env}-network"
  resource_group_name = azurerm_resource_group.vnet_resource_group.name
  location            = azurerm_resource_group.vnet_resource_group.location
  address_space       = var.network.address_spaces
  dns_servers         = var.network.dns_server
  tags                = local.vnet_tags
}

# Subnet Resources
resource "azurerm_subnet" "transit_subnets" {
  for_each = var.subnets

  name                      = each.value.name
  resource_group_name       = azurerm_resource_group.vnet_resource_group.name
  virtual_network_name = azurerm_virtual_network.default_transit_network.name
  address_prefixes          = each.value.address_prefixes
    dynamic delegation {
      for_each = each.value.delegation

      content {
        name = each.value.name

        dynamic service_delegation {
          for_each = each.value.service_delegation

          content {
            name = each.value.name
            actions = each.value.actions
          }
        }
      }
    }
}

# Public IP Address Resources
resource "azurerm_public_ip" "public_addresses" {
  for_each            = var.public_ip_addresses
  name                = each.value.name
  resource_group_name = azurerm_resource_group.vnet_resource_group.name
  location            = azurerm_resource_group.vnet_resource_group.location
  allocation_method   = each.value.allocation_method

  tags = local.pip_tags
}

# Route Table Resources
resource "azurerm_route_table" "transit_route_table" {
  for_each = var.route_tables
  name     = "fs-${local.shortname}-${local.loc}-${local.env}-rt"
  resource_group_name = azurerm_resource_group.vnet_resource_group.name
  location            = azurerm_resource_group.vnet_resource_group.location


  dynamic "route" {
    for_each = each.value.routes

    content {
      name           = each.value.name
      address_prefix = each.value.address_prefix
      next_hop_type = each.value.next_hop_type
    }
  }

  tags = local.rt_tags
}

# Route Table Association
resource "azurerm_subnet_route_table_association" "route_table_association" {
  for_each = var.route_tables

  subnet_id      = azurerm_subnet.transit_subnets[each.value.subnet_name].id
  route_table_id = azurerm_route_table.transit_route_table[each.value.rt_name].id

  depends_on = [
    azurerm_route_table.transit_route_table,
    azurerm_subnet.transit_subnets,
  ]

}

resource "azurerm_virtual_network_peering" "transit_vnet_peering" {
    for_each = var.remote_vnet_ids

    name = "fs-${local.shortname}-${each.value.app_name}-vnetpeer"
    resource_group_name = azurerm_resource_group.vnet_resource_group.name
    virtual_network_name = azurerm_virtual_network.default_transit_network.name
    remote_virtual_network_id = each.value.id
}