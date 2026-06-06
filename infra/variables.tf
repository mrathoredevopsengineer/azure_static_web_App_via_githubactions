

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "sku_tier" {
  description = "SKU tier for Static Web App (Free, Standard)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be either Free or Standard."
  }
}

variable "sku_size" {
  description = "SKU size for Static Web App"
  type        = string
  default     = "Standard"
}

variable "custom_domain" {
  description = "Custom domain name for Static Web App (optional)"
  type        = string
  default     = null
}

variable "validation_type" {
  description = "Validation type for custom domain (cname, txt)"
  type        = string
  default     = "cname"
}

variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "pe_subnet_address_prefix" {
  description = "Address prefix for Private Endpoint subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
