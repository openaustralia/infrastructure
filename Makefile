.PHONY: production ALL dev letsencrypt check-rtk
SHELL=/bin/bash
HERMIT=. bin/activate-hermit; 
ANSIBLE=.hermit/python/bin/ansible

ALL: .keybase $(ANSIBLE) roles

dev: ALL .vagrant

.keybase:
	ln -sf $(shell keybase config get -d -b mountdir) .keybase
	
.vagrant:
	VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-hostsupdater
	touch .vagrant

$(ANSIBLE): requirements.txt
	$(HERMIT) pip install --upgrade pip
	$(HERMIT) pip install -Ur requirements.txt

collections: $(ANSIBLE) roles/requirements.yml
	$(HERMIT) ansible-galaxy collection install -r roles/requirements.yml
	touch collections

roles/external: $(ANSIBLE) roles/requirements.yml
	$(HERMIT) ansible-galaxy install -r roles/requirements.yml -p roles/external
	touch roles/external

roles: roles/external collections

production: $(ANSIBLE)
	$(HERMIT) ansible-playbook site.yml

letsencrypt: $(ANSIBLE)
	$(HERMIT) ansible-playbook update-ssl-certs.yml

#Just updates the SSH keys for the deploy user on all hosts.
ssh: ansible
	$(HERMIT) ansible-playbook deploy_user.yml

retry: $(ANSIBLE) site.retry
	$(HERMIT) ansible-playbook site.yml -l @site.retry

clean:
	rm -rf .venv roles/external site.retry collections .keybase .hermit
	$(HERMIT) hermit clean -a
	
clean-all: clean
	rm -rf .vagrant

check-righttoknow: $(ANSIBLE)
	$(HERMIT) ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check

check-planningalerts: $(ANSIBLE)
	$(HERMIT) ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check
apply-righttoknow:
	$(HERMIT) ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow
apply-planningalerts:
	$(HERMIT) ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts

update-github-ssh-keys:
	$(HERMIT) ansible-playbook site.yml --tags userkeys

update-github-ssh-keys: $(ANSIBLE)
	$(HERMIT) ansible-playbook site.yml --tags userkeys
