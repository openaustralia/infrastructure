#!/bin/bash
# {{ ansible_managed }}
#
# Dump all postal databases (postal itself plus the per-mail-server
# postal-* message databases) so restic can ship them offsite. Restoring
# this dump plus /opt/postal/config is a full recovery of the postal
# installation, including organisations, servers, credentials and DKIM keys.

set -e
set -o pipefail

# postal itself plus the per-mail-server postal-* message databases (scoped
# rather than --all-databases so the dump excludes the non-transactional mysql
# system tables that --single-transaction can't snapshot consistently)
databases=$(mysql --batch --skip-column-names -e "SHOW DATABASES LIKE 'postal%'")

# shellcheck disable=SC2086  # word-splitting is intended: one arg per database
mysqldump --single-transaction --databases $databases | gzip > /opt/postal/backup/postal.sql.gz.tmp
mv /opt/postal/backup/postal.sql.gz.tmp /opt/postal/backup/postal.sql.gz
