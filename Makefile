terraform:=terraform
backend_tfvars:=backend.tfvars
terraform_files:=main.tf variables.tf outputs.tf

help:
	@echo "tfbackend state: " $(shell test -f 'local.tf' && echo 'LOCAL') $(shell test -f 'remote.tf' && echo 'REMOTE')
	@echo ""
	@echo "Available targets:"
	@echo "\tbackup\t\t Create a local backup copy of terraform.tfstate"
	@echo "\tdeploy\t\t Deploy backend infrastructure"
	@echo "\tdestroy\t\t Destroy backend infrastructure"
	@echo "\tswitch-local\t Store Terraform state in the LOCAL backend"
	@echo "\tswitch-remote\t Store Terraform state in the REMOTE backend"
	@echo "\tsync\t\t Synchronise and initialise the Terraform backend using an existing 'backend.tfbackend' file"
	@echo ""
	@echo "Run 'make deploy' to generate a Terraform state backend configuration from variables defined in ${backend_tfvars}\n"

# Targets: Switch to the local backend or the remote backend
.PHONY: switch-local switch-remote
switch-local: sync-before local.tf sync-after
switch-remote: backend.tfbackend remote.tf sync-after

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
sync: remote.tf sync-after

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
backup: sync-before
	$(terraform) state pull > backup.tfstate
	@echo "Workspace 'default' backed up to 'backup.tfstate'"

clean:
	@echo "Run 'make destroy' to destroy the remote backend defined in ${backend_tfvars}"
	@echo "Run 'make distclean' to delete all working files and prepare for distribution"

deploy: backend.tfbackend

destroy: switch-local
	# Destroy all the IaC resources for this backend
	$(terraform) destroy --auto-approve --var-file=$(backend_tfvars)

distclean:
	# Cleanup and make module distribution-ready
	rm -rf local.tf remote.tf errored.tfstate terraform.tfstate terraform.tfstate.d terraform.tfstate.backup .terraform .terraform.lock.hcl
