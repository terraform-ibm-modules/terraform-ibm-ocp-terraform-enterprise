#!/bin/bash
set -e
sed -i 's/server_names_hash_bucket_size 128;/server_names_hash_bucket_size 256;/' /etc/nginx/nginx.conf.tmpl
/usr/local/bin/supervisord-run
set +e
