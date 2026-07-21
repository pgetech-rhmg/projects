using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Epic.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddGithubSource : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_apps_GithubRepo",
                table: "apps");

            // Default matches GitHubSourceRegistry's synthesized legacy source name,
            // so every pre-existing app keeps resolving to the original single org.
            migrationBuilder.AddColumn<string>(
                name: "GithubSource",
                table: "apps",
                type: "text",
                nullable: false,
                defaultValue: "default");

            migrationBuilder.CreateIndex(
                name: "IX_apps_GithubSource_GithubRepo",
                table: "apps",
                columns: new[] { "GithubSource", "GithubRepo" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_apps_GithubSource_GithubRepo",
                table: "apps");

            migrationBuilder.DropColumn(
                name: "GithubSource",
                table: "apps");

            migrationBuilder.CreateIndex(
                name: "IX_apps_GithubRepo",
                table: "apps",
                column: "GithubRepo",
                unique: true);
        }
    }
}
