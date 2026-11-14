module "foundry" {
  source  = "Azure/avm-res-cognitiveservices-account/azurerm"
  version = "~> 0.11.1"

  kind      = "AIServices"
  location  = var.location
  name      = module.naming.names.account_ai_services.name
  parent_id = module.landing_zone_subscription.resource_group_resource_ids["workload"]
  sku_name  = var.foundry_sku_name

  allow_project_management = true
  associated_projects      = [module.naming.names.account_project.name]
  custom_subdomain_name    = module.naming.names.account_ai_services.name
  default_project          = module.naming.names.account_project.name
  enable_telemetry         = var.enable_telemetry
  cognitive_deployments = {
    mistral_small_2503 = {
      name = "mistral-small-2503"
      model = {
        format  = "Mistral AI"
        name    = "mistral-small-2503"
        version = "1"
      }
      scale = {
        capacity = var.mistral_small_2503_capacity
        type     = "GlobalStandard"
      }
    }
  }
  managed_identities = {
    system_assigned = true
  }
  network_injections = {
    microsoft_managed_network_enabled = false
    scenario                          = "agent"
    subnet_id                         = module.landing_zone_subscription.virtual_network_subnet_resource_ids["workload"]["app"]
  }
  role_assignments = {
    foundry_user = {
      principal_id               = var.foundry_user_principal_id
      principal_type             = "User"
      role_definition_id_or_name = "${module.landing_zone_subscription.subscription_resource_id}/providers/Microsoft.Authorization/roleDefinitions/53ca6127-db72-4b80-b1b0-d745d6d5456d"
    }
  }
  tags = var.tags
}

resource "azapi_resource" "foundry_project" {
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = module.naming.names.account_project.name
  location  = var.location
  parent_id = module.foundry.resource_id
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      description = "Microsoft Foundry project for ${var.workload_name} (${var.environment})."
      displayName = "${var.workload_name}-${var.environment}"
    }
  }
}
