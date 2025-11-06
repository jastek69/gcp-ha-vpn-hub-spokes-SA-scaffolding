# Output for Bootstrap
# ================================
# IAM Sanity Checks
# ================================

output "spoke_sas" {
  description = "Project → Terraform SA email"
  value       = local.spoke_sas
}

output "baseline_roles_applied" {
  description = "Baseline IAM role bindings per project"
  value = {
    for k, v in google_project_iam_member.baseline_roles : k => {
      project = v.project
      role    = v.role
      member  = v.member
    }
  }
}

output "cross_project_bindings" {
  description = "Cross-project VPN role bindings (src SA → dst project)"
  value = {
    for k, v in google_project_iam_member.cross_bindings : k => {
      src_project = v.member
      dst_project = v.project
      role        = v.role
    }
  }
}

# ================================
# VPN + Router Sanity Checks
# ================================

// Infra-only outputs removed from bootstrap to keep validation clean
