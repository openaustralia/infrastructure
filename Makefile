.PHONY: venv production ALL dev letsencrypt check-rtk ansible

ALL: .keybase venv roles
dev: venv roles .vagrant
ansible: ALL

.vagrant:
	VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-hostsupdater
	touch .vagrant

venv: .venv/bin/activate

.venv/bin/activate: requirements.txt
	test -d .venv || ./bin/python3 -m venv .venv
	.venv/bin/pip install --upgrade pip virtualenv
	.venv/bin/pip install -Ur requirements.txt
	touch .venv/bin/activate

collections:
	.venv/bin/ansible-galaxy collection install -r roles/requirements.yml

roles/external: collections roles/requirements.yml
	.venv/bin/ansible-galaxy install -r roles/requirements.yml -p roles/external
	touch roles/external

roles: roles/external

<<<<<<< HEAD
production: venv roles
=======
production: ansible
>>>>>>> b3ef96c (Tidy makefile)
	.venv/bin/ansible-playbook site.yml

letsencrypt: ansible
	.venv/bin/ansible-playbook update-ssl-certs.yml

#Just updates the SSH keys for the deploy user on all hosts.
ssh: ansible
	.venv/bin/ansible-playbook deploy_user.yml

retry: ansible site.retry
	.venv/bin/ansible-playbook site.yml -l @site.retry

clean:
	rm -rf .venv roles/external site.retry collections .keybase
	./bin/hermit clean -a
	
clean-all: clean
	rm -rf .vagrant

check-righttoknow: ansible
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check
check-planningalerts: ansible
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check

update-github-ssh-keys: ansible
	.venv/bin/ansible-playbook site.yml --tags userkeys
