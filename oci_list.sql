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
-- Get list of instances in a compartment
-- ############################################################################
set serveroutput on
DECLARE
    response_body    dbms_cloud_oci_core_instance_tbl;
    instance_details dbms_cloud_oci_core_instance_t;
    response         dbms_cloud_oci_cr_compute_list_instances_response_t;
    compartment_id   varchar2(100);
    display_name     varchar2(100);
    credential_name  varchar2(100);
    json_obj         json_object_t;
    l_keys           json_key_list;
BEGIN
    -- Input for compartment ID
    compartment_id:='&compartment_id';
    -- Filter by display name -- uncomment the next line
    -- display_name := '&display_name';
    -- Credential name for the OCI user credentials
    credential_name:='&credential_name';
    -- Run the function and get response 
    response := dbms_cloud_oci_cr_compute.list_instances(compartment_id => compartment_id, region => 'ca-toronto-1', credential_name => credential_name);
    -- The same but with a filter by display name for the instances
    --response := dbms_cloud_oci_cr_compute.list_instances(compartment_id => compartment_id, display_name => display_name, region => 'ca-toronto-1', credential_name => 'GLEB');
    response_body := response.response_body;
    -- Print response headers
    dbms_output.put_line('Headers: ' || chr(10) || '------------');
    json_obj := response.headers;
    l_keys := json_obj.get_keys;
    FOR i IN 1..l_keys.count LOOP
        dbms_output.put_line(l_keys(i) || ':' || json_obj.get(l_keys(i)).to_string);
    END LOOP;
    -- Print response status code
    dbms_output.put_line('Status Code: ' || chr(10) || '------------' || chr(10) || response.status_code);
    dbms_output.put_line(chr(10));
    -- Print sme instances properties from the esponse body
    for i in 1..response_body.count loop
       dbms_output.put_line(response_body(i).display_name);
       dbms_output.put_line(response_body(i).shape);
       dbms_output.put_line(response_body(i).lifecycle_state);
    end loop;
END;

