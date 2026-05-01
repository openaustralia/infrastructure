# OpenVPN Server for IAM-authenticated VPN access
# Users must be in the 'vpn-users' IAM group to connect

resource "aws_instance" "openvpn" {
  ami                    = var.ubuntu_22_openvpn_ami
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

output "vpn_server_ip" {
  description = "OpenVPN server public IP"
  value       = aws_eip.openvpn.public_ip
}

output "vpn_server_private_ip" {
  description = "OpenVPN server private IP"
  value       = aws_instance.openvpn.private_ip
}
