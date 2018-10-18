# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "ubuntu/trusty64"
  config.vm.box = "ubuntu/xenial64"

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

    # Uncomment the following line if you want some verbose output from ansible
    #ansible.verbose = "vv"

    ansible.groups = {
      "righttoknow"      => ["righttoknow.org.au.test"],
      "planningalerts"   => ["planningalerts.org.au.test"],
      "electionleaflets" => ["electionleaflets.org.au.test"],
      "theyvoteforyou"   => ["theyvoteforyou.org.au.test"],
      "oaf"              => ["oaf.org.au.test"],
      "openaustralia"    => ["openaustralia.org.au.test"],
      "mysql"            => ["mysql.test"],
      "postgresql"       => ["postgresql.test"],
      "opengovernment"   => ["opengovernment.org.au.test"],
      "development"      => [
        "righttoknow.org.au.test",
        "planningalerts.org.au.test",
        "electionleaflets.org.au.test",
        "theyvoteforyou.org.au.test",
        "oaf.org.au.test",
        "openaustralia.org.au.test",
        "mysql.dev",
        "postgresql.test",
        "opengovernment.org.au.test"
      ]
    }
  end

  config.vm.provider "virtualbox" do |v|
    # More cpus and crank up the memory for a faster build
    v.memory = 2048
    v.cpus = 2
  end

  hosts = {
    "righttoknow.org.au.test"      => "192.168.10.10",
    "planningalerts.org.au.test"   => "192.168.10.11",
    "electionleaflets.org.au.test" => "192.168.10.12",
    "theyvoteforyou.org.au.test"   => "192.168.10.14",
    "oaf.org.au.test"              => "192.168.10.15",
    "openaustralia.org.au.test"    => "192.168.10.16",
    "mysql.test"                   => "192.168.10.17",
    "postgresql.test"              => "192.168.10.18",
    "opengovernment.org.au.test"  => "192.168.10.19"
  }

  # Use this so that you don't need to give the machine name for all vagrant
  # commands. Set this to whatever you're most working on at the moment.
  primary_host = "openaustralia.org.au.test"

  hosts.each do |hostname, ip|
    config.vm.define hostname, primary: (hostname == primary_host) do |host|
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
