{
    "arcgis": {
        "server": {
            "private_url": "${go_server_url}",
            "web_context_url": "${go_web_context_url}",
            "admin_username": "${go_admin_username}",
            "admin_password": "${go_admin_password}",
            "is_hosting": false
        },
        "portal": {
            "private_url": "${portal_private_url}",
            "admin_username": "${portal_admin_user}",
            "admin_password": "${portal_admin_password}",
            "root_cert": "${portal_root_cert_path}",
            "root_cert_alias": "${portal_root_cert_alias}"
        }
    },
    "run_list": [
        "recipe[arcgis-enterprise::federation]"
    ]
}