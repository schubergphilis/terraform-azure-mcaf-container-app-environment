# terraform-azure-mcaf-container-app-environment
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_app_environment_certificate.custom_domain_certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_infrastructure_resource_group_name"></a> [infrastructure\_resource\_group\_name](#input\_infrastructure\_resource\_group\_name) | Name of the platform-managed resource group created for the Managed Environment to host infrastructure resources. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_infrastructure_subnet_id"></a> [infrastructure\_subnet\_id](#input\_infrastructure\_subnet\_id) | The existing Subnet to use for the Container Apps Control Plane. Changing this forces a new resource to be created.<br/><br/>The Subnet must have a /21 or larger address space. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the Container App Environment is to exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace to use for the Container Apps Managed Environment. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Container Apps Managed Environment. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the Container App Environment is to be created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_certificate"></a> [certificate](#input\_certificate) | n/a | <pre>object({<br/>    name        = optional(string)<br/>    blob_base64 = string<br/>    password    = optional(string, "")<br/>  })</pre> | `null` | no |
| <a name="input_internal_load_balancer_enabled"></a> [internal\_load\_balancer\_enabled](#input\_internal\_load\_balancer\_enabled) | Should the Container Environment operate in Internal Load Balancing Mode? Defaults to false. Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_workload_profile"></a> [workload\_profile](#input\_workload\_profile) | The name and type of the workload profile.<br/>Defaults to Consumption. | <pre>object({<br/>    name = string<br/>    type = string<br/>  })</pre> | <pre>{<br/>  "name": "Consumption",<br/>  "type": "Consumption"<br/>}</pre> | no |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | Should the Container App Environment be created with Zone Redundancy enabled? Defaults to true. Changing this forces a new resource to be created. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | The ID of the Container App Environment. |
<!-- END_TF_DOCS -->