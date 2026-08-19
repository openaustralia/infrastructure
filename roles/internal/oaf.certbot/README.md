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
`certbot_webroot`: if set, validate with HTTP-01 via `--webroot` using this
path instead of the webserver plugin
`certbot_standalone`: if true, validate with certbot's standalone webserver
(stops/starts varnish around it)
`certbot_dns_cloudflare`: if true, validate with DNS-01 via the Cloudflare
API. Takes precedence over the other methods. Use for domains proxied through
Cloudflare (orange cloud), where HTTP-01 challenges are subject to edge
redirects and security rules. Requires `certbot_dns_cloudflare_api_token`, a
Cloudflare API token scoped to Zone / DNS / Edit for the relevant zone(s)
(store it vault-encrypted in group_vars). When enabling this on a host with
existing certificates, run `update-ssl-certs.yml` afterwards: issuance uses
`--keep`, so unchanged certificates keep their old renewal config
(`authenticator = webroot`/webserver plugin) until a forced renewal rewrites
it with dns-cloudflare.

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