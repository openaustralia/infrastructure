.PHONY: ALL venv roles production letsencrypt retry clean clean-all macos-keybase tf-init tf-plan tf-apply check-rtk-prod check-rtk-staging check-planningalerts apply-rtk-prod apply-rtk-staging apply-planningalerts update-github-ssh-keys
ALL: roles .vagrant
KEYSANDROLES := .keybase roles

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

production: $(KEYSANDROLES)
	.venv/bin/ansible-playbook site.yml

letsencrypt: $(KEYSANDROLES)
	.venv/bin/ansible-playbook update-ssl-certs.yml

retry: $(KEYSANDROLES) site.retry
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
check-rtk-prod: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check --diff
check-rtk-staging: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow-staging --check --diff
check-planningalerts: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check --diff
check-theyvoteforyou: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l theyvoteforyou --check --diff


# These make changes 
apply-rtk-prod: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow
apply-rtk-staging: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i site.yml -l righttoknow-staging
apply-planningalerts: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts
apply-theyvoteforyou: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l theyvoteforyou

update-github-ssh-keys: $(KEYSANDROLES)
	.venv/bin/ansible-playbook site.yml --tags userkeys

install-linters: venv
	.venv/bin/pip install --upgrade pip ansible-lint  yamllint

yaml-lint: venv
	.venv/bin/yamllint roles/*.yml site.yml 

ansible-lint: venv
	.venv/bin/ansible-lint roles/*.yml site.yml

lint: yaml-lint ansible-lint