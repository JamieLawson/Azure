workload_name = "foundry"
environment   = "prod"

foundry_user_principal_id = "f34308a4-dfbd-4eb2-8f37-a477e071c748"

virtual_network_address_space = "10.0.0.0/24"
subnet_address_prefix_lengths = {
  app     = 27
  default = 26
}

tags = {
  environment = "prod"
  managed-by  = "terraform"
  workload    = "foundry"
}
