SHELL := /bin/bash

ROOT_DIR      := $(shell pwd)
TF_BIN        ?= terraform
TFVARS        ?= $(ROOT_DIR)/terraform.tfvars
LOCK_TIMEOUT  ?= 5m

export TF_BIN TFVARS LOCK_TIMEOUT

.PHONY: bootstrap bootstrap-plan bootstrap-destroy \
        infra infra-plan infra-destroy \
        destroy-all fmt validate clean-plans

bootstrap:
	@./scripts/bootstrap.sh apply

bootstrap-plan:
	@./scripts/bootstrap.sh plan

bootstrap-destroy:
	@./scripts/bootstrap.sh destroy

infra:
	@./scripts/infra.sh apply

infra-plan:
	@./scripts/infra.sh plan

infra-destroy:
	@./scripts/infra.sh destroy

destroy-all: infra-destroy bootstrap-destroy

fmt:
	@$(TF_BIN) fmt -recursive

validate:
	@$(TF_BIN) -chdir=$(ROOT_DIR)/bootstrap validate
	@$(TF_BIN) -chdir=$(ROOT_DIR)/infra validate

clean-plans:
	@rm -f \
		$(ROOT_DIR)/bootstrap/tfplan_bootstrap \
		$(ROOT_DIR)/infra/tfplan_infra \
		$(ROOT_DIR)/tfplan_bootstrap \
		$(ROOT_DIR)/tfplan_infra
