using System.Text;

using Paige.Api.Engine.CfnConverter.Cfn;

namespace Paige.Api.Engine.CfnConverter.Terraform;

public sealed class TerraformProjectBuilder
{
    public TerraformGenerationResponse Build(IReadOnlyList<CfnResult> modules)
    {
        var files = new Dictionary<string, string>
        {
            ["main.tf"] = GenerateMainTf(modules),
            ["providers.tf"] = ProvidersTf,
            ["versions.tf"] = VersionsTf,
            ["variables.tf"] = VariablesTf,
            ["outputs.tf"] = OutputsTf
        };

        foreach (var module in modules)
        {
            foreach (var file in module.Files.EnumerateObject())
            {
                files[$"modules/{module.Module}/{file.Name}"] = file.Value.GetString() ?? string.Empty;
            }
        }

        return new TerraformGenerationResponse
        {
            Files = files
        };
    }

    private static string GenerateMainTf(IReadOnlyList<CfnResult> modules)
    {
        var sb = new StringBuilder();

        foreach (var module in modules.Select(m => m.Module))
        {
            var safeName = module.Replace("-", "_");

            sb.AppendLine($@"
module ""{safeName}"" {{
  source = ""./modules/{module}""
}}
".Trim());

            sb.AppendLine();
        }

        return sb.ToString().Trim();
    }

    private const string ProvidersTf = @"
provider ""aws"" {
  region = var.aws_region
}
";

    private const string VersionsTf = @"
terraform {
  required_version = "">= 1.5.0""

  required_providers {
    aws = {
      source  = ""hashicorp/aws""
      version = ""~> 5.0""
    }
  }
}
";

    private const string VariablesTf = @"
variable ""aws_region"" {
  type = string
}
";

    private const string OutputsTf = "";
}

