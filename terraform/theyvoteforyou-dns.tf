# Configure the DNSMadeEasy provider
provider "dme" {
  version    = "~> 0.1"
  akey       = "${var.dnsmadeeasy_akey}"
  skey       = "${var.dnsmadeeasy_skey}"
  usesandbox = false
}

# Create an A record
resource "dme_record" "ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "A"
  name        = "ec2"
  value       = "${aws_eip.theyvoteforyou.public_ip}"
  ttl         = 60
  gtdLocation = "DEFAULT"
}

resource "dme_record" "test_ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "CNAME"
  name        = "test.ec2"
  value       = "ec2"
  ttl         = 60
  gtdLocation = "DEFAULT"
}

resource "dme_record" "www_ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "CNAME"
  name        = "www.ec2"
  value       = "ec2"
  ttl         = 60
  gtdLocation = "DEFAULT"
}

resource "dme_record" "www_test_ec2" {
  # theyvoteforyou.org.au
  domainid    = "1828502"
  type        = "CNAME"
  name        = "www.test.ec2"
  value       = "ec2"
  ttl         = 60
  gtdLocation = "DEFAULT"
}
