# ============================================================
# 03a-locals-infra.tf
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
    tiqs-ops       = var.tiqs_project # preferred *-ops alias for TIQS
    dale-ops       = var.dale_project # preferred *-ops alias for Dale
    cas-ops        = var.cas_project  # preferred *-ops alias for CAS 
    # future spokes extend here
  }

  # -------------------------------------------------------------------
  # Canonical map of logical project key -> Terraform SA email
  # -------------------------------------------------------------------
  spoke_sas = {
    taaops      = var.balerica_sa
    genosha-ops = var.genosha_sa
    wakanda-ops = var.wakanda_sa
    tiqs-ops    = var.tiqs_sa
    dale-ops    = var.dale_sa
    cas-ops     = var.cas_sa
  }

  spoke_sa_by_project_id = {
    for key, sa in local.spoke_sas :
    local.project_ids[key] => sa
  }



  # -------------------------------------------------------------------
  # VPC IDs keyed by project (from VPC modules)
  # -------------------------------------------------------------------
  vpc_ids = {
    taaops      = module.balerica_vpc.vpc_id
    genosha-ops = module.genosha_vpc.vpc_id
    wakanda-ops = module.wakanda_vpc.vpc_id
    tiqs-ops    = module.tiqs_vpc.vpc_id
    dale-ops    = module.dale_vpc.vpc_id
    cas-ops     = module.cas_vpc.vpc_id
    # future spokes extend here
  }



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
}
