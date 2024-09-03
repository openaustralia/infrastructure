# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).

# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings

# Report goes to webmaster@opengovernment.org.au
resource "cloudflare_record" "opengovernment_dmarc" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "_dmarc.opengovernment.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+hm1wga71eti@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
