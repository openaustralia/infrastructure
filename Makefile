.PHONY: all venv roles production letsencrypt retry clean clean-all macos-keybase tf-init tf-plan tf-apply check-rtk-prod check-rtk-staging check-planningalerts apply-rtk-prod apply-rtk-staging apply-planningalerts update-github-ssh-keys stage_required

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

all:
	@echo "Available targets"
	@echo "  venv                                Create Python virtualenv and install requirements"
	@echo "  roles                               Install Ansible Galaxy external roles and collections"
	@echo "  everything                          Run full site.yml playbook against all hosts"
	@echo "  letsencrypt                         Renew/update SSL certificates"
	@echo "  retry                               Re-run site.yml limited to hosts from last failed run"
	@echo "  show-inventory                      List all hosts in the EC2 inventory"
	@echo "  show-vars host=<host>               Show all Ansible variables for a host"
	@echo "  show-facts host=<host>              Show all Ansible facts for a host"
	@echo "  show-rds-facts host=<host>          Show RDS debug facts for a host"
	@echo "  lint                                Run yamllint and ansible-lint on roles and site.yml"
	@echo "  install-linters                     Install yamllint and ansible-lint into the virtualenv"
	@echo "  tf-init                             Run terraform init in the terraform directory"
	@echo "  tf-plan                             Run terraform plan in the terraform directory"
	@echo "  tf-apply                            Run terraform apply in the terraform directory"
	@echo "  update-github-ssh-keys              Update SSH keys on all servers from GitHub"
	@echo "  macos-keybase                       Set up Keybase symlink for macOS"
	@echo "  clean                               Remove virtualenv, external roles, retry file, collections, keybase symlink"
	@echo "  clean-all                           clean + remove .vagrant"
	@echo ""
	@echo "  check-righttoknow STAGE=<stage>     Dry-run Ansible for righttoknow hosts"
	@echo "  check-planningalerts STAGE=<stage>  Dry-run Ansible for planningalerts hosts"
	@echo "  check-theyvoteforyou STAGE=<stage>  Dry-run Ansible for theyvoteforyou hosts"
	@echo "  check-oaf STAGE=<stage>             Dry-run Ansible for oaf hosts"
	@echo "  check-openaustralia STAGE=<stage>   Dry-run Ansible for openaustralia hosts"
	@echo "  check-metabase STAGE=<stage>        Dry-run Ansible for metabase hosts"
	@echo ""
	@echo "  apply-righttoknow STAGE=<stage>     Apply Ansible changes to righttoknow hosts"
	@echo "  apply-planningalerts STAGE=<stage>  Apply Ansible changes to planningalerts hosts"
	@echo "  apply-theyvoteforyou STAGE=<stage>  Apply Ansible changes to theyvoteforyou hosts"
	@echo "  apply-oaf STAGE=<stage>             Apply Ansible changes to oaf hosts"
	@echo "  apply-openaustralia                 Apply Ansible changes to openaustralia hosts"
	@echo "  apply-metabase                      Apply Ansible changes to metabase hosts"
	@echo ""
	@echo "Extra vars:"
	@echo "  STAGE          Target stage, e.g. STAGE=new or old or staging or '' (required by check-*/apply-* targets)"
	@echo "  TAGS           Only run plays/tasks tagged with these (space or comma separated)"
	@echo "  SKIP_TAGS      Skip plays/tasks with these tags (space or comma separated)"
	@echo "  ANSIBLE_VERBOSE  Ansible verbosity flag, e.g. ANSIBLE_VERBOSE=vvv"
	@echo "  START_AT_TASK  Start playbook at first task matching this string (fuzzy, * wildcards added)"

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
