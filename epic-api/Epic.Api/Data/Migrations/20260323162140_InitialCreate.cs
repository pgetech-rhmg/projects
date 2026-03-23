using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Epic.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "apps",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    DisplayName = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    AppType = table.Column<string>(type: "text", nullable: false),
                    Technology = table.Column<string>(type: "text", nullable: false),
                    Cloud = table.Column<string>(type: "text", nullable: false),
                    Environment = table.Column<string>(type: "text", nullable: false),
                    Team = table.Column<string>(type: "text", nullable: false),
                    Domain = table.Column<string>(type: "text", nullable: false),
                    GithubRepo = table.Column<string>(type: "text", nullable: false),
                    GithubBranch = table.Column<string>(type: "text", nullable: false),
                    NodeVersion = table.Column<string>(type: "text", nullable: true),
                    PythonVersion = table.Column<string>(type: "text", nullable: true),
                    JavaVersion = table.Column<string>(type: "text", nullable: true),
                    DotnetVersion = table.Column<string>(type: "text", nullable: true),
                    AwsAccountId = table.Column<string>(type: "text", nullable: true),
                    AwsS3 = table.Column<string>(type: "text", nullable: true),
                    AwsCloudfront = table.Column<string>(type: "text", nullable: true),
                    AwsEc2InstanceId = table.Column<string>(type: "text", nullable: true),
                    AzureSubscription = table.Column<string>(type: "text", nullable: true),
                    AzureResourceGroup = table.Column<string>(type: "text", nullable: true),
                    CreatedBy = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastUpdatedBy = table.Column<string>(type: "text", nullable: false),
                    LastUpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_apps", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "pipeline_runs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    AppId = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    TriggeredBy = table.Column<string>(type: "text", nullable: false),
                    Branch = table.Column<string>(type: "text", nullable: false),
                    Environment = table.Column<string>(type: "text", nullable: false),
                    StartedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Duration = table.Column<string>(type: "text", nullable: true),
                    StageBuild = table.Column<string>(type: "text", nullable: false),
                    StageTest = table.Column<string>(type: "text", nullable: false),
                    StageScan = table.Column<string>(type: "text", nullable: false),
                    StageInfraDeploy = table.Column<string>(type: "text", nullable: false),
                    StageAppDeploy = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_pipeline_runs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_pipeline_runs_apps_AppId",
                        column: x => x.AppId,
                        principalTable: "apps",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_apps",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<string>(type: "text", nullable: false),
                    AppId = table.Column<int>(type: "integer", nullable: false),
                    AddedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_apps", x => x.Id);
                    table.ForeignKey(
                        name: "FK_user_apps_apps_AppId",
                        column: x => x.AppId,
                        principalTable: "apps",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_apps_GithubRepo",
                table: "apps",
                column: "GithubRepo",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_apps_Name",
                table: "apps",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_pipeline_runs_AppId",
                table: "pipeline_runs",
                column: "AppId");

            migrationBuilder.CreateIndex(
                name: "IX_user_apps_AppId",
                table: "user_apps",
                column: "AppId");

            migrationBuilder.CreateIndex(
                name: "IX_user_apps_UserId_AppId",
                table: "user_apps",
                columns: new[] { "UserId", "AppId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "pipeline_runs");

            migrationBuilder.DropTable(
                name: "user_apps");

            migrationBuilder.DropTable(
                name: "apps");
        }
    }
}
