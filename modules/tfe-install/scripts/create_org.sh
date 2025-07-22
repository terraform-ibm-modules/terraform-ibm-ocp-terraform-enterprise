#!/bin/bash

# Exit on any error
set -e

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Usage: $0 <TOKEN> <ORG_NAME> <EMAIL> <TFE_HOSTNAME>"
    exit 1
fi

TOKEN=$1
ORG_NAME=$2
EMAIL=$3
TFE_HOSTNAME=$4

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
