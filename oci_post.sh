#!/bin/bash
# Copyright 2022 Gleb Otochkin
###############################################################################
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# 
###############################################################################
# shell script to get list of OCI compute instances in a compartment
# The script requires the compartment id
###############################################################################
# the ~/.oci/config used to retrieve the required authentication values
# the path to the private key is defined in the same ~/.oci/config
#
# Tenancy OCID
tenancy_ocid=`tail -6 ~/.oci/config | grep tenancy | awk -F"=" '{ print $2 }'`

# OCID of the user making the rest call
user_ocid=`tail -6 ~/.oci/config | grep user | awk -F"=" '{ print $2 }'`

# Path to the private PEM format key for this user
privateKeyPath=`tail -6 ~/.oci/config | grep key_file | awk -F"=" '{ print $2 }'| sed "s#~#${HOME}#"`

# Fingerprint of the private key for this user
fingerprint=`tail -6 ~/.oci/config | grep fingerprint | awk -F"=" '{ print $2 }'`

# Compartment id (taken from the oci cli config)
compatment_id=`tail -8 ~/.oci/oci_cli_rc | grep compartment-id | awk -F"=" '{print $2}'`

# The REST api to call with the POST update
rest_api="/20160918/instances"

# The API endpoint hostname
host="iaas.ca-toronto-1.oraclecloud.com"

# Input data 
read -p 'Instance display name:' displayName
read -p 'SSH public key:' sshPubKey
read -p 'VCN subnet id:' subnetId

# Generate temporary file
cp post_body_tmpl.json post_body.json
sed -i -e "s|###compartmentId###|${compatment_id}|" post_body.json
sed -i -e "s|###displayName###|${displayName}|" post_body.json
sed -i -e "s|###sshPubKey###|${sshPubKey}|" post_body.json
sed -i -e "s|###subnetId###|${subnetId}|" post_body.json

# The json body from a file
body="./post_body.json"
# The json body directly from the string
#body="{\"compartmentId\": \"$COMPARTMENT_ID\", \"name\": \"$USER_NAME\", \"description\": \"$USER_DESCRIPTION\"}"
####################################################################################
# Body argument for file 
body_arg=(--data-binary @${body})
# Body argument for inline json
#body_arg=(--request-body "${body}")

# Forming headers
# Content 
content_sha256="$(openssl dgst -binary -sha256 < $body | openssl enc -e -base64)";
# Content header
content_sha256_header="x-content-sha256: $content_sha256"
# Content length
content_length="$(wc -c < $body | xargs)";
# Content length header
content_length_header="content-length: $content_length"

# The date header
date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"
request_target="(request-target): post $rest_api"
# The order in the signing_string matches the order in the headers
signing_string="$request_target\n$date_header\n$host_header"
headers="(request-target) date host"

# Post related headers
headers=$headers" x-content-sha256 content-type content-length"
content_type_header="content-type: application/json";
# for POST request include additional items
signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"

echo "====================================================================================================="
printf '%b' "signing string is $signing_string \n"
signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`
printf '%b' "Signed Request is  \n$signature\n"

echo "====================================================================================================="
set -x
curl -X POST --data-binary @post_body.json -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"" 
# Delete the temporary file
rm -rf post_body.json
