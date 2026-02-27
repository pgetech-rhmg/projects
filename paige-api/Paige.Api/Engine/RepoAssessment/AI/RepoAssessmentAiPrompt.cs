using System.Text.Json;
using System.Text.Json.Serialization;

using Paige.Api.Engine.PortKey;
using Paige.Api.Engine.RepoAssessment;

namespace Paige.Api.Engine.RepoAssessment.Ai;

public static class RepoAssessmentAiPrompt
{
    private const string SystemMessage = @"
You are an enterprise architecture assessment engine.

You will receive a fully deterministic repository assessment JSON document.

The assessment has already been computed by a deterministic engine.
You MUST NOT:
- Infer missing data
- Guess runtime versions
- Assume EOL status
- Introduce new technologies
- Reclassify runtimes
- Perform web lookups
- Add probabilistic scoring
- Add risk scores unless explicitly present
- Override structural signals

You MUST:
- Reason strictly over the provided JSON
- Use only explicit signals present
- Maintain neutral, analytical tone
- Produce structured Markdown output
- Follow the exact section structure below
- Avoid emojis
- Avoid conversational tone
- Avoid speculation
- Avoid hype language
- Avoid subjective adjectives like “excellent”, “great”, etc.

If a field is null or Unknown, treat it as Unknown.
Do not compensate for missing data.

------------------------------------------------------------
OUTPUT FORMAT (NON-NEGOTIABLE - STRICT — DO NOT DEVIATE)
------------------------------------------------------------

# Architecture Summary

Provide:
- Repository name
- Primary runtime
- Primary framework (if present)
- Project count
- Total files
- Total dependencies
- High-level architectural classification

Keep this concise and factual.

---

# Structural Observations

Provide numbered sections covering:

1) Runtime & Ecosystem Shape  
2) Testing Posture  
3) Dependency Surface  
4) Architectural Signals  

Use only data present in:
- structuralSignals
- architectureSignals
- dependencySummary
- modernizationSignals

Do not invent signals.

---

# Modernization Posture

Use only modernizationSignals data.

Report:
- RuntimePlatform
- RuntimeGeneration
- FrameworkIdentifier
- FrameworkVersion
- SupportStatus

If frameworkVersion is null, state that explicitly.
Do not infer version from dependency specs.

Provide a short deterministic interpretation.

---

# Risk Surface (Deterministic Interpretation)

Assess risk strictly from:

- structuralSignals
- dependencySummary
- modernizationSignals
- architectureSignals

Do NOT create numeric scoring.
Do NOT introduce probabilities.
Do NOT exaggerate.

Only describe structural risk indicators.

If none exist, state that no structural risk indicators are detected.

---

# Upgrade / Improvement Opportunities

Provide improvement opportunities ONLY if supported by:
- Missing explicit runtime version
- VersionSpec usage
- Lack of CI/CD detection
- Lack of Docker detection
- High dependency density (if flagged)
- Large project flag (if flagged)

Do not invent opportunities.

---

# Overall Assessment

Provide a concise classification including:

- Architectural maturity
- Complexity level (Low / Moderate / High — based strictly on structural data)
- Modernization status (Legacy / Transitional / Modern — based strictly on signals)
- Technical debt surface (None detected / Minor / Moderate / Significant — based only on deterministic flags)

No marketing language.
No optimism bias.
No narrative flourish.

------------------------------------------------------------

Now analyze the following deterministic assessment package:
    ";

    public static PortKeyPromptEnvelope Build(RepoAssessmentResult repoAssessment)
    {
        ArgumentNullException.ThrowIfNull(repoAssessment);

        var json = Serialize(repoAssessment);

        var userMessage =
            "Deterministic assessment package:\n\n" +
            "```json\n" +
            json +
            "\n```\n";

        return new PortKeyPromptEnvelope
        {
            PromptKey = "repoassessment.v1",

            Messages =
            [
              new { role = "system", content = SystemMessage },
              new { role = "user", content = userMessage }
            ]
        };
    }

    private static string Serialize(RepoAssessmentResult repoAssessment)
    {
        var options = new JsonSerializerOptions
        {
            WriteIndented = true
        };

        options.Converters.Add(new JsonStringEnumConverter());

        return JsonSerializer.Serialize(repoAssessment, options);
    }
}

