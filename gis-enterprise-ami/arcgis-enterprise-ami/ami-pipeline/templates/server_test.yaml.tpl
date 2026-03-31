name: ArcGIS Server Test
description: Tests ArcGIS Server installation
schemaVersion: 1.0

phases:
  - name: test
    steps:
      - name: VerifyInstallation
        action: ExecuteBash
        onFailure: Abort
        inputs:
          commands:
            - echo "Testing ArcGIS Server installation"
            - echo "TODO Add actual test commands here"
            - exit 0
