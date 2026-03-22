{
    "arcgis": {
        "version": "${esri_version}",
        "run_as_user": "${run_as_user}",
        "repository": {
            "archives": "${portal_archives}",
            "setups": "${portal_setups}"
        },
        "portal": {
            "hostname": "${portal_hostname}",
            "hostidentifier": "${portal_hostidentifier}",
            "install_dir": "${portal_install_dir}",
            "admin_username": "${portal_admin_user}",
            "admin_password": "${portal_admin_password}",
            "admin_email": "${portal_admin_email}",
            "admin_full_name": "${portal_admin_fullname}",
            "admin_description": "${portal_admin_description}",
            "security_question_index": ${portal_security_question_index},
            "security_question_answer": "${portal_security_question_answer}",
            "log_dir": "${portal_logs_dir}",
            "log_level": "WARNING",
            "enable_debug": false,
            "content_store_type": "${portal_content_store_type}",
            "content_store_provider": "${portal_content_store_provider}",
            "content_store_connection_string": "${portal_content_store_connection_string}",
            "object_store": "",
            "authorization_file": "${portal_authorization_file_path}",
            "user_license_type_id": "${portal_user_license_type_id}",
            "keystore_file": "${portal_keystore_file_path}",
            "keystore_password": "${portal_keystore_file_password}",
            "cert_alias": "${portal_cert_alias}",
            "install_system_requirements": true,
            "root_cert": "${portal_root_cert_path}",
            "root_cert_alias": "${portal_root_cert_alias}",
            "import_certificate_chain": true,
            "wa_name": "${portal_wa_name}",
            "system_properties": ${portal_system_properties}
        }
    },
    "run_list": [
        "recipe[arcgis-enterprise::portal]"
    ]
}