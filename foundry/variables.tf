variable "location" {
  description = "Azure region for the resource group and virtual network."
  type        = string
  default     = "uksouth"
}

variable "workload_name" {
  description = "Lowercase workload name used in Azure resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(?:-[a-z0-9]+)*$", var.workload_name))
    error_message = "workload_name must contain lowercase letters, numbers, and single hyphens only."
  }
}

variable "environment" {
  description = "Lowercase environment identifier used in Azure resource names, for example dev, test, or prod."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(?:-[a-z0-9]+)*$", var.environment))
    error_message = "environment must contain lowercase letters, numbers, and single hyphens only."
  }
}

variable "resource_instance" {
  description = "Nonnegative resource instance number. The naming module renders this as two digits."
  type        = number
  default     = 1

  validation {
    condition     = var.resource_instance >= 0 && floor(var.resource_instance) == var.resource_instance
    error_message = "resource_instance must be a nonnegative whole number."
  }
}

variable "subscription_billing_scope" {
  description = "Billing scope used to create the subscription alias."
  type        = string

  validation {
    condition     = startswith(var.subscription_billing_scope, "/providers/Microsoft.Billing/billingAccounts/")
    error_message = "subscription_billing_scope must be a full Microsoft.Billing billing-scope resource ID."
  }
}

variable "subscription_workload" {
  description = "Subscription workload type."
  type        = string
  default     = "Production"

  validation {
    condition     = contains(["Production", "DevTest"], var.subscription_workload)
    error_message = "subscription_workload must be either Production or DevTest."
  }
}

variable "management_group_id" {
  description = "Optional management group ID (not display name) in which to place the new subscription."
  type        = string
  default     = null
  nullable    = true
}

variable "virtual_network_address_space" {
  description = "IPv4 CIDR address space assigned to the virtual network and used to allocate subnet prefixes."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.virtual_network_address_space)) && !strcontains(var.virtual_network_address_space, ":")
    error_message = "virtual_network_address_space must be a valid IPv4 CIDR."
  }
}

variable "subnet_address_prefix_lengths" {
  description = "Map of subnet keys to IPv4 prefix lengths. The network IP address module allocates each subnet from virtual_network_address_space."
  type        = map(number)

  validation {
    condition = (
      length(var.subnet_address_prefix_lengths) > 0 &&
      alltrue([for prefix_length in values(var.subnet_address_prefix_lengths) : prefix_length >= 0 && prefix_length <= 32 && floor(prefix_length) == prefix_length])
    )
    error_message = "subnet_address_prefix_lengths must contain at least one subnet and each prefix length must be a whole number from 0 to 32."
  }
}

variable "foundry_sku_name" {
  description = "SKU used by the Microsoft Foundry resource."
  type        = string
  default     = "S0"

  validation {
    condition     = contains(["F0", "F1", "S0", "S", "S1", "S2", "S3", "S4", "S5", "S6", "P0", "P1", "P2", "E0", "DC0"], var.foundry_sku_name)
    error_message = "foundry_sku_name must be a supported Cognitive Services account SKU."
  }
}

variable "foundry_user_principal_id" {
  description = "Microsoft Entra object ID of the user granted the Foundry User role on the Foundry project."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.foundry_user_principal_id))
    error_message = "foundry_user_principal_id must be a valid Microsoft Entra object ID (UUID)."
  }
}

variable "kimi_k2_6_capacity" {
  description = "Global Standard deployment capacity for Kimi-K2.6, in thousands of tokens per minute."
  type        = number
  default     = 10

  validation {
    condition     = var.kimi_k2_6_capacity > 0 && floor(var.kimi_k2_6_capacity) == var.kimi_k2_6_capacity
    error_message = "kimi_k2_6_capacity must be a positive whole number."
  }
}

variable "tags" {
  description = "Tags applied to the subscription and workload resources."
  type        = map(string)
  default = {
    environment = "production"
    managed-by  = "terraform"
    workload    = "foundry"
  }
}

variable "enable_telemetry" {
  description = "Controls telemetry collection by the Azure Verified Module."
  type        = bool
  default     = true
}
