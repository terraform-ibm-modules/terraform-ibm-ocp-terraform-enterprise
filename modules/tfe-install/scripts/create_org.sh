#!/bin/bash

# Exit on any error
set -e

# using logfile to debug script locally
LOGFILE="/tmp/tfe_create_org.log"
echo "Starting create_org script at $(date)..." >> $LOGFILE

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Usage: $0 <TOKEN> <ORG_NAME> <EMAIL> <TFE_HOSTNAME>"
    exit 1
fi

TOKEN=$1
ORG_NAME=$2
EMAIL=$3
TFE_HOSTNAME=$4

if [[ ${TOKEN} == "-1" ]]; then
    echo "Input token set to ${TOKEN} which usually happens when the admin user is already created and the org hasn't to be created. Exiting successfully" >> ${LOGFILE}
    echo "Input token set to ${TOKEN} which usually happens when the admin user is already created and the org hasn't to be created. Exiting successfully"
    exit 0
fi

echo "Input ORG_NAME ${ORG_NAME} EMAIL ${EMAIL} ${TFE_HOSTNAME}" >> ${LOGFILE}
echo "Input token first 3 chars: $(printf %s "${TOKEN:0:3}")" >> ${LOGFILE}
# Create the payload
PAYLOAD=$(cat <<EOF
{
  "data": {
    "type": "organizations",
    "attributes": {
      "name": "$ORG_NAME",
      "email": "$EMAIL"
    }
  }
}
EOF
)

# Make the API call
response=$(curl \
--header "Authorization: Bearer $TOKEN" \
--header "Content-Type: application/vnd.api+json" \
--request POST \
--data "$PAYLOAD" \
"https://$TFE_HOSTNAME/api/v2/organizations")

# Check the response for success
if [[ $response =~ "created-at" ]]; then
    echo "Organization '$ORG_NAME' created successfully."
else
    echo "Failed to create organization. Response: $response"
    exit 1
fi
