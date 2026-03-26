data "local_file" "codescan_buildspec_python" {
  filename = "${path.module}/buildspec/codescan/buildspec_codescan_python.yml"
}

data "local_file" "codescan_buildspec_nodejs" {
  filename = "${path.module}/buildspec/codescan/buildspec_codescan_nodejs.yml"
}

data "local_file" "codescan_buildspec_dotnet" {
  filename = "${path.module}/buildspec/codescan/buildspec_codescan_dotnet.yml"
}

data "local_file" "codescan_buildspec_java" {
  filename = "${path.module}/buildspec/codescan/buildspec_codescan_java.yml"
}

data "local_file" "codepublish_buildspec_python" {
  filename = "${path.module}/buildspec/codepublish/buildspec_codepublish_python.yml"
}

data "local_file" "codepublish_buildspec_nodejs" {
  filename = "${path.module}/buildspec/codepublish/buildspec_codepublish_nodejs.yml"
}

data "local_file" "codepublish_buildspec_dotnet" {
  filename = "${path.module}/buildspec/codepublish/buildspec_codepublish_dotnet.yml"
}

data "local_file" "codepublish_buildspec_java" {
  filename = "${path.module}/buildspec/codepublish/buildspec_codepublish_java.yml"
}

data "local_file" "getartifact_buildspec_java" {
  filename = "${path.module}/buildspec/getartifact/buildspec_getartifact_java.yml"
}

data "local_file" "getartifact_buildspec_dotnet" {
  filename = "${path.module}/buildspec/getartifact/buildspec_getartifact_dotnet.yml"
}

data "local_file" "getartifact_buildspec_nodejs" {
  filename = "${path.module}/buildspec/getartifact/buildspec_getartifact_nodejs.yml"
}

data "local_file" "secretscan_buildspec_container" {
  filename = "${path.module}/buildspec/secretscan/buildspec_secretscan_container.yml"
}

data "local_file" "wizscan_buildspec_container_python" {
  filename = "${path.module}/buildspec/wizscan/buildspec_wizscan_container_python.yml"
}

data "local_file" "wizscan_buildspec_container_java" {
  filename = "${path.module}/buildspec/wizscan/buildspec_wizscan_container_java.yml"
}

data "local_file" "wizscan_buildspec_container_nodejs" {
  filename = "${path.module}/buildspec/wizscan/buildspec_wizscan_container_nodejs.yml"
}

# Windows-specific buildspec data sources for .NET
data "local_file" "codescan_buildspec_dotnet_windows" {
  filename = "${path.module}/buildspec/codescan/buildspec_codescan_dotnet_windows.yml"
}

data "local_file" "codepublish_buildspec_dotnet_windows" {
  filename = "${path.module}/buildspec/codepublish/buildspec_codepublish_dotnet_windows.yml"
}

# Container (Java Lambda) codescan buildspec
data "local_file" "codescan_buildspec_java_lambda_container" {
  filename = "${path.module}/buildspec/codescan/buildspec_codescan_java.yml"
}

# Container (Java Lambda) codepublish buildspec
data "local_file" "codepublish_buildspec_java_lambda_container" {
  filename = "${path.module}/buildspec/codepublish/buildspec_codepublish_java_lambda_container.yml"
}