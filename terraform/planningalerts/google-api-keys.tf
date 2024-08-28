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
  display_name = "PlanningAlerts Web Static Street View key (google_maps_key)"
  name         = "3f2cc059-ec01-4c0a-bc43-a5e9d1daa993"

  restrictions {
    browser_key_restrictions {
      allowed_referrers = concat(
        [
          "https://planningalerts.org.au",
          "https://www.planningalerts.org.au",
          "https://cuttlefish.oaf.org.au",
          "http://localhost:3000",
        ],
        # Allows maps to work when accessing the servers directly (not through the load balancer)
        # Obviously not necessary for normal production use but useful for debugging and testing
        [for s in module.blue.public_names : "http://${s}:8000"],
        [for s in module.green.public_names : "http://${s}:8000"],
      )
    }
  }
}

resource "google_apikeys_key" "google_maps_server_key" {
  display_name = "PlanningAlerts Server API key (google_maps_server_key)"
  name         = "e401e298-4aa7-4ee8-a53e-06b6da107b2a"
  restrictions {
    server_key_restrictions {
      allowed_ips = concat(module.blue.public_ips, module.green.public_ips)
    }
  }
}

# TODO: Output the api keys for easy access
