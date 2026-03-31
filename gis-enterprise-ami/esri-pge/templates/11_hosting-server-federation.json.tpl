{
    "arcgis": {
        "server": {
            "private_url": "${hosting_server_url}",
            "web_context_url": "${hosting_web_context_url}",
            "admin_username": "${hosting_admin_username}",
            "admin_password": "${hosting_admin_password}",
            "is_hosting": true
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