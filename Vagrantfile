# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require "English" # for $CHILD_STATUS
require "json"

BASE_DOMAIN = "test"
IP_NETWORK = "192.168.56"
STANDARD_ALIASES = %w[www test www.test]

# The group that says where these hosts live, standing in for "ec2" on the real ones. Renaming
# rather than keeping "ec2" matters: group_vars/ec2.yml sets ansible_user, terraform.pem and an
# RDS-derived db_host. It shares base_domain, devsite and newrelic_license_key with
# group_vars/development.yml, and db_host and planningalerts_db_host with group_vars/vagrant.yml,
# and would win all five. Local boxes must not be in it.
LOCATION_GROUP = "vagrant"

# Cap per-host memory. Production runs to 16GB for theyvoteforyou and over 36GB in total.
MAX_MEMORY = (ENV["VAGRANT_MEMORY"] || 4096).to_i

# Stand-ins for the AWS managed services, which have no aws_instance in Terraform for
# bin/dev-hosts to find. group_vars/vagrant.yml pins mysql_host to .10 and both
# postgresql_host and planningalerts_db_host to .11, so those two node numbers must not move.
#
# FIXME in #574 (Upgrade Ansible to a supported version): jammy is the newest box Ansible 2.10
# can manage at all. It vendors six 1.12.0, whose meta path importer only implements
# find_module/load_module, and Python 3.12 removed the import system's fallback to those. Every
# module task then dies on the guest with "No module named 'ansible.module_utils.six.moves'",
# starting at the first gather_facts. 24.04 ships Python 3.12 and 26.04 ships 3.14, so both are
# out until #574 lands. roles/internal/postgresql also hardcodes the jammy-pgdg apt repo, which
# needs widening at the same time. Restore these two once Ansible is new enough:
#   "mysql" => { node: 10, box: "bento/ubuntu-26.04", memory: 2048, groups: ["mysql"] },
#   "postgresql" => { node: 11, box: "bento/ubuntu-26.04", memory: 2048, groups: ["postgresql"] },
LOCAL_ONLY = {
  # MySQL 8.0.46, the jammy package (AWS has 8.4 as of Aug 2026)
  "mysql" => { node: 10, box: "ubuntu/jammy64", memory: 2048, groups: ["mysql"] },
  # PostgreSQL 15 from the pgdg repo, matching AWS as of Aug 2026
  "postgresql" => { node: 11, box: "ubuntu/jammy64", memory: 2048, groups: ["postgresql"] },
  # Redis 6.0.16, (AWS has 6.2.6 as of Aug 2026)
  "redis" => { node: 13, box: "ubuntu/jammy64", memory: 1024, groups: ["redis"] }
}.freeze

# Extra hostsupdater aliases, keyed by full hostname. Purely a local browsing convenience, so
# they are not derived from Terraform. These are the names certificates/generate-certificates.sh
# issues dev certs for.
ALIASES = {
  "openaustralia.#{BASE_DOMAIN}" => STANDARD_ALIASES + %w[data software],
  "staging.righttoknow.#{BASE_DOMAIN}" => STANDARD_ALIASES,
  "prod.righttoknow.#{BASE_DOMAIN}" => STANDARD_ALIASES,
  "theyvoteforyou.#{BASE_DOMAIN}" => STANDARD_ALIASES
}.freeze

unless File.exist?(".venv/bin/ansible") && File.exist?("terraform.pem") && Dir.exist?("roles/external") && File.exist?(".make/vagrant-plugins")
  warn "WARNING: Run `make vagrant` first to install requirements."
end

# Hosts Terraform declares, translated for local use. bin/dev-hosts exits non-zero rather than
# emitting a partial list, so a failure here is a real one worth stopping for.
def terraform_hosts
  # Anchored on __dir__, not the cwd: vagrant walks up the tree to find this file, so it is
  # routinely run from a subdirectory.
  command = "#{File.expand_path('bin/dev-hosts', __dir__)} --tld=#{BASE_DOMAIN} " \
            "--ec2=#{LOCATION_GROUP} --max-memory=#{MAX_MEMORY}"
  output = `#{command}`
  raise "#{command} failed - see its output above" unless $CHILD_STATUS.success?

  JSON.parse(output)
end

# Full hostname => box, memory, node number and Ansible groups, for every host to define.
def all_hosts
  hosts = {}
  LOCAL_ONLY.each do |name, details|
    hosts["#{name}.#{BASE_DOMAIN}"] = details.merge(groups: details[:groups] + [LOCATION_GROUP])
  end

  # .10-.13 belong to LOCAL_ONLY above, so start clear of them. Nothing references these
  # addresses, unlike mysql_host and postgresql_host, so they may shift as hosts come and go.
  node = 20
  terraform_hosts.sort_by { |host| host["name"] }.each do |host|
    hostname = host["log_name"] || host["name"]
    hostname += ".#{BASE_DOMAIN}" unless hostname.end_with?(".#{BASE_DOMAIN}")
    hosts[hostname] = {
      node: node, box: host["vagrant_box"], memory: host["memory_mb"], groups: host["groups"]
    }
    node += 1
  end
  hosts
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Boxes come from bin/dev-hosts, which decodes the Ubuntu release from the name of each
  # instance's ami variable in terraform/. Support dates, for reference when a box looks old:
  # noble (24.04 LTS) to April 2029, jammy (22.04 LTS) to April 2027, focal (20.04 LTS) EOL
  # April 2025, bionic (18.04 LTS) EOL April 2023, xenial (16.04 LTS) EOL April 2021.
  hosts = all_hosts

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
    ansible.compatibility_mode = "2.0"
    ansible.playbook_command = ".venv/bin/ansible-playbook"

    # Uncomment the following line if you want some verbose output from ansible
    ansible.verbose = "vv"

    # Every box below is in development, in LOCATION_GROUP, and in whichever groups name what it
    # runs, so the merge order between those has to be pinned rather than left to Ansible's
    # fallback of sorting same-depth groups by name. Ansible combines group_vars in
    # `sorted(groups, key=lambda g: (g.depth, g.priority, g.name))` order, last one winning
    # (ansible/inventory/helpers.py), so the numbers below read low-to-high as least-to-most
    # specific:
    #
    #   -1  development             what every dev environment shares, whatever runs it
    #    0  vagrant, ec2            where the host lives - the location group
    #    1  metabase, righttoknow   service groups, at Ansible's default
    #
    # Names would give the wrong answer at every level: "vagrant" sorts after "development" only
    # by luck, and a future "devcontainer" or "cloud" location group sorts before it and would
    # quietly lose; "ec2" sorts before every service group but "vagrant" sorts after most of
    # them. Priority has to be set in the inventory, not group_vars, since it governs how
    # group_vars files merge - see the matching sections in inventory/ec2-hosts.
    ansible.groups = {
      "catch_all_mail" => [],

      # group_vars/development.yml - base_domain, devsite and the local test credentials.
      "development" => [],
      "development:vars" => { "ansible_group_priority" => -1 },

      # Empty list just so ansible doesn't complain it doesn't know about these cloud servers.
      # The priority has no effect while the group is empty, but it keeps the two inventories
      # agreeing on where a location group sits.
      "ec2" => [],
      "ec2:vars" => { "ansible_group_priority" => 0 },

      # group_vars/vagrant.yml - the VirtualBox private-network addresses of the boxes standing
      # in for RDS. Beats development, loses to the service groups.
      LOCATION_GROUP => [],
      "#{LOCATION_GROUP}:vars" => { "ansible_group_priority" => 0 }
    }
    hosts.each do |hostname, details|
      ansible.groups["development"] << hostname
      ansible.groups["catch_all_mail"] << hostname
      details[:groups]&.each do |group|
        ansible.groups[group] ||= []
        ansible.groups[group] << hostname
      end
    end
    tags = ENV["TAGS"].to_s.gsub(/[^A-Z0-9_]+/i, ",").split(",").reject { |s| s.to_s == "" }
    if tags.any?
      tags += ["facts"]
      puts "INFO: Only running TAGS: #{tags.inspect}"
      ansible.tags = tags if tags.any?
    end
  end

  config.vm.provider "virtualbox" do |v|
    # Per-host memory is set below; this is only the fallback and the CPU count.
    v.cpus = (ENV["VAGRANT_CPUS"] || 2).to_i
  end

  # Use this so that you don't need to give the machine name for all vagrant
  # commands. Set this to whatever you're most working on at the moment.
  primary_host = ENV.fetch("DEFAULT_VAGRANT_HOST", "staging.righttoknow.#{BASE_DOMAIN}")

  hosts.each do |hostname, details|
    config.vm.define hostname, primary: (hostname == primary_host) do |host|
      host.vm.box = details[:box]
      host.vm.network :private_network, ip: "#{IP_NETWORK}.#{details[:node]}"
      host.vm.hostname = hostname
      # Sized from the production instance_type, capped at MAX_MEMORY.
      host.vm.provider "virtualbox" do |v|
        v.memory = details[:memory]
      end
      # For each host set up some common aliases
      aliases = ALIASES[hostname]
      host.hostsupdater.aliases = aliases.map { |a| "#{a}.#{hostname}" } if aliases
    end
  end
end
