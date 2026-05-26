.PHONY: all ansible-lint apply-metabase apply-oaf requirements apply-openaustralia \
        apply-planningalerts apply-righttoknow apply-rtk-prod apply-rtk-staging apply-theyvoteforyou \
        check-host check-metabase check-oaf check-openaustralia check-planningalerts check-righttoknow \
        check-rtk-prod check-rtk-staging check-theyvoteforyou check-target \
        scan-oaf scan-openaustralia scan-planningalerts \
        clean clobber help install-linters keybase letsencrypt lint \
        lima lima-requirements lima-up lima-provision lima-destroy lima-status lima-hosts-sync lima-clean \
        production retry roles \
        show-facts show-inventory show-rds-facts show-vars stage_required tf-apply tf-apply-target tf-init tf-plan \
        tf-plan-target update-github-ssh-keys vagrant venv yaml-lint

_STAGE := $(if $(filter-out all,$(STAGE)),_$(STAGE),)

ANSIBLE_TAGS := $(shell echo "$(TAGS)" | sed 's/[^A-Z0-9_]\+/,/gi' | sed 's/,\+/,/g' | sed 's/^,//' | sed 's/,$$//')
ANSIBLE_SKIP_TAGS := $(shell echo "$(SKIP_TAGS)" | sed 's/[^A-Z0-9_]\+/,/gi' | sed 's/,\+/,/g' | sed 's/^,//' | sed 's/,$$//')

# Build ansible-playbook options just like Vagrantfile
ANSIBLE_OPTS :=
ifdef ANSIBLE_TAGS
ANSIBLE_OPTS += --tags "$(ANSIBLE_TAGS),facts"
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


help:
	@echo "Available targets"
	@echo "  help                                Output this help text"
	@echo "  all                                 Run full site.yml playbook against all hosts"
	@echo "  requirements                        Install requirements: venv, roles, collections and keybase symlink"
	@echo "  keybase                             Set up Keybase symlink for MacOS or Linux and check perms"
	@echo "  roles                               Install Ansible Galaxy external roles and collections"
	@echo "  venv                                Create Python virtualenv and install requirements"
	@echo "  generate-certificates               Generate certificates for the development *.test domains"
	@echo "Independent targets (not required by all):"
	@echo "  letsencrypt                         Renew/update SSL certificates"
	@echo "  lint                                Run yamllint and ansible-lint on roles and site.yml"
	@echo "  retry                               Re-run site.yml limited to hosts from last failed run"
	@echo "  setup                               Install ubuntu packages required for development"
	@echo "  show-inventory                      List all hosts in the EC2 inventory"
	@echo "  show-vars host=<host>               Show all Ansible variables for a host"
	@echo "  show-facts host=<host>              Show all Ansible facts for a host"
	@echo "  show-rds-facts host=<host>          Show RDS debug facts for a host"
	@echo "  tf-init                             Run terraform init in the terraform directory"
	@echo "  tf-plan                             Run terraform plan in the terraform directory"
	@echo "  tf-apply                            Run terraform apply in the terraform directory"
	@echo "  update-github-ssh-keys              Update SSH keys on all servers from GitHub"
	@echo "  vagrant                             Install vagrant plugins and ensure requirements are present"
	@echo "  lima                                Apple Silicon / amd64-via-Rosetta alternative to vagrant (see docs/local-dev-with-lima.md)"
	@echo "  lima-up [HOSTS=a,b]                 Bring up Lima VMs from lima/hosts.yml"
	@echo "  lima-provision [HOSTS=a,b]          Run site.yml against the Lima fleet"
	@echo "  lima-destroy [HOSTS=a,b]            Stop and delete Lima VMs"
	@echo "  lima-status                         Show status of Lima fleet"
	@echo "  lima-hosts-sync                     Update macOS /etc/hosts for the live fleet (needs sudo)"
	@echo ""
	@echo "  clean                               Remove virtualenv, external roles, retry file, collections, keybase symlink"
	@echo "  clobber                             clobber everything make all created (clean + removes .vagrant and log)"
	@echo ""
	@echo "  check-righttoknow STAGE=<stage>     Dry-run Ansible for righttoknow production/staging/all host/s"
	@echo "  check-planningalerts                Dry-run Ansible for planningalerts hosts"
	@echo "  check-theyvoteforyou                Dry-run Ansible for theyvoteforyou host"
	@echo "  check-oaf                           Dry-run Ansible for oaf host"
	@echo "  check-openaustralia                 Dry-run Ansible for openaustralia new/old/all host/s"
	@echo "  check-metabase                      Dry-run Ansible for metabase host"
	@echo ""
	@echo "  apply-righttoknow STAGE=<stage>     Apply Ansible changes to righttoknow production/staging/all host/s"
	@echo "  apply-planningalerts                Apply Ansible changes to planningalerts hosts"
	@echo "  apply-theyvoteforyou                Apply Ansible changes to theyvoteforyou host"
	@echo "  apply-oaf                           Apply Ansible changes to oaf host"
	@echo "  apply-openaustralia                 Apply Ansible changes to openaustralia new/old/all host/s"
	@echo "  apply-metabase                      Apply Ansible changes to metabase host"
	@echo ""
	@echo "  scan-oaf                            Scan oaf.org.au for broken links (1/2 hour)"
	@echo "  scan-openaustralia                  Scan openaustralia.org.au for broken links (2-3 hours)"
	@echo "  scan-planningalerts                 Scan planningalerts.org.au for broken links (1 hour)"
	@echo ""
	@echo "Extra vars:"
	@echo "  STAGE          Target stage, e.g. STAGE=new or old or staging or '' (required by check-*/apply-* targets)"
	@echo "  TAGS           Only run plays/tasks tagged with these (space or comma separated)"
	@echo "  SKIP_TAGS      Skip plays/tasks with these tags (space or comma separated)"
	@echo "  ANSIBLE_VERBOSE  Ansible verbosity flag, e.g. ANSIBLE_VERBOSE=vvv"

setup:
	sudo apt install parallel jq direnv

requirements: .keybase .make/roles venv

# Configure .keybase for MacOS or Linux
.keybase:
	@for p in /Volumes/Keybase /keybase /run/keybase /var/lib/keybase "$$(keybase config get -d -b mountdir 2>/dev/null)"; do \
	  [ -d "$$p" ] && echo "ln -nsf $$p .keybase" && ln -nsf "$$p" .keybase && exit 0; \
	done; \
	echo "Keybase mount not found" && exit 1

# Check keybase exists and user has required permissions
keybase: .keybase
	@[ -d .keybase ] && echo "OK: .keybase exists and is linked to a directory"
	@broken=0; \
	for f in .all-vault-pass .ec2-vault-pass .rtk-vault-pass terraform.pem .vault_pass.txt; do \
      [ -f "$$f" ] && echo "OK: $$f exists" || { echo "BROKEN: $$f (permission missing?)"; broken=1; }; \
	done; \
	[ $$broken -eq 0 ]

vagrant: .make/vagrant-plugins .make/certificates requirements

# --- Lima (Apple Silicon / amd64-via-Rosetta alternative to Vagrant) -------
# See docs/local-dev-with-lima.md for one-time setup (brew install lima
# socket_vmnet, sudoers, etc).

lima: lima-requirements lima-up lima-hosts-sync lima-provision

lima-requirements: .make/certificates requirements
	@command -v limactl >/dev/null || { echo "ERROR: limactl not found. See docs/local-dev-with-lima.md."; exit 1; }
	@.venv/bin/python -c "import yaml" 2>/dev/null || .venv/bin/pip install pyyaml

lima-up: lima-requirements
	.venv/bin/python lima/bin/lima-up $(subst $(comma), ,$(HOSTS))

lima-provision: lima-requirements
	HOSTS="$(HOSTS)" TAGS="$(TAGS)" SKIP_TAGS="$(SKIP_TAGS)" ANSIBLE_VERBOSE="$(ANSIBLE_VERBOSE)" \
	  lima/bin/lima-provision

lima-destroy:
	.venv/bin/python lima/bin/lima-destroy $(subst $(comma), ,$(HOSTS))

lima-status:
	.venv/bin/python lima/bin/lima-status

lima-hosts-sync:
	sudo .venv/bin/python lima/bin/lima-hosts-sync

lima-clean: lima-destroy
	sudo .venv/bin/python lima/bin/lima-hosts-sync -d || true
	rm -rf lima/.state lima/inventory/lima-hosts

# Helper to translate HOSTS=a,b on the command line into a space-separated list.
comma := ,
# ---------------------------------------------------------------------------

generate-certificates: .make/certificates

.make/certificates: certificates/generate-certificates.sh | .make
	certificates/generate-certificates.sh
	touch .make/certificates

.make/vagrant-plugins: Makefile | .make
	mkdir -p log
	VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-hostsupdater
	touch .make/vagrant-plugins

venv: .venv/bin/activate

.venv/bin/activate: requirements.txt
	test -d .venv || python3 -m virtualenv .venv
	.venv/bin/pip install --upgrade pip virtualenv
	.venv/bin/pip install -Ur requirements.txt
	touch .venv/bin/activate

.make:
	mkdir -p .make

.make/collections: .venv/bin/activate roles/requirements.yml | .make
	.venv/bin/ansible-galaxy collection install -r roles/requirements.yml
	touch .make/collections

.make/roles: .make/collections .venv/bin/activate roles/requirements.yml | .make
	.venv/bin/ansible-galaxy install -r roles/requirements.yml -p roles/external
	touch .make/roles

roles: .make/roles

all: requirements
	.venv/bin/ansible-playbook site.yml

letsencrypt: requirements
	.venv/bin/ansible-playbook update-ssl-certs.yml

retry: requirements site.retry
	.venv/bin/ansible-playbook site.yml -l @site.retry

check-host:
ifndef host
	@echo "ERROR: host is not set! Add host=<value> using a host from inventory:\n"
	@$(MAKE) show-inventory
	@exit 1
endif

show-inventory: requirements
	.venv/bin/ansible-inventory -i ./inventory/ec2-hosts --graph

show-vars: check-host requirements
	.venv/bin/ansible -i ./inventory/ec2-hosts $(host) -m debug -a "var=hostvars[inventory_hostname]"

show-facts: check-host requirements
	.venv/bin/ansible -i ./inventory/ec2-hosts $(host) -m setup

show-rds-facts: check-host requirements
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml --limit $(host) --tags facts -e "show_rds_debug=true"

# Delete all files that are normally created by running make goals
clean:
	rm -rf .venv roles/external site.retry collections .keybase .make
	rm -rf terraform/.terraform

clobber: clean
	vagrant destroy --force || echo "WARNING: Ignoring vagrant error!"
	rm -rf .vagrant log
	rm -f certificates/*.key certificates/*.pem certificates/*.csr certificates/myCA.srl
	rm -f roles/internal/{openaustralia,righttoknow,theyvoteforyou}/files/*.test.{key,pem}
	# TODO: Should we delete terraform/terraform.tfstate.* ?

# Terraform
tf-init: .make/terraform

.make/terraform: terraform/*.tf terraform/*/*.tf | .make
	terraform -chdir=terraform init
	touch .make/terraform

tf-plan: .make/terraform
	terraform -chdir=terraform plan
tf-apply: .make/terraform
	terraform -chdir=terraform apply
tf-validate: tf-check-fmt .make/terraform
	terraform -chdir=terraform validate 
	@echo "PASSED tf-validate!"
tf-check-fmt:
	terraform -chdir=terraform fmt -check 
	@echo "PASSED tf-check-fmt!"

check-target:
ifndef TARGET
	@echo "ERROR: TARGET is not set! Available targets are:"
	@ls -1 terraform/ | grep -E '^[a-z]' | grep -v '\.tf$$' | sed 's/^/  /'
	@exit 1
endif

tf-plan-target: check-target .make/terraform
	terraform -chdir=terraform plan -target=module.$(TARGET)

tf-apply-target: check-target .make/terraform
	terraform -chdir=terraform apply -target=module.$(TARGET)

stage_required:
ifndef STAGE
	$(error STAGE is required, for example: STAGE=staging or STAGE=production or STAGE=new or STAGE=old or STAGE=all for everything)
endif

# Checks only
check-righttoknow: requirements stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l righttoknow$(_STAGE) --check --diff
check-planningalerts: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l planningalerts$(_STAGE) --check --diff
check-theyvoteforyou: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l theyvoteforyou$(_STAGE) --check --diff
check-oaf: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l oaf$(_STAGE) --check --diff
check-openaustralia: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l openaustralia$(_STAGE) --check --diff
check-metabase: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l metabase$(_STAGE) --check --diff

# These make changes 
apply-righttoknow: requirements stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l righttoknow$(_STAGE) --diff
apply-planningalerts: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l planningalerts$(_STAGE) --diff
apply-theyvoteforyou: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l theyvoteforyou$(_STAGE) --diff
apply-oaf: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l oaf$(_STAGE) --diff
apply-openaustralia: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l openaustralia$(_STAGE) --diff
apply-metabase: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory/ec2-hosts site.yml -l metabase$(_STAGE) --diff

# Update ssh keys on all servers
update-github-ssh-keys: requirements
	.venv/bin/ansible-playbook site.yml --tags userkeys

#   Behind cloudflare consider tunnelling via ssh or proxying via bastian
#	https://www.righttoknow.org.au
#	https://theyvoteforyou.org.au

log:
	mkdir -p log

scan-oaf: venv log
	@url="https://oaf.org.au"; \
	log="log/scan_oaf.html"; \
	echo "=== Checking links: $$url > $$log ==="; \
	.venv/bin/linkchecker --check-extern --no-warnings --threads 5 -F html/utf-8/$$log $$url

scan-openaustralia: venv log
	@url="https://openaustralia.org.au"; \
	log="log/scan_openaustralia.html"; \
	echo "=== Checking links: $$url > $$log ==="; \
	.venv/bin/linkchecker --check-extern --no-warnings --threads 5 -F html/utf-8/$$log $$url

scan-planningalerts: venv log
	@url="https://www.planningalerts.org.au"; \
	log="log/scan_planningalerts.html"; \
	echo "=== Checking links: $$url > $$log ==="; \
	.venv/bin/linkchecker --check-extern --no-warnings --threads 5 -F html/utf-8/$$log $$url

yaml-lint: venv
	.venv/bin/yamllint roles/internal/ roles/*.yml site.yml 
	@echo "PASSED yamllint!"

ansible-lint: venv roles
	ANSIBLE_ROLES_PATH=roles:roles/internal:roles/external .venv/bin/ansible-lint roles/internal/ roles/*.yml site.yml 
	@echo "PASSED ansible-lint!"

lint: yaml-lint ansible-lint tf-check-fmt tf-validate
