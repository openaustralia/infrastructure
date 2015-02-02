# Ansible configuration management for all of OpenAustralia Foundation's servers

** THIS IS A WORK IN PROGRESS **

We currently use four servers with the following websites running on each server:

1. Linode server 1 - Just running cuttlefish.oaf.org.au
2. Linode server 2 - Just running morph.io
3. Octopus Computing (kedumba) - The main server running openaustralia.org.au, planningalerts.org.au, electionleaflets.org.au, righttoknow.org.au, and proxying openaustraliafoundation.org.au
4. Octopus Computing (jamison) - Just runs openaustraliafoundation.org.au with CiviCRM

We need to do an OS upgrade on kedumba. We are taking the oppurtunity to do a long needed rethink of our server setup.

Our current plan is to separate the different sites currently running on kedumba into separate servers with our entire setup being managed by Ansible.
