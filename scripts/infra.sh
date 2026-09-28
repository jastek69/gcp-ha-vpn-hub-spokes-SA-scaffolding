#!/usr/bin/env bash
set -euo pipefail

# Wrapper for infra Terraform runs (impersonation mode).
# Usage:
#   ./scripts/infra.sh apply   # init + plan + apply (default)
#   ./scripts/infra.sh plan    # init + plan only
#   ./scripts/infra.sh destroy # destroy infra resources

CMD="${1:-apply}"
shift || true

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_BIN="${TF_BIN:-terraform}"
TFVARS="${TFVARS:-${ROOT_DIR}/terraform.tfvars}"
PLAN_FILE="${PLAN_FILE:-tfplan_infra}"
LOCK_TIMEOUT="${LOCK_TIMEOUT:-5m}"

run_init() {
  echo "==> terraform init (infra)"
  "$TF_BIN" -chdir="${ROOT_DIR}/infra" init -input=false >/dev/null
}

run_plan() {
  echo "==> terraform plan (bootstrap_mode=false)"
  "$TF_BIN" -chdir="${ROOT_DIR}/infra" plan \
    -input=false \
    -lock-timeout="${LOCK_TIMEOUT}" \
    -var-file="${TFVARS}" \
    -var="bootstrap_mode=false" \
    -out="${PLAN_FILE}" \
    "$@"
}

run_apply() {
  echo "==> terraform apply ${PLAN_FILE}"
  "$TF_BIN" -chdir="${ROOT_DIR}/infra" apply \
    -input=false \
    "${PLAN_FILE}"
}

run_destroy() {
  echo "==> terraform destroy (bootstrap_mode=false)"
  "$TF_BIN" -chdir="${ROOT_DIR}/infra" destroy \
    -input=false \
    -lock-timeout="${LOCK_TIMEOUT}" \
    -var-file="${TFVARS}" \
    -var="bootstrap_mode=false" \
    "$@"
}

case "${CMD}" in
  plan)
    run_init
    run_plan "$@"
    ;;
  apply)
    run_init
    run_plan "$@"
    run_apply
    ;;
  destroy)
    run_init
    run_destroy "$@"
    ;;
  *)
    echo "Usage: $0 {plan|apply|destroy}" >&2
    exit 1
    ;;
esac
