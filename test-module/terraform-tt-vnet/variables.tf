##########################################################
## Variables
##########################################################

## Global Settings Declarations

variable "global_settings" {
  description = ""
  type = object({
    app_shortname    = string
    location         = string
    loc              = string
    environment      = string
  })
}

variable "tags" {
  type        = map(string)
  description = "(optional) describe your variable"
}

## Network Variable Declarations

variable "network" {
  description = "(optional) describe your variable"
  type = object({
    address_spaces = list(string)
    dns_server = optional(list(string))
  })
}

## Subnet Variable Declarations

variable "subnets" {
  description = ""
  type = map(object({
    name             = string
    address_prefixes = list(string)
    subnet_delegation = optional(object({
      name   = string
      service_delegation = optional(object({
        name   = string
        actions = list(string)
      }))
    }))
  }))
}

## Public IP Address Declarations

variable "public_ip_addresses" {
  type = map(object({
    name              = string
    allocation_method = optional(string)
  }))
  default = {}

  description = "(optional) describe your variable"
}

## Route Tables Declarations

variable "route_tables" {
  type = map(object({
    routes = map(object({
      name           = string
      address_prefix = string
      next_hop_type = string
    }))
    subnet_name = string,
    rt_name     = string
  }))
  description = "(optional) describe your variable"
  default     = null
}

## Virtual Network Peering Declarations

variable "remote_vnet_ids" {
  type = list(object({
    app_name = string
    id = string
  }))
  description = "(optional) describe your variable"
  default = []
}

