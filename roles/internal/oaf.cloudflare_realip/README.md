# oaf.cloudflare_realip

Configure nginx or apache to restore real client IP addresses when traffic is proxied through Cloudflare.

## Overview

When Cloudflare proxies requests to your origin server, the client IP address is replaced with a Cloudflare IP. This role configures your web server to restore the original client IP using the `CF-Connecting-IP` header:

- **nginx**: Uses `ngx_http_realip_module` with `set_real_ip_from` directives
- **apache**: Uses `mod_remoteip` with `RemoteIPTrustedProxy` directives

## Requirements

- **nginx**: `ngx_http_realip_module` compiled in (included by default)
- **apache**: `mod_remoteip` available (included in apache 2.4+)
- Network access to fetch Cloudflare IP ranges from `cloudflare.com/ips-v4` and `cloudflare.com/ips-v6`

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cloudflare_webserver` | `nginx` | Web server type: `nginx` or `apache` |
| `cloudflare_nginx_config_path` | `/etc/nginx/conf.d/cloudflare-realip.conf` | nginx config path |
| `cloudflare_apache_config_path` | `/etc/apache2/conf-available/cloudflare-remoteip.conf` | apache config path |
| `cloudflare_real_ip_header` | `CF-Connecting-IP` | Header containing the real client IP |
| `cloudflare_include_ipv6` | `true` | Whether to include IPv6 ranges |
| `cloudflare_ipv4_url` | `https://www.cloudflare.com/ips-v4` | URL to fetch IPv4 ranges |
| `cloudflare_ipv6_url` | `https://www.cloudflare.com/ips-v6` | URL to fetch IPv6 ranges |

## Usage

### nginx

```yaml
- hosts: webservers
  roles:
    - role: oaf.cloudflare_realip
      cloudflare_webserver: nginx
```

### apache

```yaml
- hosts: webservers
  roles:
    - role: oaf.cloudflare_realip
      cloudflare_webserver: apache
```

### Conditional inclusion from another role

```yaml
# In your service role's tasks/main.yml
- name: Configure Cloudflare real IP
  include_role:
    name: oaf.cloudflare_realip
  vars:
    cloudflare_webserver: nginx  # or apache
  when: cloudflare_proxy_enabled | default(false)
```

## How It Works

1. The role fetches the current Cloudflare IP ranges from the official API endpoints
2. It generates a web server config file with trust directives for each CIDR
3. The config is placed in the appropriate location and the web server is reloaded

### nginx

Generates `/etc/nginx/conf.d/cloudflare-realip.conf`:
```nginx
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
# ... more ranges
real_ip_header CF-Connecting-IP;
real_ip_recursive on;
```

### apache

Enables `mod_remoteip` and generates `/etc/apache2/conf-available/cloudflare-remoteip.conf`:
```apache
<IfModule mod_remoteip.c>
    RemoteIPHeader CF-Connecting-IP
    RemoteIPTrustedProxy 173.245.48.0/20
    RemoteIPTrustedProxy 103.21.244.0/22
    # ... more ranges
</IfModule>
```

## Important Notes

- **IP ranges are dynamic**: Cloudflare occasionally adds new IP ranges. Re-run this role periodically or after Cloudflare announcements.
- **Security**: Only trust the `CF-Connecting-IP` header from Cloudflare IPs. This role ensures the web server only accepts this header from the configured ranges.
- **Testing**: After enabling Cloudflare proxy, verify that access logs show real client IPs, not Cloudflare ranges (173.245.x.x, 104.16.x.x, etc.).

## See Also

- [Cloudflare IP Ranges](https://www.cloudflare.com/ips/)
- [Cloudflare HTTP Headers](https://developers.cloudflare.com/fundamentals/reference/http-headers/)
- [nginx ngx_http_realip_module](https://nginx.org/en/docs/http/ngx_http_realip_module.html)
- [apache mod_remoteip](https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html)
