#!/bin/bash

# Exit on any error
set -e

TFE_HOSTNAME=$1
IACT_TOKEN=$2
USERNAME=$3
EMAIL=$4
PASSWORD=$5

# using logfile to debug script locally
LOGFILE="/tmp/tfe_create_admin_user.log"
echo "Starting admin user creation script at $(date)..." >> $LOGFILE

# Create JSON payload
PAYLOAD=$(cat <<EOF
{
  "username": "$USERNAME",
  "email": "$EMAIL",
  "password": "$PASSWORD"
}
EOF
)

echo "PAYLOAD $PAYLOAD" >> $LOGFILE
MAX_RETRIES=30
RETRY_INTERVAL=20
ATTEMPT=1

echo "curl -s \
    --header "Content-Type: application/json" \
    --request POST \
    --data \"$PAYLOAD\" \
    \"https://${TFE_HOSTNAME}/admin/initial-admin-user?token=${IACT_TOKEN}\"" >> $LOGFILE

while [ $ATTEMPT -le $MAX_RETRIES ]; do
  RESPONSE=$(curl -s \
    --header "Content-Type: application/json" \
    --request POST \
    --data "$PAYLOAD" \
    "https://${TFE_HOSTNAME}/admin/initial-admin-user?token=${IACT_TOKEN}")

  echo "RESPONSE $RESPONSE" >> $LOGFILE
  STATUS=$(echo "$RESPONSE" | grep -o '"status": *"[^"]*"' | cut -d'"' -f4)
  ERROR=$(echo "$RESPONSE" | grep -o '"error": *"[^"]*"' | cut -d'"' -f4)
  TOKEN=$(echo "$RESPONSE" | grep -o '"token": *"[^"]*"' | cut -d'"' -f4)

  if [ "$STATUS" == "created" ] && [ -n "$TOKEN" ]; then
    echo "Successfully created admin user." >> $LOGFILE
    >&2 echo "Successfully created admin user."
    echo "{\"token\": \"$TOKEN\"}"
    exit 0
  elif [ "$STATUS" == "error" ] && [ "$ERROR" == "admin user creation not allowed" ]; then
    echo "Attempt $ATTEMPT: server response: $ERROR. This is expected if the admin user already exists. Exiting successfully." >> $LOGFILE
    >&2 echo "Attempt $ATTEMPT: server response: $ERROR. This is expected if the admin user already exists. Exiting successfully."
    echo "{\"token\": \"\"}"
    exit 0
  else
    echo "Attempt $ATTEMPT: Unexpected response: $RESPONSE" >> $LOGFILE
    >&2 echo "Attempt $ATTEMPT: Unexpected response: $RESPONSE"
  fi

  sleep $RETRY_INTERVAL
  ATTEMPT=$((ATTEMPT + 1))
done
# If we reach here, it failed
echo '{"error": "Failed to create admin user after 30 attempts."}'
exit 1
