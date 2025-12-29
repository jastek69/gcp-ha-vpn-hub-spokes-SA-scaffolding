### This Global Enterprise-Level Infratructure contains the following:

Multi-region VMs across the globe ✅
Cross-project VPN tunnels with HA ✅
BGP peering between all spokes ✅
Custom IAM roles and cross-project permissions (no need for json files) ✅
Network Connectivity Hub integration ✅


Summary:
6-project global infrastructure spanning 4 continents (Asia, North America, South America, Europe)
Complete hub-spoke VPN mesh with BGP routing for full connectivity
Terraform scaffolding to handle proper bootstrap/infrastructure separation
Service account impersonation for secure multi-project deployment
Automated scripts that handle the complexity seamlessly
Modular architecture that's easily extensible


# Scaffolding

This project is divided into two primary area decoupling the authentication process from the building of the network framework:
  
  Boostrap: handles the provisioning and authentication. This will only need to be run at the start of a project or when
  
  Infra (infrastucture): handles the building of the network infrastrucutre. Once bootstrapping has been completed and the proper roles have been provided the infrsatructure can be built or destroyed without the need to remove the permsissions that have been established. 

When adding new accounts to expand the network it is necessary to run Bootstrap first and then add the new network resources through Infra.


# Hub-and-Spoke VPN Terraform Setup

This repository provisions a hub-and-spoke HA VPN environment in Google Cloud using Scaffold Terraform modules with env and variables. It includes projects, Modules, IAM roles, HA VPN gateways, tunnels, Cloud Routers tf files, and startup scripts. This is a secure configuration with separate deployments for bootstrap mode and an infrastructure mode. Variables are set inside .tfvars and .env so there is no need for a JSON file. It is also configured to be scalable as well as being deployable within CI/CD pipelines. This can be easily done by setting the account within .tfvars to either the CI/CD account the user account.

#

### Authors
John Sweeney
T.I.Q.S.
Michael Dale
Cassiem Davids
Vincenet Woods - Uriah
Benji
Royce Billot


#

### Resources
Authentication Methods at Google
[text](https://cloud.google.com/docs/authentication)

Service Account Impersonation
[text](https://cloud.google.com/iam/docs/service-account-impersonation)

google_service_account
[text](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam)

#### **IAM policy for Service Account**

When managing IAM roles, you can treat a service account either as a resource or as an identity. This resource is to add iam policy bindings to a service account resource, such as allowing the members to run operations as or modify the service account. To configure permissions for a service account on other GCP resources, use the [google_project_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam) set of resources.

Three different resources help you manage your IAM policy for a service account. Each of these resources serves a different use case:

- [**`google_service_account_iam_policy`**](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_policy-1): Authoritative. Sets the IAM policy for the service account and replaces any existing policy already attached.
- [**`google_service_account_iam_binding`**](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_binding-1): Authoritative for a given role. Updates the IAM policy to grant a role to a list of members. Other roles within the IAM policy for the service account are preserved.
- [**`google_service_account_iam_member`**](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_member-1): Non-authoritative. Updates the IAM policy to grant a role to a new member. Other members for the role for the service account are preserved.

**Note:**

**`google_service_account_iam_policy`** **cannot** be used in conjunction with **`google_service_account_iam_binding`** and **`google_service_account_iam_member`** or they will fight over what your policy should be.

**Note:**

**`google_service_account_iam_binding`** resources **can be** used in conjunction with **`google_service_account_iam_member`** resources **only if** they do not grant privilege to the same role.


Scaffolding
[text](https://jiminbyun.medium.com/platform-engineering-starter-kit-series-repository-scaffolding-minimal-infra-bootstrap-2-5a9034444219)


CODEX and Github CoPilot


# Repos and build version:


## Task 3 Submission:
### Michael Dale Armageddon Task 3 Repo

- https://github.com/MichaelDale1/GCP-Armageddon-2025-Dale/tree/Armageddon_Task_3

### Cassiem Armageddon Task 3 Repo

- https://github.com/kazapes/GCPArmageddon2025-cass.git
- Cass currently can’t edit. Posted on his behalf by Michael Dale.

### Uriah Victorious Armageddon Task 3 Repo

- https://github.com/UriahVictorious/gcp-be-a-man-level-5

### Benji Armageddon Task 3 Repo

- https://github.com/Newest-IT-Bro/Benji-Armageddon-Task-3-Repo.git

### Royce Billiot Armageddon Task 3 Repo

https://github.com/Rbilli51614/GCP-Armageddon-Task-3.git



## Armageddon 6.5
The start:
https://github.com/jastek69/gcp-ha-vpn-hub-spokes


Final scaffolding:
[scaffolding](https://github.com/jastek69/gcp-ha-vpn-hub-spokes-SA-scaffolding.git)



# Project Details
## Service Account Impersonation

How this works:

* When you run Terraform, the active gcloud user (ADC) is used by default.
* If var.balerica_sa or var.genosha_sa are set, Terraform will impersonate those service accounts using your ADC credentials.
* This avoids ever downloading or storing JSON keys - No JSON files are needed locally.
* In CI/CD, you can do the same with Workload Identity Federation — no keys, just impersonation.
* You authenticate with gcloud auth login (or gcloud auth application-default login).
* Terraform uses your/ active credentials to impersonate the service accounts in each project.
* If you later rotate or recreate the service account keys, nothing changes in Terraform — it always impersonates.

#

### Security

* No JSON keys.
* You can grant temporary impersonation rights to human users or CI/CD identities.
* The impersonated SA is what Terraform actually uses to create VPN, routers, IAM, etc.

Utilizing the service account for terraform (as opposed to Compute) through Service Account Impersonation eliminates the need for a JSON (the use of service account keys). [See documentation](https://cloud.google.com/iam/docs/service-account-impersonation)

You can use service account impersonation to set up a local Application Default Credentials (ADC) file. Client libraries that support impersonation can use those credentials automatically. Local ADC files created by using impersonation are supported in the following languages:
* C#
* Go
* Java
* Node.js
* Python

#

# Setup Instructions

## Scripts - Quick Start
In order ease the use of steps required to poperly deploy this environment using scaffolding a Bootstrap script and Infra (Infrastucture) scripts can be used. 
Each 
All commands assume you run from the repo root.

### bootstrap.sh
- Seeds IAM bindings/custom roles across projects.
- Apply: `./scripts/bootstrap.sh apply`
- Destroy (optional; wipes bootstrap IAM/service accounts): `./scripts/bootstrap.sh destroy`

### infra.sh
- Builds compute + networking.
- Apply with tfvars and bootstrap_mode=false: `./scripts/infra.sh apply`
- Destroy compute/network only (keeps bootstrap IAM intact): `./scripts/infra.sh destroy`

### Permissions needed for the operator (typical Owner-level set)
- compute.admin, compute.instanceAdmin.v1, compute.networkAdmin, compute.osLogin, compute.viewer
- iam.roleAdmin, iam.serviceAccountUser, resourcemanager.projectIamAdmin, serviceusage.serviceUsageAdmin, artifactregistry.admin, networkconnectivity.admin, iap.tunnelResourceAccessor, viewer/owner

### Quick checks
- List your roles on a project:
  - `gcloud projects get-iam-policy <project> --flatten="bindings[].members" --filter="bindings.members:user:<account>" --format="table(bindings.role, bindings.members)"`
- Ensure SA token creator (example for taaops Terraform SA):
  - `gcloud iam service-accounts get-iam-policy terraform@taaops.iam.gserviceaccount.com --project=taaops --format='table(bindings.role, bindings.members)'`




#### 1. Install Requirements

    * Terraform: ≥ 1.3
    * gcloud CLI: gcloud auth application-default login
    * Project APIs and Application Default Credentials: see below
       
#

#### Before you begin - Project and Service Account configuration

Any Project using this method will require the proper API's and a Terraform Service Account configured with the proper Roles:

##### Project API's

* Network Connectivity API
* Google Cloud API
* Identity and Access Management (IAM) API
* Security Token Service API

##### terraform Service Account Roles
* Owner
* Artifact Registry Admin
* Storage Admin
* Project IAM Admin
* roleAdmin - Role Administrator
* Service Account Token Creator


#### Service Account Instructions

##### Creating a Service Account

1. Create a service account
    1. In the search bar, type in “Service Account” and click on “Service Accounts”
    2. Select your desired project for the service account
        * You’ll have to create a service account for every project you want to have
    3. Click on “create service account”
        * Service account details
            * Service account name = terraform-service
            * Service account ID will automatically generate (don't edit this)
            * Service account description = terraform service account for (insert project name here)
            * Click “create and continue”
        * Grant this service account access to project
            * Click on the “select a role” box, search for 'Owner'
            * Select “add another role” to add each additional role:
                * Storage Admin
                * Artifact Registry Administrator
                * Project IAM Admin
                * roleAdmin
                * Service Account Token Creator
            * Click “continue”
        * Grant users access to this service account
            * Click “done”
2. Create keys for service account - NOTE: this is for local usage only, DO NOT to be place in terraform:

* Underneath the “Actions” column on the far right, click on the 3 vertical dots and select “Manage Keys”

[](https://lh7-rt.googleusercontent.com/docsz/AD_4nXd-tdTpnxYLqlw1bQsxUH_6Y0bY_64aBwuFhLlcQCta3jgnwnXCd4O2ltsbyawENeRtH7vGuvDVWck-sxvEpWGfLW7bGDhf7xkyVVj3kwmyogF3S-ZTZzMP3-bwDHcxBH3WyBXP5w?key=vxFwUQ116uEGLp5-ipWOb5S_)

* Click on “Add key” > “Create New Key”
* Make sure “json” is selected and click create
* The key is now saved to your computer; move the key to your Terraform folder
* Create an Cloud Storage Bucket copy the key to your Project Bucket:

  NOTE: To create a Cloud Storage bucket, go to the Cloud Storage Buckets page in the Google Cloud console, click "Create", and follow the steps on the "Create a bucket" page.

### Option 2: Using `gcloud` CLI

Run this command to give your Terraform service account `roles/iam.roleAdmin`:

Or if you want your **user account** (your own email) to have it:

```bash
gcloud projects add-iam-policy-binding taaops \
  --member="user:your.email@example.com" \
  --role="roles/iam.roleAdmin"
```

# 

# Runing the Project
in order to ease the steps 


# Project Naming Notes

Nameing convention for .tfvars

The original project name will be used to define `***projectname***-ops` as the key in the impersonation/region/subnet/tunnel maps: e.g gcp-project-name -> projectname-ops.
* Keep `"***projectname***"` in the startup script map, and the actual project id lives in the 'projectname_*' variables.
* **Actual project vars** (***projectname***_project = "original-project-name", etc.) stay in the “Projects + Service Accounts” block. Everything that talks to GCP (providers, modules) ultimately uses these real IDs.

```
# Under Project and Service Accounts:
wakanda_project = "***GCP project name***" # us-west2 Los Angeles
wakanda_region  = "us-west2"
wakanda_zone    = "us-west2-a"
wakanda_sa      = "project-terraform@project.iam.gserviceaccount.com"
```

* **Logical keys** (e.g. projectname-ops) are the friendly handles the locals use to glue things together. The key must appear everywhere the locals expect it:
  * local.project_ids
  * var.spokes and var.spoke_regions
  * var.subnet_cidrs
  * in every tunnel src/dst.

#
That way local.project_ids["project-ops"] resolves to the real project id and all downstream lookups work.

* **Provider alias** (google.project_ops) is just Terraform syntax so each module can pick the right credentials. It points at var.tiqs_project, so it follows whatever actual project id you set.

* **Startup scripts map** is the special case: in modules/compute/main.tf we index the map with the real project id (var.project), so leave the key as "class-6-5-tiqs" there.


Example:

Under Project and Service Accounts:
```
wakanda_project = "***GCP project name***" # us-west2 Los Angeles
wakanda_region  = "us-west2"
wakanda_zone    = "us-west2-a"
wakanda_sa      = "project-terraform@project.iam.gserviceaccount.com"
```

```
"wakanda-ops" = "<project-terraform@project>.iam.gserviceaccount.com"
```


# NETWORK CONFIGURATION

## Region Restrictions on site-to-site Data Transfer

  ***In order to use ***site-to-site-data-transfer***, you must create the spokes in regions that support this feature. Supported regions include all of those in the following countries:***

#### Locations Supported for Data Transfer

  **APAC**
    Australia, India, Japan, Korea, Singapore, Taiwan
    (In Japan, Network Connectivity Center is provided through Google Connect Asia Pacific Pte Ltd.)

  **North** **America**
    Canada, Mexico, United States

  **Europe**
    Belgium, Finland, France, Germany, Italy, Netherlands, Spain, Sweden, Switzerland, United Kingdom

  **Middle** **East**
    Israel, Qatar

  **South America**
    Chile

#

### HA VPN - BGP Tunnels and ASN configuration

This configuration uses an HA VPN Mesh for the tunnels that will connect to a Hub and Spoke.
##### Role of the HA VPN Gateway

* `google_compute_ha_vpn_gateway` represents the physical HA VPN endpoint in each project/region.
* The tunnels (`google_compute_vpn_tunnel`) are always anchored to a gateway.
* Without the gateway, Terraform has nowhere to attach the tunnels.

#

Example HA VPN Mesh:

```
                     ┌─────────────────────────┐
                     │     Balerica Project     │
                     │ Region: asia-southeast1  │
                     │ ASN: 65501               │
                     └───────────┬─────────────┘
                                 │
                 ┌───────────────┼─────────────────┐
                 │                                   │
        ┌────────▼────────┐                ┌────────▼────────┐
        │ HA VPN GW (if0) │                │ HA VPN GW (if1) │
        │ balerica        │                │ balerica        │
        └───────┬─────────┘                └───────┬─────────┘
                │                                  │
      Tunnel0   │                                  │   Tunnel1
(local TS=0.0.0.0/0)                     (local TS=0.0.0.0/0)
(remote TS=0.0.0.0/0)                    (remote TS=0.0.0.0/0)
                │                                  │
   169.254.10.1 │                                  │ 169.254.20.1
        ┌───────▼────────┐                ┌────────▼───────┐
        │ Router Intf T0 │                │ Router Intf T1 │
        │ 169.254.10.1/30│                │169.254.20.1/30 │
        └───────┬────────┘                └───────┬────────┘
                │                                  │
                │                                  │
        ┌───────▼────────┐                ┌────────▼───────┐
        │ BGP Peer (T0)  │                │ BGP Peer (T1)  │
        │ ASN 65515      │                │ ASN 65515      │
        └────────────────┘                └────────────────┘

                 <<======== Encrypted VPN Tunnels ========>>

        ┌────────────────┐                ┌────────────────┐
        │ BGP Peer (T0)  │                │ BGP Peer (T1)  │
        │ ASN 65501      │                │ ASN 65501      │
        └───────┬────────┘                └───────┬────────┘
   169.254.10.2 │                                  │ 169.254.20.2
        ┌───────▼────────┐                ┌────────▼───────┐
        │ Router Intf T0 │                │ Router Intf T1 │
        │ 169.254.10.2/30│                │169.254.20.2/30 │
        └───────┬────────┘                └───────┬────────┘
                │                                  │
      Tunnel0   │                                  │   Tunnel1
(local TS=0.0.0.0/0)                     (local TS=0.0.0.0/0)
(remote TS=0.0.0.0/0)                    (remote TS=0.0.0.0/0)
                │                                  │
        ┌───────▼────────┐                ┌────────▼────────┐
        │ HA VPN GW (if0)│                │ HA VPN GW (if1) │
        │ genosha        │                │ genosha         │
        └───────────┬────┘                └───────┬─────────┘
                    │                            │
                     └───────────────┬───────────┘
                                     │
                     ┌───────────────▼─────────────┐
                     │     Genosha Project         │
                     │ Region: southamerica-east1  │
                     │ ASN: 65515                  │
                     └─────────────────────────────┘

```

#

#

***CIDR:*** Treat every HA tunnel as its own /30 and only ever use the two middle addresses inside that block:

```jsx
CIDR ......... usable hosts (local | peer) ..... network/broadcast (don’t use)
169.254.a.b/30  --> 169.254.a.(b+1) | 169.254.a.(b+2)  ...... b  | (b+3)
```

So when allocating a tunnel pair:

* Pick an unused /30 from a coordination sheet (e.g. start at 169.254.10.16/30, 169.254.10.20/30, 169.254.10.24/30 … increment by 4 each time).
* t0 gets the first /30, t1 the next /30. If you pre-stage t2/t3, keep stepping by 4 so they remain unique.
* For each /30, assign ip_src to the lower usable (network+1) on the source router, and ip_dst to the higher usable (network+2) on the peer. In the reverse-direction block you simply mirror them.

Example layout for a new project pair:

```jsx
t0: 169.254.12.0/30  -> src 169.254.12.1, dst 169.254.12.2
t1: 169.254.12.4/30  -> src 169.254.12.5, dst 169.254.12.6
t2: 169.254.12.8/30  -> src 169.254.12.9, dst 169.254.12.10
t3: 169.254.12.12/30 -> src 169.254.12.13, dst 169.254.12.14
```

Keep a master list of the Router IP assignements so every project pair gets non-overlapping /30 blocks and always use the .1/.2 (or .5/.6, etc.) host addresses—never the .0 or .3 endpoints.

#

**ASN:** For Cloud Router over HA VPN (or NCC spokes) you can use any ***private BGP ASN*** that isn’t already in use on the opposite side of the session:

* **16‑bit private ASN range:** 64512–65534
* **32‑bit private ASN range:** 4200000000–4294967294

**Best practices:**

* Stay inside those ranges as these are only values Google lets you configure on Cloud Router unless you’re terminating a public peering.
* Make sure the two routers that will peer don’t reuse the same ASN.
* Avoid the documentation/reserved block 64496–64511 so you don’t collide with examples.

**Example:**
Wakanda↔Balerica HA tunnels that means:

* balerica-wakanda t0 (169.254.10.16/30):
  * Taaops side: ip_src = "169.254.10.17/30"
  * Wakanda side: ip_dst = "169.254.10.18/30"
* wakanda-balerica t0:
  * Wakanda side: ip_src = "169.254.10.18/30"
  * Taaops side: ip_dst = "169.254.10.17/30"
* balerica-wakanda t1 (169.254.10.20/30):
  * Taaops side: ip_src = "169.254.10.21/30"
  * Wakanda side: ip_dst = "169.254.10.22/30"
* wakanda-balerica t1:
  * Wakanda side: ip_src = "169.254.10.22/30"
  * Taaops side: ip_dst = "169.254.10.21/30"

When adding additional tunnels e.g. t2/t3, follow the same pattern—use 169.254.10.25/30 for the first host, 169.254.10.26/30 for the second, etc.

| **Tunnel** | **/30 block** | **Network** | **Local (src)** | **Peer (dst)** | **Broadcast** |
| --- | --- | --- | --- | --- | --- |
| t0 | 169.254.10.16/30 | 169.254.10.16 | 169.254.10.17 | 169.254.10.18 | 169.254.10.19 |
| t1 | 169.254.10.20/30 | 169.254.10.20 | 169.254.10.21 | 169.254.10.22 | 169.254.10.23 |
| t2 | 169.254.10.24/30 | 169.254.10.24 | 169.254.10.25 | 169.254.10.26 | 169.254.10.27 |
| t3 | 169.254.10.28/30 | 169.254.10.28 | 169.254.10.29 | 169.254.10.30 | 169.254.10.31 |

* balerica-wakanda uses the lower host in each /30 (.17, .21, .25, .29) as the local interface and the higher host (.18, .22, .26, .30) as the peer.
* wakanda-balerica mirrors the same pairs back, so both ends agree on the host/peer mapping.
* ASN assignments stay at 65520 (taaops) and 65515 (wakanda), which are valid private ASNs.

Adding another spoke means wiring in the new project everywhere Terraform expects per-spoke inputs. Use the tables below as your checklist (example values assume a new project called atlantis-ops).

| **Input** | **Key format** | **Example for atlantis-ops** | **File (anchor)** |
| --- | --- | --- | --- |
| Project id | atlantis_project | "atlantis-ops" | terraform.tfvars:107 |
| Region | atlantis_region | "us-west3" | terraform.tfvars:108 |
| Zone | atlantis_zone | "us-west3-a" | terraform.tfvars:109 |
| Terraform SA email | atlantis_sa | "<terraform@atlantis-ops.iam.gserviceaccount.com>" | terraform.tfvars:110 |
| Spoke impersonation map | "atlantis-ops" = "<terraform@atlantis-ops.iam.gserviceaccount.com>" | Add inside spokes = { ... } | terraform.tfvars:147 |
| Spoke region lookup | "atlantis-ops" = "us-west3" | Add inside spoke_regions = { ... } | terraform.tfvars:156 |
| Subnet CIDR | "atlantis-ops" = "10.40.0.0/24" | Add inside subnet_cidrs = { ... } | terraform.tfvars:165 |
| Startup script | "atlantis-ops" = "scripts/startup/startup.sh" | Add inside startup_scripts = { ... } | terraform.tfvars:176 |
| HA tunnels (forward) | atlantis-balerica = { … tunnels = { t0 … t1 … } } | Use t0/t1 only unless you need t2/t3 | terraform.tfvars:188 |
| HA tunnels (reverse) | balerica-atlantis = { … } | Mirror PSKs & /30s, swap src/dst | terraform.tfvars:188 |

| **File** | **What to extend for the new spoke** | **Why it matters** |
| --- | --- | --- |
| 02-variables.tf:37 | Duplicate the per-project variable blocks (*_project,*_region, *_zone,*_sa) | Keeps Terraform aware of the new tfvars entries |
| 01-providers.tf:32 | Add an aliased provider (e.g. alias = "atlantis_ops") that impersonates the new SA | Modules need a provider scoped to the project |
| 03a-locals.tf:15 | Append the logical key → real project id in local.project_ids; add module handle in local.vpc_ids | Drives every downstream for_each and router lookup |
| 03-vpc.tf:9 | Copy a module "<name>_vpc" block wired to the new provider | Creates the spoke’s VPC |
| 04-subnets.tf:9 | Copy a module "<name>_subnet" block with the new CIDR | Supplies the subnetwork for compute |
| 06-gcp-hub.tf:12 | Copy a module "<name>_hub" block | Builds the NCC hub for the spoke |
| 07-spokes.tf:5 | Copy a module "<name>_spoke" block and point vpn_tunnel_uris at the new tunnel keys | Registers the spoke with its hub and tunnels |
| 08a-compute.tf:9 | Copy a module "<name>_vm" block if you want a sample VM | Optional but keeps parity with other spokes |
| 11-custom-roles.tf:2 | Add google_project_iam_custom_role.vpn_role_<name> for the new project | Provides the shared VPN admin role |
| 05-vpn-tunnels.tf:25 | Extend the static for_each map with the new forward and reverse tunnel keys ("<src>-<dst>-t0", t1) | Ensures Terraform actually creates the tunnels you defined |
| 14-router.tf:10 | No new resource needed, but extend the ASN ternary to return your project-specific ASN instead of the 65000 fallback | Keeps BGP sessions on the intended ASN |

Reminders:

* Reuse the same logical key (e.g. atlantis-ops) across local.project_ids, spokes, spoke_regions, and the tunnel definitions so the maps join correctly - 03a-locals.tf:15

* Keep tunnel naming symmetrical (src-dst-t0/src-dst-t1 and the reverse) so the spoke module can reference predictable keys ().    07-spokes.tf:18

* If the new spoke uses more than t0/t1, add interface indexes for t2, t3, etc. in local.interface_index (). 03a-locals.tf:146

#

#

#

# Hub and Spokes Network Configuration

### Key Behavior and Logic

1. **Locals - `03a-locals.tf`**
This terraform file handles flattening - [terraform flatten Function](https://developer.hashicorp.com/terraform/language/functions/flatten)
    It takes a nested collection such as list of lists or lists of maps in a for loop and collapses them in a single list so terraforms logic can handle each element. It reduces a nested data structure into a flat one. This file handles the per-spoke/per-tunnel matrix then requires individual records to feed ***`for`*** maps.
    * ***baseline_bindings:*** handles the key, project ID, service account, and role binding. It perform a nested for loop ***`(key, role)`*** that loops over each spoke and each baseline role, producing a list of lists; `flatten()` turns that into one list of binding objects, which then becomes the `baseline_bindings_map` used by `google_project_iam_member.baseline_roles`.

    * ***cross_bindings:*** performs a nested for loop ***`(src_key, dst_key)`*** of every spoke against every other spoke to define impersonation grants; flatten collapses the nested array so each cross-project grant is a single element keyed in cross_bindings_map.
    * ***vpn_tunnels_flattened:*** flattens the user-supplied tunnel map ***`(var.tunnels)`***, which is structured as per-pair objects containing their own tunnels map. Flattening that nested output yields one entry per tunnel `(t0, t1, …)` so the later vpn_tunnels_map can be indexed as ***`<pair>-<t#>`*** when resources like `google_compute_vpn_tunnel` look them up.

    * **tunnel_projects:** collects each ***src/dst*** into a temporary list of pairs and flattens it, leaving a deduplicated set of project IDs that have routers, gateways, etc.
    * ***router_flattened:*** mirrors the tunnel flattening while adding each entry with router-facing metadata (project IDs, interface IPs, ASNs). The flattened shape feeds ***router_map***, which drives the google_compute_router_interface and google_compute_router_peer resources
2. **Hubs - `06-gcp-hub.tf`**:
    * One per project from `local.spoke_sas`.
    * Keeps naming consistent (`taaops-hub`, `genosha-ops-hub`, `atlantis-ops-hub`, etc.).
3. **Spokes - `07-spokes.tf`**:
    * One per project: (`vpn-spoke-taaops`, etc.).
    * The `linked_vpn_tunnels.uris` block **auto-collects all tunnels where that project is the source** (`t.src == each.key`).
    * Example: For `taaops`, URIs = `[vpn_tunnel. "taaops->genosha-ops-0", "taaops->genosha-ops-1"]`.
4. **Project Scaling**:
    * Add another project to `spokes` and corresponding tunnels to `tunnels = {}` → Terraform automatically generates its hub + spoke, and links the right tunnels.

5. **Gateways - `resource "google_compute_ha_vpn_gateway" "gateways"`**
    * Created for every `src` and `dst` project in the ***tunnels map*** and is handled in **`05-vpn-tunnels.tf`**.
    * Ensures each side has its own HA VPN gateway.
6. **Tunnels - `05-vpn-tunnels.tf`**
    * Built dynamically from `var.tunnels`.
    * Names use `${src}->${dst}-tunnel`.
    * Pull PSKs, ASN, router IPs, and interfaces directly from the tunnel object.
7. **Routers, Interfaces, Peers - 14-routers.tf**
    * One router per project (from tunnels).
    * Interfaces and peers iterate over each tunnel.
    * Router peer config pulls `router_ip_dst` and `asn_dst` dynamically.
8. **No hardcoded mappings**
    * PSK, ASN, region, and IPs are all in `var.tunnels`.
    * Adding a new tunnel = add to the tunnel map **`tunnels = {}`** inside `tfvars`.

#

### Terraform workflow: Variables → Locals → Providers → Authentication

The flow for creating resources in terraform is ***.tfvars, variables, providers, authentication:***

* **`.tfvars`+`02-variables.tf`** → all inputs (`bootstrap_mode`, `spokes`, `balerica_project`, etc.).
* **`03a-locals.tf`** → merges variables into derived maps (`local.spoke_sas`, `local.cross_bindings_map`).
* **`01-providers.tf`** → uses `local.spoke_sas` to dynamically declare providers per project.
* **`00-authentication.tf`** → uses providers to sanity-check who you are actually authenticated as.

#


## tfvars

the tfvars is where the primary values are set that will be input to be sent to the 02-variables.tf file. Refer to the terraform.tffvars.example file.
**bootstrap_mode**: enables to disables use of impersonation. Further details below
**ci_cd account**: set this to the PRIMARY account that will be using terraform. IT can be the user account of the ci_cd account.  

**Projects + Service accounts**: provide the details for each project including:

* the project name
* region
* zone
* terrform service account

**Spokes Regions**

* Project ID region

**Subnet CIDR**

* subnet CIDR assignments for each project

**Startup scripts**

* name of the startup scripts for each projects vpc

**tunnels**
The tunnel configuration. Refer to the prior above notes.

___

When it comes to adding additional Spokes you may refer to this table as a guide:

Adding another spoke means wiring in the new project everywhere Terraform expects per-spoke inputs. Use the tables below as your checklist (example values assume a new project called atlantis-ops).

| **Input** | **Key format** | **Example for atlantis-ops** | **File (anchor)** |
| --- | --- | --- | --- |
| Project id | atlantis_project | "atlantis-ops" | terraform.tfvars:107 |
| Region | atlantis_region | "us-west3" | terraform.tfvars:108 |
| Zone | atlantis_zone | "us-west3-a" | terraform.tfvars:109 |
| Terraform SA email | atlantis_sa | "<terraform@atlantis-ops.iam.gserviceaccount.com>" | terraform.tfvars:110 |
| Spoke impersonation map | "atlantis-ops" = "<terraform@atlantis-ops.iam.gserviceaccount.com>" | Add inside spokes = { ... } | terraform.tfvars:147 |
| Spoke region lookup | "atlantis-ops" = "us-west3" | Add inside spoke_regions = { ... } | terraform.tfvars:156 |
| Subnet CIDR | "atlantis-ops" = "10.40.0.0/24" | Add inside subnet_cidrs = { ... } | terraform.tfvars:165 |
| Startup script | "atlantis-ops" = "scripts/startup/startup.sh" | Add inside startup_scripts = { ... } | terraform.tfvars:176 |
| HA tunnels (forward) | atlantis-balerica = { … tunnels = { t0 … t1 … } } | Use t0/t1 only unless you need t2/t3 | terraform.tfvars:188 |
| HA tunnels (reverse) | balerica-atlantis = { … } | Mirror PSKs & /30s, swap src/dst | terraform.tfvars:188 |

| **File** | **What to extend for the new spoke** | **Why it matters** |
| --- | --- | --- |
| 02-variables.tf:37 | Duplicate the per-project variable blocks (*_project,*_region, *_zone,*_sa) | Keeps Terraform aware of the new tfvars entries |
| 01-providers.tf:32 | Add an aliased provider (e.g. alias = "atlantis_ops") that impersonates the new SA | Modules need a provider scoped to the project |
| 03a-locals.tf:15 | Append the logical key → real project id in local.project_ids; add module handle in local.vpc_ids | Drives every downstream for_each and router lookup |
| 03-vpc.tf:9 | Copy a module "<name>_vpc" block wired to the new provider | Creates the spoke’s VPC |
| 04-subnets.tf:9 | Copy a module "<name>_subnet" block with the new CIDR | Supplies the subnetwork for compute |
| 06-gcp-hub.tf:12 | Copy a module "<name>_hub" block | Builds the NCC hub for the spoke |
| 07-spokes.tf:5 | Copy a module "<name>_spoke" block and point vpn_tunnel_uris at the new tunnel keys | Registers the spoke with its hub and tunnels |
| 08a-compute.tf:9 | Copy a module "<name>_vm" block if you want a sample VM | Optional but keeps parity with other spokes |
| 11-custom-roles.tf:2 | Add google_project_iam_custom_role.vpn_role_<name> for the new project | Provides the shared VPN admin role |
| 05-vpn-tunnels.tf:25 | Extend the static for_each map with the new forward and reverse tunnel keys ("<src>-<dst>-t0", t1) | Ensures Terraform actually creates the tunnels you defined |
| 14-router.tf:10 | No new resource needed, but extend the ASN ternary to return your project-specific ASN instead of the 65000 fallback | Keeps BGP sessions on the intended ASN |

Reminders:

* Reuse the same logical key (e.g. atlantis-ops) across local.project_ids, spokes, spoke_regions, and the tunnel definitions so the maps join correctly ().

    03a-locals.tf:15

* Keep tunnel naming symmetrical (src-dst-t0/src-dst-t1 and the reverse) so the spoke module can reference predictable keys ().

    07-spokes.tf:18

* If the new spoke uses more than t0/t1, add interface indexes for t2, t3, etc. in local.interface_index ().

    03a-locals.tf:146

#

# Cross-Project HA VPN

This setup uses cross-project HA VPN in order to avoid the default Compute Engine SAs which is the ideal "good" security practice. It relies only on the explicit service accounts (<https://cloud.google.com/iam/docs/service-account-overview>) that Terraform itself creates and manages along with Impersonation of the project account (service account impersonation: <https://cloud.google.com/docs/authentication/use-service-account-impersonation>)

* Each project (Balerica + Genosha) has its own Terraform service account.
  * Custom IAM roles (e.g. customVpnAccess) are created in each project with only the minimum permissions.
  * Cross-project IAM bindings then allow each SA to use VPN resources in the other project.
  * depends_on ensures that Terraform doesn’t try to bind roles to SAs or apply permissions before the underlying roles/SAs exist.

For Impersonation to work each Project needs a terraform service account with the following Roles assigned:

* Enable Service Account Credentials API in your project.
* Service Account Token Creator (roles/iam.serviceAccountTokenCreator) IAM role on the service account. More details below

#

#

# Hub and Spoke network architecture

<https://cloud.google.com/architecture/deploy-hub-spoke-vpc-network-topology>

![alt text](image.png)

**Spokes:**
* not available in South America, South Africa:
  * site-to-site data transfer is not supported in South America: "southamerica-east1"

* 1 router per region, per unique ASN relationship.

* Hub-and-spoke - run one router at the hub and let it peer with multiple spokes’ routers.

* Only add multiple routers in the hub project if you need administrative isolation or different ASN policies per spoke.

#

**Tunnel**
Each tunnel has:
* Router interface `(ip_range = var.*_router_ip_tunnel*)`
* Router peer `(peer_ip_address = split["/", var.*_router_ip_tunnel*](0))`
* Peers use `split["/", var.*_router_ip_tunnel0](0)` (peer IP only)

NOTE: ***Split Explanation*** - (see appendix for more detailed explanation):  
Split breaks a single string into a list of substrings based on a specified delimiter. In this case it strips off the subnet mask and provides the peer IP address. In this method the router interface still uses the full x.x.x.x/30, while the peer uses only the x.x.x.x.

#

##### All ASNs come from .tfvars

ASNs are assigned and pulled pulled from ***name_bgp_asn*** 

* Router ASN = 65501 (Balerica)
* Peer ASN = 65515 (Genosha)

#

### Full dependency chain: IAM → Gateways → Tunnels → Interfaces → Peers

Terraform follows: IAM ➝ VPN Gateways ➝ Tunnels ➝ Router Interfaces ➝ Router Peers

This will ensure the following:

* Service accounts are created with short account_id = "terraform".
* .tfvars overrides (balerica_sa, genosha_sa) can be used if you want pre-existing SAs.
* Locals unify the references (local.balerica_sa_email, local.genosha_sa_email).
* Custom roles grant minimal VPN permissions.
* IAM bindings always reference the correct service account.
* depends_on enforces role creation before bindings.

#


#

##### How They Fit in the Config

  Dependency chain:

* IAM Bindings (google_project_iam_member) → allow cross-project SA usage
* HA VPN Gateways (google_compute_ha_vpn_gateway) → the actual VPN endpoints
* Routers (google_compute_router) → BGP-capable routers in each project
* Tunnels (google_compute_vpn_tunnel) → attach to the gateways and routers
* Router Interfaces (google_compute_router_interface) → bind tunnels to router IPs
* Router Peers (google_compute_router_peer) → configure the BGP sessions
* Terraform doesn’t “import” IAM privileges; it just **relies on your current credentials** to create/update resources.

---

#### How to grant the Terraform service account the **`roles/iam.roleAdmin`** permission directly in Google Cloud IAM

---

## 🔎 Verify Assignment

Once added, you can verify with:

```bash
gcloud projects get-iam-policy taaops \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:terraform@taaops.iam.gserviceaccount.com" \
  --format="table(bindings.role)"

```

You should now see:

```
ROLE
roles/iam.roleAdmin```




#
#
#

---

⚠️ **Security Note**: Follow Least Privelege

`roles/iam.roleAdmin` is powerful — it lets the SA create and update *any* custom role in the project. For production security, restrict this to **Terraform’s dedicated project** only, not globally.

## Terraform Bootstrap code for temporary roles/iam.roleadmin

* IAM bootstraps with RoleAdmin → custom roles → cross-project bindings.
* Gateways wait until bootstrap is finished.
* Tunnels wait until gateways + bindings are finalized.
* Interfaces wait on tunnels.
* Peers wait on interfaces.
* This ensures the mesh only builds once the IAM security foundation is in place, and that elevated privileges are revoked afterwards.

## Flow

1. **Bootstrap phase**:

    Terraform gives its SAs `roles/iam.roleAdmin` just long enough to create `customVpnAccess` roles.

2. **Custom roles created**:

    Terraform builds `customVpnAccess` in both projects and applies cross-project bindings.

3. **Tear-down phase**:

    Once bindings are in place, Terraform removes the `roles/iam.roleAdmin` grants.

    → Your SA is left with only the custom role assignments.

---


#

#

# 2. Bootstrap vs. Infractruture Mode - WIP 
TODO

Terraform can run in two modes:

- Bootstrap mode (bootstrap_mode = true)

  - Run as your Gmail Owner account.
  - Used the first time only to seed IAM impersonation bindings.
  - Example:

    ```
    bootstrap_mode = true
    cicd_account   = "user@example.com" ```

- Infrastructure (Infra) mode (bootstrap_mode = false)
  - Terraform impersonates Service Accounts.
  - Steady-state for CI/CD and day-to-day use.
  - Flip back after bootstrap is successful.

___

3. Configure Variables

Copy the template file and edit with project-specific values:
``` cp terraform.tfvars.example terraform.tfvars ```

Then open terraform.tfvars and replace placeholders:

- balerica_project / genosha_project → your actual project IDs
- balerica_sa / genosha_sa → Terraform SA emails
- spokes and spoke_regions → expand with new projects if needed
- subnet_cidrs → define subnet ranges
- startup_scripts → paths to init scripts
- tunnels → replace changeme-psk-* with strong PSKs

⚠️ Never commit real terraform.tfvars to source control. Only keep terraform.tfvars.example in Git.

___

4. Running Terraform

Initialize modules and providers:
```terraform init```

Validate syntax:
```terraform validate```

Plan the deployment:
```terraform plan```

Apply changes:
```terraform apply```

5. Testing Lifecycle
Scripts are provided for staged apply/destroy cycles:

- apply-test.sh – staged deployment

- destroy-test.sh – teardown in reverse order
- apply-safe.sh – safe deployment with prompts and timers

Example:
```./apply-safe.sh```

6. VPN Tunnel IPs

By convention:

- t0/t1 = primary HA tunnel pair
- t2/t3 = pre-allocated for expansion
- IPs are /30 ranges (RFC5735 reserved, not used inside your VPC).



___

#
## Workflow

#### Sequence: IAM bootstrap → impersonation → customRole → crossBinding sequence

1. **Bootstrap RoleAdmin Bindings**
    * Terraform’s “control SA” (the one you authenticate with) gets `roles/iam.roleAdmin` temporarily in both projects.
    * This allows Terraform to create the **custom VPN roles** and the **cross-project IAM bindings**.
2. **Create Custom VPN Roles**
    * Only possible because RoleAdmin is active.
3. **Create Cross-Project Bindings**
    * Your hub SA gets access to use VPN gateways in spoke projects, and vice versa.
4. **Tear Down RoleAdmin**
    * Once custom roles and cross-project bindings are created, the RoleAdmin binding is removed.
    * Your Terraform SA is left with **least privilege** (only the VPN custom role + any other required roles).
5. **Impersonation**
    * Providers (`google.balerica`, `google.genosha-ops`) are configured to impersonate the SAs defined in `locals.*_sa_email`.
    * No JSON keys are needed.

* Locals handle the **Terraform SAs**.
* `cicd_account` is the **identity running Terraform** (your user locally, CI/CD SA later).
* Bootstrapping (`bootstrap_roleadmin_*`) ensures Terraform SAs can create roles.
* After the VPN roles + cross bindings are applied, you can flip `teardown_roleadmin_*`’s `count` to `1` to strip `roleAdmin` away.

## Dependency Chain Recap

1. **Bootstrap RoleAdmin**

    `google_project_iam_member.bootstrap_roleadmin_*`

2. **Impersonation bindings**

    `google_service_account_iam_member.*_impersonation`

3. **Custom VPN Role**

    `google_project_iam_custom_role.*_vpn_role`

4. **Cross-Project IAM Bindings**

    `google_project_iam_member.allow_*`

5. **Compute Resources**

    HA VPN Gateways → Tunnels → Router Interfaces → Peers

Impersonation Accounts:

* `var.cicd_account` (developer or pipeline SA) gets **impersonation rights** on the Terraform SAs.
* `locals.*_sa_email` (Terraform SAs) are **the accounts Terraform runs as** once impersonation is active.

### CICD account gets rights on Terraform SAs

member = var.cicd_account
#
### Terraform SAs get baseline & custom project roles

* member = "serviceAccount:${local.balerica_sa_email}"
* Locals - use instead of dynamically querying GCP for the SA details

* If you **supply overrides** in `.tfvars` (for example, if your SA name is different), those take precedence.
* If you leave them blank, Terraform builds the default SA email conventionally (Terraform SA named `terraform` in each project).

#
## 🔹 Step-by-Step Bootstrap Flow

### 1. Authenticate as *yourself* (Owner)

Terraform can’t impersonate SAs until you give it permission. So start with your own user account:

```bash
gcloud auth application-default login

```

This creates an **ADC credential** at `~/.config/gcloud/application_default_credentials.json` (or `%APPDATA%\gcloud\application_default_credentials.json` on Windows).

Terraform will use this identity to apply IAM bindings.

---

### 2. Apply only the impersonation bindings

Seed the impersonation chain by letting your Terraform Service Accounts be impersonated:

```bash
terraform init

terraform apply \
  -target=google_service_account_iam_member.balerica_impersonation_token_creator \
  -target=google_service_account_iam_member.balerica_impersonation_sa_user \
  -target=google_service_account_iam_member.genosha_impersonation_token_creator \
  -target=google_service_account_iam_member.genosha_impersonation_sa_user

```

At this point:

* Your CI/CD account (or your Gmail account, if you set `cicd_account = ...`) can mint tokens for the Terraform SAs.
* Terraform SAs themselves don’t yet have project-level powers, but they can now be impersonated.

---

### 3. Verify impersonation works

Check that you can impersonate both project Terraform SAs:

```bash
# Balerica project
gcloud auth print-access-token \
  --impersonate-service-account=terraform@taaops.iam.gserviceaccount.com \
  | head -c 80; echo

# Genosha project
gcloud auth print-access-token \
  --impersonate-service-account=terraform@genosha-ops.iam.gserviceaccount.com \
  | head -c 80; echo

```

If you see a `ya29....` token string, impersonation works.

---

### 4. Switch Terraform providers to impersonation

Since your providers already use:

```hcl
provider "google" {
  alias                      = "balerica"
  impersonate_service_account = local.balerica_sa_email
  ...
}

```

Terraform will automatically run as the impersonated SA next time.

#

Important: make sure you are logged in as your **developer/CI/CD account** (not Owner anymore). For example:

```bash
gcloud auth application-default login   # with your dev/ci account

```

Then confirm Terraform sees impersonation working:

```bash
terraform plan

```

---

### 5. Apply baseline IAM + bootstrap roles

Now impersonation is active, apply the **baseline SA roles + temporary roleAdmin**:

```bash
terraform apply -target=google_project_iam_member.balerica_sa_viewer \
                -target=google_project_iam_member.balerica_sa_network_admin \
                -target=google_project_iam_member.balerica_sa_ncc_admin \
                -target=google_project_iam_member.genosha_sa_viewer \
                -target=google_project_iam_member.genosha_sa_network_admin \
                -target=google_project_iam_member.genosha_sa_ncc_admin \
                -target=google_project_iam_member.bootstrap_roleadmin_balerica \
                -target=google_project_iam_member.bootstrap_roleadmin_genosha

```

---

### 6. Create custom VPN roles

```bash
terraform apply -target=google_project_iam_custom_role.balerica_vpn_role \
                -target=google_project_iam_custom_role.genosha_vpn_role

```

---

### 7. Cross-bindings

```bash
terraform apply -target=google_project_iam_member.allow_balerica_on_genosha \
                -target=google_project_iam_member.allow_genosha_on_balerica

```

---

### 8. Networking (VPCs, routers, VPNs, spokes, etc.)

At this point all IAM dependencies are satisfied. You can now apply everything else in one go:

```bash
terraform apply

```

---

Building Ladder:

1. ADC as Owner.
2. Seed impersonation.
3. Verify impersonation.
4. Run Terraform as impersonated SAs.
5. Apply baseline + bootstrap.
6. Custom roles.
7. Cross-bindings.
8. Networking.

#

## SCRIPTS


#

# APENDIX

## flatten Function

<https://developer.hashicorp.com/terraform/language/functions/flatten>

flatten takes a list and replaces any elements that are lists with a flattened sequence of the list contents.

#

Examples
> flatten([["a", "b"], [], ["c"]])
["a", "b", "c"]

#

If any of the nested lists also contain directly-nested lists, these too are flattened recursively:

> flatten([[["a", "b"], []], ["c"]])
["a", "b", "c"]

Indirectly-nested lists, such as those in maps, are not flattened.

Flattening nested structures for for_each
The resource for_each and dynamic block language features both require a collection value that has one element for each repetition.

Sometimes your input data structure isn't naturally in a suitable shape for use in a for_each argument, and flatten can be a useful helper function when reducing a nested data structure into a flat one.

For example, consider a module that declares a variable like the following:

```py
variable "networks" {
  type = map(object({
    cidr_block = string
    subnets    = map(object({ cidr_block = string }))
  }))
  default = {
    "private" = {
      cidr_block = "10.1.0.0/16"
      subnets = {
        "db1" = {
          cidr_block = "10.1.0.0/24"
        }
        "db2" = {
          cidr_block = "10.1.1.0/24"
        }
      }
    },
    "public" = {
      cidr_block = "10.2.0.0/16"
      subnets = {
        "webserver" = {
          cidr_block = "10.2.1.0/24"
        }
        "email_server" = {
          cidr_block = "10.2.2.0/24"
        }
      }
    }
    "dmz" = {
      cidr_block = "10.3.0.0/16"
      subnets = {
        "firewall" = {
          cidr_block = "10.3.1.0/24"
        }
      }
    }
  }
}
```

The above is a reasonable way to model objects that naturally form a tree, such as top-level networks and their subnets. The repetition for the top-level networks can use this variable directly, because it's already in a form where the resulting instances match one-to-one with map elements:

```
resource "aws_vpc" "example" {
  for_each = var.networks

  cidr_block = each.value.cidr_block
}
```

However, in order to declare all of the subnets with a single resource block, we must first flatten the structure to produce a collection where each top-level element represents a single subnet:


``` py
locals {

# flatten ensures that this local value is a flat list of objects, rather than a list of lists of objects
  network_subnets = flatten([
    for network_key, network in var.networks : [
      for subnet_key, subnet in network.subnets : {
        network_key = network_key
        subnet_key  = subnet_key
        network_id  = aws_vpc.example[network_key].id
        cidr_block  = subnet.cidr_block
      }
    ]
  ])
}

resource "aws_subnet" "example" {
# local.network_subnets is a list, so we must now project it into a map
# where each key is unique. We'll combine the network and subnet keys to
# produce a single unique key per instance

  for_each = tomap({
    for subnet in local.network_subnets : "${subnet.network_key}.${subnet.subnet_key}" => subnet
  })

  vpc_id            = each.value.network_id
  availability_zone = each.value.subnet_key
  cidr_block        = each.value.cidr_block
}
```

The above results in one subnet instance per subnet object, while retaining the associations between the subnets and their containing networks.

## Split
Split breaks a single string into a list of substrings based on a specified delimiter. 

Separator: The argument passed to the method, in this case '.'. This is the character where the split will occur.

ip_address = "192.168.1.10"
octets = ip_address.split('.')

Example
```py
print(octets)
# Output: ['192', '168', '1', '10']

# Accessing individual octets
first_octet = octets[0]
last_octet = octets[3]

print(f"The first octet is: {first_octet}")
# Output: The first octet is: 192

print(f"The last octet is: {last_octet}")
# Output: The last octet is: 10
```

# 

Project Example:
  `peer_ip_address = split["/", var.name_router_ip_tunnel0](0)`

  var.name_router_ip_tunnel0 is defined in the .tfvars like this:
        `name_router_ip_tunnel0 = "169.254.10.2/30"`

  That’s a fule CIDR string (IP address + subnet mask).
  ***BGP Peers*** only want the actual IP address, not the mask. Using a `split` will divide the ip address string into sub-strings formin an array:
  `split("/", var.name_router_ip_tunnel0) → ["169.254.10.2", "30"]`
    `[0]` selects the first element → "169.254.10.2"

  This strips off the subnet mask and provides only the peer IP address. This way the router interface still uses the full x.x.x.x/30, while the peer only uses the x.x.x.x.
