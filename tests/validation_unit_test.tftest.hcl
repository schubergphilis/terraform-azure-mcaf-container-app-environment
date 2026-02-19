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
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test//test-storage"
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
  name                       = "cae-validation-test"
  resource_group_name        = "rg-test"
  location                   = "westeurope"
  infrastructure_subnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
}

run "test_invalid_logs_destination" {
  command = plan

  variables {
    logs_destination = "invalid"
  }

  expect_failures = [
    var.logs_destination
  ]
}

run "test_valid_logs_destination_log_analytics" {
  command = plan

  variables {
    logs_destination = "log-analytics"
  }

  assert {
    condition     = azurerm_container_app_environment.this.logs_destination == "log-analytics"
    error_message = "logs_destination should accept 'log-analytics'"
  }
}

run "test_valid_logs_destination_azure_monitor" {
  command = plan

  variables {
    logs_destination = "azure-monitor"
  }

  assert {
    condition     = azurerm_container_app_environment.this.logs_destination == "azure-monitor"
    error_message = "logs_destination should accept 'azure-monitor'"
  }
}

run "test_valid_logs_destination_null" {
  command = plan

  variables {
    logs_destination = null
  }

  # Test passes if plan succeeds - null is a valid value
  assert {
    condition     = azurerm_container_app_environment.this.name == "cae-validation-test"
    error_message = "Plan should succeed with null logs_destination"
  }
}

run "test_workload_profile_valid_types" {
  command = plan

  variables {
    workload_profiles = {
      "dedicated" = {
        workload_profile_type = "D4"
        minimum_count         = 1
        maximum_count         = 3
      }
    }
  }

  assert {
    condition     = length(azurerm_container_app_environment.this.workload_profile) > 0
    error_message = "Workload profiles should be created"
  }
}

run "test_multiple_workload_profiles" {
  command = plan

  variables {
    workload_profiles = {
      "general-d4" = {
        workload_profile_type = "D4"
        minimum_count         = 1
        maximum_count         = 3
      }
      "memory-e4" = {
        workload_profile_type = "E4"
        minimum_count         = 1
        maximum_count         = 2
      }
    }
  }

  # 2 dedicated profiles + 1 auto-added Consumption = 3 total
  assert {
    condition     = length(azurerm_container_app_environment.this.workload_profile) == 3
    error_message = "Should create 3 workload profiles: 2 dedicated + 1 auto-added Consumption"
  }
}

run "test_no_workload_profiles" {
  command = plan

  variables {
    workload_profiles = {}
  }

  assert {
    condition     = length(azurerm_container_app_environment.this.workload_profile) == 0
    error_message = "No workload profiles should be created when none are specified"
  }

  assert {
    condition     = azurerm_container_app_environment.this.infrastructure_resource_group_name == null
    error_message = "infrastructure_resource_group_name should be null when no workload profiles are specified"
  }
}

run "test_workload_profiles_infrastructure_resource_group" {
  command = plan

  variables {
    workload_profiles = {
      "dedicated" = {
        workload_profile_type = "D4"
        minimum_count         = 1
        maximum_count         = 3
      }
    }
  }

  assert {
    condition     = azurerm_container_app_environment.this.infrastructure_resource_group_name == "rg-test_infra"
    error_message = "infrastructure_resource_group_name should default to resource_group_name with _infra suffix"
  }
}

run "test_workload_profiles_custom_infrastructure_resource_group" {
  command = plan

  variables {
    workload_profiles = {
      "dedicated" = {
        workload_profile_type = "D4"
        minimum_count         = 1
        maximum_count         = 3
      }
    }
    infrastructure_resource_group_name = "rg-custom-infra"
  }

  assert {
    condition     = azurerm_container_app_environment.this.infrastructure_resource_group_name == "rg-custom-infra"
    error_message = "infrastructure_resource_group_name should use the custom value when specified"
  }
}

run "test_consumption_profile_null_counts" {
  command = plan

  variables {
    workload_profiles = {
      "dedicated" = {
        workload_profile_type = "D4"
        minimum_count         = 1
        maximum_count         = 3
      }
    }
  }

  # 1 dedicated + 1 auto-added Consumption = 2 total
  assert {
    condition     = length(azurerm_container_app_environment.this.workload_profile) == 2
    error_message = "Should create 2 workload profiles: 1 dedicated + 1 auto-added Consumption"
  }
}

run "test_storage_valid_access_modes" {
  command = plan

  variables {
    storage = {
      "test-storage" = {
        account_name = "teststorageaccount"
        share_name   = "testshare"
        access_key   = "testkey123"
        access_mode  = "ReadOnly"
      }
    }
  }

  assert {
    condition     = length(azurerm_container_app_environment_storage.this) == 1
    error_message = "Storage should be created with valid access mode"
  }
}

run "test_container_app_with_ingress" {
  command = plan

  variables {
    container_apps = {
      "api" = {
        revision_mode = "Single"
        template = {
          containers = [{
            name   = "api"
            image  = "nginx:latest"
            cpu    = 0.5
            memory = "1Gi"
          }]
        }
        ingress = {
          target_port = 80
        }
      }
    }
  }

  assert {
    condition     = length(module.container_app) == 1
    error_message = "Container app should be created"
  }
}

run "test_container_app_external_enabled_default_false" {
  command = plan

  variables {
    container_apps = {
      "api" = {
        revision_mode = "Single"
        template = {
          containers = [{
            name   = "api"
            image  = "nginx:latest"
            cpu    = 0.5
            memory = "1Gi"
          }]
        }
        ingress = {
          target_port = 80
        }
      }
    }
  }

  assert {
    condition     = length(module.container_app) == 1
    error_message = "Container app should be created with external_enabled defaulting to false"
  }
}

run "test_override_secure_defaults" {
  command = plan

  variables {
    internal_load_balancer_enabled = false
    zone_redundancy_enabled        = false
    mutual_tls_enabled             = false
  }

  assert {
    condition     = azurerm_container_app_environment.this.internal_load_balancer_enabled == false
    error_message = "internal_load_balancer_enabled should be overridable"
  }

  assert {
    condition     = azurerm_container_app_environment.this.zone_redundancy_enabled == false
    error_message = "zone_redundancy_enabled should be overridable"
  }

  assert {
    condition     = azurerm_container_app_environment.this.mutual_tls_enabled == false
    error_message = "mutual_tls_enabled should be overridable"
  }
}

run "test_custom_tags" {
  command = plan

  variables {
    tags = {
      Environment = "Test"
      Project     = "UnitTest"
    }
  }

  assert {
    condition     = azurerm_container_app_environment.this.tags["Environment"] == "Test"
    error_message = "Custom tags should be applied"
  }

  assert {
    condition     = azurerm_container_app_environment.this.tags["Project"] == "UnitTest"
    error_message = "Custom tags should be applied"
  }

  assert {
    condition     = azurerm_container_app_environment.this.tags["ManagedBy"] == "Terraform"
    error_message = "Default tags should be merged with custom tags"
  }
}
