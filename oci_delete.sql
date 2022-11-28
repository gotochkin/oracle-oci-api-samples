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
-- Terminate an instance
-- ############################################################################
set serveroutput on
DECLARE
    response         dbms_cloud_oci_cr_compute_terminate_instance_response_t;
    instance_id      varchar2(200);
    json_obj         json_object_t;
    l_keys           json_key_list;
    instance_id     varchar2(100);
    credential_name  varchar2(100);
BEGIN
    -- Instance ID to be deleted
    instance_id:='&credential_name';
    -- Credential name for the OCI user credentials
    credential_name:='&credential_name';
    -- Run the function and get response 
    response := dbms_cloud_oci_cr_compute.terminate_instance(instance_id => instance_id, preserve_boot_volume => 0, region => 'ca-toronto-1', credential_name => credential_name);
    
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
END;