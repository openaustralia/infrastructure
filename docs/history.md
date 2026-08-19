**Table of Contents**

# History

<!-- vscode-markdown-toc -->
- [History](#history)
  - [A little history](#alittlehistory)
  - [Approach](#approach)
  - [Updates](#updates)
    - [2025-05-27](#2025-05-27)
      - [Supported Platforms](#supportedplatforms)
      - [RightToKnow Dev platform](#righttoknowdevplatform)
      - [PlanningAlerts Production](#planningalertsproduction)
    - [2018-05-26](#2018-05-26)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='alittlehistory'></a>A little history

When OpenAustralia Foundation started, it just ran openaustralia.org and a
blog site. Hosting was kindly sponsored by Andrew Snow from Octopus
computing who donated a virtual machine (VM) for us to use. That server
was called kedumba.

Over the years things grew organically. We created more projects all of which
we hosted from the single VM which we maintained by hand. Andrew kept making
the VM bigger and bigger with more and more disk space.

We ended up rebuilding the server twice over the course of 7 years in order to
upgrade the operating system and modernise some of the surrounding tools.
Each time it was a mammoth exercise.

Also, as more and more services were added to this one server the dependencies
became harder to manage.

So, in 2015, prior to the last major server rebuild we started working on an
automated server setup and configuration using Ansible that you see here
in this repository. We also took the
opportunity to split the different sites into different VM configurations.
However, unfortunately this work was abandoned due to a lack of time and
we ended up (from memory) rebuilding the server once again by hand as a giant
monolithic server.

In the years since then, things have become a little more complicated. We had
a second small VM running on Octopus which runs oaf.org.au, CiviCRM, and
elasticsearch. All of these had to run on a separate VM because they required
a more recent version of the operating system.

We also created two projects that we hosted outside of Octopus, on Linode:
cuttlefish.oaf.org.au and morph.io. morph.io needed docker which couldn't run
easily on kedumba. cuttlefish is a transactional email server that we
opened up for use by the civic tech community. We didn't want to risk cuttlefish
undermining the email reputation of kedumba. So, we hosted it elsewhere.

Fast forward to early 2018. After many years of support Andrew Snow decided
to close Octopus computing. We had a couple of months to find a new hosting
provider, migrate all our services, and shut down everything on Octopus.

So, we picked up the work that we started in 2015 with, at a high level,
a very similar approach.

## <a name='approach'></a>Approach

- Split services into separate VMs - make each service easier to maintain on its
  own.
- Make it easy for different servers / services to be maintained by different
  people.
- Centralise the databases - a central database is easier to backup, easier
  to scale, and easier to manage.
- Use AWS but don't lock ourselves in. Make the architecture transferrable to
  any hosting provider.
- Spend a bit more money on hosting if it means less maintenance.

## <a name='updates'></a>Updates

### <a name=''></a>2025-05-27

_Umm. 7 years later, plus one day. That's weird._

#### <a name='supportedplatforms'></a>Supported Platforms

In the past, the tools in this repo were well supported across most common Linux platforms (including WSL), and OS X. However, newer versions of OSX only run on ARM chips, and older versions of OS X are increasingly unsupported by tools such as VirtualBox and Docker.

As of today, the only platform that we know works is debian-based Linux systems. Other linuxes probably work, including WSL; and there are probably two releases of MacOS which still run on the last generations of Intel Macs which might work.

We'd like to expand this in future, when we have time

#### <a name='righttoknowdevplatform'></a>RightToKnow Dev platform

We've moved RTK on to upstream Alavateli, so the instructions below for a dev environment are out of date. Please refer to [openaustralia/righttoknow](https://github.com/openaustralia/righttoknow?tab=readme-ov-file#development)'s README for instructions.

#### <a name='planningalertsproduction'></a>PlanningAlerts Production

We now have two production servers. Every day deployment is still run by Capistrano. For major upgrades (e.g., updating the Ruby version), we have the option of a blue/green deployment driven by Terraform, allowing us to update without downtime.

### <a name='-1'></a>2018-05-26

This repo is being used to setup and configure servers on EC2 for:

- planningalerts.org.au:
  - planningalerts.org.au
  - test.planningalerts.org.au
  - A cron job that uploads planningalerts data for a commercial client
- theyvoteforyou.org.au:
  - theyvoteforyou.org.au
  - test.theyvoteforyou.org.au
- openaustralia.org.au:
  - openaustralia.org.au
  - test.openaustralia.org.au
  - data.openaustralia.org.au
  - software.openaustralia.org.au
- righttoknow.org.au:
  - righttoknow.org.au
  - test.righttoknow.org.au
- openaustraliafoundation.org.au:
  - openaustraliafoundation.org.au
  - CiviCRM
- opengovernment.org.au (decommissioned)

On Linode running as separate VMs with automated server configuration:

- cuttlefish.oaf.org.au - automated server configuration using Ansible at
  <https://github.com/mlandauer/cuttlefish/tree/master/provisioning>
- morph.io - automated server configuration using Ansible at
  <https://github.com/openaustralia/morph/tree/master/provisioning>

If it makes sense we might move cuttlefish and morph.io to AWS as well.
