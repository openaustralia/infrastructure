.PHONY: venv production ALL dev letsencrypt check-rtk ansible
SHELL=/bin/bash
ALL: .keybase venv roles
dev: venv roles .vagrant
ansible: .hermit/python/bin/ansible

ACTIVATE=. bin/activate-hermit

.keybase:
	ln -sf $(shell keybase config get -d -b mountdir) .keybase
	
.vagrant:
	VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-hostsupdater
	touch .vagrant

.hermit/python/bin/ansible: requirements.txt
	$(ACTIVATE); pip install --upgrade pip
	$(ACTIVATE); pip install -Ur requirements.txt
	touch .hermit/python/bin/ansible

collections: ansible
	$(ACTIVATE); ansible-galaxy collection install -r roles/requirements.yml

roles/external: collections roles/requirements.yml
	$(ACTIVATE); ansible-galaxy install -r roles/requirements.yml -p roles/external
	touch roles/external

roles: roles/external

production: ansible
	$(ACTIVATE); ansible-playbook site.yml

letsencrypt: ansible
	$(ACTIVATE); ansible-playbook update-ssl-certs.yml

#Just updates the SSH keys for the deploy user on all hosts.
ssh: ansible
	$(ACTIVATE); ansible-playbook deploy_user.yml

retry: ansible site.retry
	$(ACTIVATE); ansible-playbook site.yml -l @site.retry

clean:
	rm -rf .venv roles/external site.retry collections .keybase .hermit
	$(ACTIVATE); hermit clean -a
	
clean-all: clean
	rm -rf .vagrant

check-righttoknow: ansible
	$(ACTIVATE); ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check
check-planningalerts: ansible
	$(ACTIVATE); ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check

update-github-ssh-keys: ansible
	$(ACTIVATE); ansible-playbook site.yml --tags userkeys
