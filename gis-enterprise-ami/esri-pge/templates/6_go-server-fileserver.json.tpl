{
    "arcgis": {
        "run_as_user": "${run_as_user}",
        "fileserver": {
            "directories": ${go_fs_directories},            
            "shares": ${go_fs_shares}
        }
    },
    "run_list": [
        "recipe[nfs::server]",
        "recipe[arcgis-enterprise::system]",
        "recipe[arcgis-enterprise::fileserver]"
    ]
}