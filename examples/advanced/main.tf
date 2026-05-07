provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-container-app-advanced"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-container-app-advanced"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-container-app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/21"]

  delegation {
    name = "container-app-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-container-app-advanced"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "example" {
  name                     = "stcontainerappadvanced"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "example" {
  name               = "app-data"
  storage_account_id = azurerm_storage_account.example.id
  quota              = 5
}

module "container_app_environment" {
  source = "../../"

  name                       = "cae-example-advanced"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  infrastructure_subnet_id   = azurerm_subnet.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Workload profiles for dedicated compute
  # A "Consumption" profile is automatically added by the module when any
  # workload profiles are defined, so you only need to specify the dedicated ones.
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

  # Storage mount
  storage = {
    "app-storage" = {
      account_name = azurerm_storage_account.example.name
      share_name   = azurerm_storage_share.example.name
      access_key   = azurerm_storage_account.example.primary_access_key
      access_mode  = "ReadWrite"
    }
  }

  # Container Apps
  container_apps = {
    # API running on a general purpose dedicated profile
    "api" = {
      revision_mode         = "Single"
      workload_profile_name = "general-d4"

      template = {
        min_replicas = 1
        max_replicas = 5

        containers = [{
          name   = "api"
          image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
          cpu    = 0.5
          memory = "1Gi"

          env = [
            {
              name  = "ENVIRONMENT"
              value = "production"
            },
            {
              name        = "API_KEY"
              secret_name = "api-key"
            }
          ]

          liveness_probe = {
            port      = 80
            transport = "HTTP"
            path      = "/health"
          }

          readiness_probe = {
            port      = 80
            transport = "HTTP"
            path      = "/ready"
          }
        }]

        volumes = [{
          name         = "app-data"
          storage_type = "AzureFile"
          storage_name = "app-storage"
        }]
      }

      ingress = {
        external_enabled = false
        target_port      = 80
        transport        = "auto"

        traffic_weight = [{
          percentage      = 100
          latest_revision = true
        }]

        ip_security_restrictions = [{
          name             = "allow-internal"
          action           = "Allow"
          ip_address_range = "10.0.0.0/8"
          description      = "Allow internal network"
        }]
      }

      secrets = [{
        name  = "api-key"
        value = "super-secret-api-key"
      }]

      identity = {
        type = "SystemAssigned"
      }
    }

    # Data processor running on a memory-optimized dedicated profile
    "data-processor" = {
      revision_mode         = "Single"
      workload_profile_name = "memory-e4"

      template = {
        min_replicas = 1
        max_replicas = 3

        containers = [{
          name   = "data-processor"
          image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
          cpu    = 2
          memory = "4Gi"

          env = [{
            name  = "PROCESSING_MODE"
            value = "batch"
          }]
        }]
      }

      # No ingress - internal data processor
    }

    # Worker running on the auto-added Consumption workload profile
    # Scales to zero when idle, pay-per-use
    "worker" = {
      revision_mode         = "Single"
      workload_profile_name = "Consumption"

      template = {
        min_replicas = 0
        max_replicas = 10

        containers = [{
          name   = "worker"
          image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
          cpu    = 0.25
          memory = "0.5Gi"

          env = [{
            name  = "WORKER_MODE"
            value = "true"
          }]
        }]
      }

      # No ingress - background worker
    }
  }

  tags = {
    Environment = "Example"
    Purpose     = "AdvancedDemo"
  }
}

output "container_app_environment_id" {
  value = module.container_app_environment.id
}

output "container_app_environment_default_domain" {
  value = module.container_app_environment.default_domain
}

output "container_app_ids" {
  value = module.container_app_environment.container_app_ids
}

output "container_app_fqdns" {
  value = module.container_app_environment.container_app_fqdns
}
