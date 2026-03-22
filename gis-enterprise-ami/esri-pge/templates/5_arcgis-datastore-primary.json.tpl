{
    "arcgis": {
        "version": "${esri_version}",
        "run_as_user": "${run_as_user}",
        "repository": {
            "archives": "${ds_archives}",
            "setups": "${ds_setups}"
        },
        "server": {
            "admin_username": "${hosting_admin_username}",
            "admin_password": "${hosting_admin_password}",
            "url": "${hosting_server_url}"
        },
        "data_store": {
            "hostidentifier": "${ds_hostidentifier}",
            "install_dir": "${ds_install_dir}",
            "setup_options": "-f Relational",
            "install_system_requirements": true,
            "types": "relational,object", 
            "preferredidentifier": "hostname",
            "data_dir": "${ds_data_dir}",
            "relational": {
                "backup_type": "fs", 
                "backup_location": "${ds_relational_backup_location}",
                "disk_threshold_readonly": 5120,
                "max_connections": 150,
                "pitr": "disable",
                "enablessl": true
            },
            "object": {
                "backup_type": "fs", 
                "backup_location": "${ds_object_backup_location}"
                }
        }
    },
    "run_list": [
        "recipe[arcgis-enterprise::system]",
        "recipe[arcgis-enterprise::datastore]"
    ]
}