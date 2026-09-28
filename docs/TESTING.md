# Testing

Infrastructure scaffolding is verified in two places: static checks in CI, and permission, tunnel, and BGP checks against the live projects.

---

## Continuous integration

`.github/workflows/validate.yml`:

| Job | Checks |
|---|---|
| `terraform` (matrix: `bootstrap`, `infra`) | `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate` |
| `guard` | Fails if any plan file (`tfplan*`, `*.tfplan`, `plan`, `plan.json`), state file, or service-account key JSON is tracked. Runs `bash -n` on every script. |

No cloud credentials are needed. Local equivalent:

```bash
make fmt && make validate
```

---

## Identity verification (after bootstrap)

From [`SETUP-GUIDE.md`](SETUP-GUIDE.md) ("Service Account Verification", "Quick permission checks", "Verify Assignment"):

| Check | Command (shape) | Proves |
|---|---|---|
| SAs exist | `gcloud iam service-accounts list --project <p>` | Bootstrap created the Terraform SA per project |
| Impersonation works | `gcloud auth print-access-token --impersonate-service-account=<sa>` | Token Creator grant is in place |
| Roles bound | `gcloud projects get-iam-policy <p> --flatten=bindings --filter=bindings.members:<sa>` | Baseline + `terraform_vpn_role` + cross-project bindings |
| Custom role scope | `gcloud iam roles describe terraform_vpn_role --project <p>` | Least-privilege permission set |

## Network verification (after infra)

| Check | Command (shape) | Expected |
|---|---|---|
| Tunnels up | `gcloud compute vpn-tunnels list --project <p>` | `ESTABLISHED` on every tunnel |
| BGP sessions | `gcloud compute routers get-status <router> --region <r> --project <p>` | Each peer `UP`, routes learned |
| NCC spokes | `gcloud network-connectivity spokes list --hub <hub> --project <p>` | One VPN spoke per project with its tunnels linked |
| End to end | `ping` between test VMs in different projects | Reachable over VPN |

`scripts/doctor_common.sh` bundles common diagnostics. Screenshots from a verified run are in `SubFiles/`.

---

## Known gaps

- **No `terraform test`** for the `flatten()` locals that expand `var.tunnels`. That's the most intricate logic in the repo.
- **Network verification is manual.** A post-apply script asserting tunnel `ESTABLISHED` and BGP `UP` across all projects would close the loop.
- **Modules aren't validated standalone.** They're validated through the two roots only.
