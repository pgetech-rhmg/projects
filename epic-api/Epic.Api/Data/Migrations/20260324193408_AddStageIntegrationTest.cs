using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Epic.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddStageIntegrationTest : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "StageIntegrationTest",
                table: "pipeline_runs",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StageIntegrationTest",
                table: "pipeline_runs");
        }
    }
}
