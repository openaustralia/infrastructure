Role Name
=========

Extremely simple certbot module, specific to OAF's needs right now.

Requirements
------------

- Should work on ubuntu 16.04 or later; only tested on 16.04
- Requires `nginx` or `apache` as the webserver

Role Variables
--------------

`certbot_webserver`: `nginx` or `apache`; default is `apache`
`certbot_certs`: Dict containing certificates to generate
- `email`: email address for ACME notifications
- `domains`: list of domain names to include in this certificate

As an example:

````
  certbot_webserver: apache
  certbot_certs:
    - email: contact@oaf.org.au
      domains:
        - "{{ theyvoteforyou_domain }}"
        - www."{{ theyvoteforyou_domain }}"
    - email: contact@oaf.org.au
      domains:
        - "test.{{ theyvoteforyou_domain }}"
        - "www.test.{{ theyvoteforyou_domain }}"
````

will generate two certifcates; each with two names, and install them into the appropriate Apache vhosts

Dependencies
------------


Example Playbook
----------------

See the `theyvoteforyou` role for an example of usage.

License
-------

BSD

Author Information
------------------

OpenAustralia Foundation