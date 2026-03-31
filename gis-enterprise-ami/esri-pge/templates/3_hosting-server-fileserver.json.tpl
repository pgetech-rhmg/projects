{
    "arcgis": {
        "run_as_user": "${run_as_user}",
        "fileserver": {
            "directories": ${hosting_fs_directories},            
            "shares": ${hosting_fs_shares}
        }
    },
    "run_list": [
        "recipe[nfs::server]",
        "recipe[arcgis-enterprise::system]",
        "recipe[arcgis-enterprise::fileserver]"
    ]
}