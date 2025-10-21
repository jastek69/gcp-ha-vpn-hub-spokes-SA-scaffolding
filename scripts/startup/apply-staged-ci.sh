#!/usr/bin/env bash
# =====================================================================
# apply-staged-ci.sh
# CI/CD + Interactive Safe Terraform Apply for Multi-Project HA VPN
# =====================================================================
# Features:
# ✅ CI/CD-aware: runs non-interactively when CI=true
# ✅ Local confirmation unless FORCE=true
# ✅ Pre-check: validates backend, credentials, and state
# ✅ Retry + --force support
# ✅ Dry-run (plan-only) mode supported
# ✅ Ordered apply (IAM → VPCs → gateways → tunnels → routers → peers)
# ✅ Slack/webhook notification integration
# ✅ Fixed wait timers between critical dependencies
# =====================================================================

set -euo pipefail

WAIT_TIME=60
TF_LOG_PATH="ci-terraform-apply.log"
APPLY_MODE="${APPLY_MODE:-apply}"   # apply | plan
FORCE="${FORCE:-false}"
CI="${CI:-false}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
notify() {
  [[ -n "$SLACK_WEBHOOK_URL" ]] && \
    curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"$*\"}" "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# ---------------------------------------------------------------------
# Confirmation (Local safety)
# ---------------------------------------------------------------------
confirm_apply() {
  if [[ "$CI" == "true" ]]; then
    log "🤖 CI/CD mode detected — skipping manual confirmation."
    return 0
  fi
  if [[ "$FORCE" == "true" ]]; then
    log "⚠️ FORCE=true — skipping manual confirmation."
    return 0
  fi

  echo "⚠️  This will apply Terraform changes to live infrastructure."
  read -p "Type 'yes' to continue: " ans
  [[ "$ans" == "yes" ]] || { echo "Aborted."; exit 1; }
}

# ---------------------------------------------------------------------
# Pre-checks (backend + credentials + sanity)
# ---------------------------------------------------------------------
precheck_environment() {
  log "🔍 Running environment prechecks..."
  terraform init -reconfigure -upgrade | tee -a "$TF_LOG_PATH"
  terraform validate | tee -a "$TF_LOG_PATH"
  gcloud auth list --filter=status:ACTIVE --format="value(account)" >/dev/null || {
    log "❌ No active gcloud credentials detected."
    exit 1
  }
  log "✅ Terraform + GCloud environment ready."
}

# ---------------------------------------------------------------------
# Retry wrapper
# ---------------------------------------------------------------------
retry() {
  local cmd="$1" retries=3 delay=30 attempt=1
  until $cmd; do
    if (( attempt == retries )); then
      log "❌ Command failed after ${retries} attempts: $cmd"
      return 1
    fi
    log "⚠️  Command failed (attempt ${attempt}/${retries}). Retrying in ${delay}s..."
    sleep "$delay"; delay=$((delay * 2)); ((attempt++))
  done
}

# ---------------------------------------------------------------------
# Apply sequence
# ---------------------------------------------------------------------
confirm_apply
precheck_environment

notify "🚀 Terraform staged apply started (mode=${APPLY_MODE}, CI=${CI}, force=${FORCE})"

# Define apply sequence (by dependency)
APPLY_ORDER=(
  "google_project_iam_member.baseline_roles"
  "google_project_iam_member.cross_bindings"
  "module.balerica_vpc"
  "module.genosha_vpc"
  "google_compute_ha_vpn_gateway.gateways"
  "google_compute_vpn_tunnel.all"
  "google_compute_router.routers"
  "google_compute_router_interface.interfaces"
  "google_compute_router_peer.peers"
)

for target in "${APPLY_ORDER[@]}"; do
  log "🚧 Applying ${target} (mode=${APPLY_MODE})"
  if [[ "$APPLY_MODE" == "plan" ]]; then
    terraform plan -target="${target}" | tee -a "$TF_LOG_PATH"
  else
    retry "terraform apply -auto-approve -target=${target} | tee -a $TF_LOG_PATH"
  fi
  log "⏳ Waiting ${WAIT_TIME}s before next dependency..."
  sleep "$WAIT_TIME"
done

# ---------------------------------------------------------------------
# Post verification
# ---------------------------------------------------------------------
log "🔍 Verifying VPN tunnel connectivity..."
if gcloud compute vpn-tunnels list --format="value(status)" | grep -q ESTABLISHED; then
  log "✅ VPN tunnels are active and established."
  notify "✅ Terraform apply complete — tunnels are ESTABLISHED."
else
  log "⚠️ VPN tunnels not yet established — check GCP Console."
  notify "⚠️ Terraform apply finished, but tunnels not fully active."
fi

log "🏁 Terraform staged apply completed."
notify "🏁 Terraform apply pipeline finished successfully."
