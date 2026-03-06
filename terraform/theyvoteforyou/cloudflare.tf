## theyvoteforyou.org.au - Zone Settings
resource "cloudflare_zone_settings_override" "org_au" {
  zone_id = cloudflare_zone.org_au.id
  settings {
    always_online             = "off"
    always_use_https          = "on"
    automatic_https_rewrites  = "off"
    brotli                    = "off"
    browser_cache_ttl         = 14400
    browser_check             = "on"
    cache_level               = "aggressive"
    challenge_ttl             = 1800
    ciphers                   = []
    cname_flattening          = "flatten_all"
    development_mode          = "off"
    early_hints               = "on"
    email_obfuscation         = "on"
    filter_logs_to_cloudflare = "off"
    hotlink_protection        = "on"
    http2                     = "on"
    http3                     = "on"
    ip_geolocation            = "on"
    ipv6                      = "on"
    log_to_cloudflare         = "on"
    max_upload                = 100
    min_tls_version           = "1.0"
    minify {
      css  = "off"
      html = "off"
      js   = "off"
    }
    mirage                      = "off"
    opportunistic_encryption    = "off"
    opportunistic_onion         = "on"
    orange_to_orange            = "off"
    origin_error_page_pass_thru = "off"
    polish                      = "lossy"
    privacy_pass                = "on"
    proxy_read_timeout          = "100"
    pseudo_ipv4                 = "off"
    response_buffering          = "off"
    rocket_loader               = "off"
    security_header {
      enabled            = false
      include_subdomains = false
      max_age            = 0
      nosniff            = false
      preload            = false
    }
    security_level              = "medium"
    server_side_exclude         = "on"
    sort_query_string_for_cache = "off"
    ssl                         = "full"
    tls_1_3                     = "zrt"
    tls_client_auth             = "off"
    true_client_ip_header       = "off"
    visitor_ip                  = "on"
    waf                         = "off"
    webp                        = "off"
    websockets                  = "on"
    zero_rtt                    = "on"
  }
}

## theyvoteforyou.org.au - Managed Headers
resource "cloudflare_managed_headers" "org_au" {
  zone_id = cloudflare_zone.org_au.id
}

## theyvoteforyou.org.au - Filters
resource "cloudflare_filter" "waf_attack_score" {
  expression = "(cf.waf.score.class eq \"attack\")"
  paused     = false
  zone_id    = cloudflare_zone.org_au.id
}

resource "cloudflare_filter" "block_ai_bots" {
  expression = "(http.request.uri.path ne \"/robots.txt\") and ((http.user_agent contains \"Amazonbot\") or (http.user_agent contains \"Anchor Browser\") or (http.user_agent contains \"Bytespider\") or (http.user_agent contains \"CCBot\") or (http.user_agent contains \"FacebookBot\") or (http.user_agent contains \"Google-CloudVertexBot\") or (http.user_agent contains \"meta-externalagent\") or (http.user_agent contains \"Novellum\") or (http.user_agent contains \"PetalBot\") or (http.user_agent contains \"ProRataInc\") or (http.user_agent contains \"Timpibot\"))"
  paused     = false
  zone_id    = cloudflare_zone.org_au.id
}

resource "cloudflare_filter" "api_endpoint" {
  expression = "(http.request.method eq \"GET\" and http.request.uri.path wildcard \"/api/*\")"
  paused     = false
  zone_id    = cloudflare_zone.org_au.id
}

## theyvoteforyou.org.au - Firewall Rules
resource "cloudflare_firewall_rule" "disable_bot_fight_mode_api" {
  action      = "bypass"
  description = "Disable Bot Fight Mode on API endpoint"
  filter_id   = cloudflare_filter.api_endpoint.id
  paused      = false
  zone_id     = cloudflare_zone.org_au.id

  lifecycle {
    ignore_changes = [action]
  }
}

resource "cloudflare_firewall_rule" "block_ai_bots" {
  action      = "block"
  description = "AI Crawl Control - Block AI bots by User Agent"
  filter_id   = cloudflare_filter.block_ai_bots.id
  paused      = false
  zone_id     = cloudflare_zone.org_au.id
}

resource "cloudflare_firewall_rule" "block_waf_attacks" {
  action    = "block"
  filter_id = cloudflare_filter.waf_attack_score.id
  paused    = false
  zone_id   = cloudflare_zone.org_au.id
}

## theyvoteforyou.org.au - Rulesets
resource "cloudflare_ruleset" "leaked_credential_check" {
  kind    = "zone"
  name    = "default"
  phase   = "http_ratelimit"
  zone_id = cloudflare_zone.org_au.id
  rules {
    action      = "block"
    description = "Leaked credential check"
    enabled     = true
    expression  = "(cf.waf.credential_check.password_leaked)"
    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      mitigation_timeout  = 86400
      period              = 10
      requests_per_period = 5
      requests_to_origin  = false
    }
  }
}

resource "cloudflare_ruleset" "cache_settings" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_cache_settings"
  zone_id = cloudflare_zone.org_au.id
  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = false
    }
    description = "Bypass caching for API"
    enabled     = true
    expression  = "(http.request.method eq \"GET\" and http.request.uri.path wildcard \"/api/*\")"
  }
}

resource "cloudflare_ruleset" "firewall_custom" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_firewall_custom"
  zone_id = cloudflare_zone.org_au.id
  rules {
    action = "skip"
    action_parameters {
      phases = ["http_request_sbfm"]
    }
    description = "Disable Bot Fight Mode on API endpoint"
    enabled     = true
    expression  = "(http.request.method eq \"GET\" and http.request.uri.path wildcard \"/api/*\")"
    logging {
      enabled = true
    }
  }
  rules {
    action = "block"
    action_parameters {
      response {
        content      = "{\"message\":\"Please contact the site owner for access.\"}"
        content_type = "application/json"
        status_code  = 403
      }
    }
    description = "AI Crawl Control - Block AI bots by User Agent"
    enabled     = true
    expression  = "(http.request.uri.path ne \"/robots.txt\") and ((http.user_agent contains \"Amazonbot\") or (http.user_agent contains \"Anchor Browser\") or (http.user_agent contains \"Bytespider\") or (http.user_agent contains \"CCBot\") or (http.user_agent contains \"FacebookBot\") or (http.user_agent contains \"Google-CloudVertexBot\") or (http.user_agent contains \"meta-externalagent\") or (http.user_agent contains \"Novellum\") or (http.user_agent contains \"PetalBot\") or (http.user_agent contains \"ProRataInc\") or (http.user_agent contains \"Timpibot\"))"
  }
  rules {
    action     = "block"
    enabled    = true
    expression = "(cf.waf.score.class eq \"attack\")"
  }
}

resource "cloudflare_ruleset" "firewall_managed" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_firewall_managed"
  zone_id = cloudflare_zone.org_au.id
  rules {
    action = "execute"
    action_parameters {
      id = "efb7b8c949ac4650a09736fc376e9aee"
      overrides {
        rules {
          action  = "block"
          enabled = false
          id      = "7aeb2faf29284398aeb782e54875e938"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "7babab188b3c40ae87b93ec451f4fd5b"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "23ee7cebe6e8443e99ecf932ab579455"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "76f9871c8e88445b807c9ebcd440c742"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "cd7bd3dbe8fd4add9926ad50068b2a17"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "34da2a5e0a95425d9b0e44f07c641d63"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "2fe273498e964f0bb20ac022d5a14a5e"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "47631a04883d4d7cab6bd7b83478adcb"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "977ad8daef224ecdbe475c7ab3ab3365"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "bdd776b4f296477f960acc346dfa618e"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "49449f901cab4a01b2591ab836babcca"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "d6f6d394cb01400284cfb7971e7aed1e"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "d9aeff22f1024655937e5b033a61fbc5"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "525329e705aa4fa596e126366d02615e"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "8bb4bf582f704b61980fceff442561a8"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "15b0616fe67a439a8a3852410cadd290"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "00bee3de44184f7f8a6ad10910f04e13"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "7b1cfed7fd4047c6949c4d054751ef80"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "d8c7dbf00ec546e48e3c4340486c3ee2"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "ff8b8608c2c14bf5b3de621b6fc2309c"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "71b7793c77e24287861b82f0ec97cf32"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "40cba5ee3a014208958da0855ddfd8e3"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "5dd38056f4cd43fca7f198e6384f1856"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "d384de3d016d414dbf4d14caaa83212b"
        }
        rules {
          action  = "log"
          enabled = false
          id      = "aa3411d5505b4895b547d68950a28587"
        }
        rules {
          action  = "block"
          enabled = false
          id      = "ac89e3a915594a139fc370dece6a8e28"
        }
      }
      version = "latest"
    }
    enabled    = true
    expression = "true"
  }
  rules {
    action = "execute"
    action_parameters {
      id = "4814384a9e5d4991b9815dcfc25d2f1f"
      overrides {
        categories {
          category = "paranoia-level-3"
          enabled  = false
        }
        categories {
          category = "paranoia-level-4"
          enabled  = false
        }
        rules {
          action          = "managed_challenge"
          id              = "6179ae15870a4bb7b2d480d4843b323c"
          score_threshold = 40
        }
      }
      version = "latest"
    }
    enabled    = true
    expression = "true"
  }
}

## theyvoteforyou.org - Zone Settings
resource "cloudflare_zone_settings_override" "org" {
  zone_id = cloudflare_zone.org.id
  settings {
    always_online             = "off"
    always_use_https          = "off"
    automatic_https_rewrites  = "on"
    brotli                    = "on"
    browser_cache_ttl         = 14400
    browser_check             = "on"
    cache_level               = "aggressive"
    challenge_ttl             = 1800
    ciphers                   = []
    cname_flattening          = "flatten_at_root"
    development_mode          = "off"
    early_hints               = "off"
    email_obfuscation         = "on"
    filter_logs_to_cloudflare = "off"
    hotlink_protection        = "off"
    http2                     = "on"
    http3                     = "on"
    ip_geolocation            = "on"
    ipv6                      = "on"
    log_to_cloudflare         = "on"
    max_upload                = 100
    min_tls_version           = "1.0"
    minify {
      css  = "off"
      html = "off"
      js   = "off"
    }
    mirage                      = "off"
    opportunistic_encryption    = "on"
    opportunistic_onion         = "on"
    orange_to_orange            = "off"
    origin_error_page_pass_thru = "off"
    polish                      = "off"
    privacy_pass                = "on"
    proxy_read_timeout          = "100"
    pseudo_ipv4                 = "off"
    response_buffering          = "off"
    rocket_loader               = "off"
    security_header {
      enabled            = false
      include_subdomains = false
      max_age            = 0
      nosniff            = false
      preload            = false
    }
    security_level              = "medium"
    server_side_exclude         = "on"
    sort_query_string_for_cache = "off"
    ssl                         = "full"
    tls_1_3                     = "on"
    tls_client_auth             = "off"
    true_client_ip_header       = "off"
    visitor_ip                  = "on"
    waf                         = "off"
    webp                        = "off"
    websockets                  = "on"
    zero_rtt                    = "off"
  }
}

## theyvoteforyou.com.au - Zone Settings
resource "cloudflare_zone_settings_override" "com_au" {
  zone_id = cloudflare_zone.com_au.id
  settings {
    always_online             = "off"
    always_use_https          = "off"
    automatic_https_rewrites  = "on"
    brotli                    = "on"
    browser_cache_ttl         = 14400
    browser_check             = "on"
    cache_level               = "aggressive"
    challenge_ttl             = 1800
    ciphers                   = []
    cname_flattening          = "flatten_at_root"
    development_mode          = "off"
    early_hints               = "off"
    email_obfuscation         = "on"
    filter_logs_to_cloudflare = "off"
    hotlink_protection        = "off"
    http2                     = "on"
    http3                     = "on"
    ip_geolocation            = "on"
    ipv6                      = "on"
    log_to_cloudflare         = "on"
    max_upload                = 100
    min_tls_version           = "1.0"
    minify {
      css  = "off"
      html = "off"
      js   = "off"
    }
    mirage                      = "off"
    opportunistic_encryption    = "on"
    opportunistic_onion         = "on"
    orange_to_orange            = "off"
    origin_error_page_pass_thru = "off"
    polish                      = "off"
    privacy_pass                = "on"
    proxy_read_timeout          = "100"
    pseudo_ipv4                 = "off"
    response_buffering          = "off"
    rocket_loader               = "off"
    security_header {
      enabled            = false
      include_subdomains = false
      max_age            = 0
      nosniff            = false
      preload            = false
    }
    security_level              = "medium"
    server_side_exclude         = "on"
    sort_query_string_for_cache = "off"
    ssl                         = "full"
    tls_1_3                     = "on"
    tls_client_auth             = "off"
    true_client_ip_header       = "off"
    visitor_ip                  = "on"
    waf                         = "off"
    webp                        = "off"
    websockets                  = "on"
    zero_rtt                    = "off"
  }
}
