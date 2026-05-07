mock_provider "azurerm" {
  mock_resource "azurerm_container_app_environment" {
    defaults = {
      id                               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.App/managedEnvironments/cae-test"
      name                             = "cae-test"
      default_domain                   = "cae-test.westeurope.azurecontainerapps.io"
      static_ip_address                = "20.0.0.1"
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
      outbound_ip_addresses         = ["20.0.0.2", "20.0.0.3"]
      latest_revision_name          = "test-app--revision1"
      latest_revision_fqdn          = "test-app--revision1.cae-test.westeurope.azurecontainerapps.io"
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
  name                           = "cae-public-test"
  resource_group_name            = "rg-test"
  location                       = "westeurope"
  infrastructure_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
  logs_destination               = "log-analytics"
  log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
  internal_load_balancer_enabled = false
}

run "test_public_environment_configuration" {
  command = plan

  assert {
    condition     = azurerm_container_app_environment.this.internal_load_balancer_enabled == false
    error_message = "Internal load balancer should be disabled for public-facing environment"
  }

  assert {
    condition     = azurerm_container_app_environment.this.mutual_tls_enabled == true
    error_message = "Mutual TLS should remain enabled for service-to-service security"
  }

  assert {
    condition     = azurerm_container_app_environment.this.zone_redundancy_enabled == true
    error_message = "Zone redundancy should remain enabled for high availability"
  }
}

run "test_public_environment_logging" {
  command = plan

  assert {
    condition     = azurerm_container_app_environment.this.logs_destination == "log-analytics"
    error_message = "Logging should be enabled for public-facing environments"
  }

  assert {
    condition     = azurerm_container_app_environment.this.log_analytics_workspace_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
    error_message = "Log Analytics workspace should be configured"
  }
}

run "test_public_app_with_external_ingress" {
  command = plan

  variables {
    container_apps = {
      "web-api" = {
        revision_mode = "Single"
        template = {
          min_replicas = 1
          max_replicas = 10
          containers = [{
            name   = "web-api"
            image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu    = 0.5
            memory = "1Gi"
          }]
        }
        ingress = {
          external_enabled           = true
          target_port                = 8080
          allow_insecure_connections = false
          cors_policy = {
            allowed_origins = ["https://app.example.com"]
            allowed_methods = ["GET", "POST"]
            allowed_headers = ["Authorization", "Content-Type"]
            max_age         = 3600
          }
        }
        identity = {
          type = "SystemAssigned"
        }
      }
    }
  }

  assert {
    condition     = length(module.container_app) == 1
    error_message = "Public-facing container app should be created"
  }
}

run "test_mixed_public_and_internal_apps" {
  command = plan

  variables {
    container_apps = {
      "web-api" = {
        revision_mode = "Single"
        template = {
          containers = [{
            name   = "web-api"
            image  = "nginx:latest"
            cpu    = 0.5
            memory = "1Gi"
          }]
        }
        ingress = {
          external_enabled = true
          target_port      = 8080
        }
      }
      "worker" = {
        revision_mode = "Single"
        template = {
          containers = [{
            name   = "worker"
            image  = "nginx:latest"
            cpu    = 0.25
            memory = "0.5Gi"
          }]
        }
        # No ingress - internal worker
      }
    }
  }

  assert {
    condition     = length(module.container_app) == 2
    error_message = "Both public and internal container apps should be created"
  }
}
