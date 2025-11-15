######################
# Core required args #
######################

variable "name" {
  type        = string
  description = "Specifies the name of the storage account."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters, valid characters are lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account."
}

variable "location" {
  type        = string
  description = "Specifies the Azure location where the storage account should be created."
}

variable "account_kind" {
  type        = string
  description = "Defines the kind of account. Valid: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  default     = "StorageV2"
  nullable    = false

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "account_kind must be one of BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "account_tier" {
  type        = string
  description = "Defines the tier. Valid: Standard, Premium."
  default     = "Standard"
  nullable    = false

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be Standard or Premium."
  }
}

variable "account_replication_type" {
  type        = string
  description = "Defines the type of replication. Valid: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  default     = "ZRS"
  nullable    = false

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

##########################
# Top-level simple args  #
##########################

variable "provisioned_billing_model_version" {
  type        = string
  description = "Version of the provisioned billing model (e.g. V2)."
  default     = null
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  description = "Should cross tenant replication be enabled?"
  default     = null
}

variable "access_tier" {
  type        = string
  description = "Access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid: Hot, Cool, Cold, Premium."
  default     = null

  validation {
    condition     = var.access_tier == null || contains(["Hot", "Cool", "Cold", "Premium"], var.access_tier)
    error_message = "access_tier must be one of Hot, Cool, Cold, Premium."
  }
}

variable "edge_zone" {
  type        = string
  description = "Edge Zone within the Azure region for this storage account."
  default     = null
}

# C5-relevant fields we **don’t expose as variables**:
# - https_traffic_only_enabled (we will force `true` in main.tf)
# - min_tls_version (we rely on provider default TLS1_2)
# - allow_nested_items_to_be_public (we will force `false`)
# - shared_access_key_enabled (we will force `false`)
# - public_network_access_enabled (we will force `false`)
# - infrastructure_encryption_enabled (we will force `true`)

variable "default_to_oauth_authentication" {
  type        = bool
  description = "Default to Azure AD authorization in the Azure portal when accessing the storage account."
  default     = null
}

variable "is_hns_enabled" {
  type        = bool
  description = "Is Hierarchical Namespace enabled (Data Lake Gen2)?"
  default     = null
}

variable "nfsv3_enabled" {
  type        = bool
  description = "Is NFSv3 protocol enabled?"
  default     = null
}

variable "large_file_share_enabled" {
  type        = bool
  description = "Are Large File Shares enabled?"
  default     = null
}

variable "local_user_enabled" {
  type        = bool
  description = "Is Local User enabled?"
  default     = null
}

variable "queue_encryption_key_type" {
  type        = string
  description = "Encryption type of queue service. Valid: Service, Account."
  default     = null
}

variable "table_encryption_key_type" {
  type        = string
  description = "Encryption type of table service. Valid: Service, Account."
  default     = null
}

variable "allowed_copy_scope" {
  type        = string
  description = "Restrict copy scope. Valid: AAD, PrivateLink."
  default     = null
}

variable "sftp_enabled" {
  type        = bool
  description = "Enable SFTP for the storage account."
  default     = null
}

variable "dns_endpoint_type" {
  type        = string
  description = "DNS endpoint type. Valid: Standard, AzureDnsZone."
  default     = null

  validation {
    condition     = var.dns_endpoint_type == null || contains(["Standard", "AzureDnsZone"], var.dns_endpoint_type)
    error_message = "dns_endpoint_type must be Standard or AzureDnsZone."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to the storage account."
  default     = {}
  nullable    = false
}

###################################
# Network rules & access control  #
###################################

variable "network_rules" {
  description = <<DESC
Network rules for the storage account. C5 module will always enforce default_action = "Deny" and bypass = "None" regardless of values.
DESC
  type = object({
    default_action             = optional(string)       # will be ignored / overridden
    bypass                     = optional(list(string)) # will be ignored / overridden
    ip_rules                   = optional(list(string))
    virtual_network_subnet_ids = optional(list(string))
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })))
  })
  default = {
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

# Shortcuts you already had (kept for convenience)
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to allow access."
  default     = []
  nullable    = false
}

variable "ip_rules" {
  type        = list(string)
  description = "List of IP addresses or CIDR ranges to allow access."
  default     = []
  nullable    = false
}

#################
# custom_domain #
#################

variable "custom_domain" {
  type = object({
    name          = string
    use_subdomain = optional(bool)
  })
  default     = null
  description = "Custom domain configuration for the storage account."
}

#######################
# customer_managed_key#
#######################

variable "customer_managed_key" {
  type = object({
    key_vault_key_id          = optional(string)
    managed_hsm_key_id        = optional(string)
    user_assigned_identity_id = string
  })
  default     = null
  description = "Customer-managed key block for encryption at rest."
}

############
# identity #
############

variable "identity" {
  type = object({
    type         = string # SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned
    identity_ids = optional(list(string))
  })
  default     = null
  description = "Managed identity configuration."
}

#################
# blob_properties
#################

variable "blob_properties" {
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    delete_retention_policy = optional(object({
      days                     = optional(number)
      permanent_delete_enabled = optional(bool)
    }))
    restore_policy = optional(object({
      days = number
    }))
    versioning_enabled            = optional(bool)
    change_feed_enabled           = optional(bool)
    change_feed_retention_in_days = optional(number)
    default_service_version       = optional(string)
    last_access_time_enabled      = optional(bool)
    container_delete_retention_policy = optional(object({
      days = optional(number)
    }))
  })
  default     = null
  description = "Blob service properties."
}

##################
# queue_properties
##################

variable "queue_properties" {
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    logging = optional(object({
      delete                = bool
      read                  = bool
      write                 = bool
      version               = string
      retention_policy_days = optional(number)
    }))
    minute_metrics = optional(object({
      enabled               = bool
      version               = string
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
    }))
    hour_metrics = optional(object({
      enabled               = bool
      version               = string
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
    }))
  })
  default     = null
  description = "Queue service properties."
}

#################
# static_website #
#################

variable "static_website" {
  type = object({
    index_document     = optional(string)
    error_404_document = optional(string)
  })
  default     = null
  description = "Static website configuration."
}

##################
# share_properties
##################

variable "share_properties" {
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    retention_policy = optional(object({
      days = optional(number)
    }))
    smb = optional(object({
      versions                        = optional(set(string))
      authentication_types            = optional(set(string))
      kerberos_ticket_encryption_type = optional(set(string))
      channel_encryption_type         = optional(set(string))
      multichannel_enabled            = optional(bool)
    }))
  })
  default     = null
  description = "File share properties."
}

###########################
# azure_files_authentication
###########################

variable "azure_files_authentication" {
  type = object({
    directory_type                 = string # AADDS, AD, AADKERB
    default_share_level_permission = optional(string)
    active_directory = optional(object({
      domain_name         = string
      domain_guid         = string
      domain_sid          = optional(string)
      storage_sid         = optional(string)
      forest_name         = optional(string)
      netbios_domain_name = optional(string)
    }))
  })
  default     = null
  description = "Azure Files authentication configuration."
}

###########
# routing #
###########

variable "routing" {
  type = object({
    publish_internet_endpoints  = optional(bool)
    publish_microsoft_endpoints = optional(bool)
    choice                      = optional(string) # InternetRouting, MicrosoftRouting
  })
  default     = null
  description = "Routing configuration."
}

#####################
# immutability_policy
#####################

variable "immutability_policy" {
  type = object({
    allow_protected_append_writes = bool
    state                         = string # Disabled, Unlocked, Locked
    period_since_creation_in_days = number
  })
  default     = null
  description = "Account-level immutability policy."
}

###########
# sas_policy
###########

variable "sas_policy" {
  type = object({
    expiration_period = string
    expiration_action = optional(string) # Log or Block
  })
  default     = null
  description = "SAS policy configuration."
}

####################################
# Lifecycle & logging (from before)
####################################

variable "lifecycle_prefix_match" {
  type        = set(string)
  description = "Prefixes to match for the lifecycle management rule."
  nullable    = false
  default     = [""]
}

variable "lifecycle_delete_after_days" {
  type        = number
  description = "Number of days after which blobs/versions are deleted."
  nullable    = false
  default     = 365
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for diagnostic logs."
  nullable    = false
}