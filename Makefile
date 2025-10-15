.PHONY: ALL venv roles production letsencrypt ssh retry clean clean-all macos-keybase tf-init tf-plan tf-apply check-rtk-prod check-rtk-staging check-planningalerts apply-rtk-prod apply-rtk-staging apply-planningalerts update-github-ssh-keys

ALL: venv roles .vagrant

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

production: .keybase venv roles
	.venv/bin/ansible-playbook site.yml

letsencrypt: venv roles
	.venv/bin/ansible-playbook update-ssl-certs.yml

#Just updates the SSH keys for the deploy user on all hosts.
ssh: venv roles
	.venv/bin/ansible-playbook deploy_user.yml

retry: venv roles site.retry
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
check-rtk-prod:
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check --diff
check-rtk-staging:
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow-staging --check --diff
check-planningalerts:
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check

# These make changes 
apply-rtk-prod:
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow
apply-rtk-staging:
	.venv/bin/ansible-playbook -i site.yml -l righttoknow-staging
apply-planningalerts:
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts

update-github-ssh-keys:
	.venv/bin/ansible-playbook site.yml --tags userkeys
