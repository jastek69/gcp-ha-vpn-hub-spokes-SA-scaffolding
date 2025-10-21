#!/usr/bin/env bash
# =====================================================================
# destroy-staged-ci.sh
# CI/CD Safe Terraform Destroy for Multi-Project HA VPN Infrastructure
# =====================================================================
# Features:
# ✅ Pre-check ensures no tunnels in ESTABLISHED state before teardown
# ✅ Retry mode with exponential backoff (30s → 60s → 120s)
# ✅ --force flag to bypass pre-check (CI emergency cleanup)
# ✅ Dry-run mode via DESTROY_MODE=dry-run
# ✅ Non-interactive, auto-approved Terraform destroys
# ✅ Reverse dependency order: peers → routers → tunnels → gateways → VPCs
# ✅ Fixed wait timer between stages
# ✅ Slack/webhook notifications
# =====================================================================

set -euo pipefail

WAIT_TIME=45
TF_LOG_PATH="ci-terraform-destroy.log"
DESTROY_MODE="${DESTROY_MODE:-apply}"  # Options: dry-run | apply
FORCE="${FORCE:-false}"                # Optional override flag
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

# ---------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
notify() {
  [[ -n "$SLACK_WEBHOOK_URL" ]] && \
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"$*\"}" "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# ---------------------------------------------------------------------
# VPN Tunnel Pre-Check with Retry Mode (unless forced)
# ---------------------------------------------------------------------
precheck_vpn_tunnels() {
  if [[ "$FORCE" == "true" ]]; then
    log "⚠️  Force mode enabled — skipping VPN tunnel pre-check!"
    notify "⚠️  Force mode bypassed VPN pre-check — proceeding with destroy unsafely!"
    return 0
  fi

  local retries=3
  local delay=30
  local attempt=1

  while (( attempt <= retries )); do
    log "🔍 [Attempt $attempt/$retries] Checking for active VPN tunnels..."
    local active_tunnels
    active_tunnels=$(gcloud compute vpn-tunnels list \
      --format="table(name,region,status)" \
      --filter="status:ESTABLISHED" 2>/dev/null || true)

    if [[ -z "$active_tunnels" || $(echo "$active_tunnels" | grep -c ESTABLISHED || true) -eq 0 ]]; then
      log "✅ No active VPN tunnels detected. Proceeding with destroy."
      notify "✅ VPN precheck passed — no active tunnels detected."
      return 0
    fi

    log "🚫 Found active tunnels in ESTABLISHED state:"
    echo "$active_tunnels"
    if (( attempt < retries )); then
      log "⏳ Waiting ${delay}s before retrying..."
      sleep "$delay"
      delay=$((delay * 2))  # exponential backoff
    else
      log "❌ All retries exhausted. Aborting destroy for safety."
      notify "❌ Terraform destroy aborted — active VPN tunnels remain established after ${retries} attempts."
      exit 1
    fi

    ((attempt++))
  done
}

# ---------------------------------------------------------------------
# Initialization
# ---------------------------------------------------------------------
log "🔥 Starting CI/CD Terraform destroy pipeline (mode=${DESTROY_MODE}, force=${FORCE})..."
notify "🔥 Starting Terraform staged destroy pipeline (mode=${DESTROY_MODE}, force=${FORCE})..."

terraform init -reconfigure -upgrade | tee -a "$TF_LOG_PATH"
terraform validate | tee -a "$TF_LOG_PATH"

# Run pre-check unless forced
precheck_vpn_tunnels

# ---------------------------------------------------------------------
# Ordered Destroy Stages
# ---------------------------------------------------------------------
DESTROY_ORDER=(
  "google_compute_router_peer.peers"
  "google_compute_router_interface.interfaces"
  "google_compute_router.routers"
  "google_compute_vpn_tunnel.all"
  "google_compute_ha_vpn_gateway.gateways"
  "module.balerica_vpc"
  "module.genosha_vpc"
)

# ---------------------------------------------------------------------
# Destroy Execution Loop
# ---------------------------------------------------------------------
for target in "${DESTROY_ORDER[@]}"; do
  log "=============================================="
  log "💣 TARGET: ${target} (mode=${DESTROY_MODE})"
  log "=============================================="

  if [[ "$DESTROY_MODE" == "dry-run" ]]; then
    log "🧪 Simulating destroy of ${target}..."
    terraform plan -destroy -target="${target}" | tee -a "$TF_LOG_PATH"
  else
    terraform destroy -auto-approve -target="${target}" | tee -a "$TF_LOG_PATH"
  fi

  log "⏳ Waiting ${WAIT_TIME}s before next phase..."
  sleep "$WAIT_TIME"
done

# ---------------------------------------------------------------------
# Post-Destroy Verification
# ---------------------------------------------------------------------
if [[ "$DESTROY_MODE" == "dry-run" ]]; then
  log "✅ Dry-run complete. No resources destroyed."
  notify "🧪 Terraform destroy DRY-RUN complete — no resources deleted."
  exit 0
fi

log "🧹 Cleanup complete — running final sanity check..."
if terraform plan -detailed-exitcode >/dev/null 2>&1; then
  log "✅ All resources removed cleanly."
  notify "✅ Terraform destroy complete — environment fully cleaned up."
else
  log "⚠️ Residual resources may exist (manual review recommended)."
  notify "⚠️ Terraform destroy finished, but residual resources detected."
fi

log "🏁 CI/CD Terraform destroy pipeline complete."
notify "🏁 Terraform destroy pipeline complete (mode=${DESTROY_MODE}, force=${FORCE})."
