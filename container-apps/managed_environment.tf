module "container_app_environment" {
  source  = "Azure/avm-res-app-managedenvironment/azurerm"
  version = "~> 0.6.0"

  name     = module.naming.names.container_app_environment.name
  location = var.location

  # parent_id takes precedence over resource_group_name and is required here because the
  # resource group lives in the newly vended subscription, not the provider's default one.
  parent_id           = module.landing_zone_subscription.resource_group_resource_ids["workload"]
  resource_group_name = module.naming.names.resource_group.name

  # VNet integration into the app subnet (delegated to Microsoft.App/environments in subscription.tf).
  # Workload profiles environments support subnets as small as /27.
  infrastructure_resource_group = "ME_${module.naming.names.container_app_environment.name}"
  vnet_configuration = {
    infrastructure_subnet_id = module.landing_zone_subscription.virtual_network_subnet_resource_ids["workload"]["app"]
    internal                 = var.container_app_environment_internal
  }
  public_network_access = var.container_app_environment_internal ? "Disabled" : "Enabled"

  workload_profiles = [
    {
      name                  = "Consumption"
      workload_profile_type = "Consumption"
    }
  ]

  zone_redundant   = var.container_app_environment_zone_redundant
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}
