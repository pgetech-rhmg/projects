namespace Paige.Api.Engine.CfnConverter.Scan;

public interface IRepoScanService
{
    Task<RepoScanResult> ScanAsync(RepoScanRequest request, CancellationToken cancellationToken);
}
