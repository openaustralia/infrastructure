**Table of Contents**

# PlanningAlerts

<!-- vscode-markdown-toc -->
- [PlanningAlerts](#planningalerts)
  - [Deploying PlanningAlerts](#deploying-planningalerts)
    - [Deploying PlanningAlerts to your local development server](#deploying-planningalerts-to-your-local-development-server)
    - [Deploying PlanningAlerts to production](#deploying-planningalerts-to-production)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

### <a name='DeployingPlanningAlerts'></a>Deploying PlanningAlerts

After provisioning, deploy from the [PlanningAlerts repository](https://github.com/openaustralia/planningalerts-app/).

#### <a name='DeployingPlanningAlertstoyourlocaldevelopmentserver'></a>Deploying PlanningAlerts to your local development server

The first time run:

```
bundle exec cap development deploy:setup deploy:cold foreman:start
```

Thereafter:

```
bundle exec cap development deploy
```

#### <a name='DeployingPlanningAlertstoproduction'></a>Deploying PlanningAlerts to production

We now have two productions servers, and a blue/green deployment process driven
out of Terraform. We use this only for major updates, when we're being cautious
and want to ensure no downtime. For smaller changes, just use capistrano as usual.

AMI images for the servers are built with Packer - look in the `packer/`
subdirectory for more details on how to build.

Once you have a new image, you'll need to adjust the `_ami_name` variables in
`terraform/main.tf` to update the not-currently-used cluster; then tweak
values in the blue/green modules in `terraform/planningalerts/main.tf` to
adjust where traffic is going. Don't forget that you'll need to
`terraform apply` at each stage of the change.

```
bundle exec cap production deploy
```
