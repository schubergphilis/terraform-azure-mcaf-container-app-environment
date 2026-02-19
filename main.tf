resource "azurerm_container_app_environment" "this" {
  name                                        = var.name
  location                                    = var.location
  resource_group_name                         = var.resource_group_name
  infrastructure_subnet_id                    = var.infrastructure_subnet_id
  infrastructure_resource_group_name          = local.use_workload_profiles ? coalesce(var.infrastructure_resource_group_name, "${var.resource_group_name}_infra") : null
  internal_load_balancer_enabled              = var.internal_load_balancer_enabled
  zone_redundancy_enabled                     = var.zone_redundancy_enabled
  mutual_tls_enabled                          = var.mutual_tls_enabled
  logs_destination                            = var.logs_destination
  log_analytics_workspace_id                  = var.logs_destination == "log-analytics" ? var.log_analytics_workspace_id : null
  dapr_application_insights_connection_string = var.dapr_application_insights_connection_string

  dynamic "workload_profile" {
    for_each = local.workload_profiles
    content {
      name                  = workload_profile.key
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }

  tags = local.tags
}

resource "azurerm_container_app_environment_storage" "this" {
  for_each = var.storage

  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.this.id
  account_name                 = each.value.account_name
  share_name                   = each.value.share_name
  access_key                   = each.value.access_key
  access_mode                  = each.value.access_mode
}

resource "azurerm_container_app_environment_custom_domain" "this" {
  count = var.custom_domain != null ? 1 : 0

  container_app_environment_id = azurerm_container_app_environment.this.id
  dns_suffix                   = var.custom_domain.dns_suffix
  certificate_blob_base64      = var.custom_domain.certificate_blob_base64
  certificate_password         = var.custom_domain.certificate_password
}

module "container_app" {
  source   = "./modules/container-app"
  for_each = var.container_apps

  name                         = each.key
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = each.value.revision_mode
  workload_profile_name        = each.value.workload_profile_name
  max_inactive_revisions       = each.value.max_inactive_revisions
  template                     = each.value.template
  ingress                      = each.value.ingress
  secrets                      = each.value.secrets
  registries                   = each.value.registries
  dapr                         = each.value.dapr
  identity                     = each.value.identity
  custom_domains               = each.value.custom_domains
  tags                         = local.tags
}
