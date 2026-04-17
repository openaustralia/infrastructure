# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

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

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
    ansible.compatibility_mode = "2.0"
    ansible.playbook_command = ".venv/bin/ansible-playbook"

    # Uncomment the following line if you want some verbose output from ansible
    ansible.verbose = "vv"

    ansible.groups = {
      "development" => [
        "web.metabase.oaf.org.au.test",
        "newprod.openaustralia.org.au.test",
        "oaf.org.au.test",
        "openaustralia.org.au.test",
        "web.planningalerts.org.au.test",

        "mysql.test",
        "postgresql.test",
        "au.proxy.oaf.org.au.test",
        "redis.test",

        "righttoknow.org.au.test",
        "theyvoteforyou.org.au.test"

      ],
      # Services required by the servers 192.168.56.1x
      "mysql" => ["mysql.test"],
      "postgresql" => ["postgresql.test"],
      "proxy" => ["au.proxy.oaf.org.au.test"],
      "redis" => ["redis.test"],

      # Servers 192.168.56.2x
      "metabase" => ["web.metabase.oaf.org.au.test"],
      "oaf" => ["oaf.org.au.test"],
      "openaustralia" => ["openaustralia.org.au.test", "newprod.openaustralia.org.au.test"],
      "openaustralia_old" => ["openaustralia.org.au.test"],
      "openaustralia_new" => ["newprod.openaustralia.org.au.test"],
      "planningalerts" => ["web.planningalerts.org.au.test"],
      "righttoknow" => ["righttoknow.org.au.test"],
      "righttoknow_production" => [],
      "righttoknow_staging" => ["righttoknow.org.au.test"],
      "theyvoteforyou" => ["theyvoteforyou.org.au.test"],

      # Requirements
      "requires_mysql" => ["newprod.openaustralia.org.au.test", "theyvoteforyou.org.au.test",
                           "web.metabase.oaf.org.au.test"],
      "requires_mysql_5" => ["openaustralia.org.au.test"],
      "requires_postgresql" => ["theyvoteforyou.org.au.test", "righttoknow.org.au.test",
                                "web.metabase.oaf.org.au.test", "web.planningalerts.org.au.test"],

      # Empty list just so ansible doesn't complain it doesn't know about these cloud servers
      "ec2" => [],

      # TODO: Consider adding hosts for these Server groups (that are used)
      "openvpn" => [],
      "plausible" => []
    }
    tags = ENV["TAGS"].to_s.gsub(/[^A-Z0-9_]+/i, ",").split(",").reject { |s| s.to_s == "" }
    if tags.any?
      puts "INFO: Only running TAGS: #{tags.inspect}"
      ansible.tags = tags if tags.any?
    end
    start_at_task = "*#{ENV.fetch('START_AT_TASK', nil)}*".gsub(/[^A-Z0-9_]+/i, "*")
    if start_at_task != "*"
      puts "INFO: Starting at task matching: #{start_at_task}"
      ansible.start_at_task = start_at_task
    end
  end

  config.vm.provider "virtualbox" do |v|
    # More cpus and crank up the memory for a faster build
    v.memory = 2048
    v.cpus = 2
  end

  hosts = {
    # Services required by the servers
    "mysql.test" => "192.168.56.10",
    "postgresql.test" => "192.168.56.11",
    "au.proxy.oaf.org.au.test" => "192.168.56.12",
    "redis.test" => "192.168.56.13",

    # Servers
    "web.metabase.oaf.org.au.test" => "192.168.56.20",
    "oaf.org.au.test" => "192.168.56.21",
    "openaustralia.org.au.test" => "192.168.56.22",
    "newprod.openaustralia.org.au.test" => "192.168.56.23",
    "web.planningalerts.org.au.test" => "192.168.56.24",
    "righttoknow.org.au.test" => "192.168.56.25",
    # so they can track production versions more accurately?
    "theyvoteforyou.org.au.test" => "192.168.56.26"
    # TODO: Do we want to seperate out the postgres for PA and everything else
  }

  # Use this so that you don't need to give the machine name for all vagrant
  # commands. Set this to whatever you're most working on at the moment.
  primary_host = "metabase.oaf.org.au.test"

  hosts.each do |hostname, ip|
    config.vm.define hostname, primary: (hostname == primary_host) do |host|
      host.vm.box = case hostname
                    # Only a few services so far are using a more recent version of Ubuntu
                    when "web.metabase.oaf.org.au.test", "redis.test", "web.planningalerts.org.au.test",
                         "postgresql.test", "newprod.openaustralia.org.au.test"
                      # jammy (22.04 LTS) "standard" support ends in April 2027
                      "ubuntu/jammy64"
                    when "theyvoteforyou.org.au.test"
                      # focal (20.04 LTS) "standard" support ends in April 2025
                      "ubuntu/focal64"
                    when "righttoknow.org.au.test", "oaf.org.au.test"
                      # bionic (18.04 LTS) "standard" support ends in April 2023
                      "ubuntu/bionic64"
                    when "openaustralia.org.au.test",
                        "au.proxy.oaf.org.au.test", "mysql.test"
                      # xenial (16.04 LTS) "standard" support ended in April 2021!
                      "ubuntu/xenial64"
                    else
                      raise "Couldn't figure out version of ubuntu for #{hostname}"
                    end
      host.vm.network :private_network, ip: ip
      host.vm.hostname = hostname
      # For each host set up some common aliases
      host.hostsupdater.aliases = [
        "test.#{hostname}",
        "www.#{hostname}",
        "www.test.#{hostname}",
        "api.#{hostname}"
      ]
    end
  end
end
