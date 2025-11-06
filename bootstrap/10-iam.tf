# ============================================
# 10-iam.tf
# IAM bindings (baseline + cross-project)
# ============================================

# Baseline roles - every SA in its own project
resource "google_project_iam_member" "baseline_roles" {
  for_each = local.baseline_bindings_map

  project = each.value.project_id
  member  = "serviceAccount:${each.value.sa}"
  role    = each.value.role
}

# Cross-project impersonation (SA in project X -> vpn_role in project Y)
resource "google_project_iam_member" "cross_bindings" {
  for_each = local.cross_bindings_map

  project = each.value.dst_project
  member  = "serviceAccount:${each.value.sa}"
  role    = "projects/${each.value.dst_project}/roles/${each.value.role_id}"

  depends_on = [
    google_project_iam_custom_role.vpn_role_taaops,
    google_project_iam_custom_role.vpn_role_genosha,
    google_project_iam_custom_role.vpn_role_wakanda,
    google_project_iam_custom_role.vpn_role_tiqs,
  ]
}
