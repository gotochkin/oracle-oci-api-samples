-- ############################################################################
-- Copyright 2022 Gleb Otochkin
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http:--www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ############################################################################
-- Create credentials
-- ############################################################################
DECLARE
    credential_name VARCHAR2(100);
    user_id VARCHAR2(200);
    tenancy_id VARCHAR2(200);
    private_key VARCHAR2(3000);
    fingerprint VARCHAR2(100);
begin
    -- Credential name for the OCI user credentials
    credential_name:='&credential_name';
    -- Input for user ID
    user_id:='&user_id';
    -- Input for tenancy ID
    tenancy_id:='&tenancy_id';
    -- Credential name for the OCI user credentials
    private_key:='&private_key';
    -- Credential name for the OCI user credentials
    fingerprint:='&fingerprint';
    dbms_cloud.create_credential(
        credential_name =>credential_name
        , user_ocid => user_id
        , tenancy_ocid => tenancy_id
        , private_key => private_key
        , fingerprint => fingerprint
    );
end;
-- ############################################################################
-- Create an instance instances in a compartment
-- ############################################################################
set serveroutput on
DECLARE
    response_body    dbms_cloud_oci_core_instance_t;
    response         dbms_cloud_oci_cr_compute_launch_instance_response_t;
    instance_details dbms_cloud_oci_core_launch_instance_details_t;
    json_obj         json_object_t;
    l_keys           json_key_list;
    credential_name  varchar2(100);
    display_name  varchar2(100);
    compartment_id varchar2(100);
    subnet_id  varchar2(100);
    public_key  varchar2(1000);
BEGIN
    -- Input for credentials
    credential_name:='&credential_name';
    -- Input for compartment ID
    compartment_id:='&compartment_id';
    -- Display name for the instance
    display_name := '&display_name';
    -- Input for subnet ID
    subnet_id:='&subnet_id';
    -- Input for SSH public key
    public_key:='&public_key';
    instance_details := dbms_cloud_oci_core_launch_instance_details_t();
    instance_details.availability_domain := 'IHzD:CA-TORONTO-1-AD-1';
    instance_details.compartment_id := compartment_id;
    instance_details.display_name := display_name;
    instance_details.image_id := 'ocid1.image.oc1.ca-toronto-1.aaaaaaaa3s3dkuflnmyoqxqp3narlvfl7ngpjacxxhnxcuw22jnhe6qdfgdq';
    instance_details.metadata := json_object_t.parse('{"ssh_authorized_keys":"'||public_key||'"}'
    );
    instance_details.shape := 'VM.Standard.E2.1';
    instance_details.subnet_id := subnet_id;
    response := dbms_cloud_oci_cr_compute.launch_instance(launch_instance_details => instance_details, region => 'ca-toronto-1', credential_name => credential_name);
    response_body := response.response_body;
    -- Response Headers
    dbms_output.put_line('Headers: ' || chr(10) || '------------');
    json_obj := response.headers;
    l_keys := json_obj.get_keys;
    FOR i IN 1..l_keys.count LOOP
        dbms_output.put_line(l_keys(i) || ':' || json_obj.get(l_keys(i)).to_string);
    END LOOP;
    -- Response status code
    dbms_output.put_line('Status Code: ' || chr(10) || '------------' || chr(10) || response.status_code);
    dbms_output.put_line(chr(10));
    -- Response body
    dbms_output.put_line(response_body.display_name);
    dbms_output.put_line(response_body.shape);
    dbms_output.put_line(response_body.lifecycle_state);
END;
/