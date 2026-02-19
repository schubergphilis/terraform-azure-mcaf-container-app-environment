output "id" {
  value       = azurerm_container_app.this.id
  description = "The ID of the Container App."
}

output "name" {
  value       = azurerm_container_app.this.name
  description = "The name of the Container App."
}

output "fqdn" {
  value       = try(azurerm_container_app.this.ingress[0].fqdn, null)
  description = "The FQDN of the Container App."
}

output "outbound_ip_addresses" {
  value       = azurerm_container_app.this.outbound_ip_addresses
  description = "The outbound IP addresses of the Container App."
}

output "latest_revision_name" {
  value       = azurerm_container_app.this.latest_revision_name
  description = "The name of the latest revision of the Container App."
}

output "latest_revision_fqdn" {
  value       = azurerm_container_app.this.latest_revision_fqdn
  description = "The FQDN of the latest revision of the Container App."
}

output "custom_domain_verification_id" {
  value       = azurerm_container_app.this.custom_domain_verification_id
  description = "The custom domain verification ID for the Container App."
}
