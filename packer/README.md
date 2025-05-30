# How to build the "golden" image for the PlanningAlerts service

First [install packer](https://developer.hashicorp.com/packer/install) then:

```shell
cd packer
packer init .
packer build planningalerts.pkr.hcl
```