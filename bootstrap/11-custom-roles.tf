# Create custom VPN role in both projects
resource "google_project_iam_custom_role" "vpn_role_taaops" {
  project = var.balerica_project
  role_id = local.vpn_role_id
  title   = "VPN Role"
  permissions = [
    "compute.instances.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.vpnTunnels.create",
    "compute.vpnTunnels.delete",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.list",
    "compute.vpnGateways.create",
    "compute.vpnGateways.delete",
    "compute.vpnGateways.get",
    "compute.vpnGateways.list",
    "compute.vpnGateways.use",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routers.update",
  ]
}

resource "google_project_iam_custom_role" "vpn_role_genosha" {
  project = var.genosha_project
  role_id = local.vpn_role_id
  title   = "VPN Role"
  permissions = [
    "compute.instances.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.vpnTunnels.create",
    "compute.vpnTunnels.delete",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.list",
    "compute.vpnGateways.create",
    "compute.vpnGateways.delete",
    "compute.vpnGateways.get",
    "compute.vpnGateways.list",
    "compute.vpnGateways.use",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routers.update",
  ]
}

resource "google_project_iam_custom_role" "vpn_role_wakanda" {
  project = var.wakanda_project
  role_id = local.vpn_role_id
  title   = "VPN Role"
  permissions = [
    "compute.instances.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.vpnTunnels.create",
    "compute.vpnTunnels.delete",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.list",
    "compute.vpnGateways.create",
    "compute.vpnGateways.delete",
    "compute.vpnGateways.get",
    "compute.vpnGateways.list",
    "compute.vpnGateways.use",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routers.update",
  ]
}



resource "google_project_iam_custom_role" "vpn_role_tiqs" {
  project = var.tiqs_project
  role_id = local.vpn_role_id
  title   = "VPN Role"
  permissions = [
    "compute.instances.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.vpnTunnels.create",
    "compute.vpnTunnels.delete",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.list",
    "compute.vpnGateways.create",
    "compute.vpnGateways.delete",
    "compute.vpnGateways.get",
    "compute.vpnGateways.list",
    "compute.vpnGateways.use",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routers.update",
  ]
}



resource "google_project_iam_custom_role" "vpn_role_dale" {
  project = var.dale_project
  role_id = local.vpn_role_id
  title   = "VPN Role"
  permissions = [
    "compute.instances.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.vpnTunnels.create",
    "compute.vpnTunnels.delete",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.list",
    "compute.vpnGateways.create",
    "compute.vpnGateways.delete",
    "compute.vpnGateways.get",
    "compute.vpnGateways.list",
    "compute.vpnGateways.use",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routers.update",
  ]
}


resource "google_project_iam_custom_role" "vpn_role_cas" {
  project = var.cas_project
  role_id = local.vpn_role_id
  title   = "VPN Role"
  permissions = [
    "compute.instances.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.vpnTunnels.create",
    "compute.vpnTunnels.delete",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.list",
    "compute.vpnGateways.create",
    "compute.vpnGateways.delete",
    "compute.vpnGateways.get",
    "compute.vpnGateways.list",
    "compute.vpnGateways.use",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routers.update",
  ]
}

# Future custom roles can be added here
