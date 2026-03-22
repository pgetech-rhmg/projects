name: ArcGIS ${component_name} Installer
description: Downloads and runs the install script for ${component_name}
schemaVersion: 1.0

phases:
  - name: build
    steps:
      - name: DownloadInstallScript
        action: S3Download
        inputs:
          - source: s3://${source_bucket}/arcgis_install/arcgis-install-package.zip
            destination: /tmp/arcgis-install-package.zip

      - name: ExtractPackage
        action: ExecuteBash
        inputs:
          commands:
            - echo "Extracting installation package..."
            - unzip /tmp/arcgis-install-package.zip -d /tmp/arcgis-install-package/

      - name: RunInstallation
        action: ExecuteBash
        onFailure: Abort
        maxAttempts: 3
        inputs:
          commands:
            - cd /tmp/arcgis-install-package
            - chmod +x arcgis-install.sh
            - chmod +x fetch-jfrog-artifacts.sh
            - echo "Installing ${component_name}..."
            - export BASE_S3_URI="${esri_source_location}"
            - ./arcgis-install.sh "${component_name}"
