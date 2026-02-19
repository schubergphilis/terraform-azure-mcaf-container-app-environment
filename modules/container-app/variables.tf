variable "name" {
  type        = string
  nullable    = false
  description = "The name of the Container App."
}

variable "resource_group_name" {
  type        = string
  nullable    = false
  description = "The name of the resource group."
}

variable "container_app_environment_id" {
  type        = string
  nullable    = false
  description = "The ID of the Container App Environment."
}

variable "revision_mode" {
  type        = string
  default     = "Single"
  description = "The revision mode of the Container App. Valid values are 'Single' or 'Multiple'."

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be 'Single' or 'Multiple'."
  }
}

variable "workload_profile_name" {
  type        = string
  default     = null
  description = "The name of the workload profile to use."
}

variable "max_inactive_revisions" {
  type        = number
  default     = null
  description = "The maximum number of inactive revisions to keep."
}

variable "template" {
  type = object({
    min_replicas = optional(number, 0)
    max_replicas = optional(number, 10)

    containers = list(object({
      name    = string
      image   = string
      cpu     = number
      memory  = string
      command = optional(list(string))
      args    = optional(list(string))

      env = optional(list(object({
        name        = string
        value       = optional(string)
        secret_name = optional(string)
      })), [])

      volume_mounts = optional(list(object({
        name = string
        path = string
      })), [])

      liveness_probe = optional(object({
        port                    = number
        transport               = optional(string, "HTTP")
        path                    = optional(string)
        initial_delay           = optional(number, 1)
        interval_seconds        = optional(number, 10)
        timeout                 = optional(number, 1)
        failure_count_threshold = optional(number, 3)
      }))

      readiness_probe = optional(object({
        port                    = number
        transport               = optional(string, "HTTP")
        path                    = optional(string)
        initial_delay           = optional(number, 0)
        interval_seconds        = optional(number, 10)
        timeout                 = optional(number, 1)
        failure_count_threshold = optional(number, 3)
        success_count_threshold = optional(number, 3)
      }))

      startup_probe = optional(object({
        port                    = number
        transport               = optional(string, "HTTP")
        path                    = optional(string)
        initial_delay           = optional(number, 0)
        interval_seconds        = optional(number, 10)
        timeout                 = optional(number, 1)
        failure_count_threshold = optional(number, 3)
      }))
    }))

    init_containers = optional(list(object({
      name    = string
      image   = string
      cpu     = number
      memory  = string
      command = optional(list(string))
      args    = optional(list(string))

      env = optional(list(object({
        name        = string
        value       = optional(string)
        secret_name = optional(string)
      })), [])

      volume_mounts = optional(list(object({
        name = string
        path = string
      })), [])
    })), [])

    volumes = optional(list(object({
      name         = string
      storage_type = optional(string, "EmptyDir")
      storage_name = optional(string)
    })), [])
  })
  description = "The template configuration for the Container App."
}

variable "ingress" {
  type = object({
    external_enabled           = optional(bool, false)
    target_port                = number
    transport                  = optional(string, "auto")
    allow_insecure_connections = optional(bool, false)
    exposed_port               = optional(number)

    traffic_weight = optional(list(object({
      percentage      = number
      label           = optional(string)
      latest_revision = optional(bool, true)
      revision_suffix = optional(string)
    })), [{ percentage = 100, latest_revision = true }])

    ip_security_restrictions = optional(list(object({
      name             = string
      action           = string
      ip_address_range = string
      description      = optional(string)
    })), [])

    cors_policy = optional(object({
      allowed_origins   = list(string)
      allowed_methods   = optional(list(string))
      allowed_headers   = optional(list(string))
      expose_headers    = optional(list(string))
      max_age           = optional(number)
      allow_credentials = optional(bool, false)
    }))
  })
  default     = null
  description = "Ingress configuration for the Container App. external_enabled defaults to false for security."
}

variable "secrets" {
  type = list(object({
    name                = string
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))
  default     = []
  sensitive   = true
  description = "A list of secrets for the Container App. Use 'value' for inline secrets or 'key_vault_secret_id' + 'identity' for Key Vault references."
}

variable "registries" {
  type = list(object({
    server               = string
    username             = optional(string)
    password_secret_name = optional(string)
    identity             = optional(string)
  }))
  default     = []
  description = "A list of container registries for the Container App."
}

variable "dapr" {
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string, "http")
  })
  default     = null
  description = "Dapr configuration for the Container App."
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default     = null
  description = "Identity configuration for the Container App."

  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
}

variable "custom_domains" {
  type = list(object({
    name                     = string
    certificate_binding_type = optional(string, "SniEnabled")
    certificate_id           = optional(string)
  }))
  default     = []
  description = "A list of custom domains for the Container App."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the Container App."
}
