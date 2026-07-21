using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Epic.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddStageReview : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Additive column. Existing rows backfill to "Skipped" (i.e. the
            // Review stage did not run for historical pipeline runs), matching
            // how prior stage columns behave. Non-destructive.
            migrationBuilder.AddColumn<string>(
                name: "StageReview",
                table: "pipeline_runs",
                type: "text",
                nullable: false,
                defaultValue: "Skipped");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StageReview",
                table: "pipeline_runs");
        }
    }
}
