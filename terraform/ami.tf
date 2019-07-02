# Get the AMI for Ubuntu 16.04. Lock it to a specific version so that we don't
# keep re-provisioning the servers when the AMI gets updated
data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180205"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

data "aws_ami" "ubuntu_bionic" {
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190627.1"]
  }

  # Canonical
  owners = ["099720109477"]
}
