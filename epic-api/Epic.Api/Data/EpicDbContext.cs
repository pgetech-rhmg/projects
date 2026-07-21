using Epic.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace Epic.Api.Data;

public sealed class EpicDbContext(DbContextOptions<EpicDbContext> options) : DbContext(options)
{
    public DbSet<AppEntity> Apps => Set<AppEntity>();
    public DbSet<PipelineRunEntity> PipelineRuns => Set<PipelineRunEntity>();
    public DbSet<UserAppEntity> UserApps => Set<UserAppEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AppEntity>(entity =>
        {
            entity.ToTable("apps");
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Name).IsUnique();
            // A repo name is unique only within its source — the same name can
            // exist in two different orgs/hosts.
            entity.HasIndex(e => new { e.GithubSource, e.GithubRepo }).IsUnique();
        });

        modelBuilder.Entity<PipelineRunEntity>(entity =>
        {
            entity.ToTable("pipeline_runs");
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.App)
                .WithMany(a => a.Runs)
                .HasForeignKey(e => e.AppId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<UserAppEntity>(entity =>
        {
            entity.ToTable("user_apps");
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => new { e.UserId, e.AppId }).IsUnique();
            entity.HasOne(e => e.App)
                .WithMany(a => a.UserApps)
                .HasForeignKey(e => e.AppId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
