## Network Resource Group Output

output "net_rg_id" {
  value = azurerm_resource_group.vnet_resource_group.id
}

output "net_rg_name" {
  value = azurerm_resource_group.vnet_resource_group.name
}

## Virtual Network Resource Output

output "vnet_id" {
  value = azurerm_virtual_network.default_transit_network.id
}

output "vnet_name" {
  value = azurerm_virtual_network.default_transit_network.name
}

## Subnet Resource Output

output "subnet_id" {
  value = tomap({
    for id, details in azurerm_subnet.transit_subnets : id => details.id
  })
}

output "subnet_name" {
  value = tomap({
    for name, details in azurerm_subnet.transit_subnets : name => details.name
  })
}

## Public IP Resource Output

output "pip_id" {
  value = tomap({
    for id, details in azurerm_subnet.transit_subnets : id => details.id
  })
}

output "pip_name" {
  value = tomap({
    for name, details in azurerm_subnet.transit_subnets : name => details.name
  })
}

## Route Table Resource Output

output "rt_id" {
  value = tomap({
    for id, details in azurerm_subnet.transit_subnets : id => details.id
  })
}
