# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

BASE_DOMAIN = "test"
IP_NETWORK = "192.168.56"
STANDARD_ALIASES = %w[www test www.test]

unless File.exist?(".venv/bin/ansible") && Dir.exist?(".keybase") && Dir.exist?("roles/external") && File.exist?(".make/vagrant-plugins")
  warn "WARNING: Run `make vagrant` first to install requirements."
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

  # noble (24.04 LTS) "standard" support ends in April 2029 (Yet to be used)
  # jammy (22.04 LTS) "standard" support ends in April 2027
  # focal (20.04 LTS) "standard" support ends in April 2025 EOL!
  # bionic (18.04 LTS) "standard" support ends in April 2023 EOL!
  # xenial (16.04 LTS) "standard" support ended in April 2021 EOL!
  hosts = {
    # Services required by the servers
    "mysql" => { node: 10,
                 box: "ubuntu/xenial64",
                 groups: ["mysql"] },
    # TODO: Do we want to seperate out the postgres for PA and everything else
    "postgresql" => { node: 11,
                      box: "ubuntu/jammy64",
                      groups: ["postgresql"] },
    "au.proxy" => { node: 12,
                        box: "ubuntu/xenial64",
                        groups: ["proxy"] },
    "redis" => { node: 13,
                 box: "ubuntu/jammy64",
                 groups: ["redis"] },

    # Servers
    "web.metabase.oaf" => { node: 20,
                            box: "ubuntu/jammy64",
                            groups: ["metabase", "requires_postgresql"] },
    "oaf" => { node: 21,
               box: "ubuntu/bionic64",
               groups: ["oaf"] },
    "openaustralia" => { node: 22,
                         box: "ubuntu/xenial64",
                         aliases: STANDARD_ALIASES + ["data", "software"],
                         groups: ["openaustralia", "openaustralia_old", "requires_mysql_5"] },
    "newprod.openaustralia" => { node: 23,
                                 box: "ubuntu/jammy64",
                                 groups: ["openaustralia", "openaustralia_new", "requires_mysql"] },
    "web.planningalerts" => { node: 24,
                              box: "ubuntu/jammy64",
                              groups: ["planningalerts", "requires_postgresql"] },
    "staging.righttoknow" => { node: 25,
                               box: "ubuntu/bionic64",
                               aliases: STANDARD_ALIASES,
                               groups: ["righttoknow", "righttoknow_staging", "requires_postgresql"] },
    "prod.righttoknow" => { node: 25,
                            box: "ubuntu/bionic64",
                            aliases: STANDARD_ALIASES,
                            groups: ["righttoknow", "righttoknow_production", "requires_postgresql"] },
    "theyvoteforyou" => { node: 26,
                          box: "ubuntu/focal64",
                          aliases: STANDARD_ALIASES,
                          groups: ["theyvoteforyou", "requires_mysql"] },
    # FIXME: Has not been constructed, and is not in any (extra) group
    # "vpn.oaf" => { node: 27,
    #                       box: "ubuntu/jammy64",
    #                       groups: [] },

    "openvpn" => { node: 28,
                   box: "ubuntu/jammy64",
                   groups: ["openvpn"] },

  }

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
    ansible.compatibility_mode = "2.0"
    ansible.playbook_command = ".venv/bin/ansible-playbook"

    # Uncomment the following line if you want some verbose output from ansible
    ansible.verbose = "vv"

    ansible.groups = {
      "development" => [ ],

      # Empty list just so ansible doesn't complain it doesn't know about these cloud servers
      "ec2" => [],

      # TODO: Consider adding hosts for these Server groups (that are used)
      "openvpn" => [],
      "plausible" => []
    }
    hosts.each do |hostname, details|
      hostname = "#{hostname}.#{BASE_DOMAIN}"
      ansible.groups["development"] << hostname
      details[:groups]&.each do |group|
        ansible.groups[group] ||= []
        ansible.groups[group] << hostname
      end
    end
    tags = ENV["TAGS"].to_s.gsub(/[^A-Z0-9_]+/i, ",").split(",").reject { |s| s.to_s == "" }
    if tags.any?
      tags = tags + ["facts"]
      puts "INFO: Only running TAGS: #{tags.inspect}"
      ansible.tags = tags if tags.any?
    end
  end

  config.vm.provider "virtualbox" do |v|
    # More cpus and crank up the memory for a faster build
    v.memory = (ENV['VAGRANT_MEMORY'] || 2048).to_i
    v.cpus   = (ENV['VAGRANT_CPUS']   || 2).to_i
  end

  # Use this so that you don't need to give the machine name for all vagrant
  # commands. Set this to whatever you're most working on at the moment.
  primary_host = ENV.fetch("DEFAULT_VAGRANT_HOST", "metabase.oaf.#{BASE_DOMAIN}")

  hosts.each do |hostname, details|
    hostname = "#{hostname}.#{BASE_DOMAIN}"
    config.vm.define hostname, primary: (hostname == primary_host) do |host|
      host.vm.box = details[:box]
      host.vm.network :private_network, ip: "#{IP_NETWORK}.#{details[:node]}"
      host.vm.hostname = hostname
      # For each host set up some common aliases
      host.hostsupdater.aliases = details[:aliases].map { |a| "#{a}.#{hostname}" } if details[:aliases]
    end
  end
end
