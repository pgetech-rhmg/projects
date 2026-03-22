#  See https://esri.github.io/arcgis-cookbook/cookbooks/arcgis-enterprise/5.2.0.html for ArcGIS variable values

# -------------------------------
# AWS settings
# -------------------------------
variable "region" { type = string }
variable "portal_instance_id" { type = string }
variable "hosting_instance_id" { type = string }
variable "go_instance_id" { type = string }
variable "datastore_instance_id" { type = string }
variable "webadaptor_instance_id" { type = string }
variable "s3_bucket" { type = string }
variable "s3_region" { type = string }


#--------------------------------
# Global ArcGIS settings
#--------------------------------
variable "run_as_user" {
  type        = string
  default     = "arcgis"
  description = "User account under which ArcGIS services will run."
}

variable "esri_version" {
  type        = string
  default     = "11.5"
  description = "Version of Esri ArcGIS Enterprise to install."
}

# -------------------------------
# Portal settings
# -------------------------------

variable "portal_fs_directories" {
  type        = list(string)
  default     = ["/gisdata/arcgisportal", "/gisdata/arcgisportal/content"]
  description = "List of directories used by ArcGIS Portal for data and content."
}

variable "portal_fs_shares" {
  type        = list(string)
  default     = ["/gisdata/arcgisportal"]
  description = "List of shared file system paths for ArcGIS Portal."
}

variable "portal_archives" {
  type        = string
  default     = "/opt/software/archives"
  description = "Path to the directory containing ArcGIS Portal archive files."
}

variable "portal_setups" {
  type        = string
  default     = "/opt/software/setups"
  description = "Path to the directory containing ArcGIS Portal setup files."
}

variable "portal_certs_dir" {
  type        = string
  default     = "/opt/certificates"
  description = "Location where certificates will be downloaded to from S3 bucket. THIS PATH NEEDS TO MATCH PORTAL_KEYSTORE_FILE_PATH AND PORTAL_ROOT_CERT_PATH."
}

variable "portal_pfx_cert_name" {
  type        = string
  default     = "portal.pfx"
  description = "File name of Portal's .pfx certificate."
}

variable "portal_root_cert_name" {
  type        = string
  default     = "root.cer"
  description = "File name of Portal's root certificate."
}

variable "portal_license_dir" {
  type        = string
  default     = "/opt/license"
  description = "Location where Portal license will be downloaded to from S3 bucket.  THIS PATH NEEDS TO MATCH PORTAL_AUTHORIZATION_FILE_PATH."
}

variable "portal_license_name" {
  type        = string
  default     = "portallicense.json"
  description = "File name of Portal's license."
}

variable "portal_install_dir" {
  type        = string
  default     = "/opt"
  description = "Base installation directory for ArcGIS Portal."
}

variable "portal_admin_user" {
  type        = string
  default     = "portaladmin"
  description = "Username for the ArcGIS Portal administrator account."
}

variable "portal_admin_email" {
  type        = string
  default     = ""
  description = "Email address for the ArcGIS Portal administrator account."
}

variable "portal_admin_fullname" {
  type        = string
  default     = ""
  description = "Full name of the ArcGIS Portal administrator account."
}

variable "portal_admin_description" {
  type        = string
  default     = ""
  description = "Description or display name for the ArcGIS Portal administrator."
}

variable "portal_security_question_index" {
  type        = number
  default     = 1
  description = "Index of the security question used for the administrator account setup."
}

variable "portal_logs_dir" {
  type        = string
  default     = "/opt/arcgis/portal/usr/arcgisportal/logs"
  description = "Directory path where ArcGIS Portal logs are stored."
}

variable "portal_content_store_connection_string" {
  type        = string
  default     = "/net/FILESERVER/gisdata/arcgisportal/content"
  description = "Connection string or path for the ArcGIS Portal content store."
}

variable "portal_authorization_file_path" {
  type        = string
  default     = "/opt/software/authorization_files/11.5/portal.json"
  description = "Path to the ArcGIS Portal authorization (license) file.  THIS PATH NEEDS TO MATCH PORTAL_LICENSE_DIR."
}

variable "portal_content_store_type" {
  type        = string
  default     = "fileStore"
  description = "Type of content store used by ArcGIS Portal (e.g., fileStore or cloudStore)."
}

variable "portal_content_store_provider" {
  type        = string
  default     = "FileSystem"
  description = "Provider type for the ArcGIS Portal content store."
}

variable "portal_user_license_type_id" {
  type        = string
  default     = "creatorUT"
  description = "User license type ID assigned to the ArcGIS Portal administrator."
}

variable "portal_keystore_file_path" {
  type        = string
  default     = "/opt/certificates/portal.pfx"
  description = "Path to the keystore file used by ArcGIS Portal for HTTPS communication.  THIS PATH NEEDS TO MATCH PORTAL_CERTS_DIR."
}

variable "portal_cert_alias" {
  type        = string
  default     = "portalpfx"
  description = "Alias name for the certificate in the ArcGIS Portal keystore."
}

variable "portal_root_cert_path" {
  type        = string
  default     = "/opt/certificates/portal.cer"
  description = "Path to the root certificate file used for ArcGIS Portal SSL configuration.  THIS PATH NEEDS TO MATCH PORTAL_CERTS_DIR."
}

variable "portal_root_cert_alias" {
  type        = string
  default     = "root"
  description = "Alias name for the root certificate in the ArcGIS Portal keystore."
}

variable "portal_system_properties" {
  type        = map(string)
  default     = { privatePortalURL = "https://ip.domain.com:7443/arcgis", WebContextURL = "https://alb.domain.com/portal" }
  description = "Map of custom system properties for ArcGIS Portal configuration."
}

variable "portal_hostname" {
  type        = string
  default     = ""
  description = "Hostname or IP address used for accessing ArcGIS Portal."
}

variable "portal_hostidentifier" {
  type        = string
  default     = ""
  description = "Unique host identifier (hostname or IP address) for the ArcGIS Portal machine."
}

variable "portal_wa_name" {
  type        = string
  default     = "portal"
  description = "Web adaptor name used by ArcGIS Portal."
}

variable "portal_private_url" {
  type        = string
  default     = "https://machine.domain.com:7443/arcgis"
  description = "Portal's private URL used during federation for ArcGIS Server communication."
}


#------------------------------
# Hosting Server settings
#------------------------------

variable "hosting_fs_directories" {
  type        = list(string)
  default     = ["/gisdata/arcgisserver", "/gisdata/arcgisserver/rasterstore"]
  description = "List of directories used by Hosting Server for data and content."
}

variable "hosting_fs_shares" {
  type        = list(string)
  default     = ["/gisdata/arcgisserver"]
  description = "List of shared file system paths for Hosting Server."
}

variable "hosting_archives" {
  type        = string
  default     = "/opt/software/archives"
  description = "Path to the directory containing Hosting Server archive files."
}

variable "hosting_setups" {
  type        = string
  default     = "/opt/software/setups"
  description = "Path to the directory containing Hosting Server setup files."
}

variable "hosting_install_dir" {
  type        = string
  default     = "/opt"
  description = "Base installation directory for Hosting Server."
}

variable "hosting_admin_username" {
  type        = string
  default     = "siteadmin"
  description = "Username for the ArcGIS Server Primary Site Administrator account."
}

variable "hosting_authorization_file" {
  type        = string
  default     = "/opt/software/authorization_files/11.5/server.prvc"
  description = "Path to the Hosting Server authorization (license) file.  THIS PATH NEEDS TO MATCH HOSTING_LICENSE_DIR."
}

variable "hosting_log_dir" {
  type        = string
  default     = "/opt/arcgis/server/usr/logs"
  description = "Directory path where Hosting Server logs are stored."
}

variable "hosting_directories_root" {
  type        = string
  default     = "/net/FILESERVER/gisdata/arcgisserver"
  description = "Root directory of the Hosting Server's site directories."
}

variable "hosting_config_store_type" {
  type        = string
  default     = "FILESYSTEM"
  description = "Provider type for the Hosting Server config-store."
}

variable "hosting_config_store_connection_string" {
  type        = string
  default     = "/net/FILESERVER/gisdata/arcgisserver/config-store"
  description = "Connection string or path for the Hosting Server config-store."
}

variable "hosting_wa_name" {
  type        = string
  default     = "hosting"
  description = "Web adaptor name used by Hosting Server."
}

variable "hosting_hostname" {
  type        = string
  default     = ""
  description = "Hostname or IP address used for accessing Hosting Server."
}

variable "hosting_web_context_url" {
  type        = string
  default     = "https://alb.domain.com/hosting"
  description = "Friendly URL used for accessing Hosting Server."
}

variable "hosting_keystore_file_path" {
  type        = string
  default     = "/opt/certificates/server.pfx"
  description = "Path to the keystore file used by Hosting Server for HTTPS communication.  THIS PATH NEEDS TO MATCH HOSTING_CERTS_DIR."
}

variable "hosting_cert_alias" {
  type        = string
  default     = "hostingpfx"
  description = "Alias displayed in the Hosting Server's Admin API for its certificate."
}

variable "hosting_root_cert" {
  type        = string
  default     = "/opt/certificates/server.cer"
  description = "Path to the root certificate file used for Hosting Server SSL configuration. THIS PATH NEEDS TO MATCH HOSTING_CERTS_DIR."
}

variable "hosting_root_cert_alias" {
  type        = string
  default     = "root"
  description = "Alias name for the root certificate in the Hosting Server keystore."
}

variable "hosting_certs_dir" {
  type        = string
  default     = "/opt/certificates"
  description = "Location where certificates will be downloaded to from S3 bucket.  THIS NEEDS TO MATCH THE PATH OF HOSTING_ROOT_CERT AND HOSTING_KEYSTORE_FILE_PATH"
}

variable "hosting_pfx_cert_name" {
  type        = string
  default     = "hosting.pfx"
  description = "File name of Hosting Server's .pfx certificate."
}

variable "hosting_root_cert_name" {
  type        = string
  default     = "root.cer"
  description = "File name of Hosting Server's root certificate."
}

variable "hosting_license_dir" {
  type        = string
  default     = "/opt/license"
  description = "Location where Hosting Server license will be downloaded to from S3 bucket.  THIS PATH NEEDS TO MATCH HOSTING_AUTHORIZATION_FILE."
}

variable "hosting_license_name" {
  type        = string
  default     = "hostinglicense.prvc"
  description = "File name of Hosting Server's license."
}

variable "hosting_server_url" {
  type        = string
  default     = "https://server.domain.com:6443/arcgis"
  description = "Hosting Server URL used by the Data Store to access the Hosting Server during Data Store registration, as well as for the Web Adaptor during Web Adaptor configuration."
}


#--------------------------------
# Data Store settings
#--------------------------------
variable "ds_archives" {
  type        = string
  default     = "/opt/software/archives"
  description = "Path to the directory containing Data Store archive files."
}

variable "ds_setups" {
  type        = string
  default     = "/opt/software/setups"
  description = "Path to the directory containing Data Store setup files."
}

variable "ds_install_dir" {
  type        = string
  default     = "/opt"
  description = "Base installation directory for Data Store."
}

variable "ds_hostidentifier" {
  type        = string
  default     = "10.0.0.1"
  description = "Unique host identifier (hostname or IP address) for the ArcGIS Data Store machine."
}

variable "ds_data_dir" {
  type        = string
  default     = "/gisdata/arcgisdatastore"
  description = "Data directory location for the ArcGIS Data Store."
}

variable "ds_relational_backup_location" {
  type        = string
  default     = "/gisdata/arcgisdatastore/relational"
  description = "Default backup location for the Relational Data Store."
}

variable "ds_object_backup_location" {
  type        = string
  default     = "/gisdata/arcgisdatastore/object"
  description = "Default backup location for the Object Data Store."
}


#------------------------------
# Go ArcGIS Server settings
#------------------------------

variable "go_fs_directories" {
  type        = list(string)
  default     = ["/gisdata/arcgisserver", "/gisdata/arcgisserver/rasterstore"]
  description = "List of directories used by Go Server for data and content."
}

variable "go_fs_shares" {
  type        = list(string)
  default     = ["/gisdata/arcgisserver"]
  description = "List of shared file system paths for Go Server."
}

variable "go_archives" {
  type        = string
  default     = "/opt/software/archives"
  description = "Path to the directory containing Go Server archive files."
}

variable "go_setups" {
  type        = string
  default     = "/opt/software/setups"
  description = "Path to the directory containing Go Server setup files."
}

variable "go_install_dir" {
  type        = string
  default     = "/opt"
  description = "Base installation directory for Go Server."
}

variable "go_admin_username" {
  type        = string
  default     = "siteadmin"
  description = "Username for the ArcGIS Server Primary Site Administrator account."
}

variable "go_authorization_file" {
  type        = string
  default     = "/opt/software/authorization_files/11.5/server.prvc"
  description = "Path to the Go Server authorization (license) file.  THIS PATH NEEDS TO MATCH GO_LICENSE_DIR."
}

variable "go_log_dir" {
  type        = string
  default     = "/opt/arcgis/server/usr/logs"
  description = "Directory path where Go Server logs are stored."
}

variable "go_directories_root" {
  type        = string
  default     = "/net/FILESERVER/gisdata/arcgisserver"
  description = "Root directory of the Go Server's site directories."
}

variable "go_config_store_type" {
  type        = string
  default     = "FILESYSTEM"
  description = "Provider type for the Go Server config-store."
}

variable "go_config_store_connection_string" {
  type        = string
  default     = "/net/FILESERVER/gisdata/arcgisserver/config-store"
  description = "Connection string or path for the Go Server config-store."
}

variable "go_wa_name" {
  type        = string
  default     = "go"
  description = "Web adaptor name used by Go Server."
}

variable "go_hostname" {
  type        = string
  default     = ""
  description = "Hostname or IP address used for accessing Go Server."
}

variable "go_web_context_url" {
  type        = string
  default     = "https://alb.domain.com/go"
  description = "Friendly URL used for accessing Go Server."
}

variable "go_keystore_file_path" {
  type        = string
  default     = "/opt/certificates/server.pfx"
  description = "Path to the keystore file used by Go Server for HTTPS communication.  THIS PATH NEEDS TO MATCH GO_CERTS_DIR."
}

variable "go_cert_alias" {
  type        = string
  default     = "gopfx"
  description = "Alias displayed in the Go Server's Admin API for its certificate."
}

variable "go_root_cert" {
  type        = string
  default     = "/opt/certificates/server.cer"
  description = "Path to the root certificate file used for Go Server SSL configuration. THIS PATH NEEDS TO MATCH GO_CERTS_DIR."
}

variable "go_root_cert_alias" {
  type        = string
  default     = "root"
  description = "Alias name for the root certificate in the Go Server keystore."
}

variable "go_certs_dir" {
  type        = string
  default     = "/opt/certificates"
  description = "Location where certificates will be downloaded to from S3 bucket.  THIS NEEDS TO MATCH THE PATH OF GO_ROOT_CERT AND GO_KEYSTORE_FILE_PATH"
}

variable "go_pfx_cert_name" {
  type        = string
  default     = "go.pfx"
  description = "File name of Go Server's .pfx certificate."
}

variable "go_root_cert_name" {
  type        = string
  default     = "root.cer"
  description = "File name of Go Server's root certificate."
}

variable "go_license_dir" {
  type        = string
  default     = "/opt/license"
  description = "Location where Go Server license will be downloaded to from S3 bucket.  THIS PATH NEEDS TO MATCH GO_AUTHORIZATION_FILE."
}

variable "go_license_name" {
  type        = string
  default     = "golicense.prvc"
  description = "File name of Go Server's license."
}

variable "go_server_url" {
  type        = string
  default     = "https://server.domain.com:6443/arcgis"
  description = "Go Server URL used by the Data Store to access the Go ArcGIS Server during Web Adaptor configuration."
}


#--------------------------------
# Web Adaptor settings
#--------------------------------
variable "tomcat_keystore_file" {
  type        = string
  default     = "tomcat.pfx"
  description = "Private key certificate (.pfx or .p12) that will be applied to the tomcat certificate store."
}

variable "wa_archives" {
  type        = string
  default     = "/opt/software/archives"
  description = "Path to the directory containing Web Adaptor archive files."
}

variable "wa_setups" {
  type        = string
  default     = "/opt/software/setups"
  description = "Path to the directory containing Web Adaptor setup files."
}

variable "wa_webapp_dir" {
  type        = string
  default     = "/opt/tomcat_arcgis_9.0.97/webapps"
  description = "Path to the directory containing webapp files."
}

variable "wa_hosting_server_url" {
  type        = string
  default     = "https://server.domain.com/hosting"
  description = "Web Adaptor URL used for the Hosting Server Web Adaptor configuration."
}

variable "wa_go_server_url" {
  type        = string
  default     = "https://server.domain.com/go"
  description = "Web Adaptor URL used for the Go ArcGIS Server Web Adaptor configuration."
}

variable "wa_portal_url" {
  type        = string
  default     = "https://server.domain.com/portal"
  description = "Web Adaptor URL used for the Portal Web Adaptor configuration."
}

variable "wa_install_dir" {
  type        = string
  default     = "/opt"
  description = "Base installation directory for Web Adaptor."
}



# -------------------------------
# AWS Secrets Manager variables
# -------------------------------

variable "portal_admin_password" {
  type        = string
  default     = "portal-admin-password"
  description = "Name or value of the ArcGIS Portal Initial Administrator Account password."
}

variable "portal_security_question_answer" {
  type        = string
  default     = "portal-security-question-answer"
  description = "Answer to the security question for the ArcGIS Portal IAA account."
}

variable "portal_keystore_file_password" {
  type        = string
  default     = "portal-keystore-file-password"
  description = "Password for the ArcGIS Portal keystore (.pfx) certificate."
}

variable "hosting_admin_password" {
  type        = string
  default     = "hosting-admin-password"
  description = "Name or value of the Hosting Server Primary Site Administrator Account password."
}

variable "hosting_keystore_file_password" {
  type        = string
  default     = "hosting-keystore-file-password"
  description = "Password for the Hosting Server's keystore (.pfx) certificate."
}

variable "go_admin_password" {
  type        = string
  default     = "go-admin-password"
  description = "Name or value of the Go Server Primary Site Administrator Account password."
}

variable "go_keystore_file_password" {
  type        = string
  default     = "go-keystore-file-password"
  description = "Password for the Go ArcGIS Server's keystore (.pfx) certificate."
}

variable "tomcat_keystore_password" {
  type        = string
  default     = "tomcat-keystore-password"
  description = "Password for tomcat's keystore (.pfx) certificate."
}
