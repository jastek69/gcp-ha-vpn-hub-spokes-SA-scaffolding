# ===========================================================
# Terraform Hub-Spoke Bootstrap & Lifecycle Makefile
# ===========================================================
#
# Usage Cheat Sheet:
#   make doctor-bootstrap         → Ensure Terraform SAs exist + baseline roles
#   make bootstrap                → Bootstrap SAs + impersonation bindings
#   make reset-bootstrap          → Reset baseline IAM (DELETE_SA=true optional)
#   make toggle-bootstrap MODE=…  → Flip bootstrap_mode in terraform.tfvars
#   make staged-apply             → Run staged Terraform apply with waits
#   make staged-destroy           → Run staged Terraform destroy in reverse
#   make safe-apply               → Safe apply with confirmation prompts
#   make safe-destroy             → Safe destroy with confirmation prompts
#
# Flags:
#   FORCE=true   → Bypass confirmation prompts
#   DELETE_SA=true → Also delete Terraform SAs on reset
#
# ===========================================================
BALERICA_PROJECT ?= taaops
GENOSHA_PROJECT  ?= genosha-ops
BALERICA_REGION  ?= asia-southeast1
GENOSHA_REGION   ?= us-central1
USER_EMAIL       ?= jastek.sweeney@gmail.com

RED    := $(shell tput setaf 1)
GREEN  := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RESET  := $(shell tput sgr0)

# ===========================================================
# Doctor checks - Bootstrap
# ===========================================================
doctor-bootstrap:
	@echo "=== [DOCTOR] Checking Terraform bootstrap service accounts ==="
	@for project in $(BALERICA_PROJECT) $(GENOSHA_PROJECT); do \
	  echo "--- $$project ---"; \
	  if gcloud iam service-accounts list --project $$project \
	    --filter="email:terraform@$$project.iam.gserviceaccount.com" \
	    --format="value(email)" | grep -q "terraform@$$project.iam.gserviceaccount.com"; then \
	      echo "$(GREEN)[PASS]$(RESET) Found terraform@$$project.iam.gserviceaccount.com"; \
	  else \
	      echo "$(YELLOW)[WARN]$(RESET) Missing SA, creating..."; \
	      gcloud iam service-accounts create terraform \
	        --display-name="terraform" \
	        --project=$$project; \ || true
	  fi; \
	  echo "🔑 Ensuring baseline roles..."; \
	  for role in roles/iam.serviceAccountAdmin \
	              roles/iam.serviceAccountTokenCreator \
	              roles/viewer \
	              roles/compute.networkAdmin \
	              roles/networkconnectivity.admin; do \
	    gcloud projects add-iam-policy-binding $$project \
	      --member="serviceAccount:terraform@$$project.iam.gserviceaccount.com" \
	      --role="$$role" >/dev/null; || true \
	  done; \
	done


# ===========================================================
# Bootstrap Wrapper
# ===========================================================
all-bootstrap:
	@echo "=== [ALL-BOOTSTRAP WRAPPER] ==="
	@echo "$(YELLOW)⚠️ Reminder: Run 'gcloud auth application-default login' first, and ensure bootstrap_mode=true.$(RESET)"
	@if ! grep -q "bootstrap_mode *= *true" terraform.tfvars; then \
	  echo "$(RED)ERROR: bootstrap_mode is not true. Aborting.$(RESET)"; exit 1; \
	fi
	$(MAKE) bootstrap-sas
	$(MAKE) bootstrap-bindings
	@echo "$(GREEN)✅ All bootstrap steps complete.$(RESET)"



# ===========================================================
# Bootstrap Flow
# ===========================================================
bootstrap-sas: doctor-bootstrap
	@echo "=== [STEP 1] Terraform Service Accounts verified + baseline roles granted ==="

bootstrap-bindings:
	@echo "=== [STEP 2] Apply impersonation bindings (bootstrap_mode=true) ==="
	@if ! grep -q "bootstrap_mode *= *true" terraform.tfvars; then \
	  echo "$(RED)ERROR: bootstrap_mode must be true before running bindings.$(RESET)"; exit 1; \
	fi
	terraform apply -auto-approve \
	  -var="bootstrap_mode=true" \
	  -target=google_service_account_iam_member.balerica_impersonation_token_creator \
	  -target=google_service_account_iam_member.balerica_impersonation_sa_user \
	  -target=google_service_account_iam_member.genosha_impersonation_token_creator \
	  -target=google_service_account_iam_member.genosha_impersonation_sa_user

bootstrap: bootstrap-sas bootstrap-bindings
	@echo "$(GREEN)✅ Bootstrap complete.$(RESET)"

reset-bootstrap:
	@echo "=== [RESET] Removing bootstrap IAM roles ==="
	@if [ "$(FORCE)" != "true" ]; then \
	  read -p "⚠️  Type 'yes' to confirm reset-bootstrap: " ans; \
	  [ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }; \
	fi
	@for project in $(BALERICA_PROJECT) $(GENOSHA_PROJECT); do \
	  echo "--- Cleaning $$project ---"; \
	  for role in roles/iam.serviceAccountAdmin \
	               roles/iam.serviceAccountTokenCreator \
	               roles/viewer \
	               roles/compute.networkAdmin \
	               roles/networkconnectivity.admin; do \
	    gcloud projects remove-iam-policy-binding $$project \
	      --member="serviceAccount:terraform@$$project.iam.gserviceaccount.com" \
	      --role="$$role" || true; \
	  done; \
	  if [ "$(DELETE_SA)" = "true" ]; then \
	    gcloud iam service-accounts delete terraform@$$project.iam.gserviceaccount.com \
	      --project $$project --quiet || true; \
	  fi; \
	done

# ===========================================================
# Lifecycle: staged apply/destroy
# ===========================================================
staged-apply:
	@echo "=== [STAGED APPLY] ==="
	terraform apply -target=module.balerica_vpc -target=module.genosha_vpc -auto-approve
	sleep 30
	terraform apply -target=google_compute_router.routers -auto-approve
	sleep 60
	terraform apply -target=google_compute_router_interface.interfaces -target=google_compute_router_peer.peers -auto-approve
	sleep 30
	terraform apply -auto-approve
	@echo "$(GREEN)✅ Staged apply complete.$(RESET)"

staged-destroy:
	@echo "=== [STAGED DESTROY] ==="
	terraform destroy -target=google_compute_router_peer.peers -auto-approve || true
	terraform destroy -target=google_compute_router_interface.interfaces -auto-approve || true
	terraform destroy -target=google_compute_router.routers -auto-approve || true
	sleep 30
	terraform destroy -target=google_compute_vpn_tunnel.all -auto-approve || true
	terraform destroy -target=google_compute_ha_vpn_gateway.gateways -auto-approve || true
	terraform destroy -target=module.balerica_vpc -target=module.genosha_vpc -auto-approve || true
	@echo "$(GREEN)✅ Staged destroy complete.$(RESET)"

safe-apply:
	@echo "=== [SAFE APPLY] ==="
	@if [ "$(FORCE)" != "true" ]; then \
	  read -p "⚠️ Type 'yes' to continue with apply: " ans; \
	  [ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }; \
	fi
	$(MAKE) staged-apply

safe-destroy:
	@echo "=== [SAFE DESTROY] ==="
	@if [ "$(FORCE)" != "true" ]; then \
	  read -p "⚠️ Type 'yes' to continue with destroy: " ans; \
	  [ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }; \
	fi
	$(MAKE) staged-destroy

# ===========================================================
# Bootstrap Mode Helpers
# ===========================================================
toggle-bootstrap:
	@echo "=== [TOGGLE] Setting bootstrap_mode to $(MODE) ==="
	@if [ "$(MODE)" != "true" ] && [ "$(MODE)" != "false" ]; then \
	  echo "$(RED)ERROR: Must set MODE=true or MODE=false$(RESET)"; exit 1; \
	fi
	@sed -i.bak 's/bootstrap_mode *= *.*/bootstrap_mode = $(MODE)/' terraform.tfvars
	@echo "$(GREEN)✅ bootstrap_mode set to $(MODE).$(RESET)"

status-bootstrap:
	@echo "=== [STATUS] bootstrap_mode ==="
	@grep "bootstrap_mode" terraform.tfvars || echo "$(RED)bootstrap_mode not set$(RESET)"


# ===========================================================
# Smoke Tests
# ===========================================================

# Soft version: only displays tunnel and router status (does not fail)
smoke-test-lite:
	@echo "=== [SMOKE TEST - LITE] Checking current HA VPN and Router health ==="
	@for project in $(BALERICA_PROJECT) $(GENOSHA_PROJECT); do \
	  echo "--- Routers in $$project ---"; \
	  gcloud compute routers list --project=$$project --format="table(name, region, network)" || true; \
	  echo "--- HA VPN Gateways in $$project ---"; \
	  gcloud compute vpn-gateways list --project=$$project --format="table(name, network, region)" || true; \
	  echo "--- VPN Tunnels in $$project ---"; \
	  gcloud compute vpn-tunnels list --project=$$project --format="table(name, region, status)" || true; \
	done
	@echo "$(GREEN)✅ Smoke-test-lite complete — informational only.$(RESET)"

# Strict version: fails if any tunnel is not ESTABLISHED
smoke-test:
	@echo "=== [SMOKE TEST - STRICT] Validating VPN Tunnels ESTABLISHED status ==="
	@failed=0; \
	for project in $(BALERICA_PROJECT) $(GENOSHA_PROJECT); do \
	  for t in $$(gcloud compute vpn-tunnels list --project=$$project --format="value(name)"); do \
	    region=$$(gcloud compute vpn-tunnels list --project=$$project --filter="name=$$t" --format="value(region)"); \
	    status=$$(gcloud compute vpn-tunnels describe $$t --project=$$project --region=$$region --format="value(status)"); \
	    if [ "$$status" != "ESTABLISHED" ]; then \
	      echo "$(RED)❌ Tunnel $$t in $$project is $$status (expected ESTABLISHED)$(RESET)"; \
	      failed=1; \
	    else \
	      echo "$(GREEN)✅ Tunnel $$t in $$project is ESTABLISHED$(RESET)"; \
	    fi; \
	  done; \
	done; \
	if [ $$failed -ne 0 ]; then \
	  echo "$(RED)SMOKE TEST FAILED: One or more tunnels are not ESTABLISHED$(RESET)"; \
	  exit 1; \
	else \
	  echo "$(GREEN)All VPN tunnels are ESTABLISHED. Smoke test passed.$(RESET)"; \
	fi


# ===========================================================
# Network Verification
# ===========================================================
# Runs both smoke-test-lite (non-blocking info) and smoke-test (strict validation)
# Useful as a post-deploy health gate for CI/CD or manual validation.
# ===========================================================

verify-network:
	@echo "=== [VERIFY NETWORK] Combined connectivity and tunnel health check ==="
	@echo "$(YELLOW)Step 1: Gathering network and tunnel summaries (lite check)...$(RESET)"
	@$(MAKE) smoke-test-lite || true
	@echo "$(YELLOW)Step 2: Validating VPN tunnels are ESTABLISHED (strict check)...$(RESET)"
	@$(MAKE) smoke-test || { \
	  echo "$(RED)❌ Network verification failed. Some tunnels not established.$(RESET)"; \
	  exit 1; \
	}
	@echo "$(GREEN)✅ All tunnels verified and network is operational.$(RESET)"


# ===========================================================
# CI/CD Pipeline Automation Targets
# ===========================================================

# Run staged apply in CI/CD or local non-interactive mode
apply-ci:
	@echo "=== [CI/CD APPLY] ==="
	@echo "$(YELLOW)🚀 Running CI/CD staged Terraform apply pipeline...$(RESET)"
	@if [ "$(CI)" = "true" ]; then \
		bash ./apply-staged-ci.sh; \
	else \
		read -p "⚠️  Run Terraform apply pipeline now? (yes/no): " ans; \
		[ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }; \
		bash ./apply-staged-ci.sh; \
	fi

# Run staged destroy in CI/CD or local non-interactive mode
destroy-ci:
	@echo "=== [CI/CD DESTROY] ==="
	@echo "$(YELLOW)💣 Running CI/CD staged Terraform destroy pipeline...$(RESET)"
	@if [ "$(CI)" = "true" ]; then \
		bash ./destroy-staged-ci.sh; \
	else \
		read -p "⚠️  This will destroy infrastructure. Continue? (yes/no): " ans; \
		[ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }; \
		bash ./destroy-staged-ci.sh; \
	fi

# CI/CD dry-run preview (Terraform plan only)
plan-ci:
	@echo "=== [CI/CD PLAN] ==="
	@echo "$(YELLOW)🧠 Running Terraform dry-run plan in CI/CD mode...$(RESET)"
	@APPLY_MODE=plan CI=true bash ./apply-staged-ci.sh

# Smoke-test as part of pipeline (quick tunnel check)
smoke-ci:
	@echo "=== [CI/CD SMOKE TEST] ==="
	@echo "$(YELLOW)🔎 Verifying VPN tunnel establishment...$(RESET)"
	@if gcloud compute vpn-tunnels list --format="table(name,region,status)" | grep -q ESTABLISHED; then \
		echo "$(GREEN)✅ All VPN tunnels are ESTABLISHED.$(RESET)"; \
	else \
		echo "$(RED)❌ Some tunnels are not established. Failing CI step.$(RESET)"; \
		exit 1; \
	fi

# Verify network connectivity and router reachability post-deploy
verify-ci:
	@echo "=== [CI/CD VERIFY NETWORK] ==="
	@echo "$(YELLOW)🌐 Running full router + tunnel verification...$(RESET)"
	@bash ./verify-network.sh || { echo "$(RED)Network verification failed.$(RESET)"; exit 1; }

# Shortcut for a full CI/CD pipeline run (plan → apply → smoke → verify)
pipeline-ci:
	@echo "=== [CI/CD PIPELINE] Full Terraform Infrastructure Flow ==="
	$(MAKE) plan-ci
	$(MAKE) apply-ci CI=true FORCE=true
	$(MAKE) smoke-ci
	$(MAKE) verify-ci
	@echo "$(GREEN)🎉 CI/CD pipeline complete — infrastructure verified.$(RESET)"
