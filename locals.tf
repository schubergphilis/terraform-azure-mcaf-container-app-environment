locals {
  # Determine if workload profiles should be used
  use_workload_profiles = length(var.workload_profiles) > 0

  # Build workload profiles list including consumption if any profiles are defined
  # For Consumption profiles, minimum_count and maximum_count must be null
  # as Azure does not support these attributes for the Consumption type.
  workload_profiles = local.use_workload_profiles ? {
    for k, v in merge(
      {
        "Consumption" = {
          workload_profile_type = "Consumption"
          minimum_count         = null
          maximum_count         = null
        }
      },
      var.workload_profiles
      ) : k => {
      workload_profile_type = v.workload_profile_type
      minimum_count         = v.workload_profile_type == "Consumption" ? null : v.minimum_count
      maximum_count         = v.workload_profile_type == "Consumption" ? null : v.maximum_count
    }
  } : {}

  # Default tags
  default_tags = {
    ManagedBy = "Terraform"
  }

  tags = merge(local.default_tags, var.tags)
}
