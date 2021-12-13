terraform:=terraform
backend_tfvars:=backend.tfvars
terraform_files:=main.tf variables.tf outputs.tf

help: spacing:=20

help: ## Print this help message
	@echo "tfbackend state: " $(shell test -f 'local.tf' && echo 'LOCAL') $(shell test -f 'remote.tf' && echo 'REMOTE')
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(spacing)s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Run 'make deploy' to generate a Terraform state backend configuration from variables defined in ${backend_tfvars}\n"

# Targets: Switch to the local backend or the remote backend
.PHONY: switch-local switch-remote
switch-local: sync-before local.tf sync-after ## Store Terraform state in the LOCAL backend
switch-remote: backend.tfbackend remote.tf sync-after ## Store Terraform state in the REMOTE backend

# Build the backend configuration for use in other projects
# The backend infrastructure is built step-by-step onto the currently configured state backend
backend.tfbackend: sync-before $(terraform_files)
	$(terraform) workspace select default
	$(terraform) apply --auto-approve --var-file=$(backend_tfvars)
	# Export the newly-created backend variables (adding quotes to values if Terraform <= 0.13)
	$(terraform) output | sed 's/^\([a-zA-Z0-9_-]*\)\( *= *\)"*\([a-zA-Z0-9_\.-]*\)"*/\1 = "\3"/g'> $@

# Selects the terraform backend block
local.tf: local.tf.example
	@echo "Selecting backend: LOCAL"
	rm -rf remote.tf
	ln -sf local.tf.example local.tf
	@echo "tfbackend state: " $(shell test -f 'local.tf' && echo 'LOCAL') $(shell test -f 'remote.tf' && echo 'REMOTE')

remote.tf: remote.tf.example
	@echo "Selecting backend: REMOTE"
	rm -rf local.tf
	ln -sf remote.tf.example remote.tf
	@echo "tfbackend state: " $(shell test -f 'local.tf' && echo 'LOCAL') $(shell test -f 'remote.tf' && echo 'REMOTE')

# Synchronise with an existing backend.tfbackend files
.PHONY: sync sync-before sync-after
sync: remote.tf sync-after ## Synchronise and initialise the Terraform backend using an existing 'backend.tfbackend' file

# Synchronise the selected backend 'LOCAL' or 'REMOTE' with the appropriate backend configuration
sync-before: backend_config=$(shell test -f 'remote.tf' && echo '--backend-config=backend.tfbackend')
sync-before:
	$(terraform) init -force-copy $(backend_config)
	$(terraform) workspace select default
	$(terraform) refresh --var-file=$(backend_tfvars)

sync-after: backend_config=$(shell test -f 'remote.tf' && echo '--backend-config=backend.tfbackend')
sync-after:
	$(terraform) init -force-copy $(backend_config)
	$(terraform) workspace select default
	$(terraform) refresh --var-file=$(backend_tfvars)

# backup, clean, destroy, and distclean
.PHONY: backup clean deploy destroy distclean
backup: sync-before ## Create a local backup copy of terraform.tfstate
	$(terraform) state pull > backup.tfstate
	@echo "Workspace 'default' backed up to 'backup.tfstate'"

clean:
	@echo "Run 'make destroy' to destroy the remote backend defined in ${backend_tfvars}"
	@echo "Run 'make distclean' to delete all working files and prepare for distribution"

deploy: backend.tfbackend ## Deploy backend infrastructure

destroy: switch-local ## Destroy backend infrastructure
	# Destroy all the IaC resources for this backend
	$(terraform) destroy --auto-approve --var-file=$(backend_tfvars)

distclean: ## Delete generated files, restoring working directory to distribution-ready state
	# Cleanup and make module distribution-ready
	rm -rf local.tf remote.tf errored.tfstate terraform.tfstate terraform.tfstate.d terraform.tfstate.backup .terraform .terraform.lock.hcl
