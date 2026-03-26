run "s3web_html" {
  command = apply

  module {
    source = "./examples/s3web_html"
  }
}

variables {
  account_num                      = "750713712981"
  account_num_r53                  = "514712703977"
  aws_role                         = "CloudAdmin"
  kms_role                         = "CloudAdmin"
  aws_r53_role                     = "CloudAdmin"
  secretsmanager_github_token      = "github_token_r5vd:pat"
  secretsmanager_artifactory_user  = "jfrog_credentials:jfrog_user"
  secretsmanager_artifactory_token = "jfrog_credentials:jfrog_token"
  secretsmanager_sonar_token       = "sonarqube_credentials:sonar_token"
  aws_region                       = "us-west-2"
  cloudfront_priceclass            = "PriceClass_200"
  build_args1                      = ""
  project_key                      = "s3-static-web-react-npm"
  project_name                     = "s3-static-web-react-npm"
  cloudfront_oac_name              = "s3web-html-oac"
  kms_name                         = "pge_s3web_kms_01"
  kms_description                  = "ccoe-pge-s3web-kms"
  DataClassification               = "Public"
  AppID                            = "1001"
  Environment                      = "Dev"
  CRIS                             = "Low"
  Notify                           = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                            = ["abc1", "def2", "ghi3"]
  Compliance                       = ["None"]
  Order                            = 8115205
  github_repo_url_html             = "https://github.com/pgetech/s3web_html.git"
  github_branch_html               = "main"
  bucket_name_html                 = "rb1c-s3web-html"
  custom_domain_name_html          = "rb1c-s3web-html.nonprod.pge.com"
  s3web_type_html                  = "html"
  project_name_html                = "s3web-html"
  project_key_html                 = "s3web-html"
  object_lock_configuration        = null
}
