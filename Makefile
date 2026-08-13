.PHONY: all ansible-lint apply-metabase apply-oaf requirements apply-openaustralia \
        apply-planningalerts apply-postal apply-righttoknow  apply-theyvoteforyou \
        aws-check \
        check-host check-metabase check-oaf check-openaustralia check-planningalerts check-postal check-righttoknow \
        check-theyvoteforyou check-target \
        scan-oaf scan-openaustralia scan-planningalerts \
        clean clobber help letsencrypt lint op-check retry roles \
        show-facts show-inventory show-rds-facts show-vars stage_required tf-apply tf-apply-target \
        tf-env-check tf-init tf-plan tf-plan-target tf-secrets \
        update-github-ssh-keys vagrant venv yaml-lint template-check

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
	@echo "  requirements                        Install requirements: venv, roles, collections, terraform.pem and check required commands"
	@echo "  op-check                            Fail if not signed into the OAF 1Password account"
	@echo "  aws-check                           Fail if aws-cli/Session Manager plugin missing; bootstrap ~/.aws/config oaf/oaf-legacy profiles"
	@echo "  terraform.pem                       Materialise terraform.pem from 1Password"
	@echo "  tf-secrets                          Render terraform/secrets.auto.tfvars from 1Password via op inject"
	@echo "  tf-env-check                        Warn (non-fatal) if AWS or gcloud credentials aren't reachable"
	@echo "  roles                               Install Ansible Galaxy external roles and collections"
	@echo "  venv                                Create Python virtualenv and install requirements"
	@echo "  generate-certificates               Generate certificates for the development *.test domains"
	@echo "Independent targets (not required by all):"
	@echo "  letsencrypt                         Renew/update SSL certificates"
	@echo "  lint                                Run the following lint targets:"
	@echo "    yaml-lint                         Run yamllint on roles/internal/, roles/*.yml and site.yml only"
	@echo "    ansible-lint                      Run ansible-lint on roles/internal/, roles/*.yml and site.yml only"
	@echo "    tf-check-fmt                      Check terraform files are correctly formatted"
	@echo "    tf-validate                       Check terraform formatting and validate config"
	@echo "  retry                               Re-run site.yml limited to hosts from last failed run"
	@echo "  setup                               Install ubuntu packages required for development"
	@echo "  show-inventory                      Show the group/host tree from both inventory sources (--graph)"
	@echo "  show-aws-inventory                  Terse table of every instance the aws_ec2 dynamic source discovers, with tags"
	@echo "  ssh-config                          Output configuration snippet for OpenSSH ~/.ssh/config"
	@echo "  server-status [HOST=<host-or-group>] Quick fleet-wide uptime/memory/disk check"
	@echo "  show-vars HOST=<host>               Show all Ansible variables for a host"
	@echo "  show-facts HOST=<host>              Show all Ansible facts for a host"
	@echo "  show-rds-facts HOST=<host>          Show RDS debug facts for a host"
	@echo "  tf-init                             Run terraform init in the terraform directory"
	@echo "  tf-plan                             Run terraform plan in the terraform directory"
	@echo "  tf-apply                            Run terraform apply in the terraform directory"
	@echo "  tf-plan-target MODULE=<module>       Run terraform plan scoped to a single module"
	@echo "  tf-apply-target MODULE=<module>      Run terraform apply scoped to a single module"
	@echo "  tf-plan-target RESOURCE=<type>.<name>  Run terraform plan scoped to a single resource"
	@echo "  tf-apply-target RESOURCE=<type>.<name> Run terraform apply scoped to a single resource"
	@echo "  update-github-ssh-keys              Update SSH keys on all servers from GitHub"
	@echo "  vagrant                             Install vagrant plugins and ensure requirements are present"
	@echo ""
	@echo "  clean                               Remove virtualenv, external roles, retry file, collections"
	@echo "  clobber                             clobber everything make all created (clean + removes .vagrant and log)"
	@echo ""
	@echo "  check-righttoknow STAGE=<stage>     Dry-run Ansible for righttoknow production/staging/all host/s"
	@echo "  check-planningalerts                Dry-run Ansible for planningalerts hosts"
	@echo "  check-theyvoteforyou                Dry-run Ansible for theyvoteforyou host"
	@echo "  check-oaf                           Dry-run Ansible for oaf host"
	@echo "  check-openaustralia                 Dry-run Ansible for openaustralia host"
	@echo "  check-metabase                      Dry-run Ansible for metabase host"
	@echo "  check-postal                        Dry-run Ansible for postal host"
	@echo ""
	@echo "  apply-righttoknow STAGE=<stage>     Apply Ansible changes to righttoknow production/staging/all host/s"
	@echo "  apply-planningalerts                Apply Ansible changes to planningalerts hosts"
	@echo "  apply-theyvoteforyou                Apply Ansible changes to theyvoteforyou host"
	@echo "  apply-oaf                           Apply Ansible changes to oaf host"
	@echo "  apply-openaustralia                 Apply Ansible changes to openaustralia host"
	@echo "  apply-metabase                      Apply Ansible changes to metabase host"
	@echo "  apply-postal                        Apply Ansible changes to postal host"
	@echo ""
	@echo "  scan-oaf                            Scan oaf.org.au for broken links (1/2 hour)"
	@echo "  scan-openaustralia                  Scan openaustralia.org.au for broken links (2-3 hours)"
	@echo "  scan-planningalerts                 Scan planningalerts.org.au for broken links (1 hour)"
	@echo ""
	@echo "Extra vars:"
	@echo "  ANSIBLE_VERBOSE  Ansible verbosity flag, e.g. ANSIBLE_VERBOSE=vvv"
	@echo "  HOST           Ansible host pattern (required by show-* targets, will list inventory host names if not supplied)"
	@echo "  SKIP_TAGS      Skip plays/tasks with these tags (optional, space or comma separated)"
	@echo "  STAGE          Target stage: staging, production or all (required by check-righttoknow/apply-righttoknow only)"
	@echo "  TAGS           Only run plays/tasks tagged with these (optional, space or comma separated)"
	@echo "  MODULE         Terraform module name for tf-plan-target/tf-apply-target (lists options if not supplied)"
	@echo "  RESOURCE       Terraform resource address <type>.<name> for tf-plan-target/tf-apply-target, instead of MODULE"
	@echo "                 Find it in plan output ('  # <type>.<name> will be ...') or a 'resource \"<type>\" \"<name>\" {' block"

setup:
	sudo apt install parallel jq direnv

requirements: op-check terraform.pem .make/roles venv aws-check

# Fail if the operator can't read the OAF 1Password account. 1Password
# is the sole source for the Ansible Vault passphrases, the RDS admin
# password and terraform.pem, so failing fast here gives a clear error
# instead of a cryptic one downstream. We probe with `op vault list`
# rather than `op whoami` because the latter doesn't recognise sessions
# inherited from the 1Password desktop app integration.
op-check:
	@if command -v op >/dev/null 2>&1 && \
	    op vault list --account "$$(cat bin/.op-account)" >/dev/null 2>&1; then \
	  echo "OK: OAF 1Password reachable ($$(cat bin/.op-account))"; \
	else \
	  echo "ERROR: OAF 1Password not reachable (account=$$(cat bin/.op-account))." >&2; \
	  echo "  Install the 1Password CLI and sign in: op signin --account $$(cat bin/.op-account)" >&2; \
	  exit 1; \
	fi

# Fail if aws-cli or the Session Manager plugin aren't on PATH. The plugin is
# needed for `aws ssm start-session` and the SSH-over-SSM ProxyCommand
# Capistrano will use once a host is SSM-managed:
#   ssh -o ProxyCommand="aws ssm start-session --target %h \
#     --document-name AWS-StartSSHSession --parameters 'portNumber=%p'" ...
# Checked in this order (aws first, plugin second) since the plugin is useless
# without the CLI, and reporting the more fundamental problem first is clearer.
# Also bootstraps ~/.aws/config: both [profile oaf-legacy] and [profile oaf] are only ever written
# to if missing, never overwritten - so if either was customised for some unexpected reason, that
# customisation is left alone. [profile oaf]'s login_session ARN is operator-specific, so its
# bootstrapped value is a placeholder you're expected to edit with your own username; see README
# "CLI tools for credentials".
aws-check:
	@if command -v aws >/dev/null 2>&1; then \
      if aws --version 2>&1 | grep -qE 'aws-cli/2\.(3[2-9]|[4-9][0-9]|[1-9][0-9][0-9])'; then \
	    echo "OK: recent aws CLI found ($$(aws --version 2>&1))"; \
	  else \
        echo "ERROR: Require aws CLI version 2.32.0 or higher to support 'aws login' (currently $$(aws --version 2>&1))" >&2; \
        exit 1; \
	  fi \
	else \
	  echo "ERROR: aws CLI not found." >&2; \
	  echo "  Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" >&2; \
	  exit 1; \
	fi
	@if command -v session-manager-plugin >/dev/null 2>&1; then \
	  echo "OK: session-manager-plugin found ($$(session-manager-plugin --version 2>&1))"; \
	else \
	  echo "ERROR: session-manager-plugin not found." >&2; \
	  echo "  Install: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html" >&2; \
	  echo "For MacOS users, install using brew: brew install session-manager-plugin" >&2; \
	  exit 1; \
	fi
	@if aws configure get login_session --profile oaf >/dev/null 2>&1; then \
	  echo "OK: [profile oaf] already has a login_session set"; \
	else \
	  aws configure set region ap-southeast-2 --profile oaf; \
	  aws configure set login_session "arn:aws:iam::924104513718:user/REPLACE_ME" --profile oaf; \
	  echo "WARN: [profile oaf] had no login_session - added a placeholder in ~/.aws/config." >&2; \
	  echo "  Edit it with your own IAM username, then run: aws login --profile oaf" >&2; \
	fi
	@if aws configure get credential_process --profile oaf-legacy >/dev/null 2>&1; then \
	  echo "OK: [profile oaf-legacy] already configured"; \
	else \
	  aws configure set region ap-southeast-2 --profile oaf-legacy; \
	  aws configure set credential_process "aws configure export-credentials --profile oaf --format process" --profile oaf-legacy; \
	  echo "OK: [profile oaf-legacy] configured in ~/.aws/config (bridges 'aws login --profile oaf' for Terraform/Ansible)"; \
	fi

# Materialise terraform.pem from 1Password. The script is idempotent
# (no-op if the file is already present), so we name the file directly
# as the target — that way `rm terraform.pem` correctly triggers a
# rebuild on the next `make`.
terraform.pem:
	bin/fetch-terraform-pem

# Render terraform/secrets.auto.tfvars from the committed template via
# `op inject`. Same reasoning as terraform.pem: target the real file
# so deleting it forces a rebuild.
tf-secrets: terraform/secrets.auto.tfvars
terraform/secrets.auto.tfvars: terraform/secrets.auto.tfvars.tmpl bin/.op-account
	OP_ACCOUNT="$$(cat bin/.op-account)" op inject --force --account "$$(cat bin/.op-account)" \
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
	bin/tag-provisioning --wip all "" "" ""
	.venv/bin/ansible-playbook site.yml
	bin/tag-provisioning all "" "" ""

letsencrypt: requirements
	bin/tag-provisioning --wip letsencrypt "" "" ""
	.venv/bin/ansible-playbook update-ssl-certs.yml
	bin/tag-provisioning letsencrypt "" "" ""

retry: requirements site.retry
	bin/tag-provisioning --wip retry "" "" ""
	.venv/bin/ansible-playbook site.yml -l @site.retry
	bin/tag-provisioning retry "" "" ""

check-host:
ifndef HOST
	@echo "ERROR: host is not set! Add HOST=<value> using a host from inventory:\n"
	@$(MAKE) show-inventory
	@exit 1
endif

show-inventory: requirements
	.venv/bin/ansible-inventory -i ./inventory --graph

ssh-config:
	bin/ssh-config

server-status: requirements
ifdef HOST
	bin/server-status --limit $(HOST)
else
	bin/server-status
endif

# Terse, human-readable listing of every EC2 instance the aws_ec2 dynamic inventory plugin
# discovers - instance-id, state, Name tag, IPs, and AnsibleGroups tag ("-" if unmanaged/not yet
# tagged). Runs the real plugin (via inventory/aws_ec2.yml), so this actually verifies its
# keyed_groups/hostnames config, not a separate reimplementation of it.
show-aws-inventory: requirements
	bin/show-aws-inventory

show-vars: check-host requirements
	.venv/bin/ansible -i ./inventory $(HOST) -m debug -a "var=hostvars[inventory_hostname]"

show-facts: check-host requirements
	.venv/bin/ansible -i ./inventory $(HOST) -m setup

show-rds-facts: check-host requirements
	.venv/bin/ansible-playbook -i ./inventory site.yml --limit $(HOST) --tags facts -e "show_rds_debug=true"

# Delete all files that are normally created by running make goals
clean:
	rm -rf .venv roles/external site.retry collections .make
	rm -rf terraform/.terraform
	rm -f terraform/secrets.auto.tfvars terraform.pem

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
	bin/tag-provisioning --wip terraform "" "" ""
	terraform -chdir=terraform apply
	bin/tag-provisioning terraform "" "" ""
tf-validate: tf-check-fmt .make/terraform
	terraform -chdir=terraform validate
	@echo "PASSED tf-validate!"
tf-check-fmt:
	terraform -chdir=terraform fmt -check -recursive -diff
	@echo "PASSED tf-check-fmt!"

check-target:
ifdef MODULE
ifdef RESOURCE
	@echo "ERROR: Set only one of MODULE or RESOURCE, not both!"
	@exit 1
endif
endif
ifndef MODULE
ifndef RESOURCE
	@echo "ERROR: MODULE or RESOURCE must be set! Available modules are:"
	@ls -1 terraform/ | grep -E '^[a-z]' | grep -Ev '\.tf|\.sh' | sed 's/^/  /'
	@echo "Or set RESOURCE=<type>.<name> for a single resource, e.g. RESOURCE=aws_db_instance.maindb"
	@echo "  Find <type>.<name> in plan output ('  # <type>.<name> will be ...') or a 'resource \"<type>\" \"<name>\" {' block in a .tf file"
	@exit 1
endif
endif

TF_TARGET := $(if $(MODULE),module.$(MODULE),$(RESOURCE))

tf-plan-target: check-target tf-secrets tf-env-check .make/terraform
	terraform -chdir=terraform plan -target=$(TF_TARGET)

tf-apply-target: check-target tf-secrets tf-env-check .make/terraform
	bin/tag-provisioning --wip terraform "$(TF_TARGET)" "" ""
	terraform -chdir=terraform apply -target=$(TF_TARGET)
	bin/tag-provisioning terraform "$(TF_TARGET)" "" ""

stage_required:
ifndef STAGE
	$(error STAGE is required, for example: STAGE=staging or STAGE=production or STAGE=new or STAGE=old or STAGE=all for everything)
endif

# Checks only
check-righttoknow: requirements stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l righttoknow$(_STAGE) --check --diff
check-planningalerts: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l planningalerts$(_STAGE) --check --diff
check-theyvoteforyou: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l theyvoteforyou$(_STAGE) --check --diff
check-oaf: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l oaf$(_STAGE) --check --diff
check-openaustralia: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l openaustralia$(_STAGE) --check --diff
check-metabase: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l metabase$(_STAGE) --check --diff
check-postal: requirements # stage_required
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l postal$(_STAGE) --check --diff

# These make changes
apply-righttoknow: requirements stage_required
	bin/tag-provisioning --wip righttoknow "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l righttoknow$(_STAGE) --diff
	bin/tag-provisioning righttoknow "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
apply-planningalerts: requirements # stage_required
	bin/tag-provisioning --wip planningalerts "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l planningalerts$(_STAGE) --diff
	bin/tag-provisioning planningalerts "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
apply-theyvoteforyou: requirements # stage_required
	bin/tag-provisioning --wip theyvoteforyou "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l theyvoteforyou$(_STAGE) --diff
	bin/tag-provisioning theyvoteforyou "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
apply-oaf: requirements # stage_required
	bin/tag-provisioning --wip oaf "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l oaf$(_STAGE) --diff
	bin/tag-provisioning oaf "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
apply-openaustralia: requirements # stage_required
	bin/tag-provisioning --wip openaustralia "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l openaustralia$(_STAGE) --diff
	bin/tag-provisioning openaustralia "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
apply-metabase: requirements # stage_required
	bin/tag-provisioning --wip metabase "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l metabase$(_STAGE) --diff
	bin/tag-provisioning metabase "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
apply-postal: requirements # stage_required
	bin/tag-provisioning --wip postal "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"
	.venv/bin/ansible-playbook $(ANSIBLE_OPTS) -i ./inventory site.yml -l postal$(_STAGE) --diff
	bin/tag-provisioning postal "$(STAGE)" "$(TAGS)" "$(SKIP_TAGS)"

# Update ssh keys on all servers
update-github-ssh-keys: requirements
	bin/tag-provisioning --wip update-github-ssh-keys "" "userkeys" ""
	.venv/bin/ansible-playbook site.yml --tags userkeys
	bin/tag-provisioning update-github-ssh-keys "" "userkeys" ""

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

template-check:
	@bad=$$(find roles/internal -path '*/templates/*' -type f ! -name '*.j2'); \
	if [ -n "$$bad" ]; then \
		echo "ERROR: Jinja2 templates must use the .j2 extension. Rename these, or move static files to the role's files/ dir and use copy:"; \
		echo "$$bad"; \
		exit 1; \
	fi
	@echo "PASSED template-check!"

ansible-lint: venv roles
	ANSIBLE_ROLES_PATH=roles:roles/internal:roles/external .venv/bin/ansible-lint roles/internal/ roles/*.yml site.yml
	@echo "PASSED ansible-lint!"

lint: yaml-lint template-check ansible-lint tf-check-fmt tf-validate
