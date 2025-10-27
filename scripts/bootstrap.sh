#!/usr/bin/env bash
set -euo pipefail

OWNER_ACCOUNT="user:you@example.com"

echo "==> authenticating ADC as bootstrap owner"
gcloud auth application-default login

echo "==> terraform init (bootstrap mode)"
terraform init -reconfigure

echo "==> stage 1: impersonation bindings"
terraform apply -auto-approve \
  -target=google_service_account_iam_member.balerica_impersonation_token_creator \
  -target=google_service_account_iam_member.balerica_impersonation_sa_user \
  -target=google_service_account_iam_member.genosha_impersonation_token_creator \
  -target=google_service_account_iam_member.genosha_impersonation_sa_user \
  -target=google_service_account_iam_member.tiqs_impersonation_token_creator \
  -target=google_service_account_iam_member.tiqs_impersonation_sa_user

echo "==> verify impersonation (optional)"
gcloud auth print-access-token \
  --impersonate-service-account=terraform@taaops.iam.gserviceaccount.com >/dev/null

echo "==> stage 2: baseline IAM roles (still in bootstrap account)"
terraform apply -auto-approve \
  -target=google_project_iam_member.baseline_roles \
  -target=google_project_iam_member.cross_bindings \
  -target=google_project_iam_custom_role.vpn_role_taaops \
  -target=google_project_iam_custom_role.vpn_role_genosha \
  -target=google_project_iam_custom_role.vpn_role_tiqs

echo "==> stage 3: switch to impersonation"
gcloud auth application-default login --no-launch-browser \
  --account "ci-account@example.com"
terraform plan >/dev/null

echo "==> stage 4: full converge"
terraform apply -auto-approve
echo "==> complete!"
