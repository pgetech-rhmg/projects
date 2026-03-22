{
    "arcgis": {
        "run_as_user": "${run_as_user}",
        "version": "${esri_version}",
        "repository": {
            "archives": "${hosting_archives}",
            "setups": "${hosting_setups}"
        },
        "server": {
            "hostname": "${hosting_hostname}",
            "install_dir": "${hosting_install_dir}",
            "install_system_requirements": true,            
            "admin_username": "${hosting_admin_username}",
            "admin_password": "${hosting_admin_password}",
            "authorization_file": "${hosting_authorization_file}",
            "log_level": "WARNING",
            "enable_debug": false,
            "log_dir": "${hosting_log_dir}",
            "directories_root": "${hosting_directories_root}",
            "config_store_type": "${hosting_config_store_type}",
            "config_store_connection_string": "${hosting_config_store_connection_string}",
            "soc_max_heap_size": 64,
            "services_dir_enabled": true,
            "system_properties": {
                "suspendedMachineUnregisterThreshold": -1,
                "machineSuspendThreshold": 60,
                "WebContextURL": "${hosting_web_context_url}"
            },
            "wa_name": "${hosting_wa_name}",
            "web_context_url": "${hosting_web_context_url}"
            "is_hosting": true,
            "keystore_file": "${hosting_keystore_file_path}",
            "keystore_password": "${hosting_keystore_file_password}",
            "cert_alias": "${hosting_cert_alias}",
            "import_certificate_chain": true,
            "root_cert": "${hosting_root_cert}",
            "root_cert_alias": "${hosting_root_cert_alias}"			
        }
    },
    "run_list": [
        "recipe[arcgis-enterprise::server]"
    ]
}