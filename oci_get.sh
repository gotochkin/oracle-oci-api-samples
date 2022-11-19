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
compartment_id=`tail -8 ~/.oci/oci_cli_rc | grep compartment-id | awk -F"=" '{print $2}'`

# The REST api you want to call, compartment id is a required parameter
rest_api="/20160918/instances?compartmentId=${compartment_id}"
# Filtered by displayName of an instance
#rest_api="/20160918/instances?compartmentId=${compartment_id}&displayName=vm-name"

# The API endpoint hostname
host="iaas.ca-toronto-1.oraclecloud.com"

# Forming headers
date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"
request_target="(request-target): get $rest_api"
# The order in the signing_string matches the order in the headers
signing_string="$request_target\n$date_header\n$host_header"
headers="(request-target) date host"

echo "====================================================================================================="
printf '%b' "signing string is $signing_string \n"
signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`
printf '%b' "Signed Request is  \n$signature\n"

echo "====================================================================================================="
set -x
#curl -v -X GET -sS https://$host$rest_api -H "date: $date" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"" 
curl -X GET -sS https://$host$rest_api -H "date: $date" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"" | python -m json.tool