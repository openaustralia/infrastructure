.PHONY: ALL venv roles production letsencrypt retry clean clean-all macos-keybase tf-init tf-plan tf-apply check-rtk-prod check-rtk-staging check-planningalerts apply-rtk-prod apply-rtk-staging apply-planningalerts update-github-ssh-keys stage_required
ALL: roles .vagrant
KEYSANDROLES := .keybase roles

_STAGE := $(if $(STAGE),_$(STAGE),)

ANSIBLE_TAGS := $(shell echo "$(TAGS)" | sed 's/[^A-Z0-9_]\+/,/gi' | sed 's/,\+/,/g' | sed 's/^,//' | sed 's/,$$//')
ANSIBLE_SKIP_TAGS := $(shell echo "$(SKIP_TAGS)" | sed 's/[^A-Z0-9_]\+/,/gi' | sed 's/,\+/,/g' | sed 's/^,//' | sed 's/,$$//')
ANSIBLE_START_TASK := $(if $(START_AT_TASK),*$(shell echo "$(START_AT_TASK)" | sed 's/[^A-Z0-9_]\+/*/gi')*,)

# Build ansible-playbook options just like Vagrantfile
ANSIBLE_OPTS :=
ifdef ANSIBLE_TAGS
ANSIBLE_OPTS += --tags "$(ANSIBLE_TAGS)"
$(info INFO: Only running TAGS: $(ANSIBLE_TAGS))
endif
ifdef ANSIBLE_SKIP_TAGS
ANSIBLE_OPTS += --skip-tags "$(ANSIBLE_SKIP_TAGS)"
$(info INFO: Skipping TAGS: $(ANSIBLE_SKIP_TAGS))
endif
ifdef ANSIBLE_VERBOSE
ANSIBLE_OPTS += -$(ANSIBLE_VERBOSE)
$(info INFO: Setting verbose: -$(ANSIBLE_VERBOSE))
endif
ifdef ANSIBLE_START_TASK
ANSIBLE_OPTS += --start-at-task "$(ANSIBLE_START_TASK)"
$(info INFO: Starting at task matching: $(ANSIBLE_START_TASK))
endif

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

everything: $(KEYSANDROLES)
	.venv/bin/ansible-playbook site.yml

letsencrypt: $(KEYSANDROLES)
	.venv/bin/ansible-playbook update-ssl-certs.yml

retry: $(KEYSANDROLES) site.retry
	.venv/bin/ansible-playbook site.yml -l @site.retry

check-host:
ifndef host
	@echo "ERROR: host is not set! Add host=<value> using a host from inventory:\n"
	@$(MAKE) show-inventory
	@exit 1
endif

show-inventory:
	.venv/bin/ansible-inventory -i ./inventory/ec2-hosts --graph

show-vars: check-host
	.venv/bin/ansible -i ./inventory/ec2-hosts $(host) -m debug -a "var=hostvars[inventory_hostname]"

show-facts: check-host
	.venv/bin/ansible -i ./inventory/ec2-hosts $(host) -m setup

show-rds-facts: check-host
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml --limit $(host) --tags facts -e "show_rds_debug=true"

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

stage_required:
ifndef STAGE
	$(error STAGE is required, for example: STAGE=staging or STAGE=production or STAGE= for both)
endif

# Checks only
check-righttoknow: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l righttoknow$(_STAGE) --check --diff
check-planningalerts: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l planningalerts$(_STAGE) --check --diff
check-theyvoteforyou: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l theyvoteforyou$(_STAGE) --check --diff
check-oaf: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l oaf$(_STAGE) --check --diff
check-openaustralia: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l openaustralia$(_STAGE) --check --diff
check-metabase: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l metabase$(_STAGE) --check --diff

# These make changes 
apply-righttoknow: stage_required $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l righttoknow$(_STAGE) --diff
apply-planningalerts: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l planningalerts$(_STAGE) --diff
apply-theyvoteforyou: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l theyvoteforyou$(_STAGE) --diff
apply-oaf: $(KEYSANDROLES) stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l oaf$(_STAGE) --diff
apply-openaustralia:
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l openaustralia$(_STAGE) --diff


apply-openaustralia-old: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l openaustralia_old --diff
apply-openaustralia-new: $(KEYSANDROLES)
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l openaustralia_new --diff
apply-metabase: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l metabase$(_STAGE) --diff

# Update ssh keys on all servers
update-github-ssh-keys: $(KEYSANDROLES)
	.venv/bin/ansible-playbook site.yml --tags userkeys

install-linters: venv
	.venv/bin/pip install --upgrade pip ansible-lint  yamllint

yaml-lint: venv
	.venv/bin/yamllint roles/*.yml site.yml 

ansible-lint: venv
	.venv/bin/ansible-lint roles/*.yml site.yml

lint: yaml-lint ansible-lint
