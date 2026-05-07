output "id" {
  value       = azurerm_container_app_environment.this.id
  description = "The ID of the Container App Environment."
}

output "name" {
  value       = azurerm_container_app_environment.this.name
  description = "The name of the Container App Environment."
}

output "default_domain" {
  value       = azurerm_container_app_environment.this.default_domain
  description = "The default domain of the Container App Environment."
}

output "static_ip_address" {
  value       = azurerm_container_app_environment.this.static_ip_address
  description = "The static IP address of the Container App Environment."
}

output "custom_domain_verification_id" {
  value       = azurerm_container_app_environment.this.custom_domain_verification_id
  description = "The custom domain verification ID for the Container App Environment."
}

output "docker_bridge_cidr" {
  value       = azurerm_container_app_environment.this.docker_bridge_cidr
  description = "The Docker bridge CIDR block for the Container App Environment."
}

output "platform_reserved_cidr" {
  value       = azurerm_container_app_environment.this.platform_reserved_cidr
  description = "The platform reserved CIDR block for the Container App Environment."
}

output "platform_reserved_dns_ip_address" {
  value       = azurerm_container_app_environment.this.platform_reserved_dns_ip_address
  description = "The platform reserved DNS IP address for the Container App Environment."
}

output "container_app_ids" {
  value = {
    for k, v in module.container_app : k => v.id
  }
  description = "A map of container app names to their IDs."
}

output "container_app_fqdns" {
  value = {
    for k, v in module.container_app : k => v.fqdn
  }
  description = "A map of container app names to their FQDNs."
}

output "container_app_outbound_ip_addresses" {
  value = {
    for k, v in module.container_app : k => v.outbound_ip_addresses
  }
  description = "A map of container app names to their outbound IP addresses."
}
