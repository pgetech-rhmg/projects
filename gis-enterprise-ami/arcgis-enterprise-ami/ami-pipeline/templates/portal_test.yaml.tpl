name: ArcGIS Portal Test
description: Tests ArcGIS Portal installation
schemaVersion: 1.0

phases:
  - name: test
    steps:
      - name: VerifyInstallation
        action: ExecuteBash
        onFailure: Abort
        inputs:
          commands:
            - echo "Testing ArcGIS Portal installation"
            - echo "TODO Add actual test commands here"
            - exit 0
