provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-container-app-public"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-container-app-public"
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
  name                = "law-container-app-public"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "container_app_environment" {
  source = "../../"

  name                       = "cae-example-public"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  infrastructure_subnet_id   = azurerm_subnet.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Public-facing environment: disable internal load balancer
  internal_load_balancer_enabled = false

  # Keep mTLS enabled for secure service-to-service communication
  # even when the environment is publicly accessible
  mutual_tls_enabled = true

  container_apps = {
    # Public-facing API accessible from the internet
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

          env = [
            {
              name  = "ASPNETCORE_ENVIRONMENT"
              value = "Production"
            },
            {
              name  = "ASPNETCORE_URLS"
              value = "http://+:8080"
            }
          ]

          liveness_probe = {
            port      = 8080
            transport = "HTTP"
            path      = "/healthz"
          }

          readiness_probe = {
            port      = 8080
            transport = "HTTP"
            path      = "/ready"
          }

          startup_probe = {
            port      = 8080
            transport = "HTTP"
            path      = "/healthz"
          }
        }]
      }

      ingress = {
        # Publicly accessible from the internet
        external_enabled = true
        target_port      = 8080
        transport        = "auto"

        # Force HTTPS only - no insecure connections
        allow_insecure_connections = false

        traffic_weight = [{
          percentage      = 100
          latest_revision = true
        }]

        # CORS policy for web frontend consumers
        cors_policy = {
          allowed_origins = ["https://app.example.com", "https://www.example.com"]
          allowed_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
          allowed_headers = ["Authorization", "Content-Type", "X-Request-ID"]
          max_age         = 3600
        }
      }

      identity = {
        type = "SystemAssigned"
      }
    }

    # Internal background worker - not exposed to the internet
    "worker" = {
      revision_mode = "Single"

      template = {
        min_replicas = 1
        max_replicas = 5

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

      # No ingress - background worker only reachable within the environment
    }
  }

  tags = {
    Environment = "Example"
    Purpose     = "PublicDemo"
  }
}

output "container_app_environment_id" {
  value = module.container_app_environment.id
}

output "container_app_environment_default_domain" {
  value = module.container_app_environment.default_domain
}

output "container_app_environment_static_ip" {
  value       = module.container_app_environment.static_ip_address
  description = "The public IP address of the environment. Create a DNS A record pointing to this IP."
}

output "container_app_ids" {
  value = module.container_app_environment.container_app_ids
}

output "container_app_fqdns" {
  value = module.container_app_environment.container_app_fqdns
}
