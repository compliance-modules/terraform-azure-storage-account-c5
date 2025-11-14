# -----------------------------
# Storage Account (C5-hardened)
# -----------------------------
resource "azurerm_storage_account" "this" {
  account_replication_type = var.account_replication_type
  location                 = var.location
  name                     = var.name
  resource_group_name      = var.resource_group_name

  account_kind = "StorageV2"
  account_tier = var.account_tier

  tags = merge(
    var.tags,
    {
      "c5-profile" = "bsi-c5-2020"
    }
  )

  lifecycle {
    prevent_destroy = true
  }

  # --- Transport security (CRY / COS) ---
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # --- At-rest encryption (CRY) ---
  infrastructure_encryption_enabled = true

  # --- Public exposure / weak auth (IDM / PSS / OPS-24) ---
  public_network_access_enabled = false
  shared_access_key_enabled     = false

  # --- Identity for RBAC & optional CMK (IDM / CRY) ---
  identity {
    type = "SystemAssigned"
  }

  # --- Network segregation (OPS-24 / COS-06) ---
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = var.subnet_ids
    ip_rules                   = var.ip_rules
    bypass                     = "None"
  }
}

# -----------------------------------
# Customer-managed key
# -----------------------------------
resource "azurerm_storage_account_customer_managed_key" "this" {
  count = var.cmk != null ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id

  key_vault_id = var.cmk.key_vault_id
  key_name     = var.cmk.key_name
  key_version  = var.cmk.key_version
}

# --------------------------------------------------
# Management policy for lifecycle / secure deletion
# (PI-03 Sichere Datenlöschung, OPS-06/OPS-09)
# --------------------------------------------------
resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id

  rule {
    name    = "delete-old-data"
    enabled = true

    filters {
      prefix_match = var.lifecycle_prefix_match
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.lifecycle_delete_after_days
      }

      version {
        delete_after_days_since_creation = var.lifecycle_delete_after_days
      }
    }
  }
}