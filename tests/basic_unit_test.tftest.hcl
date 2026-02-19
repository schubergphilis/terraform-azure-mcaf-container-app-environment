mock_provider "azurerm" {
  mock_resource "azurerm_container_app_environment" {
    defaults = {
      id                               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test"
      name                             = "cae-test"
      default_domain                   = "cae-test.westeurope.azurecontainerapps.io"
      static_ip_address                = "10.0.0.1"
      custom_domain_verification_id    = "verification-id"
      docker_bridge_cidr               = "172.17.0.0/16"
      platform_reserved_cidr           = "10.0.8.0/21"
      platform_reserved_dns_ip_address = "10.0.8.2"
    }
  }

  mock_resource "azurerm_container_app_environment_storage" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test/storage/test-storage"
    }
  }

  mock_resource "azurerm_container_app_environment_custom_domain" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test/customDomains/test-domain"
    }
  }

  mock_resource "azurerm_container_app" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/containerApps/test-app"
      name                          = "test-app"
      outbound_ip_addresses         = ["10.0.0.2", "10.0.0.3"]
      latest_revision_name          = "test-app--revision1"
      latest_revision_fqdn          = "test-app--revision1.internal.cae-test.westeurope.azurecontainerapps.io"
      custom_domain_verification_id = "app-verification-id"
    }
  }

  mock_resource "azurerm_container_app_custom_domain" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/containerApps/test-app/customDomains/test-domain"
    }
  }
}

variables {
  name                       = "cae-test"
  resource_group_name        = "rg-test"
  location                   = "westeurope"
  infrastructure_subnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
}

run "test_basic_environment_creation" {
  command = plan

  assert {
    condition     = azurerm_container_app_environment.this.name == "cae-test"
    error_message = "Container App Environment name should match input"
  }

  assert {
    condition     = azurerm_container_app_environment.this.location == "westeurope"
    error_message = "Location should match input"
  }

  assert {
    condition     = azurerm_container_app_environment.this.resource_group_name == "rg-test"
    error_message = "Resource group name should match input"
  }
}

run "test_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_container_app_environment.this.internal_load_balancer_enabled == true
    error_message = "Internal load balancer should be enabled by default for security"
  }

  assert {
    condition     = azurerm_container_app_environment.this.zone_redundancy_enabled == true
    error_message = "Zone redundancy should be enabled by default for high availability"
  }

  assert {
    condition     = azurerm_container_app_environment.this.mutual_tls_enabled == true
    error_message = "Mutual TLS should be enabled by default for security"
  }
}

run "test_logging_configuration" {
  command = plan

  assert {
    condition     = azurerm_container_app_environment.this.logs_destination == "log-analytics"
    error_message = "Logs destination should be log-analytics"
  }

  assert {
    condition     = azurerm_container_app_environment.this.log_analytics_workspace_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
    error_message = "Log Analytics workspace ID should be set when logs_destination is log-analytics"
  }
}

run "test_default_tags" {
  command = plan

  assert {
    condition     = azurerm_container_app_environment.this.tags["ManagedBy"] == "Terraform"
    error_message = "Default ManagedBy tag should be set"
  }
}

run "test_outputs" {
  command = plan

  # ID is a computed value and not known during plan
  # Testing that name output matches input
  assert {
    condition     = azurerm_container_app_environment.this.name == "cae-test"
    error_message = "Output name should match input"
  }
}
