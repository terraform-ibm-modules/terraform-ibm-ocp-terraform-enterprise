#!/bin/bash
set -e
sed -i '/^[ ]\{2\}pool:/a\ \ schema_search_path: "public,ibm_extension"' /app/config/database.yml
sed -i 's/server_names_hash_bucket_size 128;/server_names_hash_bucket_size 256;/' /etc/nginx/nginx.conf.tmpl
/usr/local/bin/supervisord-run
set +e
