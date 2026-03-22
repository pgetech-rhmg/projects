{
    "arcgis": {
        "version": "${esri_version}",
        "run_as_user": "${run_as_user}",
        "fileserver": {
            "directories": ${portal_fs_directories},
            "shares": ${portal_fs_shares}
        }
    },
    "run_list": [
        "recipe[nfs::server]",
        "recipe[arcgis-enterprise::system]",
        "recipe[arcgis-enterprise::fileserver]"
    ]
}
