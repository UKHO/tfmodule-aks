variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The vnet_resource_group_name variable must be supplied"
  }
}

variable "location" {
  description = "Azure region"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "The location variable must be supplied"
  }
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string

  validation {
    condition     = length(var.tenant_id) > 0
    error_message = "The tenant_id variable must be supplied"
  }
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

variable "vnet_name" {
  type = string

  validation {
    condition     = length(var.vnet_name) > 0
    error_message = "The vnet_name variable must be supplied"
  }
}

variable "vnet_resource_group_name" {
  type    = string
  default = "m-spokeconfig-rg"

  validation {
    condition     = length(var.vnet_resource_group_name) > 0
    error_message = "The vnet_resource_group_name variable must be supplied"
  }
}

variable "aks_subnet_name" {
  type = string

  validation {
    condition     = length(var.aks_subnet_name) > 0
    error_message = "The aks_subnet_name variable must be supplied"
  }
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

# Flux

variable "flux_enabled" {
  description = "Enable Flux configuration for the AKS cluster"
  type        = bool
  default     = false
}

variable "flux_git_repository_url" {
  description = "Git repository URL for Flux configuration"
  type        = string
  default     = ""
  
  validation {
    condition     = (length(var.flux_git_repository_url) > 0 || var.flux_enabled == false)
    error_message = "The flux_git_repository_url variable must be supplied if Flux is enabled"
  }
}

variable "flux_git_reference_type" {
  description = "Git reference type for Flux configuration (e.g., branch, tag)"
  type        = string
  default     = "branch"
  
  validation {
    condition     = (length(var.flux_git_reference_type) > 0 || var.flux_enabled == false)
    error_message = "The flux_git_reference_type variable must be supplied if Flux is enabled"
  }
}

variable "flux_git_reference_value" {
  description = "Git reference value for Flux configuration (e.g., branch name, tag name)"
  type        = string
  default     = "main"
  
  validation {
    condition     = (length(var.flux_git_reference_value) > 0 || var.flux_enabled == false)
    error_message = "The flux_git_reference_value variable must be supplied if Flux is enabled"
  }
}

variable "flux_ssh_private_key_base64" {
  description = "Base64 encoded SSH private key for Flux Git repository access"
  type        = string
  default     = ""
  
  validation {
    condition     = (length(var.flux_ssh_private_key_base64) > 0 || var.flux_enabled == false)
    error_message = "The flux_ssh_private_key_base64 variable must be supplied if Flux is enabled"
  }
}

variable "flux_git_repository_path" {
  description = "Path to the Flux Git repository configuration"
  type        = string
  default     = ""
  
  validation {
    condition     = (length(var.flux_git_repository_path) > 0 || var.flux_enabled == false)
    error_message = "The flux_git_repository_path variable must be supplied if Flux is enabled"
  }
}

# PE

variable "pe_enabled" {
  description = "Enable private endpoint"
  type        = bool
  default     = true
}

variable "pe_environment" {
    description = "environment for private endpoint (for example dev | prd | qa | pre)"
    default = ""

  validation {
    condition     = var.pe_enabled == true ? length(var.pe_environment) > 0 : true
    error_message = "The pe_environment variable must be supplied"
  }
}

variable "pe_subnet_name" {
  description = "subnet name that the private endpoint will associate"
  default     = ""

  validation {
    condition     = var.pe_enabled == true ? length(var.pe_subnet_name) > 0 : true
    error_message = "The pe_subnet_name variable must be supplied"
  }
}

variable "dns_resource_group_name" {
  description = "dns resource group name, please change domain-rg to either business-rg or engineering-rg"
  default     = ""

  validation {
    condition     = var.pe_enabled == true ? length(var.dns_resource_group_name) > 0 : true
    error_message = "The dns_resource_group_name variable must be supplied"
  }
}

variable "dns_zone_group_name" {
  description = "private dns zone group"
  default     = ""

  validation {
    condition     = var.pe_enabled == true ? length(var.dns_zone_group_name) > 0 : true
    error_message = "The dns_zone_group_name variable must be supplied"
  }
}

variable "dns_zone_name" {
  description = "alias to create private dns zone - be aware this is dependant on the endpoint"
  default     = "privatelink.azurewebsites.net"

  validation {
    condition     = var.pe_enabled == true ? length(var.dns_zone_name) > 0 : true
    error_message = "The dns_zone_name variable must be supplied"
  }
}