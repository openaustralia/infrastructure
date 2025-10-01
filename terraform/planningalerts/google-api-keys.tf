# Google Maps API Keys Configuration
# 
# Security Architecture (Updated Oct 2025):
# - Client key (google_maps_key): Restricted to browser-based JavaScript APIs only
#   * NO static-maps or street-view-image APIs (prevents $100k abuse bills)
#   * Referrer restrictions to planningalerts.org.au domains
# 
# - Server key (google_maps_server_key): For server-side static map generation
#   * IP-restricted to production servers only
#   * Includes static-maps and street-view APIs safely behind IP restrictions
#
# TODO: Check usage of all these keys and how they are set up
# TODO: Probably all these keys could do with rotation. They've been in use for a while now.
resource "google_apikeys_key" "google_maps_email_key" {
  display_name = "PlanningAlerts Web API Key (google_maps_email_key)"
  name         = "8405437045225725397"

  restrictions {
    browser_key_restrictions {
      allowed_referrers = [
        "https://planningalerts.org.au",
        "https://www.planningalerts.org.au",
        "https://cuttlefish.oaf.org.au",
        "http://localhost:3000",
      ]
    }
  }
}

resource "google_apikeys_key" "google_maps_key" {
  display_name = "PlanningAlerts Web Client-Side API Key (google_maps_key)"
  name         = "3f2cc059-ec01-4c0a-bc43-a5e9d1daa993"

  restrictions {
    browser_key_restrictions {
      allowed_referrers = concat(
        [
          "https://planningalerts.org.au/*",
          "https://www.planningalerts.org.au/*",
          "https://cuttlefish.oaf.org.au/*",
          "http://localhost:3000/*",
        ],
        # Allows maps to work when accessing the servers directly (not through the load balancer)
        # Obviously not necessary for normal production use but useful for debugging and testing
        [for s in module.blue.public_names : "http://${s}:8000/*"],
        [for s in module.green.public_names : "http://${s}:8000/*"],
      )
    }

    # Restrict to ONLY client-side JavaScript APIs
    # Prevents abuse of static maps and street view image generation
    api_targets {
      service = "maps-backend.googleapis.com"
    }
    api_targets {
      service = "geocoding-backend.googleapis.com"
    }
    api_targets {
      service = "places-backend.googleapis.com"
    }
  }
}

resource "google_apikeys_key" "google_maps_server_key" {
  display_name = "PlanningAlerts Server-Side API Key (google_maps_server_key)"
  name         = "e401e298-4aa7-4ee8-a53e-06b6da107b2a"
  
  restrictions {
    server_key_restrictions {
      allowed_ips = concat(module.blue.public_ips, module.green.public_ips)
    }

    # Server-side APIs for static map generation and street view
    # IP-restricted to prevent abuse
    api_targets {
      service = "static-maps-backend.googleapis.com"
    }
    api_targets {
      service = "street-view-image-backend.googleapis.com"
    }
    api_targets {
      service = "geocoding-backend.googleapis.com"
    }
  }
}

# TODO: Output the api keys for easy access
