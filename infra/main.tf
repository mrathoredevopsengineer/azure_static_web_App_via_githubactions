# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.common_tags
}

# Create Static Web App
resource "azurerm_static_web_app" "swa" {
  name                = "${local.resource_prefix}-swa"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  sku_size            = var.sku_size
  sku_tier            = var.sku_tier

  tags = local.common_tags
}

# Create Static Web App Custom Domain (optional)
resource "azurerm_static_web_app_custom_domain" "custom_domain" {
  count             = var.custom_domain != null ? 1 : 0
  static_web_app_id = azurerm_static_web_app.swa.id
  domain_name       = var.custom_domain
  validation_type   = var.validation_type
}
