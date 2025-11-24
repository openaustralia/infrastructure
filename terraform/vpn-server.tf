# OpenVPN Server for IAM-authenticated VPN access
# Users must be in the 'vpn-users' IAM group to connect

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

# Elastic IP for consistent VPN endpoint
resource "aws_eip" "openvpn" {
  instance = aws_instance.openvpn.id

  tags = {
    Name = "openvpn-server"
  }
}

output "vpn_server_ip" {
  description = "OpenVPN server public IP"
  value       = aws_eip.openvpn.public_ip
}

output "vpn_server_private_ip" {
  description = "OpenVPN server private IP"
  value       = aws_instance.openvpn.private_ip
}
