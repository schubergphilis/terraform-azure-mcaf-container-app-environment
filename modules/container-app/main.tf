resource "azurerm_container_app" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name
  tags                         = var.tags

  template {
    min_replicas = var.template.min_replicas
    max_replicas = var.template.max_replicas

    dynamic "container" {
      for_each = var.template.containers
      content {
        name    = container.value.name
        image   = container.value.image
        cpu     = container.value.cpu
        memory  = container.value.memory
        command = container.value.command
        args    = container.value.args

        dynamic "env" {
          for_each = container.value.env
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }

        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
          content {
            port                    = liveness_probe.value.port
            transport               = liveness_probe.value.transport
            path                    = liveness_probe.value.path
            initial_delay           = liveness_probe.value.initial_delay
            interval_seconds        = liveness_probe.value.interval_seconds
            timeout                 = liveness_probe.value.timeout
            failure_count_threshold = liveness_probe.value.failure_count_threshold
          }
        }

        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
          content {
            port                    = readiness_probe.value.port
            transport               = readiness_probe.value.transport
            path                    = readiness_probe.value.path
            initial_delay           = readiness_probe.value.initial_delay
            interval_seconds        = readiness_probe.value.interval_seconds
            timeout                 = readiness_probe.value.timeout
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            success_count_threshold = readiness_probe.value.success_count_threshold
          }
        }

        dynamic "startup_probe" {
          for_each = container.value.startup_probe != null ? [container.value.startup_probe] : []
          content {
            port                    = startup_probe.value.port
            transport               = startup_probe.value.transport
            path                    = startup_probe.value.path
            initial_delay           = startup_probe.value.initial_delay
            interval_seconds        = startup_probe.value.interval_seconds
            timeout                 = startup_probe.value.timeout
            failure_count_threshold = startup_probe.value.failure_count_threshold
          }
        }
      }
    }

    dynamic "init_container" {
      for_each = var.template.init_containers
      content {
        name    = init_container.value.name
        image   = init_container.value.image
        cpu     = init_container.value.cpu
        memory  = init_container.value.memory
        command = init_container.value.command
        args    = init_container.value.args

        dynamic "env" {
          for_each = init_container.value.env
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "volume" {
      for_each = var.template.volumes
      content {
        name         = volume.value.name
        storage_type = volume.value.storage_type
        storage_name = volume.value.storage_name
      }
    }
  }

  dynamic "ingress" {
    for_each = var.ingress != null ? [var.ingress] : []
    content {
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      transport                  = ingress.value.transport
      allow_insecure_connections = ingress.value.allow_insecure_connections
      exposed_port               = ingress.value.exposed_port

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight
        content {
          percentage      = traffic_weight.value.percentage
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
        }
      }

      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restrictions
        content {
          name             = ip_security_restriction.value.name
          action           = ip_security_restriction.value.action
          ip_address_range = ip_security_restriction.value.ip_address_range
          description      = ip_security_restriction.value.description
        }
      }

      dynamic "cors" {
        for_each = ingress.value.cors_policy != null ? [ingress.value.cors_policy] : []
        content {
          allowed_origins           = cors.value.allowed_origins
          allowed_methods           = cors.value.allowed_methods
          allowed_headers           = cors.value.allowed_headers
          exposed_headers           = cors.value.expose_headers
          max_age_in_seconds        = cors.value.max_age
          allow_credentials_enabled = cors.value.allow_credentials
        }
      }
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name                = secret.value.name
      value               = secret.value.key_vault_secret_id == null ? secret.value.value : null
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = secret.value.identity
    }
  }

  dynamic "registry" {
    for_each = var.registries
    content {
      server               = registry.value.server
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
      identity             = registry.value.identity
    }
  }

  dynamic "dapr" {
    for_each = var.dapr != null ? [var.dapr] : []
    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

resource "azurerm_container_app_custom_domain" "this" {
  for_each = { for domain in var.custom_domains : domain.name => domain }

  container_app_id                         = azurerm_container_app.this.id
  name                                     = each.value.name
  certificate_binding_type                 = each.value.certificate_binding_type
  container_app_environment_certificate_id = each.value.certificate_id
}
