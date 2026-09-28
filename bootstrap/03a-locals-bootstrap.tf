# ============================================================
# 03a-locals.tf
# Locals for IAM, VPN Tunnels, and Router Interfaces
# ============================================================


locals {
  # -------------------------------------------------------------------
  # Project IDs keyed by logical project key (friendly name -> real ID)
  # -------------------------------------------------------------------
  project_ids = {
    taaops         = var.balerica_project
    genosha-ops    = var.genosha_project
    wakanda-ops    = var.wakanda_project # preferred *-ops alias
    class-6-5-tiqs = var.tiqs_project
    tiqs-ops       = var.tiqs_project # preferred *-ops alias
    dale-ops       = var.dale_project
    cas-ops        = var.cas_project
    # future spokes extend here
  }

  # -------------------------------------------------------------------
  # Canonical map of logical project key -> Terraform SA email
  # Normalize incoming spokes to preferred keys to avoid duplicates.
  # Normalization logic converts the raw key into the preferred key - 
  # map the real project IDs with the preferred logical keys;
  # incoming raw project ID  gets rewritten to the *-ops alias before merging
  # -------------------------------------------------------------------
  normalized_spokes = {
    for k, v in var.spokes :
    (
      k == "class-6-5-tiqs" ? "tiqs-ops" :
      k == "changing3-15-25" ? "dale-ops" :
      k == "kazapes1" ? "cas-ops" :
      k
    ) => v
  }

  normalized_extra_spokes = {
    for k, v in var.extra_bootstrap_spokes :
    (
      k == "class-6-5-tiqs" ? "tiqs-ops" :
      k == "changing3-15-25" ? "dale-ops" :
      k == "kazapes1" ? "cas-ops" :
      k
    ) => v
  }




  spoke_sas = merge(
    local.normalized_spokes,
    {
      taaops      = var.balerica_sa
      genosha-ops = var.genosha_sa
      wakanda-ops = var.wakanda_sa # preferred *-ops alias
      tiqs-ops    = var.tiqs_sa    # preferred *-ops alias
      dale-ops    = var.dale_sa    # preferred *-ops alias
      cas-ops     = var.cas_sa     # preferred *-ops alias
    },
    local.normalized_extra_spokes
  )


  # -------------------------------------------------------------------
  # Normalized spoke context: include real project IDs alongside emails
  # -------------------------------------------------------------------
  spoke_context = {
    for key, sa in local.spoke_sas :
    key => {
      project_id = local.project_ids[key]
      sa         = sa
    }
    if contains(keys(local.project_ids), key)
  }

  # Shortcut lookup: project ID -> Terraform SA email
  spoke_sa_by_project_id = {
    for _, ctx in local.spoke_context :
    ctx.project_id => ctx.sa
  }

  # Shared custom role ID for cross-project VPN administration
  vpn_role_id = "terraform_vpn_role"

  # -------------------------------------------------------------------
  # Baseline roles + expand into bindings
  # -------------------------------------------------------------------
  baseline_roles = toset([
    "roles/viewer",
    "roles/compute.networkAdmin",
    "roles/networkconnectivity.admin",
    "roles/compute.instanceAdmin.v1",
    "roles/compute.admin",
    "roles/iam.serviceAccountUser",
  ])

  baseline_bindings = flatten([
    for key, ctx in local.spoke_context : [
      for role in local.baseline_roles : {
        key        = "${ctx.project_id}-${role}"
        project_id = ctx.project_id
        sa         = ctx.sa
        role       = role
      }
    ]
  ])

  baseline_bindings_map = {
    for b in local.baseline_bindings : b.key => b
  }

  # -------------------------------------------------------------------
  # Cross-project impersonation (vpn_role sharing)
  # -------------------------------------------------------------------
  cross_bindings = flatten([
    for src_key, src_ctx in local.spoke_context : [
      for dst_key, dst_ctx in local.spoke_context : {
        key         = "${src_ctx.project_id}->${dst_ctx.project_id}"
        src_project = src_ctx.project_id
        dst_project = dst_ctx.project_id
        sa          = src_ctx.sa
        role_id     = local.vpn_role_id
      }
      if src_key != dst_key
    ]
  ])

  cross_bindings_map = {
    for b in local.cross_bindings : b.key => b
  }

}


/*
  # -------------------------------------------------------------------
  # VPC IDs keyed by project (from VPC modules)
  # -------------------------------------------------------------------
  vpc_ids = {
    taaops      = module.balerica_vpc.vpc_id
    genosha-ops = module.genosha_vpc.vpc_id
    wakanda-ops = module.wakanda_vpc.vpc_id
    tiqs-ops    = module.tiqs_vpc.vpc_id
    # future spokes extend here
  }


/* Removed for bootstrap layer

  # -------------------------------------------------------------------
  # Flattened VPN tunnels (from var.tunnels HA definition)
  # -------------------------------------------------------------------
  vpn_tunnels_flattened = flatten([
    for k, v in var.tunnels : [
      for tname, t in v.tunnels : {
        tunnel_key = "${k}-${tname}" # e.g., balerica-genosha-t0
        name       = tname
        src        = v.src
        dst        = v.dst
        region_src = v.region_src
        region_dst = v.region_dst
        psk        = t.psk
        ip_src     = t.ip_src
        ip_dst     = t.ip_dst
        asn_src    = v.asn_src
        asn_dst    = v.asn_dst
      }
    ]
  ])

  vpn_tunnels_map = {
    for tunnel in local.vpn_tunnels_flattened :
    tunnel.tunnel_key => tunnel
  }

  # -------------------------------------------------------------------
  # Tunnel participants (all unique projects)
  # -------------------------------------------------------------------
  tunnel_projects = toset([
    for project in flatten([for _, v in var.tunnels : [v.src, v.dst]]) :
    project if contains(keys(local.project_ids), project)
  ])

  # Map tunnel label ("t0"/"t1") to HA gateway interface index
  interface_index = {
    t0 = 0
    t1 = 1
    t2 = 0
    t3 = 1
    # predefine more if you will scale further
  }

  # -------------------------------------------------------------------
  # Flattened router interfaces (bind tunnels to routers)
  # -------------------------------------------------------------------
  router_flattened = flatten([
    for k, v in var.tunnels : [
      for tname, t in v.tunnels : {
        router_key     = "${k}-${tname}"
        src_key        = v.src
        dst_key        = v.dst
        src_project_id = local.project_ids[v.src]
        dst_project_id = local.project_ids[v.dst]
        region         = v.region_src
        router         = "${v.src}-router"
        ip_range       = t.ip_src # your 169.254.x.x/30 goes here
        tunnel         = "${v.src}-to-${v.dst}-${tname}"
        peer_asn       = v.asn_dst
        name           = tname
      }
      if contains(keys(local.project_ids), v.src) && contains(keys(local.project_ids), v.dst)
    ]
  ])

  router_map = {
    for r in local.router_flattened : r.router_key => r
  }


*/
