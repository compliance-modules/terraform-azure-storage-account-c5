variable "location" {
  type        = string
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the resource."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters, valid characters are lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`.  Defaults to `ZRS`"
  nullable    = false

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Invalid value for replication type. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`."
  }
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "(Required) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created."
  nullable    = false

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Invalid value for account tier. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created."
  }
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "(Required) The Kind of storage account. Valid options are `Storage`, `StorageV2`, `BlobStorage`, `FileStorage`, `BlockBlobStorage`, and `PremiumBlockBlobStorage`."
  nullable    = false

  validation {
    condition     = contains(["Storage", "StorageV2", "BlobStorage", "FileStorage", "BlockBlobStorage", "PremiumBlockBlobStorage"], var.account_kind)
    error_message = "Invalid value for account kind. Valid options are `Storage`, `StorageV2`, `BlobStorage`, `FileStorage`, `BlockBlobStorage`, and `PremiumBlockBlobStorage`."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of Subnet IDs to be allowed access to the Storage Account."
  nullable    = false
  default     = []
}

variable "ip_rules" {
  type        = list(string)
  description = "List of IP addresses or CIDR ranges to be allowed access to the Storage Account."
  nullable    = false
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  nullable    = false
  default     = {}
}

variable "cmk" {
  type = object({
    key_vault_id = string
    key_name     = string
    key_version  = string
  })
  description = "Customer-managed key (CMK) details for at-rest encryption."
  nullable    = true
  default     = null
}

variable "lifecycle_prefix_match" {
  type        = set(string)
  description = "Prefixes to match for the lifecycle management rule."
  nullable    = false
  default     = [""]
}

variable "lifecycle_delete_after_days" {
  type        = number
  description = "Number of days after which blobs are deleted in the lifecycle management rule."
  nullable    = false
  default     = 365
}