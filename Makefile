.PHONY: ALL venv roles production letsencrypt retry clean clean-all macos-keybase tf-init tf-plan tf-apply check-rtk-prod check-rtk-staging check-planningalerts apply-rtk-prod apply-rtk-staging apply-planningalerts update-github-ssh-keys
ALL: roles .vagrant
PRODUCTION := .keybase roles

.keybase:
	ln -sf $(shell keybase config get -d -b mountdir) .keybase
	
.vagrant:
	VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-hostsupdater
	touch .vagrant

venv: .venv/bin/activate

.venv/bin/activate: requirements.txt
	test -d .venv || python3 -m virtualenv .venv
	.venv/bin/pip install --upgrade pip virtualenv
	.venv/bin/pip install -Ur requirements.txt
	touch .venv/bin/activate

collections:
	.venv/bin/ansible-galaxy collection install -r roles/requirements.yml

roles/external: venv collections roles/requirements.yml
	.venv/bin/ansible-galaxy install -r roles/requirements.yml -p roles/external

roles: roles/external

production: $(PRODUCTION)
	.venv/bin/ansible-playbook site.yml

letsencrypt: $(PRODUCTION)
	.venv/bin/ansible-playbook update-ssl-certs.yml

retry: $(PRODUCTION) site.retry
	.venv/bin/ansible-playbook site.yml -l @site.retry

clean:
	rm -rf .venv roles/external site.retry collections .keybase
	
clean-all: clean
	rm -rf .vagrant

# Configure Keybase for MacOS
macos-keybase:
	ln -sf /Volumes/Keybase .keybase

# Terraform
tf-init:
	terraform -chdir=terraform init
tf-plan:
	terraform -chdir=terraform plan
tf-apply:
	terraform -chdir=terraform apply

# Checks only
check-righttoknow-all: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check --diff
check-righttoknow-staging: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow_staging --check --diff
check-righttoknow-prod: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow_production --check --diff
check-planningalerts: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check

# These make changes 
apply-righttoknow-all: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow
apply-righttoknow-staging: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow_staging
apply-righttoknow-prod: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow_production
apply-planningalerts: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts

# Update ssh keys on all servers
update-github-ssh-keys: $(PRODUCTION)
	.venv/bin/ansible-playbook site.yml --tags userkeys
