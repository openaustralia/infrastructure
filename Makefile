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
	$(if $(STAGE),,$(error STAGE is required, for example: STAGE=staging or STAGE=production))

# Checks only
check-righttoknow: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l righttoknow$(_STAGE) --check --diff
check-planningalerts: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l planningalerts$(_STAGE) --check --diff
check-theyvoteforyou: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l theyvoteforyou$(_STAGE) --check --diff
check-oaf: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l oaf$(_STAGE) --check --diff
check-openaustralia: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l openaustralia$(_STAGE) --check --diff
check-metabase: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l metabase$(_STAGE) --check --diff

# These make changes 
apply-righttoknow: stage_required $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l righttoknow$(_STAGE) --diff
apply-planningalerts: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l planningalerts$(_STAGE) --diff
apply-theyvoteforyou: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l theyvoteforyou$(_STAGE) --diff
apply-oaf: $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l oaf$(_STAGE) --diff
apply-openaustralia: stage_required $(KEYSANDROLES)
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS)  -i ./inventory/ec2-hosts site.yml -l openaustralia$(_STAGE) --diff
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