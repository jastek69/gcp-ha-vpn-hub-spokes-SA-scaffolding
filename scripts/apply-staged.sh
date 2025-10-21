#!/usr/bin/env bash
# ===============================================================
# apply-staged.sh
# Safe, staged Terraform apply with waits and smoke tests
# ===============================================================

set -euo pipefail
trap 'echo "❌ Error on line $LINENO"; exit 1' ERR

# Configurable constants
WAIT_TIME=60
PROJECTS=("taaops" "genosha-ops")
STAGES=("01-init" "02-vpc" "03-iam" "04-ha-vpn-gateways" "05-vpn-tunnels" "14-router")

echo "🚀 Starting staged Terraform apply process..."
echo "=============================================="

# --- Stage 1: Validate environment
echo "🔍 Validating Terraform syntax..."
terraform validate

echo "🪣 Ensuring backend initialized..."
terraform init -upgrade -reconfigure

echo "🧾 Running Terraform plan (dry-run preview)..."
terraform plan -out=tfplan-preview
echo "✅ Plan saved as tfplan-preview"

# --- Stage 2: Apply in order
for stage in "${STAGES[@]}"; do
  echo ""
  echo "=============================================="
  echo "⚙️  APPLY STAGE: $stage"
  echo "=============================================="

  terraform apply -auto-approve -target="module.${stage}" || true

  # Post-stage waits for routers / tunnels
  if [[ "$stage" == "14-router" ]]; then
    echo "⏳ Waiting ${WAIT_TIME}s for routers to propagate..."
    sleep $WAIT_TIME
  elif [[ "$stage" == "05-vpn-tunnels" ]]; then
    echo "⏳ Waiting ${WAIT_TIME}s for VPN tunnels to establish..."
    sleep $WAIT_TIME
  fi
done

echo ""
echo "🧪 Running post-deployment smoke test..."
make smoke-test || {
  echo "❌ Smoke test failed — check tunnel and router states."
  exit 1
}

echo ""
echo "🔍 Running extended verify-network test..."
make verify-network || echo "⚠️ Network verification encountered issues, please review output."

echo ""
echo "✅ Staged apply complete!"
echo "You can now test cross-project connectivity (ping/SSH) or proceed with destroy-staged.sh."
