resource "aws_instance" "au_proxy" {
  ami = var.ubuntu_16_ami

  # Keeping this as small as we possibly can
  instance_type = "t3.nano"
  ebs_optimized = true
  key_name      = "deployer_key"
  tags = {
    Name = "au.proxy"
  }
  security_groups = [aws_security_group.proxy.name]

  # disable_api_termination = true
  iam_instance_profile = aws_iam_instance_profile.logging.name
}

resource "aws_eip" "au_proxy" {
  instance = aws_instance.au_proxy.id
  tags = {
    Name = "au.proxy"
  }
}

resource "cloudflare_record" "au_proxy" {
  zone_id = cloudflare_zone.oaf_org_au.id
  name    = "au.proxy.oaf.org.au"
  type    = "A"
  value   = aws_eip.au_proxy.public_ip
}
