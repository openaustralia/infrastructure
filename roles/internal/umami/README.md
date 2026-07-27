# umami

Provisions [Umami](https://umami.is) on analytics.oaf.org.au, our self-hosted
replacement for hosted plausible.io (issue #607). The EC2 instance, security
group and DNS are managed in `terraform/analytics/`; this role installs and
configures everything on the box.

What the role sets up:

- nginx, terminating TLS with a Let's Encrypt certificate obtained by the
  `oaf.certbot` role in webroot mode, and reverse-proxying to Umami
- `cloudflare_realip`, so nginx resolves `$remote_addr` to the visitor's
  address rather than Cloudflare's
- Docker CE, from Docker's apt repository
- A `umami` database on the shared RDS PostgreSQL instance, owned by a `umami`
  role. Ownership matters on PostgreSQL 15: the public schema is owned by
  `pg_database_owner`, so a role with only ALL on the database cannot create
  tables. Umami applies its own schema migrations on startup.
- The Umami container itself, published on `127.0.0.1:3000` only

Unlike `metabase`, this box does **not** sit behind the shared load balancer.
`analytics.oaf.org.au` is an A record proxied by Cloudflare, which caches the
tracking script at the edge and keeps the collector off the listener that
PlanningAlerts shares. `srv.analytics.oaf.org.au` is the unproxied name Ansible
and ssh use, and is what appears in `inventory/ec2-hosts`.

## No compose file

`community.docker` is pinned at 1.2.2 by ansible 2.10, which predates
`docker_compose_v2`, and docker-compose v1 no longer installs cleanly from pip
on a fresh box. Since Umami is a single container the role uses
`community.docker.docker_container` instead. That means there is no
`docker-compose.yml` on the box to read, so to see how the container is
actually configured:

```sh
docker inspect umami            # image, ports, environment, restart policy
docker logs --tail 100 umami    # startup, including the prisma migrations
docker restart umami
```

## First-time setup

Terraform has to be applied first, because `make check-analytics` cannot resolve
the host until the instance and DNS records exist.

1. Generate and vault the two secrets in `group_vars/analytics.yml`
   (instructions are in that file).
2. `make tf-plan-target TARGET=analytics`, then `make tf-apply-target
   TARGET=analytics`.
3. Confirm `analytics.oaf.org.au` and `srv.analytics.oaf.org.au` both resolve.
   Then check the `oaf.org.au` zone's SSL/TLS encryption mode in the Cloudflare
   dashboard is **Full (strict)**. This is the first proxied record in that
   zone, so the setting has never been exercised; on Flexible, Cloudflare talks
   to the origin over HTTP, our port 80 redirect sends it back to Cloudflare and
   the site is a permanent redirect loop. Terraform does not manage zone
   settings, so this has to be checked by hand.
4. `make check-analytics`, then `make apply-analytics`. Expect the first
   check-mode run against a bare instance to report errors: `--check` cannot
   see the effect of tasks it did not perform, so anything downstream of
   installing nginx or docker has nothing to inspect. It is informative from
   the second run onwards.
5. Confirm `https://analytics.oaf.org.au` loads with a valid certificate. A 526
   before certbot has finished is expected: Full (strict) has no origin
   certificate to validate yet.
6. In the Cloudflare dashboard, check that Bot Fight Mode and the WAF are not
   challenging `POST /api/send`. A challenge there silently drops pageviews.

## Application setup runbook

Umami's first-run credentials and website records can only be created through
the web interface. All of this state lives in PostgreSQL and is covered by the
RDS instance's backups.

1. Log in with the default credentials `admin` / `umami` and **change the
   password immediately**. Umami ships these on every install and there is no
   CLI to rotate them.
2. Add one website per site: PlanningAlerts, Right To Know, They Vote For You,
   OpenAustralia.
3. For each, copy the `data-website-id` from Settings. Those ids go into the
   tracking snippet in each application's own repository, which is where the
   Plausible snippet lives today:

   ```html
   <script defer src="https://analytics.oaf.org.au/script.js"
           data-website-id="..."></script>
   ```

4. Send a test pageview and confirm the visit is recorded against the correct
   country. If everything shows as one location, `CLIENT_IP_HEADER` is not
   reaching the container and sessions are being merged.
5. Once every site is reporting, cancel the plausible.io subscription.

## Upgrading

Bump `umami_docker_image` in `group_vars/analytics.yml` and run
`make check-analytics` then `make apply-analytics`. Umami runs `prisma migrate deploy`
on startup, so schema changes apply themselves. Check the release notes for
breaking changes first, and note that the RDS backup is the rollback path if a
migration goes wrong: rolling the image back does not roll the schema back.

## Role variables

| Variable | Where | Notes |
| --- | --- | --- |
| `umami_docker_image` | defaults | Pinned image tag |
| `umami_domain` | defaults | Defaults to `site_name` |
| `umami_db_name`, `umami_db_user` | defaults | Both `umami` |
| `umami_port` | defaults | Loopback port nginx proxies to |
| `umami_certbot_webroot` | defaults | Where ACME challenges are served from |
| `umami_certbot_email` | defaults | Registration address for Let's Encrypt |
| `db_password` | `group_vars/analytics.yml` | Vaulted; the PostgreSQL role's password |
| `umami_app_secret` | `group_vars/analytics.yml` | Vaulted; **do not regenerate**, see below |
| `db_host`, `rds_admin_password` | `group_vars/ec2.yml`, `all.yml` | Shared RDS |

`umami_app_secret` signs authentication tokens. Changing it logs every user out
and invalidates outstanding sessions, so treat it as fixed once set.
