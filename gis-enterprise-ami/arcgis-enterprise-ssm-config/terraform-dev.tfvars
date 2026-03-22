# See https://esri.github.io/arcgis-cookbook/cookbooks/arcgis-enterprise/5.2.0.html for ArcGIS variable values

# -------------------------------
# AWS settings
# -------------------------------
region               = "us-west-2"
portal_instance_id = ""
hosting_instance_id = ""
datastore_instance_id = ""
webadaptor_instance_id = ""
s3_bucket            = "esri-aes-pge-sftwr"
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
portal_license_name                    = "BCGIS-SOR-ArcGIS_Enterprise_Portal_115_555467_20260220.json"
portal_install_dir                     = "/opt"
portal_admin_user                      = "portaladmin"
portal_admin_email                     = "GRN0@pge.com"
portal_admin_fullname                  = "Initial Administrator"
portal_admin_description               = "The Portal Initial Administrator Account."
portal_security_question_index         = 13
portal_logs_dir                        = "/opt/arcgis/portal/usr/arcgisportal/logs"
portal_content_store_connection_string = "/gisdata/arcgisportal/content"
#For the auth path - when doing this manually - I had to specify the full path with auth file in one line\/
portal_authorization_file_path         = "/opt/license/11.5/BCGIS-SOR-ArcGIS_Enterprise_Portal_115_555467_20260220.json" #the root of this needs to match portal_license_dir
portal_content_store_type              = "fileStore"
portal_content_store_provider          = "FileSystem"
portal_user_license_type_id            = "creatorUT"
portal_keystore_file_path              = "/opt/certificates/staraespsdotcomks.p12" #the root of this needs to match portal_certs_dir
portal_root_cert_path                  = "/opt/certificates/AmazonCertChain.crt"        #the root of this needs to match portal_certs_dir
portal_root_cert_alias                 = "root"
portal_system_properties               = { "privatePortalURL": "https://bcgis-sor-portal-sandbox.nonprod.pge.com:7443/arcgis", "WebContextURL": "https://bcgis-sor-sandbox.nonprod.pge.com/portal" }
portal_hostname                        = "bcgis-sor-portal-sandbox.nonprod.pge.com"
portal_hostidentifier                  = "bcgis-sor-portal-sandbox.nonprod.pge.com"
portal_wa_name                         = "portal"
portal_private_url                     = "https://bcgis-sor-portal-sandbox.nonprod.pge.com:7443/arcgis"

#---------------------------------
# Hosting Server settings
#---------------------------------
hosting_fs_directories                 = ["/gisdata/hosting/arcgisserver", "/gisdata/hosting/arcgisserver/rasterstore"]
hosting_fs_shares                      = ["/gisdata/hosting/arcgisserver"]
hosting_archives                       = "/opt/software/archives"
hosting_setups                         = "/opt/software/setups"
hosting_install_dir                    = "/opt"
hosting_admin_username                 = "siteadmin"
hosting_authorization_file             = "/opt/license/11.5/ArcGISGISServerAdvanced_ArcGISServer_1556363.ecp"
hosting_log_dir                        = "/opt/arcgis/server/usr/logs"
hosting_directories_root               = "/gisdata/hosting/arcgisserver"
hosting_config_store_type              = "FILESYSTEM"
hosting_config_store_connection_string = "/gisdata/hosting/arcgisserver/config-store"
hosting_wa_name                        = "hosting"
hosting_hostname                       = "bcgis-sor-server-sandbox.nonprod.pge.com"
hosting_web_context_url                = "https://bcgis-sor-sandbox.nonprod.pge.com/hosting"
hosting_keystore_file_path             = "/opt/certificates/staraespsdotcomks.p12" #the root of this needs to match hosting_certs_dir
hosting_cert_alias                     = "hostingpfx"
hosting_root_cert                      = "/opt/certificates/AmazonCertChain.crt" #the root of this needs to match hosting_certs_dir
hosting_root_cert_alias                = "root"
hosting_certs_dir                      = "/opt/certificates" #this needs to match hosting_keystore_file_path and hosting_root_cert
hosting_pfx_cert_name                  = "staraespsdotcomks.p12"
hosting_root_cert_name                 = "AmazonRootCA1.crt"
hosting_license_dir                    = "/opt/license"
hosting_license_name                   = "ArcGISGISServerAdvanced_ArcGISServer_1556363.ecp"
hosting_server_url                     = "https://bcgis-sor-server-sandbox.nonprod.pge.com:6443/arcgis"



#---------------------------------
# Data Store settings
#---------------------------------
ds_archives                   = "/opt/software/archives"
ds_setups                     = "/opt/software/setups"
ds_install_dir                = "/opt"
ds_hostidentifier             = "bcgis-sor-dataStore-sandbox.nonprod.pge.com"
ds_data_dir                   = "/opt/arcgisdatastore"
ds_relational_backup_location = "/opt/arcgisdatastore/relational"
ds_object_backup_location     = "/opt/arcgisdatastore/object"

#----------------------------------
# Web Adaptor settings
#----------------------------------
tomcat_keystore_file  = "staraespsdotcomks.p12"
wa_archives           = "/opt/software/archives"
wa_setups             = "/opt/software/setups"
wa_webapp_dir         = "/opt/tomcat_arcgis_9.0.106/webapps"
wa_hosting_server_url = "https://bcgis-sor-wa-sandbox.nonprod.pge.com/hosting"
wa_install_dir        = "/opt"
wa_portal_url         = "https://bcgis-sor-portal-sandbox.nonprod.pge.com/portal"

#--------------------------------------------------------------
# Secrets Manager secrets storing the ArcGIS-related passwords
#--------------------------------------------------------------
portal_admin_password           = "sandbox/portal-siteadmin"
portal_security_question_answer = "sandbox/portal-sec-qus-ans"
portal_keystore_file_password   = "sandbox/portal-siteadmin"
hosting_admin_password          = "sandbox/server-siteadmin"
hosting_keystore_file_password  = "sandbox/server-siteadmin"
tomcat_keystore_password        = "sandbox/server-siteadmin"

tfc_role_name = "tfc-oidc-dev-entgis-arcgis-enterprise-ssm-config-role"
