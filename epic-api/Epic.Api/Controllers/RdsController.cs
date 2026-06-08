using System.Data;
using System.Data.Common;
using Epic.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Epic.Api.Controllers;

[ApiController]
[Route("api/diag/rds")]
[Tags("Diag")]
public sealed class RdsController(EpicDbContext db, IHostEnvironment env) : ControllerBase
{
    [HttpPost]
    [ProducesResponseType(200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> Execute([FromBody] SqlRequest request, CancellationToken ct)
    {
        if (!env.IsDevelopment())
            return NotFound();

        if (string.IsNullOrWhiteSpace(request.Sql))
            return BadRequest(new { error = "sql is required" });

        var connection = db.Database.GetDbConnection();
        if (connection.State != ConnectionState.Open)
            await connection.OpenAsync(ct);

        try
        {
            await using var command = connection.CreateCommand();
            command.CommandText = request.Sql;

            var trimmed = request.Sql.TrimStart();
            var isQuery = trimmed.StartsWith("SELECT", StringComparison.OrdinalIgnoreCase)
                       || trimmed.StartsWith("WITH", StringComparison.OrdinalIgnoreCase);

            if (isQuery)
            {
                await using var reader = await command.ExecuteReaderAsync(ct);
                var rows = new List<Dictionary<string, object?>>();

                while (await reader.ReadAsync(ct))
                {
                    var row = new Dictionary<string, object?>();
                    for (var i = 0; i < reader.FieldCount; i++)
                    {
                        row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                    }
                    rows.Add(row);
                }

                return Ok(new { rowCount = rows.Count, rows });
            }
            else
            {
                var rowsAffected = await command.ExecuteNonQueryAsync(ct);
                return Ok(new { rowsAffected });
            }
        }
        catch (DbException ex)
        {
            return Ok(new { error = ex.Message });
        }
    }
}

public sealed record SqlRequest(string Sql);
