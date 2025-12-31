#!/bin/bash


# cat /srv/www/staging/current/config/database.yml
pass=$(./scripts/get_rds_pass.sh)
mysql --host=127.0.0.1 --port=3306 --user=admin --password="${pass}"