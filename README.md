# terraform-azure-mcaf-container-app-environment

Terraform module for Azure Container App Environments following MCAF (Microsoft Cloud Adoption Framework) patterns.

## Features

- **Security-first defaults**: Internal load balancer, mutual TLS, and zone redundancy enabled by default
- **(Standalone) Container Apps submodule**: Deploy container apps directly via the module
- **Workload profiles**: Support for dedicated compute profiles
- **Storage mounts**: Azure Files storage integration
- **Custom domains**: Environment-level custom DNS suffix support
- **Comprehensive testing**: Unit tests using Terraform's native test framework

## Usage

### Basic Example

```hcl
module "container_app_environment" {
  source = "github.com/schubergphilis/terraform-azure-mcaf-container-app-environment"

  name                       = "cae-example"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = "westeurope"
  infrastructure_subnet_id   = azurerm_subnet.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}
```

### With Container Apps

```hcl
module "container_app_environment" {
  source = "github.com/schubergphilis/terraform-azure-mcaf-container-app-environment"

  name                       = "cae-example"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = "westeurope"
  infrastructure_subnet_id   = azurerm_subnet.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  container_apps = {
    "api" = {
      revision_mode = "Single"
      template = {
        containers = [{
          name   = "api"
          image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
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
```

### Without Container App Environment (Only Container App)

```hcl
module "container_app" {
  source        = "git::https://github.com/schubergphilis/terraform-azure-mcaf-container-app-environment.git//modules/container-app?ref=vx.x.x"
  name          = "my-api"
  revision_mode = "Single"

  template = {
    containers = [{
      name   = "api"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.5
      memory = "1Gi"
    }]
  }

  ingress = {
    target_port = 80
  }
}
```

## Security Defaults

| Setting | Default | Rationale |
|---------|---------|-----------|
| `internal_load_balancer_enabled` | `true` | No public exposure by default |
| `mutual_tls_enabled` | `true` | Service-to-service encryption |
| `zone_redundancy_enabled` | `true` | High availability for production |
| Container app `external_enabled` | `false` | Internal-only by default |
| Container app `allow_insecure_connections` | `false` | Force HTTPS |

All secure defaults can be overridden when needed.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| azurerm | ~> 4.16 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.16 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| container_app | ./modules/container-app | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_app_environment_custom_domain.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_custom_domain) | resource |
| [azurerm_container_app_environment_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_storage) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Container App Environment. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Container App Environment. | `string` | n/a | yes |
| location | The Azure region where the Container App Environment will be created. | `string` | n/a | yes |
| infrastructure_subnet_id | The ID of the subnet to use for the Container App Environment infrastructure. Must be a /21 or larger address space. | `string` | n/a | yes |
| internal_load_balancer_enabled | Whether the Container App Environment should use an internal load balancer. Defaults to true for security. | `bool` | `true` | no |
| zone_redundancy_enabled | Whether zone redundancy is enabled for the Container App Environment. Defaults to true for high availability. | `bool` | `true` | no |
| mutual_tls_enabled | Whether mutual TLS authentication is enabled for service-to-service communication. Defaults to true for security. | `bool` | `true` | no |
| logs_destination | The destination for logs. Valid values are 'log-analytics' or 'azure-monitor'. Set to null to disable. | `string` | `"log-analytics"` | no |
| log_analytics_workspace_id | The ID of the Log Analytics Workspace to send logs to. Required when logs_destination is 'log-analytics'. | `string` | `null` | no |
| workload_profiles | A map of workload profiles for the Container App Environment. | `map(object)` | `{}` | no |
| storage | A map of storage configurations for the Container App Environment. | `map(object)` | `{}` | no |
| custom_domain | Custom domain configuration for the Container App Environment. | `object` | `null` | no |
| container_apps | A map of container apps to create in this environment. | `map(object)` | `{}` | no |
| tags | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Container App Environment. |
| name | The name of the Container App Environment. |
| default_domain | The default domain of the Container App Environment. |
| static_ip_address | The static IP address of the Container App Environment. |
| container_app_ids | A map of container app names to their IDs. |
| container_app_fqdns | A map of container app names to their FQDNs. |
<!-- END_TF_DOCS -->

## Examples

- [Basic](./examples/basic) - Minimal internal environment
- [Advanced](./examples/advanced) - Full-featured with container apps, storage, and workload profiles
- [Public](./examples/public) - Public-facing environment with external ingress, CORS, and mixed workloads

## License

MIT
