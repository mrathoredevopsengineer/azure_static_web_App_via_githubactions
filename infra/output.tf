output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "static_web_app_name" {
  description = "The name of the Static Web App"
  value       = azurerm_static_web_app.swa.name
}

output "static_web_app_id" {
  description = "The ID of the Static Web App"
  value       = azurerm_static_web_app.swa.id
}

output "default_host_name" {
  description = "The default hostname of the Static Web App"
  value       = azurerm_static_web_app.swa.default_host_name
}

output "api_key" {
  description = "The API key for the Static Web App"
  value       = azurerm_static_web_app.swa.api_key
  sensitive   = true
}

output "private_endpoint_id" {
  description = "The ID of the Private Endpoint"
  value       = azurerm_private_endpoint.swa_pe.id
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the Private Endpoint"
  value       = azurerm_private_endpoint.swa_pe.private_service_connection[0].private_ip_address
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "pe_subnet_id" {
  description = "The ID of the Private Endpoint subnet"
  value       = azurerm_subnet.pe_subnet.id
}

output "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone"
  value       = azurerm_private_dns_zone.swa_dns.id
}

output "private_dns_fqdn" {
  description = "The FQDN of the Static Web App in Private DNS"
  value       = "${azurerm_static_web_app.swa.name}.privatelink.staticwebapps.azure.com"
}
