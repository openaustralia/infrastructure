# For the time being we're just using DMARC records to get some data on what's
# happening with email that we're sending (and whether anyone else is impersonating
# us).

# We're using a free service provided by https://dmarc.postmarkapp.com/
# This generates a weekly DMARC report which gets sent by email on Monday mornings

# Report goes to webmaster@morph.io
resource "cloudflare_record" "morph_dmarc" {
  zone_id = var.morph_io_zone_id
  name    = "_dmarc.morph.io"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+yuyhziqptlw@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

# Report goes to webmaster@oaf.org.au
resource "cloudflare_record" "oaf_dmarc" {
  zone_id = var.oaf_org_au_zone_id
  name    = "_dmarc.oaf.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+ff2eamlrqpn@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

# Report goes to webmaster@openaustraliafoundation.org.au
resource "cloudflare_record" "oaf_alt_dmarc" {
  zone_id = var.openaustraliafoundation_org_au_zone_id
  name    = "_dmarc.openaustraliafoundation.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+tziobvarown@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

# Report goes to webmaster@openaustralia.org
resource "cloudflare_record" "oa_dmarc" {
  zone_id = var.openaustralia_org_zone_id
  name    = "_dmarc.openaustralia.org"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+dkbgzuudi8i@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

# Report goes to webmaster@openaustralia.org.au
resource "cloudflare_record" "oa_alt_dmarc" {
  zone_id = var.openaustralia_org_au_zone_id
  name    = "_dmarc.openaustralia.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+no6xy3wrymr@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

# Report goes to webmaster@opengovernment.org.au
resource "cloudflare_record" "opengovernment_dmarc" {
  zone_id = var.opengovernment_org_au_zone_id
  name    = "_dmarc.opengovernment.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+hm1wga71eti@dmarc.postmarkapp.com; sp=none; aspf=r;"
}

# Report goes to webmaster@righttoknow.org.au
resource "cloudflare_record" "rtk_dmarc" {
  zone_id = var.righttoknow_org_au_zone_id
  name    = "_dmarc.righttoknow.org.au"
  type    = "TXT"
  value   = "v=DMARC1; p=none; pct=100; rua=mailto:re+aysyay6u9ct@dmarc.postmarkapp.com; sp=none; aspf=r;"
}
