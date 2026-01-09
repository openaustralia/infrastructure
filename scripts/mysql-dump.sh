#!/bin/bash


if [ -z "$1" ]; then
    echo "Usage: $0 <database_name>"
    exit 1
fi

mkdir -p db_dumps

# set -euv
# cat /srv/www/staging/current/config/database.yml
output="${1}_dump_$(date +%F).sql"
pass=$(./scripts/get_rds_pass.sh)

echo "Dumping database '$1' to 'db_dumps/$output'..."
mysqldump "$1" --host=127.0.0.1 --port=3306 --user=admin --password="${pass}" \
    > "db_dumps/$output"

cd db_dumps
gzip "$output"

echo "Database dump completed: db_dumps/$output.gz"