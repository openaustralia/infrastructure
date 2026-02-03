# Cloudflare Proxy Migration Guide

This document covers the infrastructure changes required when migrating OAF services to sit behind Cloudflare's proxy (orange cloud mode).

## Overview

When Cloudflare proxy is enabled for a domain, all HTTP/HTTPS traffic flows through Cloudflare's edge network before reaching our origin servers. This provides DDoS protection, caching, and WAF capabilities, but requires configuration changes to:

1. Restore real client IP addresses in nginx and apache
2. Restrict origin access to Cloudflare IPs only
3. Handle IP-based blocklists appropriately
4. Ensure Let's Encrypt certificate renewals continue working

## Infrastructure Components

### Terraform (Already Implemented)

The Terraform configuration already supports Cloudflare-only mode for each service:

```hcl
# In terraform/variables.tf
variable "theyvoteforyou_cloudflare_only" { default = false }
variable "righttoknow_cloudflare_only"    { default = false }
variable "openaustralia_cloudflare_only"  { default = false }
variable "opengovernment_cloudflare_only" { default = false }
variable "planningalerts_cloudflare_only" { default = false }
```

Setting these to `true` creates AWS security group rules that only allow HTTP/HTTPS from Cloudflare IP ranges (dynamically fetched from `cloudflare.com/ips-v4` and `ips-v6`).

**Files:**
- [terraform/cloudflare-security-groups.tf](../terraform/cloudflare-security-groups.tf)
- [terraform/variables.tf](../terraform/variables.tf)

### Ansible (New Role)

The `oaf.cloudflare_realip` role configures nginx or apache to restore real client IPs:

```yaml
# For nginx services
- hosts: webservers
  roles:
    - role: oaf.cloudflare_realip
      cloudflare_webserver: nginx

# For apache services
- hosts: webservers
  roles:
    - role: oaf.cloudflare_realip
      cloudflare_webserver: apache
```

This role:
1. Fetches current Cloudflare IP ranges from the official API
2. Generates the appropriate config for nginx (`/etc/nginx/conf.d/cloudflare-realip.conf`) or apache (`/etc/apache2/conf-available/cloudflare-remoteip.conf`)
3. Configures the web server to trust `CF-Connecting-IP` header from Cloudflare IPs

**Files:**
- [roles/internal/oaf.cloudflare_realip/](../roles/internal/oaf.cloudflare_realip/)

## IP Blocklist Migration

### Current State

Several services have IP-based deny rules in their nginx configurations:

| Service | Deny Rules | Location |
|---------|-----------|----------|
| theyvoteforyou | 563 | `roles/internal/theyvoteforyou/templates/production` |
| righttoknow | 29 | `roles/internal/righttoknow/templates/nginx/stage` |

These block:
- Known bot/scraper networks (SEMrush, aggressive crawlers)
- Cloud provider ranges used for abuse (Alibaba, Hetzner, various Chinese ISPs)
- Specific IP ranges associated with SQL injection attempts
- ASN blocks (particularly ASN 136907)

### Migration Options

#### Option 1: Keep in nginx (Recommended Initially)

**How it works:** With the `oaf.cloudflare_realip` role configured, nginx's `$remote_addr` variable is restored to the real client IP via the `CF-Connecting-IP` header. Existing `deny` directives continue to work.

**Pros:**
- No changes to existing blocklists
- Works immediately after enabling proxy
- No Cloudflare plan requirements

**Cons:**
- Blocked requests still reach origin (use bandwidth)
- No visibility into blocked requests in Cloudflare dashboard

**Implementation:** Include `oaf.cloudflare_realip` role before the service role. No changes to existing deny rules needed.

#### Option 2: Cloudflare Firewall Rules

**How it works:** Create firewall rules in Cloudflare dashboard to block IPs at the edge before they reach origin.

**Pros:**
- Blocks at edge (no origin bandwidth used)
- Visibility in Cloudflare dashboard
- Can use additional signals (ASN, country, threat score)

**Cons:**
- Free plan: 5 rules maximum
- Pro plan: 20 rules maximum
- Must consolidate 500+ IPs into manageable rules
- Manual management (not in Terraform currently)

**Implementation:**
1. Analyse existing blocklists to identify patterns (ASN, CIDR aggregation)
2. Create Cloudflare firewall rules via dashboard or API
3. Consider Terraform `cloudflare_filter` and `cloudflare_firewall_rule` resources

#### Option 3: Cloudflare WAF Custom Rules

**How it works:** Use Cloudflare's WAF with IP lists to block large numbers of IPs.

**Pros:**
- IP lists can contain thousands of entries
- Managed via API/Terraform
- Blocks at edge

**Cons:**
- Requires Pro plan or higher
- Additional configuration complexity

**Implementation:**
1. Create IP lists via `cloudflare_list` Terraform resource
2. Reference lists in WAF custom rules
3. Maintain lists alongside existing nginx blocklists

### Recommendation

**Phase 1:** Use Option 1 (keep in nginx). This allows immediate migration with no blocklist changes.

**Phase 2:** After migration is stable, evaluate whether edge blocking (Options 2 or 3) provides meaningful benefit. Consider:
- Volume of blocked requests (check nginx logs)
- Bandwidth impact of blocked requests
- Cloudflare plan features available

## Let's Encrypt Certificate Compatibility

### Current Certbot Modes

| Service | Mode | Challenge Path |
|---------|------|----------------|
| righttoknow | webroot | `/usr/share/nginx/html/.well-known/acme-challenge/` |
| theyvoteforyou | nginx plugin | Handled by certbot-nginx |
| openaustralia | apache plugin | Handled by certbot-apache |
| planningalerts | apache plugin | Handled by certbot-apache |

### Cloudflare Behaviour

By default, Cloudflare:
- **Proxies** `.well-known/acme-challenge/*` requests to origin (no caching)
- **Does not** strip or modify the challenge path
- **Does** require origin to be reachable on the proxied port

### Requirements for Successful Renewal

1. **SSL Mode**: Set Cloudflare SSL/TLS mode to "Full" or "Full (Strict)"
   - "Flexible" mode won't work because origin expects HTTPS from Cloudflare
   - "Full (Strict)" requires valid origin certificate

2. **No Page Rules Blocking Challenges**: Ensure no page rules cache or redirect `.well-known/*`

3. **Origin Accessible**: Origin must accept connections from Cloudflare IPs on port 443

### Verification Steps

After enabling Cloudflare proxy:

```bash
# Test that challenges are reachable through Cloudflare
curl -I https://example.org/.well-known/acme-challenge/test

# Dry run renewal
sudo certbot renew --dry-run
```

### Fallback Procedure

If certificate renewal fails after enabling proxy:

1. **Temporary**: Disable proxy (grey cloud) for the domain during renewal
2. **Permanent**: Consider Cloudflare Origin CA certificates instead of Let's Encrypt

Cloudflare Origin CA certificates are trusted by Cloudflare but not browsers. They're suitable when origin is always accessed through Cloudflare, simplifying certificate management.

## Migration Checklist

For each service, complete these steps:

### Pre-Migration

- [ ] Apply `oaf.cloudflare_realip` role to the service's playbook
- [ ] Verify role creates `/etc/nginx/conf.d/cloudflare-realip.conf`
- [ ] Test that nginx reloads successfully

### Enable Proxy

- [ ] In Cloudflare dashboard, enable proxy (orange cloud) for the domain
- [ ] Set Terraform variable `{service}_cloudflare_only = true`
- [ ] Run `terraform apply` to restrict security groups

### Post-Migration Verification

- [ ] Check nginx access logs show real client IPs (not 173.245.x.x, 104.16.x.x, etc.)
- [ ] Verify IP blocklists still function (test with a blocked IP if possible)
- [ ] Run `certbot renew --dry-run` to verify certificate renewal
- [ ] Monitor for any access issues or unexpected blocks

## Cloudflare IP Ranges

Current Cloudflare IP ranges (as of configuration time):

**IPv4 (14 ranges):**
- Fetched from: https://www.cloudflare.com/ips-v4

**IPv6 (6 ranges):**
- Fetched from: https://www.cloudflare.com/ips-v6

These are dynamically fetched by both:
- Terraform (`data.http.cloudflare_ipv4/ipv6`)
- Ansible (`oaf.cloudflare_realip` role)

Cloudflare occasionally adds new ranges. Re-run Terraform and Ansible when this happens.

## References

- [Cloudflare IP Ranges](https://www.cloudflare.com/ips/)
- [Restoring Original Visitor IPs](https://developers.cloudflare.com/support/troubleshooting/restoring-visitor-ips/)
- [Cloudflare HTTP Headers](https://developers.cloudflare.com/fundamentals/reference/http-headers/)
- [Let's Encrypt HTTP-01 Challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge)
