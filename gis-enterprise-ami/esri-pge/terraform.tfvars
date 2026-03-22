# See https://esri.github.io/arcgis-cookbook/cookbooks/arcgis-enterprise/5.2.0.html for ArcGIS variable values

# -------------------------------
# AWS settings
# -------------------------------
region               = "us-west-2"
portal_instance_id = "i-0f4c8cf2edacefbe6"#updated to the west ID
hosting_instance_id = "i-0cb32dfd8a7b2ef66"
go_instance_id = "i-0fb6f0a2e9e13d7c9"
datastore_instance_id = "i-02203e3f98743ee9d"
webadaptor_instance_id = "i-02761ef639d51597b"#updated to the west ID
s3_bucket            = "esri-aes-austin-sftwr"
s3_region            = "us-west-2"


#--------------------------------
# Global ArcGIS settings
#--------------------------------
run_as_user  = "arcgis"
esri_version = "11.5"

# -------------------------------
# Portal settings
# -------------------------------
portal_fs_directories                  = ["/gisdata/arcgisportal", "/gisdata/arcgisportal/content"]
portal_fs_shares                       = ["/gisdata/arcgisportal"]
portal_archives                        = "/opt/software/archives"
portal_setups                          = "/opt/software/setups"
portal_certs_dir                       = "/opt/certificates" #this needs to match portal_keystore_file_path and portal_root_cert_path
portal_cert_alias                      = "portalpfx"
portal_pfx_cert_name                   = "staraespsdotcomks.p12"
portal_root_cert_name                  = "AmazonRootCA1.crt"
portal_license_dir                     = "/opt/license" #this needs to match portal_authorization_file_path
portal_license_name                    = "AllUTs_AllAddOnApps.json"
portal_install_dir                     = "/opt"
portal_admin_user                      = "portaladmin"
portal_admin_email                     = "example@email.com"
portal_admin_fullname                  = "Initial Administrator"
portal_admin_description               = "The Portal Initial Administrator Account."
portal_security_question_index         = 1
portal_logs_dir                        = "/opt/arcgis/portal/usr/arcgisportal/logs"
portal_content_store_connection_string = "/gisdata/arcgisportal/content"
#For the auth path - when doing this manually - I had to specify the full path with auth file in one line\/
portal_authorization_file_path         = "/opt/license/11.5/AllUTs_AllAddOnApps.json" #the root of this needs to match portal_license_dir 
portal_content_store_type              = "fileStore"
portal_content_store_provider          = "FileSystem"
portal_user_license_type_id            = "creatorUT"
portal_keystore_file_path              = "/opt/certificates/staraespsdotcomks.p12" #the root of this needs to match portal_certs_dir
portal_root_cert_path                  = "/opt/certificates/AmazonCertChain.crt"        #the root of this needs to match portal_certs_dir
portal_root_cert_alias                 = "root"
portal_system_properties               = { "privatePortalURL": "https://pgeportal.aes-ps.com:7443/arcgis", "WebContextURL": "https://pge.aes-ps.com/portal" }
portal_hostname                        = "pgeportal.aes-ps.com"
portal_hostidentifier                  = "pgeportal.aes-ps.com"
portal_wa_name                         = "portal"
portal_private_url                     = "https://pgeportal.aes-ps.com:7443/arcgis"

#---------------------------------
# Hosting Server settings
#---------------------------------
hosting_fs_directories                 = ["/gisdata/hosting/arcgisserver", "/gisdata/hosting/arcgisserver/rasterstore"]
hosting_fs_shares                      = ["/gisdata/hosting/arcgisserver"]
hosting_archives                       = "/opt/software/archives"
hosting_setups                         = "/opt/software/setups"
hosting_install_dir                    = "/opt"
hosting_admin_username                 = "siteadmin"
hosting_authorization_file             = "/opt/license/11.5/Server_Ent_Adv.ecp"
hosting_log_dir                        = "/opt/arcgis/server/usr/logs"
hosting_directories_root               = "/gisdata/hosting/arcgisserver"
hosting_config_store_type              = "FILESYSTEM"
hosting_config_store_connection_string = "/gisdata/hosting/arcgisserver/config-store"
hosting_wa_name                        = "hosting"
hosting_hostname                       = "pgehosting.aes-ps.com"
hosting_web_context_url                = "https://pge.aes-ps.com/hosting"
hosting_keystore_file_path             = "/opt/certificates/staraespsdotcomks.p12" #the root of this needs to match hosting_certs_dir
hosting_cert_alias                     = "hostingpfx"
hosting_root_cert                      = "/opt/certificates/AmazonCertChain.crt" #the root of this needs to match hosting_certs_dir
hosting_root_cert_alias                = "root"
hosting_certs_dir                      = "/opt/certificates" #this needs to match hosting_keystore_file_path and hosting_root_cert
hosting_pfx_cert_name                  = "staraespsdotcomks.p12"
hosting_root_cert_name                 = "AmazonRootCA1.crt"
hosting_license_dir                    = "/opt/license"
hosting_license_name                   = "Server_Ent_Adv.ecp"
hosting_server_url                     = "https://pgehosting.aes-ps.com:6443/arcgis"



#---------------------------------
# Data Store settings
#---------------------------------
ds_archives                   = "/opt/software/archives"
ds_setups                     = "/opt/software/setups"
ds_install_dir                = "/opt"
ds_hostidentifier             = "pgeds.aes-ps.com"
ds_data_dir                   = "/opt/arcgisdatastore"
ds_relational_backup_location = "/opt/arcgisdatastore/relational"
ds_object_backup_location     = "/opt/arcgisdatastore/object"


#---------------------------------
# Go ArcGIS Server settings
#---------------------------------
go_fs_directories                 = ["/gisdata/go/arcgisserver", "/gisdata/go/arcgisserver/rasterstore"]
go_fs_shares                      = ["/gisdata/go/arcgisserver"]
go_archives                       = "/opt/software/archives"
go_setups                         = "/opt/software/setups"
go_install_dir                    = "/opt"
go_admin_username                 = "siteadmin"
go_authorization_file             = "/opt/license/11.5/Server_Ent_Adv.ecp"
go_log_dir                        = "/opt/arcgis/server/usr/logs"
go_directories_root               = "/gisdata/go/arcgisserver"
go_config_store_type              = "FILESYSTEM"
go_config_store_connection_string = "/gisdata/go/arcgisserver/config-store"
go_wa_name                        = "go"
go_hostname                       = "pgego.aes-ps.com"
go_web_context_url                = "https://pge.aes-ps.com/go"
go_keystore_file_path             = "/opt/certificates/staraespsdotcomks.p12" #the root of this needs to match go_certs_dir
go_cert_alias                     = "gopfx"
go_root_cert                      = "/opt/certificates/AmazonCertChain.crt" #the root of this needs to match go_certs_dir
go_root_cert_alias                = "root"
go_certs_dir                      = "/opt/certificates" #this needs to match go_keystore_file_path and go_root_cert
go_pfx_cert_name                  = "staraespsdotcomks.p12"
go_root_cert_name                 = "AmazonRootCA1.crt"
go_license_dir                    = "/opt/license"
go_license_name                   = "Server_Ent_Adv.ecp"
go_server_url                     = "https://pgego.aes-ps.com:6443/arcgis"



#----------------------------------
# Web Adaptor settings
#----------------------------------
tomcat_keystore_file  = "staraespsdotcomks.p12"
wa_archives           = "/opt/software/archives"
wa_setups             = "/opt/software/setups"
wa_webapp_dir         = "/opt/tomcat_arcgis_9.0.106/webapps"
wa_hosting_server_url = "https://pgewa.aes-ps.com/hosting"
wa_go_server_url      = "https://pgego.aes-ps.com/go"
wa_install_dir        = "/opt"
wa_portal_url         = "https://pgeportal.aes-ps.com/portal"

#--------------------------------------------------------------
# Secrets Manager secrets storing the ArcGIS-related passwords
#--------------------------------------------------------------
portal_admin_password           = "portal-admin-password2"
portal_security_question_answer = "portal-security-question-answer2"
portal_keystore_file_password   = "portal-keystore-file-password2"
hosting_admin_password          = "hosting-admin-password"
hosting_keystore_file_password  = "hosting-keystore-file-password"
go_admin_password               = "go-admin-password"
go_keystore_file_password       = "go-keystore-file-password"
tomcat_keystore_password        = "tomcat-keystore-password"