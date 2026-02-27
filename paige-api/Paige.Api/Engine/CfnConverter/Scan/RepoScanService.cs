using Microsoft.Extensions.Options;

using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class RepoScanService : IRepoScanService
{
    private readonly Config _config;
    private readonly IRepoCloner _repoCloner;
    private readonly IFileScanner _fileScanner;
    private readonly ICloudFormationDetector _cfnDetector;
    private readonly ICloudFormationClassifier _cfnClassifier;

    public RepoScanService(
        IOptions<Config> config,
        IRepoCloner repoCloner,
        IFileScanner fileScanner,
        ICloudFormationDetector cfnDetector,
        ICloudFormationClassifier cfnClassifier)
    {
        _config = config.Value;
        _repoCloner = repoCloner;
        _fileScanner = fileScanner;
        _cfnDetector = cfnDetector;
        _cfnClassifier = cfnClassifier;
    }

    public async Task<RepoScanResult> ScanAsync(RepoScanRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        ClonedRepo clonedRepo = await _repoCloner.CloneAsync($"{_config.GithubBaseUrl}/{request.RepoName}", request.Branch, _config.GithubToken, cancellationToken);

        IReadOnlyList<ScannedFile> scannedFiles = _fileScanner.Scan(clonedRepo.LocalPath);

        List<CloudFormationScanResult> scanResults = [];

        foreach (ScannedFile file in scannedFiles)
        {
            if (!_cfnDetector.IsCloudFormation(file))
            {
                continue;
            }

            CloudFormationTemplate template = CloudFormationTemplateLoader.Load(file);

            if (!template.RawTemplate.ContainsKey("Resources"))
            {
                continue;
            }

            CloudFormationTemplateClassification classification = _cfnClassifier.Classify(template);

            IReadOnlyDictionary<string, object?> parameterDefaults = ExtractParameterDefaults(template);

            scanResults.Add(new CloudFormationScanResult
            {
                Path = file.RelativePath,
                Format = template.Format,
                Classification = classification,
                ResourceTypes = ExtractResourceTypes(template),
                ParameterDefaults = parameterDefaults,
                RawTemplate = template.RawTemplate,
                RawCfn = template.RawCfn
            });
        }

        return new RepoScanResult
        {
            Repo = new RepoMetadata
            {
                RepoName = request.RepoName,
                Branch = request.Branch,
                CommitSha = clonedRepo.CommitSha
            },
            CloudFormationFiles = scanResults
                .OrderBy(r => r.Path, StringComparer.OrdinalIgnoreCase)
                .ToList(),
            Summary = new RepoScanSummary
            {
                FilesScanned = scannedFiles.Count,
                CloudFormationFilesDetected = scanResults.Count,
                TerraformResourcesGenerated = 0
            }
        };
    }

    private static IReadOnlyList<string> ExtractResourceTypes(
        CloudFormationTemplate template)
    {
        if (!template.RawTemplate.TryGetValue("Resources", out object? resources)
            || resources is not Dictionary<string, object?> resourceMap)
        {
            return [];
        }

        HashSet<string> types = new(StringComparer.OrdinalIgnoreCase);

        foreach (object? resource in resourceMap.Values)
        {
            if (resource is Dictionary<string, object?> resourceBody
                && resourceBody.TryGetValue("Type", out object? typeValue)
                && typeValue is string type)
            {
                types.Add(type);
            }
        }

        return [.. types.OrderBy(t => t, StringComparer.OrdinalIgnoreCase)];
    }

    private static IReadOnlyDictionary<string, object?> ExtractParameterDefaults(CloudFormationTemplate template)
    {
        if (!template.RawTemplate.TryGetValue("Parameters", out object? parameters)
            || parameters is not Dictionary<string, object?> parameterMap)
        {
            return new Dictionary<string, object?>();
        }

        Dictionary<string, object?> defaults = new(StringComparer.OrdinalIgnoreCase);

        foreach ((string parameterName, object? parameterValue) in parameterMap)
        {
            if (parameterValue is not Dictionary<string, object?> parameterBody)
            {
                continue;
            }

            if (!parameterBody.TryGetValue("Default", out object? defaultValue))
            {
                continue;
            }

            defaults[parameterName] = defaultValue;
        }

        return defaults;
    }
}
