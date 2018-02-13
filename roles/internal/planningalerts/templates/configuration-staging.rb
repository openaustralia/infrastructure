# Stores application configuration settings
module Configuration
  # URL Stuff
  HOST = 'www.test.{{ planningalerts_domain }}'

  # See https://morph.io/api
  MORPH_API_KEY = "{{ morph_api_key }}"

  # Email setup
  EMAIL_FROM_ADDRESS = 'contact@planningalerts.org.au'
  EMAIL_FROM_NAME = 'PlanningAlerts'
  # The email that abuse reports are sent to
  EMAIL_MODERATOR = EMAIL_FROM_ADDRESS

  # Scraper params
  SCRAPE_DELAY = 14

  # Google maps key
  GOOGLE_MAPS_KEY = "{{ google_maps_key }}"

  # If you have Google Maps API for Business (OpenAustralia Foundation gets it through the Google Maps API
  # grants programme for charities) uncomment and fill out the two lines below
  GOOGLE_MAPS_CLIENT_ID = "{{ google_maps_client_id }}"
  GOOGLE_MAPS_CRYPTOGRAPHIC_KEY = "{{ google_maps_cryptographic_key }}"

  # Google Analytics key
  GOOGLE_ANALYTICS_KEY = 'UA-3107958-6'

  # OAuth details for Twitter application with read access only (for twitter feed on home page)
  TWITTER_CONSUMER_KEY = "{{ twitter_consumer_key }}"
  TWITTER_CONSUMER_SECRET = "{{ twitter_consumer_secret }}"
  TWITTER_OAUTH_TOKEN = "{{ twitter_oauth_token }}"
  TWITTER_OAUTH_TOKEN_SECRET = "{{ twitter_oauth_token_secret }}"

  # cuttlefish.io is used to send out emails in production
  CUTTLEFISH_SERVER = "cuttlefish.oaf.org.au"
  CUTTLEFISH_USER_NAME = "{{ cuttlefish_user_name }}"
  CUTTLEFISH_PASSWORD = "{{ cuttlefish_password }}"

  # Configuration for the theme
  THEME_NSW_HOST = "applicationtracking.planning.nsw.gov.au"
  THEME_NSW_EMAIL_FROM_ADDRESS = "eplanning@planning.nsw.gov.au"
  THEME_NSW_EMAIL_FROM_NAME = "Application Tracking"

  THEME_NSW_CUTTLEFISH_USER_NAME = "{{ theme_nsw_cuttlefish_user_name }}"
  THEME_NSW_CUTTLEFISH_PASSWORD = "{{ theme_nsw_cuttlefish_password }}"

  THEME_NSW_GOOGLE_ANALYTICS_KEY = "UA-3107958-12"

  HONEYBADGER_API_KEY = "{{ honeybadger_api_key }}"
end
