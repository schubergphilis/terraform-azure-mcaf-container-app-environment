terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.16, < 5.0"
    }
  }
}

# Example: Certificate from blob (base64-encoded PFX)
module "container_app_environment_blob" {
  source = "../.."

  name                = "my-cae"
  resource_group_name = "my-rg"
  location            = "West Europe"

  infrastructure_resource_group_name = "infra-rg"
  infrastructure_subnet_id           = "subnet-id"
  logs_destination                   = "log-analytics"
  log_analytics_workspace_id         = "log-analytics-workspace-id"

  certificates = {
    "my-cert" = {
      blob_base64 = "base64-encoded-certificate"
      password    = "certificate-password"
    }
  }
}

# Example: Certificate from Key Vault (recommended for rotation)
module "container_app_environment_keyvault" {
  source = "../.."

  name                = "my-cae-kv"
  resource_group_name = "my-rg"
  location            = "West Europe"

  infrastructure_resource_group_name = "infra-rg"
  infrastructure_subnet_id           = "subnet-id"
  logs_destination                   = "log-analytics"
  log_analytics_workspace_id         = "log-analytics-workspace-id"

  certificates = {
    "my-cert-from-kv" = {
      key_vault = {
        identity            = "/subscriptions/.../userAssignedIdentities/my-identity"
        key_vault_secret_id = "https://my-keyvault.vault.azure.net/secrets/my-cert"
      }
    }
  }
}
