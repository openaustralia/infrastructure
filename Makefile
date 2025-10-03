.PHONY: production ALL dev letsencrypt check-rtk
SHELL=/bin/bash
ACTIVATE=. bin/activate-hermit
ANSIBLE=.hermit/python/bin/ansible

ALL: .keybase $(ANSIBLE) roles

dev: ALL .vagrant

.keybase:
	ln -sf $(shell keybase config get -d -b mountdir) .keybase
	
.vagrant:
	VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-hostsupdater
	touch .vagrant

$(ANSIBLE): requirements.txt
	$(ACTIVATE); pip install --upgrade pip
	$(ACTIVATE); pip install -Ur requirements.txt

collections: $(ANSIBLE) roles/requirements.yml
	$(ACTIVATE); ansible-galaxy collection install -r roles/requirements.yml
	touch collections

roles/external: $(ANSIBLE) roles/requirements.yml
	$(ACTIVATE); ansible-galaxy install -r roles/requirements.yml -p roles/external
	touch roles/external

roles: roles/external collections

production: $(ANSIBLE)
	$(ACTIVATE); ansible-playbook site.yml

letsencrypt: $(ANSIBLE)
	$(ACTIVATE); ansible-playbook update-ssl-certs.yml

#Just updates the SSH keys for the deploy user on all hosts.
ssh: ansible
	$(ACTIVATE); ansible-playbook deploy_user.yml

retry: $(ANSIBLE) site.retry
	$(ACTIVATE); ansible-playbook site.yml -l @site.retry

clean:
	rm -rf .venv roles/external site.retry collections .keybase .hermit
	$(ACTIVATE); hermit clean -a
	
clean-all: clean
	rm -rf .vagrant

check-righttoknow: $(ANSIBLE)
	$(ACTIVATE); ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check

check-planningalerts: $(ANSIBLE)
	$(ACTIVATE); ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check

update-github-ssh-keys: $(ANSIBLE)
	$(ACTIVATE); ansible-playbook site.yml --tags userkeys
