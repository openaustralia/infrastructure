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
tf-init tf-plan tf-apply:
	terraform -chdir=terraform $(patsubst tf-%,%,$@)


# Checks only
check-rtk check-righttoknow check-rtk-staging check-righttoknow-staging check-planningalerts: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l $(patsubst check-%,%,$(subst rtk,righttoknow,$@)) --check --diff

apply-rtk-prod apply-righttoknow apply-rtk-staging apply-righttoknow-staging apply-planningalerts: $(PRODUCTION)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l $(patsubst check-%,%,$(subst rtk,righttoknow,$@))

update-github-ssh-keys: $(PRODUCTION)
	.venv/bin/ansible-playbook site.yml --tags userkeys
