#!/usr/bin/env sh

export PATH=/usr/local/bin:/usr/bin
bin/rails action_mailbox:ingress:postfix URL=https://www.planningalerts.org.au/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD={{ ingress_password }} RAILS_ENV=production
