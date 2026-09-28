# Security Policy

## Reporting a vulnerability

Please **don't** open a public issue. Email **jastek.sweeney@gmail.com** with the affected file and details.

---

## Identity model

| Principal | Used for | Credentials |
|---|---|---|
| Project owner (human) | `bootstrap/` only: create SAs, roles, bindings | ADC via `gcloud auth application-default login` |
| Terraform SA per project | `infra/`: all network and compute resources | **Impersonated** short-lived tokens. No key file. |
| CI identity | Same as the Terraform SAs | Workload Identity Federation → impersonation |

Each Terraform SA holds baseline roles plus a **custom `terraform_vpn_role` role** with only the VPN permissions it needs, and cross-project bindings limited to VPN resources in its peer project. Owner rights are used once, during bootstrap.

## Secrets

| Secret | Where | Never |
|---|---|---|
| VPN pre-shared keys | `terraform.tfvars` (gitignored) | In code, logs, **or plan files in git** |
| SA key JSON | Not used. `*.json` is gitignored as a backstop. | Created, downloaded, or committed |
| Terraform state | Remote backend | Committed (`*.tfstate` is gitignored) |

## ⚠️ Incident: pre-shared keys in committed plan files

**What happened:** three binary plan files (`tfplan`, `infra/tfplan_infra`, `bootstrap/tfplan_bootstrap`) were committed on 2025-12-28. Terraform plans embed variable values. `tfplan` and `infra/tfplan_infra` together contain **16 of the 21 VPN pre-shared keys** from `terraform.tfvars`. This repository is **public**.

**Done (2026-09-28):**
- All three files untracked (`git rm --cached`) and ignored (`tfplan`, `tfplan_*`, `*.tfplan`, `plan`, `plan.json`).
- CI `guard` job fails the build if a plan, state, or key file is ever tracked again.

**Still required (owner action):**
1. **Rotate every PSK** for any tunnel that still exists, or confirm that all tunnels are destroyed.
2. Optionally purge history: `git filter-repo --path tfplan --path infra/tfplan_infra --path bootstrap/tfplan_bootstrap --invert-paths`, then force-push. This rewrites history for every clone.

## Recommended checks

```bash
git ls-files | grep -E 'tfplan|\.tfstate|-[0-9a-f]{12}\.json$'   # should print nothing
checkov -d . --framework terraform
gitleaks detect --source . --log-opts="--all"
```
