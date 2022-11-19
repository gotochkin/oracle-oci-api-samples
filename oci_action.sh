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
# shell script to execute an action on an OCI compute instance
# actions in the sample are limited to "START" "STOP" "RESET"
# The script requires the instance ocid and the action
###############################################################################
# the ~/.oci/config used to retrieve the required authentication values
# the path to the private key is defined in the same ~/.oci/config
#
# Tenancy OCID
tenancy_ocid=`tail -6 ~/.oci/config | grep tenancy | awk -F"=" '{ print $2 }'`

# OCID of the user making the rest call
user_ocid=`tail -6 ~/.oci/config | grep user | awk -F"=" '{ print $2 }'`

# path to the private PEM format key for this user
privateKeyPath=`tail -6 ~/.oci/config | grep key_file | awk -F"=" '{ print $2 }'| sed "s#~#${HOME}#"`

# fingerprint of the private key for this user
fingerprint=`tail -6 ~/.oci/config | grep fingerprint | awk -F"=" '{ print $2 }'`
#compartment_id=`tail -8 ~/.oci/oci_cli_rc | grep compartment-id | awk -F"=" '{print $2}'`

# Applied to the instance with the ID, instance id is a required parameter
read -p 'Instance ocid:' instanceId

if [[ $instanceId == "" ]]; then
    echo "Instance ocid cannot be null exiting"
    exit 1
fi

# select action 
PS3="Select action please: "
actions=("START" "STOP" "RESET")
select action in "${actions[@]}" Quit
do 
    case $REPLY in
        1) echo "Selected action is $action"; break;;
        2) echo "Selected action is $action"; break;;
        3) echo "Selected action is $action"; break;;
        $((${#iteactionsms[@]}+1))) echo "We're done!"; break 2;;
        *) echo "Ooops - unknown choice $REPLY"; break;
    esac
done

# The REST api you want to call, with any required paramters.
rest_api="/20160918/instances/${instanceId}?action=${action}"

# The API endpoint hostname
host="iaas.ca-toronto-1.oraclecloud.com"
####################################################################################

# In case of the action the body is empty but still required
body="./post_action.json"
body_arg=(--data-binary "${body}")

# content 
content_sha256="$(openssl dgst -binary -sha256 < $body | openssl enc -e -base64)";
# content header
content_sha256_header="x-content-sha256: $content_sha256"
# content length
content_length="$(wc -c < $body | xargs)";

# content length header
content_length_header="content-length: $content_length"

date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"
request_target="(request-target): post $rest_api"
# the order in the signing_string matches the order in the headers
signing_string="$request_target\n$date_header\n$host_header"
headers="(request-target) date host"

# Headers for POST and PUT requests
headers=$headers" x-content-sha256 content-type content-length"
content_type_header="content-type: application/json";
# full signing string for OST and PUT
signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"


echo "====================================================================================================="
printf '%b' "signing string is $signing_string \n"
signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`
printf '%b' "Signed Request is  \n$signature\n"

echo "====================================================================================================="
set -x
#curl -v -X POST --data "" -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"" 
curl -X POST --data-binary @post_action.json -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"" 