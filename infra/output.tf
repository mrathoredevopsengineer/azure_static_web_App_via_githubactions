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
