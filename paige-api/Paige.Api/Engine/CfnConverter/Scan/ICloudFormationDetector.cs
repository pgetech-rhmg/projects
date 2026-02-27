using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.CfnConverter.Scan;

public interface ICloudFormationDetector
{
    bool IsCloudFormation(ScannedFile file);
}
