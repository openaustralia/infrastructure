SERVER NAMES
============

_The purpose of this document is to provide a pragmatically useful naming scheme to make maintaining infrastructure
simple and consistent, and avoid bike shedding._

* Based on [RFC1178](http://www.faqs.org/rfcs/rfc1178.html), Servers are given a name that is
    * persistent and unique to each server, in addition:
    * Easy to spell, type, and remember the name of the server (no "cute" misspelling)
    * Reminds you of the server's unchanging reason for being, but not state that changes.
    * Is easy to find in a list of servers, ie distinct from other names.
* Don't include new/old etc. as the use of the server will change
* Typically, the server name will be used for the DNS name used for direct ssh access, but NOT the web host name, so not
  www, staging, etc.

# Server Naming Suggestions

| Ubuntu version | OA                 | OAF                      | Vote                    | Know                  | PA                 |
|----------------|--------------------|--------------------------|-------------------------|-----------------------|--------------------|
| 24.04 (N)      | Nile, Naryn, Noah  | Nickel, Napak, Natty     | Nehru, Numa, Nifty      | Newton, Nash, Nimble  | Nara, Nadi, Nome   |
| 26.04 (R)      | Rhine, Ravi, Rio   | Rhenium, Ruby, Rakish    | Roosevelt, Roma, Racy   | Rubin, Remi, Rowdy    | Ruse, Rangi, Ribe  |
| 28.04 (V)      | Volga, Vaal, Venta | Vanadium, Vespa, Valiant | Voltaire, Vesta, Vivid  | Volta, Venn, Vesalius | Vaduz, Varna, Vibo |
| 30.04 (Z)      | Zeya, Zola, Zenta  | Zircon, Zinc, Zesty      | Zapata, Zenobia, Zany   | Zinn, Zsiga, Zippy    | Zug, Zeist, Zadar  |
| 32.04 (D)      | Danube, Deva, Doon | Diorite, Dunite, Dapper  | Douglass, Danton, Droll | Darwin, Dirac, Deft   | Dili, Drin, Dabo   |

### Existing servers as of April 2026

* Update the existing openaustralia server to be named "olaf" and have DNS olaf.openaustralia.org.au point to it (name
  chosen to be similar to "old" and "oa")
* Update the new openaustralia server to be called "noah" and have DNS noah.openaustralia.org.au point to it (name
  chosen to be similar to "new" and "oa")

## Themes

* Use a name that starts with the same letter as the ubuntu LTS version installed, eg 24.04 is Noble, so names that
  start with "n".
* Keep to 2, max 3 syllables.
* Where theme names are weak, infrequently used adjectives (eg Dapper, Rakish, Zesty) are used as fallback.

| App  | Theme                                                        |
|------|--------------------------------------------------------------|
| OA   | Rivers & oceans                                              |
| OAF  | Rocks, mountains & elements (foundation)                     |
| Vote | Historical/fictional political figures & places of democracy |
| Know | Scientists, real and fictional                               |
| PA   | Short, unusual place names                                   |

## Hostname

When someone ssh's into a server, they should be prompted with the server name, eg "Noah" or "Nara1" so it is an obvious
reminder of what server they are on.

DOMAIN NAMES
============

Domain names are based on the purpose.

* The domain name to ssh into the server is the same as the server name.
* The domain name to access the website is related to the purpose, eg:
    * www - production environment on the live server
    * staging - staging environment on the live server
    * newprod - production environment on the new server
    * newstage - staging environment on the new server
* No domain name for a server is a subdomain of other servers names to avoid issues with web cookies

Where there are multiple servers, they should have a number from 1 onward appended and respond to their numbered name
as well (assists with diagnostics).

IMPLICATIONS ON REPLACING SERVERS
================================= 

Using openaustralia as an example.

## Existing "live" server

So olaf.openaustralia.org.au DNS points directly to the live server (we currently call it the old server, but old will
become a state, not a server name)

Apache Virtual hosts:

* production accepts requests for
    * www.openaustralia.org.au
* staging accepts requests for
    * staging.openaustralia.org.au

## "new" (release candidate) server

For example, called noah.openaustralia.org.au points directly to the new server without DNS proxying.

Apache virtual hosts:

* production accepts requests for
    * newprod.openaustralia.org.au (accessible)
    * www.openaustralia.org.au (ready to go, but not accessible yet)
* staging accepts requests for
    * newstage.openaustralia.org.au (accessible)
    * staging.openaustralia.org.au (ready to go, but not accessible yet)

## Upgrading Server

**Preparation**

1. Add olaf to the "old" group in the infrastructure inventory list
2. Update DNS oldprod and oldstage to point to olaf (existing live) server
3. Update olaf vhosts to accept "oldprod" and "oldstage" as valid web hosts names
4. Trigger update of SSL certs to include oldprod and oldstage (The order of these last 2 steps depends on the specific
   mechanism)

**Actual Cut-over**

1. put live (olaf) and new (noah) into "Maintenance / read only? mode" (OUTSTANDING DECISION)
2. Disable cron jobs that send emails or update data on the noah and olaf servers
3. start a final data sync
4. Remove olaf from the "live" group in the infrastructure inventory list
5. Add noah to the "live" group in the infrastructure inventory list and remove it from "new"
6. Update live DNS (www and staging) to point to the new server
7. Update noah to send email to cuttlefish (should be safe with no email being generated)
8. Update olaf to send email to mailcatcher (should be safe with no email being generated)
9. check that the final data sync has completed and the old and new servers show the same data
10. take noah out of "Maintenance / read-only?" mode (Leaving olaf in maintenance mode, so any delay in DNS propagation
    is not an issue)
11. Reenable cronjobs on noah, manually running any missed overnight sync that was not run on olaf
    TODO later: change overnight jobs to a "catchup / ensure" style rather than "yesterday"

Note: the old server's web servers will still be accessible via oldprod.openaustralia.org.au and
oldstage.openaustralia.org.au

**Cleanup**

1. Wait between 3 days and a week (Decide at the time)
2. decommission olaf (oldprod.openaustralia.org.au) and remove oldprod/oldstage from DNS

### Capistrano deployment

capistrano deployment will have 4 targets: production, staging (live server) and newprod and newstage (new server).

OUTSTANDING DECISION – EITHER:

1. live.openaustralia.org.au and new.openaustralia.org.au DNS entries to be maintained as part of the process above (NOT
   server names), or
2. the `config/deploy/*.rb` files updated as we move through the list of names (currently olaf and noah).

CLOUDFLARE CDN IN THE FUTURE
============================

When we move across to cloudflare CDN, I suggest each server gets additional DNS entries with "-prod" and "-stage"
appended to their server names, which is what cloudflare will know them as (they need two names as cloudflare has to
distinguish production from staging environment).

We could choose to start doing this now, as names that will always work irrespective of if the server is being used for
new, live, or old purposes. 
