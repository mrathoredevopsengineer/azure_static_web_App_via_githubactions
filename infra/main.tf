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

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.resource_prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.common_tags
}

# Create Subnet for Private Endpoint
resource "azurerm_subnet" "pe_subnet" {
  name                 = "${local.resource_prefix}-pe-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.pe_subnet_address_prefix

  private_endpoint_network_policies_enabled = true
}

# Create Private Endpoint for Static Web App
resource "azurerm_private_endpoint" "swa_pe" {
  name                = "${local.resource_prefix}-swa-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "${local.resource_prefix}-swa-psc"
    private_connection_resource_id = azurerm_static_web_app.swa.id
    subresource_names              = ["staticSites"]
    is_manual_connection           = false
  }

  tags = local.common_tags
}

# Create Private DNS Zone for Static Web App
resource "azurerm_private_dns_zone" "swa_dns" {
  name                = "privatelink.staticwebapps.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.common_tags
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "swa_dns_link" {
  name                  = "${local.resource_prefix}-swa-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.swa_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  tags = local.common_tags
}

# Create DNS A Record for Private Endpoint
resource "azurerm_private_dns_a_record" "swa_dns_record" {
  name                = azurerm_static_web_app.swa.name
  zone_name           = azurerm_private_dns_zone.swa_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.swa_pe.private_service_connection[0].private_ip_address]

  tags = local.common_tags
}
