name: ArcGIS Web Adapter Test
description: Tests ArcGIS Web Adapter installation
schemaVersion: 1.0

phases:
  - name: test
    steps:
      - name: VerifyInstallation
        action: ExecuteBash
        onFailure: Abort
        inputs:
          commands:
            - echo "Testing ArcGIS Web Adapter installation"
            - echo "TODO Add actual test commands here"
            - exit 0
