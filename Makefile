.PHONY: all ansible-lint apply-metabase apply-oaf requirements apply-openaustralia \
        apply-planningalerts apply-righttoknow apply-rtk-prod apply-rtk-staging apply-theyvoteforyou \
        check-host check-metabase check-oaf check-openaustralia check-planningalerts check-righttoknow \
        check-rtk-prod check-rtk-staging check-theyvoteforyou check-target \
        scan-oaf scan-openaustralia scan-planningalerts \
        clean clobber help install-linters keybase letsencrypt lint op-check production retry roles \
        show-facts show-inventory show-rds-facts show-vars stage_required tf-apply tf-apply-target \
        tf-env-check tf-init tf-plan tf-plan-target tf-secrets \
        update-github-ssh-keys vagrant venv yaml-lint

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
	@echo "  requirements                        Install requirements: venv, roles, collections, terraform.pem"
	@echo "  op-check                            Warn if not signed into the OAF 1Password account"
	@echo "  terraform.pem                       Materialise terraform.pem from 1Password (or use Keybase fallback)"
	@echo "  tf-secrets                          Render terraform/secrets.auto.tfvars from 1Password via op inject"
	@echo "  tf-env-check                        Warn if AWS/Cloudflare/Linode/gcloud credentials aren't reachable"
	@echo "  keybase                             (Legacy fallback) Set up Keybase symlink and check perms"
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
	sudo apt install parallel

requirements: op-check terraform.pem .make/roles venv

# Warn (but don't fail) if the operator can't read the OAF 1Password
# account. Non-fatal so contributors who still use Keybase symlinks can
# run `make` without 1Password. We probe with `op vault list` rather
# than `op whoami` because the latter doesn't recognise sessions
# inherited from the 1Password desktop app integration.
op-check:
	@if command -v op >/dev/null 2>&1 && \
	    op vault list --account "$$(cat bin/.op-account)" >/dev/null 2>&1; then \
	  echo "OK: OAF 1Password reachable ($$(cat bin/.op-account))"; \
	else \
	  echo "WARN: OAF 1Password not reachable (account=$$(cat bin/.op-account)). Will fall back to Keybase symlinks where possible."; \
	fi

# Materialise terraform.pem from 1Password. The script is idempotent
# (no-op if the file is already present, e.g. as the Keybase symlink),
# so we name the file directly as the target — that way `rm terraform.pem`
# correctly triggers a rebuild on the next `make`.
terraform.pem:
	bin/fetch-terraform-pem

# Render terraform/secrets.auto.tfvars from the committed template via
# `op inject`. Same reasoning as terraform.pem: target the real file
# so deleting it forces a rebuild.
tf-secrets: terraform/secrets.auto.tfvars
terraform/secrets.auto.tfvars: terraform/secrets.auto.tfvars.tmpl bin/.op-account
	OP_ACCOUNT="$$(cat bin/.op-account)" op inject --account "$$(cat bin/.op-account)" \
	    -i terraform/secrets.auto.tfvars.tmpl -o terraform/secrets.auto.tfvars
	chmod 600 terraform/secrets.auto.tfvars

# Advisory check that the per-operator credentials terraform needs are reachable.
# Non-fatal: print warnings and continue; terraform itself will fail loudly if
# anything is truly missing.
tf-env-check:
	@aws sts get-caller-identity >/dev/null 2>&1 \
	    || echo "WARN: 'aws sts get-caller-identity' failed — sign into AWS (e.g. \`aws sso login\`)"
	@gcloud auth application-default print-access-token >/dev/null 2>&1 \
	    || echo "WARN: gcloud application-default credentials missing — run \`gcloud auth application-default login\`"
	@[ -n "$$CLOUDFLARE_API_TOKEN" ] \
	    || echo "WARN: CLOUDFLARE_API_TOKEN is unset — export it (e.g. in .envrc)"
	@[ -n "$$LINODE_TOKEN" ] \
	    || echo "WARN: LINODE_TOKEN is unset — export it (e.g. in .envrc)"

# --- Legacy Keybase fallback (kept until the follow-up cleanup PR) ---

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
	rm -f terraform/secrets.auto.tfvars
	@# Only remove terraform.pem if it's a real file (i.e. materialised from
	@# 1Password). If it's the Keybase symlink, leave it alone.
	@if [ -f terraform.pem ] && [ ! -L terraform.pem ]; then rm -f terraform.pem; fi

clobber: clean
	vagrant destroy --force || echo "WARNING: Ignoring vagrant error!"
	rm -rf .vagrant log
	rm -f certificates/*.key certificates/*.pem certificates/*.csr certificates/myCA.srl
	rm -f roles/internal/{openaustralia,righttoknow,theyvoteforyou}/files/*.test.{key,pem}
	# TODO: Should we delete terraform/terraform.tfstate.* ?

# Terraform
tf-init: tf-secrets .make/terraform

.make/terraform: terraform/*.tf terraform/*/*.tf | .make
	terraform -chdir=terraform init
	touch .make/terraform

tf-plan: tf-secrets tf-env-check .make/terraform
	terraform -chdir=terraform plan
tf-apply: tf-secrets tf-env-check .make/terraform
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

tf-plan-target: check-target tf-secrets tf-env-check .make/terraform
	terraform -chdir=terraform plan -target=module.$(TARGET)

tf-apply-target: check-target tf-secrets tf-env-check .make/terraform
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
