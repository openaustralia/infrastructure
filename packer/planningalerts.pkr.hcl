packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}



source "amazon-ebs" "planningalerts-ruby33" {
  ami_name = "planningalerts-ruby-3.3-v1"
  instance_type = "t3.small"
  region = "ap-southeast-2"
  ami_block_device_mappings {
    // Double the volume size to 16 GiB from the default of 8 GiB
    device_name = "/dev/sda1"
    volume_size = 16
  }
  source_ami_filter {
    filters = {
      name = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  // Useful while debugging
  // skip_create_ami = true
}

build {
  name = "planningalerts-ruby33"
  sources = [
    "source.amazon-ebs.planningalerts-ruby33"
  ]

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    command = "../.venv/bin/ansible-playbook"
    ansible_env_vars = ["ANSIBLE_ROLES_PATH=../roles/internal:../roles/external"]
    // See https://github.com/hashicorp/packer-plugin-ansible/issues/69
    use_proxy = false
    extra_arguments = [
      // Useful for debugging
      // "-vv",
      "--vault-id", "../.vault_pass.txt",
      "--vault-id", "ec2@../.ec2-vault-pass",
      "--vault-id", "all@../.all-vault-pass"
    ]
    groups = ["ec2", "planningalerts"]
    inventory_directory = ".."
  }
}