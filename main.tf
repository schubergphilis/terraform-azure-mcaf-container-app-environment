resource "azurerm_container_app_environment" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  infrastructure_subnet_id           = var.infrastructure_subnet_id
  infrastructure_resource_group_name = var.infrastructure_resource_group_name
  internal_load_balancer_enabled     = var.internal_load_balancer_enabled
  zone_redundancy_enabled            = var.zone_redundancy_enabled

  # Apply log_analytics_workspace_id only when logs_destination is 'log-analytics'
  log_analytics_workspace_id = var.logs_destination == "log-analytics" ? var.log_analytics_workspace_id : null
  
  # Set logs_destination if specified
  logs_destination = var.logs_destination

  workload_profile {
    name                  = var.workload_profile.name
    workload_profile_type = var.workload_profile.type
  }
}

resource "azurerm_container_app_environment_certificate" "custom_domain_certificate" {
  count = var.certificate != null ? 1 : 0

  name                         = var.certificate.name != null ? var.certificate.name : "${var.name}-cert"
  certificate_blob_base64      = var.certificate.blob_base64
  certificate_password         = var.certificate.password
  container_app_environment_id = azurerm_container_app_environment.this.id
}
