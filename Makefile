TERRAFORM=terraform
GIT=git
AWS=aws

pull:
	$(GIT) pull

init:
	$(TERRAFORM) init 

init/backend:
	$(TERRAFORM) init -backend-config=backend.hcl


plan:
	$(TERRAFORM) plan

apply:
	$(TERRAFORM) apply

output:
	$(TERRAFORM) output
