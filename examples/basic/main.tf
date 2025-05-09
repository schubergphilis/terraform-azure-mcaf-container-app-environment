terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16"
    }
  }
}

module "container_app_environment" {
  source              = "../.."
  name                = "my-cae"
  resource_group_name = "my-rg"
  location            = "West Europe"
  workload_profile = {
    name = "Consumption"
    type = "Consumption"
  }

  infrastructure_resource_group_name = "infra-rg"
  infrastructure_subnet_id           = "subnet-id"
  log_analytics_workspace_id         = "log-analytics-workspace-id"
}
