using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Epic.Api.Data.Migrations
{
    /// <summary>
    /// Data migration: the identity key on user_apps.UserId was the MSAL display
    /// name (e.g. "Morgan, Robb") under the old X-Epic-User placeholder auth.
    /// With real Entra ID JWT auth, UserId is now the 4-char PG&amp;E corpId derived
    /// from the token's email local-part. This remaps existing rows from display
    /// name to corpId so users keep their app associations.
    ///
    /// The display-name → corpId mapping is not derivable in SQL (no email on
    /// user_apps), so known users are mapped explicitly below. Any row not matched
    /// here keeps its old display-name value and will simply not resolve for the
    /// re-authenticated user — a safe, non-destructive orphan: the user re-adds
    /// the app (or an admin updates the row). Add a WHERE/UPDATE pair per user as
    /// the roster grows. apps.CreatedBy / apps.LastUpdatedBy already stored display
    /// names and are intentionally left unchanged (they are display-only).
    /// </summary>
    public partial class MigrateUserAppsToCorpId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "UPDATE user_apps SET \"UserId\" = 'rhmg' WHERE \"UserId\" = 'Morgan, Robb';");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "UPDATE user_apps SET \"UserId\" = 'Morgan, Robb' WHERE \"UserId\" = 'rhmg';");
        }
    }
}
