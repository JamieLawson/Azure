module "naming" {
  source  = "Azure/avm-utl-naming/azure"
  version = "~> 0.2"

  instance      = var.resource_instance
  unique_length = 0

  naming_template_variables = {
    workload_name = var.workload_name
    environment   = var.environment
    location      = var.location
  }

  naming_templates = {
    name = "$${join(separator, compact([slug, workload_name, environment, location, instance]))}"
  }
}

module "subnet_naming" {
  for_each = var.subnet_address_prefix_lengths

  source  = "Azure/avm-utl-naming/azure"
  version = "~> 0.2"

  instance      = var.resource_instance
  unique_length = 0

  naming_template_variables = {
    subnet_purpose = each.key
    workload_name  = var.workload_name
    environment    = var.environment
    location       = var.location
  }

  naming_templates = {
    name = "$${join(separator, compact([slug, subnet_purpose, workload_name, environment, location, instance]))}"
  }
}

module "network_ip_addresses" {
  source  = "Azure/avm-utl-network-ip-addresses/azurerm"
  version = "~> 0.1.0"

  address_space    = var.virtual_network_address_space
  address_prefixes = var.subnet_address_prefix_lengths

  enable_telemetry = var.enable_telemetry
}

module "landing_zone_subscription" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "~> 0.3.0"

  location = var.location

  subscription_alias_enabled = true
  subscription_alias_name    = "sub-${var.workload_name}-${var.environment}-001"
  subscription_billing_scope = var.subscription_billing_scope
  subscription_display_name  = "sub-${var.workload_name}-${var.environment}-001"
  subscription_workload      = var.subscription_workload
  subscription_tags          = var.tags

  subscription_management_group_association_enabled = var.management_group_id != null
  subscription_management_group_id                  = var.management_group_id

  subscription_register_resource_providers_enabled = true
  subscription_register_resource_providers_and_features = {
    "Microsoft.CognitiveServices" = []
    "Microsoft.Network"           = []
  }

  resource_group_creation_enabled = true
  resource_groups = {
    workload = {
      name     = module.naming.names.resource_group.name
      location = var.location
      tags     = var.tags
    }
  }

  network_security_group_enabled = true
  network_security_groups = {
    for subnet_key in keys(var.subnet_address_prefix_lengths) :
    subnet_key => {
      name               = module.subnet_naming[subnet_key].network_security_group.name
      location           = var.location
      resource_group_key = "workload"
      tags               = var.tags
    }
  }

  virtual_network_enabled = true
  virtual_networks = {
    workload = {
      name               = module.naming.names.virtual_network.name
      location           = var.location
      resource_group_key = "workload"
      address_space      = [var.virtual_network_address_space]
      tags               = var.tags

      subnets = {
        for subnet_key, address_prefix in module.network_ip_addresses.address_prefixes : subnet_key => {
          name             = module.subnet_naming[subnet_key].subnet.name
          address_prefixes = [address_prefix]
          delegations = subnet_key == "default" ? [{
            name = "Microsoft.App-environments"
            service_delegation = {
              name = "Microsoft.App/environments"
            }
          }] : []
          network_security_group = {
            key_reference = subnet_key
          }
        }
      }
    }
  }

  enable_telemetry = var.enable_telemetry
}
