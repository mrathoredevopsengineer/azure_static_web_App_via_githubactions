locals {
  environment = var.environment
  project     = var.project_name
  location    = var.location

  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }

  resource_prefix = "${local.project}-${local.environment}"
}
