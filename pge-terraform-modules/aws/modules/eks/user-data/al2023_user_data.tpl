MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

%{ if pre_bootstrap_user_data != "" ~}
--BOUNDARY
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex
${pre_bootstrap_user_data}

%{ endif ~}
--BOUNDARY
Content-Type: application/node.eks.aws

%{ if enable_bootstrap_user_data ~}
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${cluster_endpoint}
    certificateAuthority: ${cluster_auth_base64}
    cidr: ${cluster_service_cidr}
  kubelet:
    config:
      maxPods: 112
    flags:
    - "--node-labels=key=value"${bootstrap_extra_args != "" ? "\n    ${bootstrap_extra_args}" : ""}

%{ endif ~}
%{ if post_bootstrap_user_data != "" ~}
--BOUNDARY
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex
${post_bootstrap_user_data}

%{ endif ~}
--BOUNDARY--