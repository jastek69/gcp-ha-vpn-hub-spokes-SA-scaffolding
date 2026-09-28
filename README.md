# GCP HA VPN Hub-and-Spoke — Service-Account Impersonation Scaffolding

![IaC](https://img.shields.io/badge/IaC-Terraform-orange)
![GCP](https://img.shields.io/badge/Cloud-GCP-4285F4?logo=googlecloud)
![VPN](https://img.shields.io/badge/VPN-HA%20%2B%20BGP-green)
![NCC](https://img.shields.io/badge/Network%20Connectivity%20Center-hub%20%2F%20spoke-blue)
![Keys](https://img.shields.io/badge/SA%20keys-none-success)

*Armageddon 6.5 — Brotherhood of Evil jerMutants, Wolfpack.* Team: John Sweeney, T.I.Q.S., Michael Dale, Cassiem Davids, Vincenet Woods (Uriah), Benji, Royce Billot.

> Full setup, IAM detail, per-file network notes, and script reference: [`docs/SETUP-GUIDE.md`](docs/SETUP-GUIDE.md) · Workspace repo: [gcp-ha-vpn-hub-spokes](https://github.com/jastek69/gcp-ha-vpn-hub-spokes)

---

# Executive Summary

A Terraform scaffold for a multi-project Google Cloud network: HA VPN gateways and tunnels with BGP between projects, Network Connectivity Center hubs and spokes, and per-project Cloud Routers. The environment spans **six projects across four continents**.

The scaffold separates **identity bootstrap** from **infrastructure**. `bootstrap/` seeds Terraform service accounts, custom VPN roles, and cross-project bindings once. `infra/` builds and destroys compute and networking freely without touching identity. Terraform authenticates through **service-account impersonation** from the operator's Application Default Credentials (or Workload Identity Federation in CI), so **no JSON key file is ever needed.**

About 51 Terraform resources across two roots and seven modules, driven by a single `tunnels = {}` map. Correctness is verified by `terraform validate` on both roots in CI, plus documented permission and tunnel/BGP status checks.

---

## Problem

- **Multi-project GCP tempts people into key files.** Downloaded service-account JSON keys are the most common way GCP credentials leak, and each extra project multiplies them.
- **Identity and network have different lifecycles.** Rebuilding a network shouldn't mean tearing down and re-granting IAM. Adding a project shouldn't mean hand-editing every tunnel.
- **Mesh configuration explodes.** Every spoke pair needs gateways, tunnels, router interfaces, and BGP peers on both sides, each with matching PSKs, ASNs, and link-local IPs.

---

## Solution

- **Bootstrap / infra split.** `bootstrap_mode = true` runs as the project owner via ADC and grants impersonation. `bootstrap_mode = false` runs as the per-project Terraform service accounts.
- **Impersonation instead of keys.** Providers set `impersonate_service_account`. Rotating or recreating an SA changes nothing in Terraform. CI uses the same path through WIF.
- **Least-privilege custom roles.** `terraform_vpn_role` in each project, plus cross-project bindings, so each SA can use VPN resources in its peer project and nothing more.
- **Data-driven mesh.** One `tunnels = {}` map in tfvars holds PSK, ASN, region, and interface IPs per tunnel. `flatten()`ed locals expand it into gateways, tunnels, router interfaces, and peers. Adding a project is a map entry.

Governing constraint: **no hard-coded mappings.** Every PSK, ASN, region, and IP comes from `var.tunnels`, and every resource is generated from it.

---

## Architecture

```
            bootstrap/ (once)                              infra/ (build / destroy freely)
  Owner ADC ──► per-project Terraform SAs          ┌──────────────── tunnels = {} ────────────────┐
             ├─ custom role terraform_vpn_role         │         flatten() → per-tunnel records        │
             ├─ baseline roles                      ▼                                               ▼
             └─ cross-project impersonation   HA VPN GW (project A) ══ 2 tunnels · BGP ══ HA VPN GW (project B)
                                                     │                                               │
                                              Cloud Router ASN 65501                        Cloud Router ASN 65515
                                                     │                                               │
                                              NCC hub ◄── spoke (linked_vpn_tunnels: all tunnels where src == project)
```

Dependency chain: **IAM → gateways → tunnels → router interfaces → BGP peers.**

| Module | Role |
|---|---|
| `vpc`, `subnet`, `network` | Per-project VPC and subnets |
| `hub`, `spoke` | NCC hub per project. Spokes auto-collect their source tunnels. |
| `router_link` | Router interfaces + BGP peers per tunnel. The peer IP is `split("/", cidr)[0]`. |
| `compute` | Test VMs per region |

Diagrams: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

---

## Technologies

| Domain | Services |
|---|---|
| IaC | Terraform (two roots: `bootstrap/`, `infra/`; seven modules), Make, Bash |
| Networking | GCP HA VPN, Cloud Router (BGP), Network Connectivity Center (hubs, VPN spokes, site-to-site data transfer) |
| Identity | Service-account impersonation (ADC), Workload Identity Federation for CI, IAM custom roles |
| Compute | Compute Engine test VMs across regions |
| CI | GitHub Actions: `fmt`, `validate` on both roots, committed-plan and key guard |

---

## Deployment

**Prerequisites:** Terraform; `gcloud auth application-default login` as a user with Owner on each project (bootstrap only); the IAM Service Account Credentials API enabled; `terraform.tfvars` at the repo root (copy [`terraform.tfvars.example`](terraform.tfvars.example)).

```bash
make bootstrap-plan && make bootstrap     # once: SAs, custom roles, impersonation grants
make infra-plan && make infra             # networking + compute (bootstrap_mode = false)

make infra-destroy                        # tear down network, keep identity
make destroy-all                          # infra-destroy, then bootstrap-destroy
```

The equivalent scripts are `./scripts/bootstrap.sh apply|destroy` and `./scripts/infra.sh apply|destroy`. Site-to-site data transfer isn't supported in every region (for example `southamerica-east1`), so choose spoke regions accordingly.

**Cost:** HA VPN tunnels bill hourly per tunnel. Run `make infra-destroy` when you're not demonstrating.

Full procedure: [`docs/SETUP-GUIDE.md`](docs/SETUP-GUIDE.md)

---

## Security

- **No service-account keys.** Terraform uses short-lived impersonated tokens. Key JSON files are gitignored (`*.json`) and aren't needed.
- **Owner rights are used once.** Only bootstrap runs as the owner. Infra runs as least-privilege Terraform SAs with custom VPN roles.
- **Pre-shared keys live only in `terraform.tfvars`** (gitignored). **Plan files embed them.** See the incident note in [`SECURITY.md`](SECURITY.md).
- **Not responsible for:** firewall policy between spokes beyond what the test VMs need, or org-policy constraints.

---

## Repository Structure

```
.
├── bootstrap/          Root 1: provider (ADC), SAs, custom roles, IAM bindings
├── infra/              Root 2: VPCs, subnets, HA VPN, tunnels, NCC hub/spokes, routers, compute
├── modules/            vpc · subnet · network · hub · spoke · router_link · compute
├── scripts/            bootstrap.sh · infra.sh · CI variants · lock cleanup · doctor diagnostics
├── Makefile            bootstrap / infra / destroy-all / fmt / validate / clean-plans
├── SubFiles/           Screenshots, flowchart, submission PDF
└── docs/               Setup guide, architecture, testing
```

| Document | Covers |
|---|---|
| [`docs/SETUP-GUIDE.md`](docs/SETUP-GUIDE.md) | Full original README: impersonation, SA permissions and verification, scripts, Makefile, project naming, region restrictions, BGP/ASN config, hub-and-spoke logic, step-by-step bootstrap |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Mermaid diagrams: two-phase flow, tunnel pair, data-driven expansion |
| [`docs/TESTING.md`](docs/TESTING.md) | CI checks, permission and impersonation verification, tunnel/BGP status, known gaps |
| [`SECURITY.md`](SECURITY.md) | Vulnerability reporting, identity model, secrets, PSK exposure note |
| [`README_serviceAccounts.md`](README_serviceAccounts.md) · [`README_scaffolding.md`](README_scaffolding.md) · [`Workflow.md`](Workflow.md) | Service-account and scaffolding deep dives, workflow |
| [`scripts/README_scripts.md`](scripts/README_scripts.md) | Script reference |

---

## Lessons Learned

**Plan files are secrets.** A saved `tfplan` embeds every variable value, including VPN pre-shared keys. Three plan files were committed to this public repo before `.gitignore` covered them. They're now untracked and a CI guard rejects them, but history still holds the keys.

**Impersonation removes a whole class of credential problems.** With no key files there's nothing to rotate, leak, or distribute. Recreating a service account doesn't touch Terraform, and humans and CI take the same auth path.

**`split()` lets one variable serve two resources.** A router interface wants the `/30` (`169.254.x.y/30`), while its BGP peer wants the bare IP. `split("/", cidr)[0]` derives the peer from the same variable, so they can't drift.

**Separate lifecycles deserve separate roots.** Putting IAM in the same root as the network meant every network rebuild risked identity churn. Two roots with a mode flag made infra truly disposable.

**Regional feature support shapes topology.** NCC site-to-site data transfer is unavailable in some regions (South America among them), which constrained where spokes could go before any code was written.

**A mistyped CLI flag creates files.** `-target=...` passed where the shell expected a filename left seven empty files in the repo root. They're gone now, and CI's `fmt` and `validate` would have made the typo obvious sooner.

---

## Future Improvements

- **Purge plan files from git history** (`git filter-repo`) and rotate any PSK still in use.
- **Remote state with locking** documented and enforced for both roots in CI.
- **`terraform test`** for the `flatten()` locals. The tunnel-map expansion is the most intricate logic here and has no automated coverage.
- **Firewall and org-policy baseline** per spoke, so connectivity isn't implicitly all-to-all.
- **Hub-centric routing option.** Today every project gets its own hub. A single transit hub would demonstrate NCC's intended hub-and-spoke shape.
