variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "principal_id" {
  description = "The object id of the terraform principal (Optional). If not supplied then data.azurerm_client_config.current.object_id will be used"
  type        = string
  default     = null
}

variable "aks_name" { 
  type = string

  validation {
    condition     = length(var.aks_name) > 0
    error_message = "The aks_name variable must be supplied"
  }
}

variable "aks_sku" { 
  type = string

  validation {
    condition     = length(var.aks_sku) > 0
    error_message = "The aks_sku variable must be supplied"
  }
}

variable "aks_kubernetes_version" { 
  type = string

  validation {
    condition     = length(var.aks_kubernetes_version) > 0
    error_message = "The aks_kubernetes_version variable must be supplied"
  }
}

variable "vnet_id" { 
  type = string

  validation {
    condition     = length(var.vnet_id) > 0
    error_message = "The vnet_id variable must be supplied"
  }
}

variable "vnet_subnet_id" { 
  type = string

  validation {
    condition     = length(var.vnet_subnet_id) > 0
    error_message = "The vnet_subnet_id variable must be supplied"
  }
}

variable "aks_system_node_vm_size" {
  type        = string
  description = "Azure VM size to be used for the system nodes"

  validation {
    condition     = length(var.aks_system_node_vm_size) > 0
    error_message = "The aks_system_node_vm_size variable must be supplied"
  }
}

variable "aks_system_node_disk_size" {
  type        = number
  description = "Azure disk size to be used for the system nodes"

  validation {
    condition     = var.aks_system_node_disk_size > 0
    error_message = "The aks_system_node_disk_size variable must be supplied"
  }
}

variable "aks_system_node_min_count" {
  type        = number
  description = "Minimum number of system nodes for autoscaling and before spotting"

  validation {
    condition     = var.aks_system_node_min_count > 0
    error_message = "The aks_system_node_min_count variable must be supplied"
  }
}

variable "aks_system_node_max_count" {
  type        = number
  description = "Maximum number of system nodes for autoscaling"

  validation {
    condition     = var.aks_system_node_max_count > 0
    error_message = "The aks_system_node_max_count variable must be supplied"
  }
}

variable "user_node_pools" {
  type = list(object({
    name      = string
    os_type   = string
    vm_size   = string
    disk_size = number
    min_count = number
    max_count = number
  }))

  validation {
    condition     = length(var.user_node_pools) > 0
    error_message = "The user_node_pools variable must be supplied"
  }

  validation {
    condition = alltrue([
      for x in var.user_node_pools : length(x.name) > 0
    ])
    error_message = "All user node pools must have a name variable supplied"
  }

  validation {
    condition = alltrue([
      for o in var.user_node_pools : contains(["Linux", "Windows"], o.os_type)
    ])
    error_message = "All user node pools must have an os_type variable supplied with a value of either 'Linux' or 'Windows'"
  }

  validation {
    condition = alltrue([
      for x in var.user_node_pools : length(x.vm_size) > 0
    ])
    error_message = "All user node pools must have a vm_size variable supplied"
  }

  validation {
    condition = alltrue([
      for x in var.user_node_pools : x.disk_size > 0
    ])
    error_message = "All user node pools must have a disk_size variable supplied"
  }

  validation {
    condition = alltrue([
      for x in var.user_node_pools : x.min_count > 0
    ])
    error_message = "All user node pools must have a min_count variable supplied"
  }

  validation {
    condition = alltrue([
      for x in var.user_node_pools : x.max_count > 0
    ])
    error_message = "All user node pools must have a max_count variable supplied"
  }
}

variable "aks_use_spot" {
  type        = bool
  description = "Should the user node pools be configured to use spot instances"
  default     = false
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}

variable "ip_rules" {
  description = "List of IP addresses that are allowed to access the AKS Cluster"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs that are allowed to access the AKS Cluster"
  type        = list(string)
  default     = []
}