.PHONY: venv roles production ALL dev letsencrypt check-rtk

ALL: venv roles
dev: venv roles .vagrant

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

roles/external: venv collections roles/requirements.yml
	.venv/bin/ansible-galaxy install -r roles/requirements.yml -p roles/external

roles: roles/external

production: venv roles
	.venv/bin/ansible-playbook site.yml

letsencrypt: venv roles
	.venv/bin/ansible-playbook update-ssl-certs.yml

#Just updates the SSH keys for the deploy user on all hosts.
ssh: venv roles
	.venv/bin/ansible-playbook deploy_user.yml

retry: venv roles site.retry
	.venv/bin/ansible-playbook site.yml -l @site.retry

clean:
	rm -rf .venv roles/external site.retry collections
	./bin/hermit clean -a
	
clean-all: clean
	rm -rf .vagrant

check-righttoknow:
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l righttoknow --check
check-planningalerts:
	.venv/bin/ansible-playbook -i ./inventory/ec2-hosts site.yml -l planningalerts --check

update-github-ssh-keys:
	.venv/bin/ansible-playbook site.yml --tags userkeys
