name: ArcGIS DataStore Test
description: Tests ArcGIS DataStore installation
schemaVersion: 1.0

phases:
  - name: test
    steps:
      - name: VerifyInstallation
        action: ExecuteBash
        onFailure: Abort
        inputs:
          commands:
            - echo "Testing ArcGIS DataStore installation"
            - echo "TODO Add actual test commands here"
            - exit 0
