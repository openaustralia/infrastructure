.phony: ansible venv roles

ALL: ansible

venv: venv/bin/activate

venv/bin/activate: requirements.txt
	test -d venv || virtualenv venv
	. venv/bin/activate; pip install --upgrade pip virtualenv
	. venv/bin/activate; pip install -Ur requirements.txt
	touch venv/bin/activate

roles/external: venv roles/requirements.yml
	. venv/bin/activate; \
	ansible-galaxy install -r roles/requirements.yml -p roles/external

roles: roles/external

ansible: venv roles
	. venv/bin/activate; \
	ansible-playbook site.yml

retry: venv roles setup.retry
	. venv/bin/activate; ansible-playbook site.yml -l @setup.retry

clean:
	rm -rf venv roles/external setup.retry
