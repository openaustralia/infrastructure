# Security group for OpenVPN server
resource "aws_security_group" "openvpn" {
  name        = "openvpn-server"
  description = "Security group for OpenVPN server"

  # OpenVPN port - accessible from anywhere
  ingress {
    from_port        = 1194
    to_port          = 1194
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "OpenVPN UDP port"
  }

  # SSH for management - accessible from anywhere initially
  # TODO: Restrict this after VPN is working
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "SSH for server management"
  }

  # Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "openvpn-server"
  }
}

# VPN subnet that will be assigned to VPN clients
locals {
  vpn_subnet = "10.8.0.0/24"
}

# Update webserver security group to allow SSH only from VPN
# This replaces the existing SSH rule that allows 0.0.0.0/0
resource "aws_security_group_rule" "webserver_ssh_from_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.vpn_subnet]
  security_group_id = aws_security_group.webserver.id
  description       = "SSH from VPN clients only"
}

# Update planningalerts security group to allow SSH only from VPN
resource "aws_security_group_rule" "planningalerts_ssh_from_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.vpn_subnet]
  security_group_id = aws_security_group.planningalerts.id
  description       = "SSH from VPN clients only"
}
