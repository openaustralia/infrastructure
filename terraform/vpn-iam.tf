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

output "vpn_users_group_name" {
  description = "IAM group name for VPN access"
  value       = aws_iam_group.vpn_users.name
}
