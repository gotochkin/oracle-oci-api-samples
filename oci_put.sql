begin
dbms_cloud.create_credential(
    credential_name =>credential_name
    , user_ocid => ''
    , tenancy_ocid => ''
    , private_key => ''
    , fingerprint => ''
);
end;


-- ######################
-- ## Update instance  ##
-- ######################
set serveroutput on
DECLARE
    response_body    dbms_cloud_oci_core_instance_t;
    response         dbms_cloud_oci_cr_compute_update_instance_response_t;
    instance_details dbms_cloud_oci_core_update_instance_details_t;
    instance_id varchar2(100);
    json_obj         json_object_t;
    l_keys           json_key_list;
BEGIN
    instance_details := dbms_cloud_oci_core_update_instance_details_t();    
    instance_details.shape := 'VM.Standard.E2.2';
    instance_id :=instance_id;
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