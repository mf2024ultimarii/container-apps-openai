resource "azurerm_cognitive_account" "openai" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "OpenAI"
  custom_subdomain_name         = var.custom_subdomain_name
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_cognitive_deployment" "deployment" {
  for_each             = {for deployment in var.deployments: deployment.name => deployment}

  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = each.value.model.name
    version = each.value.model.version
  }

  scale {
    type = "Standard"
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"

    # retention_policy {
    #   enabled = true
    #   days    = var.log_analytics_retention_days
    # }
  }

  enabled_log {
    category = "RequestResponse"

    # retention_policy {
    #   enabled = true
    #   days    = var.log_analytics_retention_days
    # }
  }

  enabled_log {
    category = "Trace"

    # retention_policy {
    #   enabled = true
    #   days    = var.log_analytics_retention_days
    # }
  }

  metric {
    category = "AllMetrics"

    # retention_policy {
    #   enabled = true
    #   days    = var.log_analytics_retention_days
    # }
  }
}

resource "azurerm_storage_management_policy" "settings" {
  storage_account_id = azurerm_storage_account.rg.id

  rule {
    name    = "Audit"
    enabled = true
    filters {
      prefix_match = ["${var.name}-sc-1/Audit"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_analytics_retention_days
      }
    }
  }
  rule {
    name    = "RequestResponse"
    enabled = true
    filters {
      prefix_match = ["${var.name}-sc-1/RequestResponse"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_analytics_retention_days
      }
    }
  }
  rule {
    name    = "Trace"
    enabled = true
    filters {
      prefix_match = ["${var.name}-sc-1/Trace"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_analytics_retention_days
      }
    }
  }
  rule {
    name    = "AllMetrics"
    enabled = true
    filters {
      prefix_match = ["${var.name}-sc-1/AllMetrics"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_analytics_retention_days
      }
    }
  }
}