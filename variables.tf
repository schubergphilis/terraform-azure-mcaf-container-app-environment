# Required variables
variable "name" {
  type        = string
  nullable    = false
  description = "The name of the Container App Environment."
}

variable "resource_group_name" {
  type        = string
  nullable    = false
  description = "The name of the resource group in which to create the Container App Environment."
}

variable "location" {
  type        = string
  nullable    = false
  description = "The Azure region where the Container App Environment will be created."
}

variable "infrastructure_subnet_id" {
  type        = string
  nullable    = false
  description = "The ID of the subnet to use for the Container App Environment infrastructure. Must be a /21 or larger address space."
}

# Optional variables with secure defaults
variable "internal_load_balancer_enabled" {
  type        = bool
  default     = true
  description = "Whether the Container App Environment should use an internal load balancer. Defaults to true for security."
}

variable "zone_redundancy_enabled" {
  type        = bool
  default     = true
  description = "Whether zone redundancy is enabled for the Container App Environment. Defaults to true for high availability."
}

variable "mutual_tls_enabled" {
  type        = bool
  default     = true
  description = "Whether mutual TLS authentication is enabled for service-to-service communication. Defaults to true for security."
}

variable "logs_destination" {
  type        = string
  default     = null
  description = "The destination for logs. Valid values are 'log-analytics' or 'azure-monitor'. Set to null to disable."

  validation {
    condition     = var.logs_destination == null || contains(["log-analytics", "azure-monitor"], var.logs_destination)
    error_message = "logs_destination must be 'log-analytics', 'azure-monitor', or null."
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the Log Analytics Workspace to send logs to. Required when logs_destination is 'log-analytics'."
}

variable "dapr_application_insights_connection_string" {
  type        = string
  default     = null
  sensitive   = true
  description = "The Application Insights connection string for Dapr telemetry."
}

variable "infrastructure_resource_group_name" {
  type        = string
  default     = null
  description = "The name of the resource group for the platform-managed infrastructure resources."
}

variable "workload_profiles" {
  type = map(object({
    workload_profile_type = string
    minimum_count         = optional(number)
    maximum_count         = optional(number)
  }))
  default     = {}
  description = "A map of workload profiles for the Container App Environment. Key is the profile name."

  validation {
    condition = alltrue([
      for k, v in var.workload_profiles :
      contains(["Consumption", "Consumption-GPU-NC24-A100", "Consumption-GPU-NC8as-T4", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32", "NC24-A100", "NC48-A100", "NC96-A100"], v.workload_profile_type)
    ])
    error_message = "workload_profile_type must be one of: Consumption, Consumption-GPU-NC24-A100, Consumption-GPU-NC8as-T4, D4, D8, D16, D32, E4, E8, E16, E32, NC24-A100, NC48-A100, NC96-A100."
  }
}

variable "storage" {
  type = map(object({
    account_name = string
    share_name   = string
    access_key   = string
    access_mode  = optional(string, "ReadOnly")
  }))
  default     = {}
  description = "A map of storage configurations for the Container App Environment. Note: access_key contains sensitive data."

  validation {
    condition = alltrue([
      for k, v in var.storage :
      contains(["ReadOnly", "ReadWrite"], v.access_mode)
    ])
    error_message = "access_mode must be 'ReadOnly' or 'ReadWrite'."
  }
}

variable "custom_domain" {
  type = object({
    dns_suffix              = string
    certificate_blob_base64 = string
    certificate_password    = string
  })
  default     = null
  sensitive   = true
  description = "Custom domain configuration for the Container App Environment."
}

variable "container_apps" {
  type = map(object({
    revision_mode          = optional(string, "Single")
    workload_profile_name  = optional(string)
    max_inactive_revisions = optional(number)

    template = object({
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

    ingress = optional(object({
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
    }))

    secrets = optional(list(object({
      name                = string
      value               = optional(string)
      key_vault_secret_id = optional(string)
      identity            = optional(string)
    })), [])

    registries = optional(list(object({
      server               = string
      username             = optional(string)
      password_secret_name = optional(string)
      identity             = optional(string)
    })), [])

    dapr = optional(object({
      app_id       = string
      app_port     = optional(number)
      app_protocol = optional(string, "http")
    }))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }))

    custom_domains = optional(list(object({
      name                     = string
      certificate_binding_type = optional(string, "SniEnabled")
      certificate_id           = optional(string)
    })), [])
  }))
  default     = {}
  description = "A map of container apps to create in this environment. Note: secrets contains sensitive data."

  validation {
    condition = alltrue([
      for k, v in var.container_apps :
      contains(["Single", "Multiple"], v.revision_mode)
    ])
    error_message = "revision_mode must be 'Single' or 'Multiple'."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resources."
}
