variable "name" {
  type        = string
  description = "The name of the Container Apps Managed Environment. Changing this forces a new resource to be created."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Container App Environment is to be created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the Container App Environment is to exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "infrastructure_subnet_id" {
  type        = string
  description = "The existing Subnet to use for the Container Apps Control Plane. Changing this forces a new resource to be created.\n\nThe Subnet must have a /21 or larger address space."
  nullable    = false
}

variable "infrastructure_resource_group_name" {
  type        = string
  description = "Name of the platform-managed resource group created for the Managed Environment to host infrastructure resources. Changing this forces a new resource to be created."
  nullable    = false
}

variable "internal_load_balancer_enabled" {
  type        = bool
  description = "Should the Container Environment operate in Internal Load Balancing Mode? Defaults to false. Changing this forces a new resource to be created."
  default     = false
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Should the Container App Environment be created with Zone Redundancy enabled? Defaults to true. Changing this forces a new resource to be created."
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "(Optional) The ID for the Log Analytics Workspace to link this Container Apps Managed Environment to."
  nullable    = true
}

variable "workload_profile" {
  type = object({
    name = string
    type = string
  })
  default = {
    name = "Consumption"
    type = "Consumption"
  }
  description = "The name and type of the workload profile.\nDefaults to Consumption."
  validation {
    condition     = contains(["Consumption", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], var.workload_profile.type)
    error_message = "Invalid workload profile. Valid values are Consumption, D4, D8, D16, D32, E4, E8, E16, E32."
  }
}

variable "certificate" {
  type = object({
    name        = optional(string)
    blob_base64 = string
    password    = optional(string, "")
  })
  default = null
}
