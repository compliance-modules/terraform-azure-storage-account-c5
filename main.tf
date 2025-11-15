resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  provisioned_billing_model_version = var.provisioned_billing_model_version
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  access_tier                       = var.access_tier
  edge_zone                         = var.edge_zone
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  is_hns_enabled                    = var.is_hns_enabled
  nfsv3_enabled                     = var.nfsv3_enabled
  large_file_share_enabled          = var.large_file_share_enabled
  local_user_enabled                = var.local_user_enabled
  queue_encryption_key_type         = var.queue_encryption_key_type
  table_encryption_key_type         = var.table_encryption_key_type
  allowed_copy_scope                = var.allowed_copy_scope
  sftp_enabled                      = var.sftp_enabled
  dns_endpoint_type                 = var.dns_endpoint_type

  # C5-enforced settings (not exposed as variables)
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = false
  public_network_access_enabled     = false
  infrastructure_encryption_enabled = true

  # Tags + C5 profile tag
  tags = merge(
    var.tags,
    {
      "c5-profile" = "bsi-c5-2020"
    }
  )

  lifecycle {
    prevent_destroy = true
  }

  ###########
  # Identity
  ###########
  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  ################
  # custom_domain
  ################
  dynamic "custom_domain" {
    for_each = var.custom_domain == null ? [] : [var.custom_domain]
    content {
      name          = custom_domain.value.name
      use_subdomain = lookup(custom_domain.value, "use_subdomain", null)
    }
  }

  #####################
  # customer_managed_key
  #####################
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]
    content {
      key_vault_key_id          = lookup(customer_managed_key.value, "key_vault_key_id", null)
      managed_hsm_key_id        = lookup(customer_managed_key.value, "managed_hsm_key_id", null)
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  ##################
  # blob_properties
  ##################
  dynamic "blob_properties" {
    for_each = var.blob_properties == null ? [] : [var.blob_properties]
    content {
      dynamic "cors_rule" {
        for_each = coalesce(blob_properties.value.cors_rule, [])
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "delete_retention_policy" {
        for_each = blob_properties.value.delete_retention_policy == null ? [] : [blob_properties.value.delete_retention_policy]
        content {
          days                     = lookup(delete_retention_policy.value, "days", null)
          permanent_delete_enabled = lookup(delete_retention_policy.value, "permanent_delete_enabled", null)
        }
      }

      dynamic "restore_policy" {
        for_each = blob_properties.value.restore_policy == null ? [] : [blob_properties.value.restore_policy]
        content {
          days = restore_policy.value.days
        }
      }

      versioning_enabled            = lookup(blob_properties.value, "versioning_enabled", null)
      change_feed_enabled           = lookup(blob_properties.value, "change_feed_enabled", null)
      change_feed_retention_in_days = lookup(blob_properties.value, "change_feed_retention_in_days", null)
      default_service_version       = lookup(blob_properties.value, "default_service_version", null)
      last_access_time_enabled      = lookup(blob_properties.value, "last_access_time_enabled", null)

      dynamic "container_delete_retention_policy" {
        for_each = blob_properties.value.container_delete_retention_policy == null ? [] : [blob_properties.value.container_delete_retention_policy]
        content {
          days = lookup(container_delete_retention_policy.value, "days", null)
        }
      }
    }
  }

  ###################
  # queue_properties
  ###################
  dynamic "queue_properties" {
    for_each = var.queue_properties == null ? [] : [var.queue_properties]
    content {
      dynamic "cors_rule" {
        for_each = coalesce(queue_properties.value.cors_rule, [])
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "logging" {
        for_each = queue_properties.value.logging == null ? [] : [queue_properties.value.logging]
        content {
          delete                = logging.value.delete
          read                  = logging.value.read
          write                 = logging.value.write
          version               = logging.value.version
          retention_policy_days = lookup(logging.value, "retention_policy_days", null)
        }
      }

      dynamic "minute_metrics" {
        for_each = queue_properties.value.minute_metrics == null ? [] : [queue_properties.value.minute_metrics]
        content {
          enabled               = minute_metrics.value.enabled
          version               = minute_metrics.value.version
          include_apis          = lookup(minute_metrics.value, "include_apis", null)
          retention_policy_days = lookup(minute_metrics.value, "retention_policy_days", null)
        }
      }

      dynamic "hour_metrics" {
        for_each = queue_properties.value.hour_metrics == null ? [] : [queue_properties.value.hour_metrics]
        content {
          enabled               = hour_metrics.value.enabled
          version               = hour_metrics.value.version
          include_apis          = lookup(hour_metrics.value, "include_apis", null)
          retention_policy_days = lookup(hour_metrics.value, "retention_policy_days", null)
        }
      }
    }
  }

  ##################
  # static_website
  ##################
  dynamic "static_website" {
    for_each = var.static_website == null ? [] : [var.static_website]
    content {
      index_document     = lookup(static_website.value, "index_document", null)
      error_404_document = lookup(static_website.value, "error_404_document", null)
    }
  }

  ###################
  # share_properties
  ###################
  dynamic "share_properties" {
    for_each = var.share_properties == null ? [] : [var.share_properties]
    content {
      dynamic "cors_rule" {
        for_each = coalesce(share_properties.value.cors_rule, [])
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "retention_policy" {
        for_each = share_properties.value.retention_policy == null ? [] : [share_properties.value.retention_policy]
        content {
          days = lookup(retention_policy.value, "days", null)
        }
      }

      dynamic "smb" {
        for_each = share_properties.value.smb == null ? [] : [share_properties.value.smb]
        content {
          versions                        = lookup(smb.value, "versions", null)
          authentication_types            = lookup(smb.value, "authentication_types", null)
          kerberos_ticket_encryption_type = lookup(smb.value, "kerberos_ticket_encryption_type", null)
          channel_encryption_type         = lookup(smb.value, "channel_encryption_type", null)
          multichannel_enabled            = lookup(smb.value, "multichannel_enabled", null)
        }
      }
    }
  }

  #################
  # azure_files_authentication
  #################
  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication == null ? [] : [var.azure_files_authentication]
    content {
      directory_type                 = azure_files_authentication.value.directory_type
      default_share_level_permission = lookup(azure_files_authentication.value, "default_share_level_permission", null)

      dynamic "active_directory" {
        for_each = azure_files_authentication.value.active_directory == null ? [] : [azure_files_authentication.value.active_directory]
        content {
          domain_name         = active_directory.value.domain_name
          domain_guid         = active_directory.value.domain_guid
          domain_sid          = lookup(active_directory.value, "domain_sid", null)
          storage_sid         = lookup(active_directory.value, "storage_sid", null)
          forest_name         = lookup(active_directory.value, "forest_name", null)
          netbios_domain_name = lookup(active_directory.value, "netbios_domain_name", null)
        }
      }
    }
  }

  ###########
  # routing
  ###########
  dynamic "routing" {
    for_each = var.routing == null ? [] : [var.routing]
    content {
      publish_internet_endpoints  = lookup(routing.value, "publish_internet_endpoints", null)
      publish_microsoft_endpoints = lookup(routing.value, "publish_microsoft_endpoints", null)
      choice                      = lookup(routing.value, "choice", null)
    }
  }

  #####################
  # immutability_policy
  #####################
  dynamic "immutability_policy" {
    for_each = var.immutability_policy == null ? [] : [var.immutability_policy]
    content {
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes
      state                         = immutability_policy.value.state
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days
    }
  }

  ###########
  # sas_policy
  ###########
  dynamic "sas_policy" {
    for_each = var.sas_policy == null ? [] : [var.sas_policy]
    content {
      expiration_period = sas_policy.value.expiration_period
      expiration_action = lookup(sas_policy.value, "expiration_action", null)
    }
  }

  ################
  # network_rules
  ################
  network_rules {
    # C5 enforced:
    default_action = "Deny"
    bypass         = "None"

    ip_rules                   = length(coalesce(var.network_rules.ip_rules, [])) > 0 ? var.network_rules.ip_rules : var.ip_rules
    virtual_network_subnet_ids = length(coalesce(var.network_rules.virtual_network_subnet_ids, [])) > 0 ? var.network_rules.virtual_network_subnet_ids : var.subnet_ids

    dynamic "private_link_access" {
      for_each = coalesce(var.network_rules.private_link_access, [])
      content {
        endpoint_resource_id = private_link_access.value.endpoint_resource_id
        endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
      }
    }
  }
}

##########################################
# Management policy for lifecycle / C5  #
##########################################

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

###############################################
# Diagnostics for C5 logging (OPS-10..OPS-15)
###############################################

resource "azurerm_monitor_diagnostic_setting" "this" {
  name               = "${azurerm_storage_account.this.name}-c5"
  target_resource_id = azurerm_storage_account.this.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_log {
    category = "AllMetrics"
  }
}
