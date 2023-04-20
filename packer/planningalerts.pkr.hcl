source "amazon-ebs" "planningalerts-22" {
  ami_name = "planningalerts-puma-ubuntu-22.04-v2"
  instance_type = "t3.small"
  region = "ap-southeast-2"
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
  name = "planningalerts-22"
  sources = [
    "source.amazon-ebs.planningalerts-22"
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