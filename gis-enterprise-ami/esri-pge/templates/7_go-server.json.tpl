{
    "arcgis": {
        "run_as_user": "${run_as_user}",
        "version": "${esri_version}",
        "repository": {
            "archives": "${go_archives}",
            "setups": "${go_setups}"
        },
        "server": {
            "hostname": "${go_hostname}",
            "install_dir": "${go_install_dir}",
            "install_system_requirements": true,            
            "admin_username": "${go_admin_username}",
            "admin_password": "${go_admin_password}",
            "authorization_file": "${go_authorization_file}",
            "log_level": "WARNING",
            "enable_debug": false,
            "log_dir": "${go_log_dir}",
            "directories_root": "${go_directories_root}",
            "config_store_type": "${go_config_store_type}",
            "config_store_connection_string": "${go_config_store_connection_string}",
            "soc_max_heap_size": 64,
            "services_dir_enabled": true,
            "system_properties": {
                "suspendedMachineUnregisterThreshold": -1,
                "machineSuspendThreshold": 60,
                "WebContextURL": "${go_web_context_url}"
            },
            "wa_name": "${go_wa_name}",
            "web_context_url": "${go_web_context_url}",
            "is_hosting": false,
            "keystore_file": "${go_keystore_file_path}",
            "keystore_password": "${go_keystore_file_password}",
            "cert_alias": "${go_cert_alias}",
            "import_certificate_chain": true,
            "root_cert": "${go_root_cert}",
            "root_cert_alias": "${go_root_cert_alias}"			
        }
    },
    "run_list": [
        "recipe[arcgis-enterprise::server]"
    ]
}