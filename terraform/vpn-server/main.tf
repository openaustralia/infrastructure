# OpenVPN Server for IAM-authenticated VPN access
# Users must be in the 'vpn-users' IAM group to connect

# Use latest Ubuntu 22.04 LTS
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM role and policies for OpenVPN server
# Allows the server to validate IAM credentials and check group membership
resource "aws_iam_role" "openvpn" {
  name = "openvpn-server"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "openvpn-server"
  }
}

resource "aws_iam_role_policy" "openvpn_auth" {
  name = "openvpn-authentication"
  role = aws_iam_role.openvpn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetUser",
          "iam:ListGroupsForUser",
          "iam:GetAccessKeyLastUsed"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "openvpn" {
  name = "openvpn-server"
  role = aws_iam_role.openvpn.name
}

# Create the vpn-users IAM group
resource "aws_iam_group" "vpn_users" {
  name = "vpn-users"
  path = "/"
}

# VPN users group membership
# These are manually created IAM users who need VPN access
resource "aws_iam_group_membership" "vpn_users" {
  name  = "vpn-users-membership"
  group = aws_iam_group.vpn_users.name

  users = [
    "jon.vpn",
    "ben.vpn",
    "brenda.vpn",
    "ian.vpn",
    "james.vpn",
  ]
}

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
  security_group_id = var.webserver_security_group_id
  description       = "SSH from VPN clients only"
}

# Update planningalerts security group to allow SSH only from VPN
resource "aws_security_group_rule" "planningalerts_ssh_from_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.vpn_subnet]
  security_group_id = var.planningalerts_security_group_id
  description       = "SSH from VPN clients only"
}

resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.ubuntu_jammy.id
  instance_type          = "t3.small"
  key_name               = "terraform"
  vpc_security_group_ids = [aws_security_group.openvpn.id]
  iam_instance_profile   = aws_iam_instance_profile.openvpn.name

  # Enable source/dest check disable for NAT functionality
  source_dest_check = false

  user_data = file("${path.module}/vpn-user-data.sh")

  tags = {
    Name = "openvpn-server"
    Role = "vpn"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }
}

# Elastic IP for consistent VPN endpoint
resource "aws_eip" "openvpn" {
  instance = aws_instance.openvpn.id

  tags = {
    Name = "openvpn-server"
  }
}
