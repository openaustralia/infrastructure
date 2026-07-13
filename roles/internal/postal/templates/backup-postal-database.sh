#!/bin/bash
# {{ ansible_managed }}
#
# Dump all postal databases (postal itself plus the per-mail-server
# postal-* message databases) so restic can ship them offsite. Restoring
# this dump plus /opt/postal/config is a full recovery of the postal
# installation, including organisations, servers, credentials and DKIM keys.

set -e
set -o pipefail

mysqldump --all-databases --single-transaction | gzip > /opt/postal/backup/postal.sql.gz.tmp
mv /opt/postal/backup/postal.sql.gz.tmp /opt/postal/backup/postal.sql.gz
