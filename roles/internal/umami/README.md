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
- A `umami` database on the shared RDS PostgreSQL instance, plus a `umami` role
  granted ALL on both the database and the public schema. See
  [Database grants](#database-grants) below, because both grants matter and for
  different reasons. Umami applies its own schema migrations on startup.
- The Umami container itself, published on `127.0.0.1:3000` only

Unlike `metabase`, this box does **not** sit behind the shared load balancer.
`analytics.oaf.org.au` is an A record proxied by Cloudflare. That caches the
tracking script at the edge, which matters because it loads on every page of
every OAF site; it puts Cloudflare in front of a collector endpoint that has to
be publicly reachable; and it keeps analytics off the ALB listener that
PlanningAlerts shares. The trade is that TLS becomes ours to manage, hence nginx
and certbot on the box. `srv.analytics.oaf.org.au` is the unproxied name Ansible
and ssh use, and is what appears in `inventory/ec2-hosts`.

## Database grants

The database is created by `root` and stays owned by `root`. It is **not** owned
by the `umami` role, and it cannot be: RDS's `root` has `rds_superuser` but is
not a superuser, and PostgreSQL only lets you create a database owned by another
role if you are a member of that role. This follows the pattern in
`roles/internal/planningalerts/tasks/database.yml`.

The `umami` role then gets two grants, both of which are load-bearing:

- **ALL on the public schema** is what lets the migrations create tables. On
  PostgreSQL 15, which is what the RDS instance runs, the public schema belongs
  to `pg_database_owner` and is no longer writable by everyone.
- **ALL on the database** carries `CREATE`, which is what lets Umami's first
  migration run `CREATE EXTENSION IF NOT EXISTS "pgcrypto"`. pgcrypto is a
  trusted extension, so `CREATE` on the database is sufficient and superuser is
  not required. If this grant is missing, the very first migration fails on a
  permission error rather than anything schema-related.

## Location data

Umami resolves a visitor's country, region and city one of two ways, and it
prefers the first (`getLocation` in the image's `src/lib/detect.ts`):

1. **Cloudflare's location headers**, if `CF-IPCountry` is present. It returns as
   soon as it sees that header, taking region and city from `CF-Region-Code` and
   `CF-IPCity`.
2. **A bundled MaxMind database** at `/app/geo/GeoLite2-City.mmdb`, looked up
   against the IP from `CLIENT_IP_HEADER`, if no provider country header arrived.

We use path 1, following
[the Umami docs](https://docs.umami.is/docs/enable-cloudflare-headers), which is
why `umami.conf.j2` forwards all three headers. **Cloudflare only sends
`CF-IPCountry` by default.** `CF-Region-Code` and `CF-IPCity` require the
**Rules > Managed Transforms > "Add visitor location headers"** toggle. If that
toggle is off, `CF-IPCountry` still arrives, path 1 is still taken, and Umami
reports country with region and city empty. It does not fall back to path 2, so
the failure is silent. Terraform does not manage Cloudflare zone settings, so
this has to be checked by hand.

Two notes for anyone editing the nginx config:

- The header is `CF-Region-Code`, so the nginx variable is
  `$http_cf_region_code`. The Umami docs example says `$http_cf_regioncode`,
  which reads a header Cloudflare does not send and always resolves empty. This
  is verifiable with a logging backend: the underscore-per-hyphen form returns
  `SA`, the docs' form returns nothing.
- A request that reaches the origin directly, bypassing Cloudflare, carries no
  `CF-IPCountry`, so it takes path 2 and still gets located from
  `CF-Connecting-IP`, which nginx sets from `$remote_addr`. Such a request could
  forge the location headers; it is analytics data rather than a trust boundary,
  but worth knowing before treating city counts as authoritative.

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
4. Still in the Cloudflare dashboard, confirm nothing at the edge redirects
   `/.well-known/acme-challenge/` to HTTPS: check **Always Use HTTPS** under
   SSL/TLS > Edge Certificates, and any Redirect Rules or Page Rules matching
   this hostname. Because the record is proxied, ACME validation traffic reaches
   Cloudflare before it reaches the `location ^~ /.well-known/acme-challenge/`
   block in our nginx config. This is worth getting right once: it affects
   **renewals** via `certbot.timer` and `make letsencrypt` every 60 days, not
   just the first issuance, and it fails silently.
5. `make check-analytics`, then `make apply-analytics`. Expect the first
   check-mode run against a bare instance to report errors: `--check` cannot
   see the effect of tasks it did not perform, so anything downstream of
   installing nginx or docker has nothing to inspect. It is informative from
   the second run onwards.
6. Confirm `https://analytics.oaf.org.au` loads with a valid certificate. A 521
   before certbot has finished is expected: there is no `listen 443` block on
   the origin yet, so Full (strict) gets connection-refused. (A 526 would mean
   something *is* listening on 443 with a certificate Cloudflare won't accept,
   which is a different problem.)
7. In the Cloudflare dashboard, check that Bot Fight Mode and the WAF are not
   challenging `POST /api/send`. A challenge there silently drops pageviews.
8. Enable **Rules > Managed Transforms > "Add visitor location headers"** on the
   `oaf.org.au` zone. Without it, region and city are silently empty; see
   [Location data](#location-data).

## Verifying an apply

The database tasks cannot be dry-run: `--check` will not create anything for the
later steps to inspect, and there is no staging RDS instance. So work through
these in order after an apply, on a fresh box or after changing the database
tasks. Each fails in a recognisable way if the step above it went wrong.

1. The four database tasks complete. `must be member of role "umami"` means the
   database is being created with an owner again; `database "root" does not
   exist` means a `postgresql_user` task lost its `db:`.
2. `\l umami` shows owner `root`, and `\dn+ public` shows the `umami` role
   holding `UC` on the public schema.
3. `docker logs --tail 100 umami` shows the prisma migrations completing. The
   first statement they run is `CREATE EXTENSION IF NOT EXISTS "pgcrypto"`, so a
   permission error here means the database-level grant did not take, or
   `rds.allowed_extensions` has been narrowed on the instance.
4. `docker inspect umami --format '{{.HostConfig.LogConfig}}'` shows the size
   caps, and `--format '{{.State.Health.Status}}'` reports `healthy`. Give it up
   to the healthcheck's 60s `start_period` on a fresh box, because the prisma
   migrations run before the app answers `/api/heartbeat`.
5. Re-run `make apply-analytics`. The container task should report unchanged.

The "Run umami" task sets `no_log: true`, because `docker_container` returns the
container's whole inspect output and `Config.Env` holds the database password
and `APP_SECRET`. So when that task fails you get no detail from Ansible: use
`docker logs umami` and `docker inspect umami`, which is where the useful
information is anyway. Only flip `no_log` off as a last resort, and not on a
shared terminal.

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

4. Send a test pageview and confirm it is recorded against the correct country
   **and city**. Check the city specifically: country arriving while city is
   blank is the signature of the managed transform in step 8 of first-time setup
   being off, and it is the one failure here that looks like success. If instead
   every visit lands on one location, the visitor IP is not reaching Umami, so
   check `CLIENT_IP_HEADER` and the `CF-Connecting-IP` header nginx sets. See
   [Location data](#location-data) for how the two paths differ.
5. Once every site is reporting, cancel the plausible.io subscription.

## Upgrading

Bump `umami_docker_image` in `group_vars/analytics.yml` and run
`make check-analytics` then `make apply-analytics`. Umami runs `prisma migrate deploy`
on startup, so schema changes apply themselves. Check the release notes for
breaking changes first, and note that the RDS backup is the rollback path if a
migration goes wrong: rolling the image back does not roll the schema back.

## Role variables

Configuration lives in `group_vars/analytics.yml`, as it does for the other
service roles, not in the role's `defaults/`.

| Variable | Where | Notes |
| --- | --- | --- |
| `umami_docker_image` | `group_vars/analytics.yml` | Pinned image tag |
| `umami_domain` | `group_vars/analytics.yml` | Tied to `site_name` |
| `umami_db_name`, `umami_db_user` | `group_vars/analytics.yml` | Both `umami` |
| `umami_port` | `group_vars/analytics.yml` | Loopback port nginx proxies to |
| `umami_certbot_webroot` | `group_vars/analytics.yml` | Where ACME challenges are served from; `certbot_webroot` is tied to it |
| `umami_certbot_email` | `group_vars/analytics.yml` | Registration address for Let's Encrypt |
| `db_password` | `group_vars/analytics.yml` | Vaulted; the PostgreSQL role's password |
| `umami_app_secret` | `group_vars/analytics.yml` | Vaulted; **do not regenerate**, see below |
| `db_host`, `rds_admin_password` | `group_vars/ec2.yml`, `all.yml` | Shared RDS |
| `umami_database_url` | `vars/main.yml` | Derived, not configured |

`umami_app_secret` signs authentication tokens. Changing it logs every user out
and invalidates outstanding sessions, so treat it as fixed once set.
