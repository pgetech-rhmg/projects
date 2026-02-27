namespace Paige.Api.Engine.RepoAssessment.Detection;

public static class LanguageRegistry
{
    private static readonly Dictionary<string, string> ExtensionToLanguage =
        new(StringComparer.OrdinalIgnoreCase)
        {
            // C#
            [".cs"] = "C#",
            [".csx"] = "C#",

            // .NET Config
            [".config"] = ".NET-Config",

            // TypeScript / JavaScript
            [".ts"] = "TypeScript",
            [".tsx"] = "TypeScript",
            [".js"] = "JavaScript",
            [".jsx"] = "JavaScript",
            [".mjs"] = "JavaScript",
            [".cjs"] = "JavaScript",

            // Python
            [".py"] = "Python",

            // Java
            [".java"] = "Java",
            [".kt"] = "Kotlin",
            [".kts"] = "Kotlin",

            // Go
            [".go"] = "Go",

            // Rust
            [".rs"] = "Rust",

            // C/C++
            [".c"] = "C",
            [".h"] = "C",
            [".cpp"] = "C++",
            [".hpp"] = "C++",
            [".cc"] = "C++",

            // PHP
            [".php"] = "PHP",

            // Ruby
            [".rb"] = "Ruby",

            // Swift
            [".swift"] = "Swift",

            // Terraform
            [".tf"] = "Terraform",
            [".tfvars"] = "Terraform",

            // CloudFormation
            [".yaml"] = "YAML",
            [".yml"] = "YAML",
            [".json"] = "JSON",

            // Docker
            [".dockerfile"] = "Dockerfile",

            // Shell
            [".sh"] = "Shell",
            [".bash"] = "Shell",
            [".zsh"] = "Shell",
            [".ps1"] = "PowerShell",

            // SQL
            [".sql"] = "SQL",

            // HTML / CSS
            [".html"] = "HTML",
            [".htm"] = "HTML",
            [".css"] = "CSS",
            [".scss"] = "SCSS",
            [".sass"] = "SCSS",

            // Markdown
            [".md"] = "Markdown",

            // XML
            [".xml"] = "XML"
        };

    public static string? DetectLanguage(string extension)
    {
        if (string.IsNullOrWhiteSpace(extension))
        {
            return null;
        }

        if (ExtensionToLanguage.TryGetValue(extension, out string? language))
        {
            return language;
        }

        return null;
    }
}

