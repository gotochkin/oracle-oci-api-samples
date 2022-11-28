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
-- Update an instance
-- ############################################################################
set serveroutput on
DECLARE
    response_body    dbms_cloud_oci_core_instance_t;
    response         dbms_cloud_oci_cr_compute_update_instance_response_t;
    instance_details dbms_cloud_oci_core_update_instance_details_t;
    json_obj         json_object_t;
    l_keys           json_key_list;
    credential_name  varchar2(100);
    instance_id      varchar2(200);
BEGIN
    instance_details := dbms_cloud_oci_core_update_instance_details_t();    
    instance_details.shape := 'VM.Standard.E2.1';
    -- Instance ID to be updated
    instance_id:='&instance_id';
    -- Credential name for the OCI user credentials
    credential_name:='&credential_name';
    -- Run the function and get response
    response := dbms_cloud_oci_cr_compute.update_instance(instance_id => instance_id, update_instance_details => instance_details, region => 'ca-toronto-1', credential_name => credential_name);
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
    dbms_output.put_line(response_body.availability_domain);
    dbms_output.put_line(response_body.shape);
    dbms_output.put_line(response_body.lifecycle_state);
END;
/