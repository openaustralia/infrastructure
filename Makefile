.phony: venv roles production ALL letsencrypt

ALL: venv roles .vagrant

.vagrant:
	VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-hostsupdater
	touch .vagrant

venv: .venv/bin/activate

.venv/bin/activate: requirements.txt
	test -d .venv || virtualenv .venv
	.venv/bin/pip install --upgrade pip virtualenv
	.venv/bin/pip install -Ur requirements.txt
	touch .venv/bin/activate

roles/external: venv roles/requirements.yml
	.venv/bin/ansible-galaxy install -r roles/requirements.yml -p roles/external

roles: roles/external

production: venv roles
	.venv/bin/ansible-playbook site.yml

letsencrypt: venv roles
	.venv/bin/ansible-playbook update-ssl-certs.yml

retry: venv roles setup.retry
	.venv/bin/ansible-playbook site.yml -l @setup.retry

clean:
	rm -rf .venv roles/external setup.retry .vagrant
