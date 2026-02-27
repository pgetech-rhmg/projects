namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class RepoScanSummary
{
    public int FilesScanned { get; set; }

    public int CloudFormationFilesDetected { get; set; }

    public int TerraformResourcesGenerated { get; set; }
}
