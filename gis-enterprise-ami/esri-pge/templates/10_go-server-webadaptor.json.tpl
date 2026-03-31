{
    "java": {
        "version": "17.0.17+10",
        "tarball_uri": "file:///opt/software/archives/OpenJDK17U-jdk_x64_linux_hotspot_17.0.17_10.tar.gz",
        "tarball_path": "/opt/software/archives/OpenJDK17U-jdk_x64_linux_hotspot_17.0.17_10.tar.gz"
    },
    "tomcat": {
        "version": "9.0.106",
        "tarball_path": "/opt/software/archives/apache-tomcat-9.0.106.tar.gz",
        "install_path": "/opt/tomcat_arcgis_9.0.106",
        "tarball_base_uri": "file:///opt/software/archives/",
        "checksum_base_uri": "file:///opt/software/archives/",
        "verify_checksum": false,
        "keystore_file": "/opt/tomcat_arcgis_9.0.106/conf/${tomcat_keystore_file}",
        "keystore_type": "pkcs12",
        "keystore_password": "${tomcat_keystore_password}"
    },
    "arcgis": {
        "version": "${esri_version}",
        "run_as_user": "${run_as_user}",
        "repository": {
            "archives": "${wa_archives}",
            "setups": "${wa_setups}"
        },
        "web_server": {
            "webapp_dir": "${wa_webapp_dir}"
        },
        "server": {
            "url": "${go_server_url}",
            "wa_url": "${wa_go_server_url}",
            "admin_username": "${go_admin_username}",
            "admin_password": "${go_admin_password}",
            "wa_name": "${go_wa_name}"
        },
        "web_adaptor": {
            "install_dir": "${wa_install_dir}"
        }
    },
    "run_list": [
        "recipe[arcgis-enterprise::system]",
        "recipe[esri-tomcat::openjdk]",
        "recipe[esri-tomcat]",
        "recipe[arcgis-enterprise::server_wa]"
    ]
}
