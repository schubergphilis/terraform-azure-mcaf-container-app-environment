resource "azurerm_container_app_environment" "this" {
    name = var.name
    resource_group_name = var.resource_group_name
    location = var.location

    infrastructure_subnet_id = var.infrastructure_subnet_id
    infrastructure_resource_group_name = var.infrastructure_resource_group_name
    internal_load_balancer_enabled = var.internal_load_balancer_enabled
    zone_redundancy_enabled = var.zone_redundancy_enabled
    log_analytics_workspace_id = var.log_analytics_workspace_id

    workload_profile {
      name = var.workload_profile.name
      workload_profile_type = var.workload_profile.type
    }
}

resource "azurerm_container_app_environment_certificate" "custom_domain_certificate" {
  count = var.certificate != null ? 1 : 0

  name = var.certificate.name != null ? var.certificate.name : "${var.name}-cert"
  container_app_environment_id = azurerm_container_app_environment.this.id
  certificate_blob_base64 = var.certificate.blob_base64
  certificate_password = var.certificate.password
}