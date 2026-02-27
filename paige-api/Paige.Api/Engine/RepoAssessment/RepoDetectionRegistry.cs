namespace Paige.Api.Engine.RepoAssessment;

public static class RepoDetectionRegistry
{
    public static readonly IReadOnlyCollection<LanguageRule> Languages =
    [
        new("C#", [".cs"]),
        new("TypeScript", [".ts"]),
        new("JavaScript", [".js"]),
        new("HTML", [".html", ".htm"]),
        new("CSS", [".css", ".scss", ".sass", ".less"]),
        new("Python", [".py"]),
        new("Java", [".java"]),
        new("Kotlin", [".kt"]),
        new("Scala", [".scala"]),
        new("Groovy", [".groovy"]),
        new("Go", [".go"]),
        new("Rust", [".rs"]),
        new("Ruby", [".rb"]),
        new("PHP", [".php"]),
        new("Shell", [".sh"]),
        new("PowerShell", [".ps1"]),
        new("C", [".c"]),
        new("C++", [".cpp", ".cc", ".cxx", ".hpp", ".h"]),
        new("Swift", [".swift"]),
        new("Objective-C", [".m"]),
        new("Dart", [".dart"]),
        new("Lua", [".lua"]),
        new("R", [".r"]),
        new("SQL", [".sql"]),
        new("COBOL", [".cbl", ".cob"]),
        new("Apex", [".cls"]),
        new("ABAP", [".abap"]),
        new("DataWeave", [".dwl"]),
        new("HCL", [".tf", ".tfvars"]),
    ];

    public static readonly IReadOnlyCollection<FrameworkRule> Frameworks =
    [
        new(
        "ASP.NET Core",
        files => files.Any(f =>
            f.RelativePath.EndsWith("Program.cs") &&
            f.Content != null && f.Content.Contains("WebApplication.CreateBuilder", StringComparison.Ordinal))
        ),

        new(
            "ASP.NET MVC",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("Controller", StringComparison.Ordinal) &&
                f.RelativePath.EndsWith(".cs"))
        ),

        new(
            "Spring Boot",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("@SpringBootApplication", StringComparison.Ordinal))
        ),

        new(
            "Spring MVC",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("@RestController", StringComparison.Ordinal))
        ),

        new(
            "Quarkus",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("io.quarkus", StringComparison.OrdinalIgnoreCase))
        ),

        new(
            "Micronaut",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("io.micronaut", StringComparison.OrdinalIgnoreCase))
        ),

        new(
            "Angular",
            files => files.Any(f =>
                f.RelativePath.EndsWith("angular.json") ||
                f.Content != null && f.Content.Contains("@angular/core", StringComparison.Ordinal))
        ),

        new(
            "React",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("react", StringComparison.OrdinalIgnoreCase) &&
                (f.RelativePath.EndsWith(".tsx") || f.RelativePath.EndsWith(".jsx")))
        ),

        new(
            "Vue",
            files => files.Any(f => f.RelativePath.EndsWith(".vue"))
        ),

        new(
            "Next.js",
            files => files.Any(f =>
                f.RelativePath.Contains("next.config", StringComparison.OrdinalIgnoreCase))
        ),

        new(
            "Svelte",
            files => files.Any(f => f.RelativePath.EndsWith(".svelte"))
        ),

        new(
            "Django",
            files => files.Any(f => f.RelativePath.EndsWith("manage.py"))
        ),

        new(
            "FastAPI",
            files => files.Any(f => f.Content != null && f.Content.Contains("FastAPI(", StringComparison.Ordinal))
        ),

        new(
            "Flask",
            files => files.Any(f => f.Content != null && f.Content.Contains("Flask(", StringComparison.Ordinal))
        ),

        new(
            "MuleSoft",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("www.mulesoft.org/schema/mule", StringComparison.OrdinalIgnoreCase))
        ),

        new(
            "Terraform",
            files => files.Any(f => f.RelativePath.EndsWith(".tf"))
        ),

        new(
            "CloudFormation",
            files => files.Any(f =>
                f.Content != null && f.Content.Contains("AWSTemplateFormatVersion", StringComparison.OrdinalIgnoreCase))
        ),

        new(
            "Maven",
            files => files.Any(f => f.RelativePath.EndsWith("pom.xml"))
        ),

        new(
            "Gradle",
            files => files.Any(f =>
                f.RelativePath.EndsWith("build.gradle") ||
                f.RelativePath.EndsWith("build.gradle.kts"))
        ),

        new(
            "Node.js",
            files => files.Any(f => f.RelativePath.EndsWith("package.json"))
        ),
    ];

    const string FRONTEND = "Frontend";
    const string BACKEND = "Backend";
    const string INTEGRATION = "Integration";
    const string SERVERLESS = "Serverless";
    const string MOBILE = "Mobile";
    const string CONTAINER = "Container";

    public static readonly IReadOnlyCollection<EntryPoint> Entries =
    [
        new("ASP.NET Core Entry", "Program.cs", EntryPointMatchType.FileName, BACKEND, 5),
        new("ASP.NET Core Startup", "Startup.cs", EntryPointMatchType.FileName, BACKEND, 4),
        new("Azure Function", "FunctionName(", EntryPointMatchType.ContentContains, SERVERLESS, 4),
        new("Java Main", "public static void main", EntryPointMatchType.ContentContains, BACKEND, 5),
        new("Spring Boot App", "@SpringBootApplication", EntryPointMatchType.ContentContains, BACKEND, 5),
        new("Python Main", "__main__", EntryPointMatchType.ContentContains, BACKEND, 5),
        new("Django App", "manage.py", EntryPointMatchType.FileName, BACKEND, 5),
        new("FastAPI App", "FastAPI(", EntryPointMatchType.ContentContains, BACKEND, 4),
        new("Flask App", "Flask(__name__)", EntryPointMatchType.ContentContains, BACKEND, 4),
        new("Node Entry", "index.js", EntryPointMatchType.FileName, BACKEND, 4),
        new("Node Entry (TS)", "main.ts", EntryPointMatchType.FileName, BACKEND, 4),
        new("Express App", "app.listen(", EntryPointMatchType.ContentContains, BACKEND, 4),
        new("NestJS App", "NestFactory.create", EntryPointMatchType.ContentContains, BACKEND, 5),
        new("HTML Entry", "index.html", EntryPointMatchType.FileName, FRONTEND, 5),
        new("Angular Bootstrap", "platformBrowserDynamic", EntryPointMatchType.ContentContains, FRONTEND, 5),
        new("React Entry", "createRoot(", EntryPointMatchType.ContentContains, FRONTEND, 5),
        new("Vue Entry", "createApp(", EntryPointMatchType.ContentContains, FRONTEND, 5),
        new("Go Main", "func main()", EntryPointMatchType.ContentContains, BACKEND, 5),
        new("Rust Main", "fn main()", EntryPointMatchType.ContentContains, BACKEND, 5),
        new("Mule Flow", "<flow", EntryPointMatchType.ContentContains, INTEGRATION, 5),
        new("Mule App", "mule-artifact.json", EntryPointMatchType.FileName, INTEGRATION, 4),
        new("Azure Function App", "[FunctionName", EntryPointMatchType.ContentContains, SERVERLESS, 4),
        new("Spring Controller", "@RestController", EntryPointMatchType.ContentContains, BACKEND, 4),
        new("Nuxt Entry", "nuxt.config", EntryPointMatchType.PathContains, FRONTEND, 4),
        new("Svelte Entry", "App.svelte", EntryPointMatchType.FileName, FRONTEND, 4),
        new("Rails Entry", "config/routes.rb", EntryPointMatchType.FileName, BACKEND, 5),
        new("Laravel Entry", "artisan", EntryPointMatchType.FileName, BACKEND, 5),
        new("Android Entry", "MainActivity", EntryPointMatchType.ContentContains, MOBILE, 5),
        new("iOS Entry", "AppDelegate", EntryPointMatchType.ContentContains, MOBILE, 5),
        new("Docker Entrypoint", "ENTRYPOINT", EntryPointMatchType.ContentContains, CONTAINER, 4),
   ];
}

