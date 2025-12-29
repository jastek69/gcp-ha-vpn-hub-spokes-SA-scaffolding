## Scripts quick start

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

