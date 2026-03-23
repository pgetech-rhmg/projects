-- ============================================================================
-- EPIC API — Local seed data
-- Run: psql -h localhost -U epic -d epicdb -f seed.sql
-- Or:  docker exec -i epic-postgres psql -U epic -d epicdb < seed.sql
-- ============================================================================

-- Clear existing data
TRUNCATE user_apps, pipeline_runs, apps RESTART IDENTITY CASCADE;

-- ============================================================================
-- Apps
-- ============================================================================
INSERT INTO apps (
  "Id", "Name", "DisplayName", "Description", "AppType", "Technology",
  "Cloud", "Environment", "Team", "Domain", "GithubRepo", "GithubBranch",
  "NodeVersion", "PythonVersion", "JavaVersion", "DotnetVersion",
  "AwsAccountId", "AwsS3", "AwsCloudfront",
  "CreatedBy", "LastUpdatedBy", "CreatedAt", "LastUpdatedAt"
) VALUES
  (1,  'customer-portal',    'Customer Portal',    'Public-facing Angular app for customers.',          'angular', 'Angular', 'AWS',   'prod', 'Digital Experience', 'portal.pge.com',           'customer-portal',    'main', '20', NULL, NULL, NULL, '514712703977', 'pge-epic-customer-portal-web-prod', 'E1A2B3C4D5E6F7', 'rhmg', 'rhmg', '2026-01-15', '2026-03-20'),
  (2,  'billing-api',        'Billing API',        'Backend API for billing and payment processing.',   'python',  'Python',  'AWS',   'prod', 'Revenue Services',  'billing-api.pge.com',      'billing-api',        'main', NULL, '3.11', NULL, NULL, '514712703977', NULL, NULL, 'rhmg', 'rhmg', '2026-01-20', '2026-03-20'),
  (3,  'outage-tracker',     'Outage Tracker',     'Java service for real-time outage tracking.',       'java',    'Java',    'Azure', 'test', 'Grid Operations',   'outage.pge.com',           'outage-tracker',     'main', NULL, NULL, '17', NULL, '514712703977', NULL, NULL, 'maxine.bailey', 'maxine.bailey', '2026-02-01', '2026-03-19'),
  (4,  'grid-dashboard',     'Grid Dashboard',     '.NET dashboard for grid monitoring.',               'dotnet',  '.NET',    'AWS',   'dev',  'Grid Operations',   'grid.pge.com',             'grid-dashboard',     'main', NULL, NULL, NULL, '10.x', '514712703977', NULL, NULL, 'rhmg', 'rhmg', '2026-02-05', '2026-03-18'),
  (5,  'field-ops-ui',       'Field Ops UI',       'Angular app for field operations management.',      'angular', 'Angular', 'Azure', 'qa',   'Field Services',    'fieldops.pge.com',         'field-ops-ui',       'main', '20', NULL, NULL, NULL, NULL, NULL, NULL, 'rhmg', 'rhmg', '2026-02-10', '2026-03-17'),
  (6,  'meter-data-service', 'Meter Data Service', 'Java service for smart meter data ingestion.',      'java',    'Java',    'AWS',   'prod', 'Metering',          'meterdata.pge.com',        'meter-data-service', 'main', NULL, NULL, '17', NULL, '514712703977', NULL, NULL, 'maxine.bailey', 'maxine.bailey', '2026-02-15', '2026-03-17'),
  (7,  'notifications-api',  'Notifications API',  'Python service for push/email notifications.',      'python',  'Python',  'AWS',   'prod', 'Digital Experience', 'notify-api.pge.com',       'notifications-api',  'main', NULL, '3.11', NULL, NULL, '514712703977', NULL, NULL, 'rhmg', 'rhmg', '2026-02-20', '2026-03-16'),
  (8,  'asset-tracker',      'Asset Tracker',      '.NET service for infrastructure asset management.', 'dotnet',  '.NET',    'Azure', 'qa',   'Asset Management',  'assets.pge.com',           'asset-tracker',      'main', NULL, NULL, NULL, '10.x', NULL, NULL, NULL, 'rhmg', 'rhmg', '2026-02-25', '2026-03-16'),
  (9,  'work-order-service', 'Work Order Service', 'Java backend for work order lifecycle.',            'java',    'Java',    'AWS',   'test', 'Field Services',    'workorders.pge.com',       'work-order-service', 'main', NULL, NULL, '17', NULL, '514712703977', NULL, NULL, 'maxine.bailey', 'maxine.bailey', '2026-03-01', '2026-03-15'),
  (10, 'ops-reporting-ui',   'Ops Reporting UI',   'Angular reporting dashboard for operations.',       'angular', 'Angular', 'AWS',   'dev',  'Grid Operations',   'ops-reports.pge.com',      'ops-reporting-ui',   'main', '20', NULL, NULL, NULL, '514712703977', NULL, NULL, 'rhmg', 'rhmg', '2026-03-05', '2026-03-15');

-- Reset sequence
SELECT setval(pg_get_serial_sequence('apps', 'Id'), (SELECT MAX("Id") FROM apps));

-- ============================================================================
-- Pipeline runs (for customer-portal — app_id=1)
-- ============================================================================
INSERT INTO pipeline_runs (
  "Id", "AppId", "Status", "TriggeredBy", "Branch", "Environment",
  "StartedAt", "Duration",
  "StageBuild", "StageTest", "StageScan", "StageInfraDeploy", "StageAppDeploy"
) VALUES
  (4821, 1, 'Success',   'Robb Morgan',   'main',                     'prod', '2026-03-20 08:42', '4m 32s', 'Success',   'Success', 'Success', 'External', 'Success'),
  (4820, 1, 'Success',   'System',        'main',                     'prod', '2026-03-19 02:00', '4m 18s', 'Success',   'Success', 'Success', 'External', 'Success'),
  (4819, 1, 'Failed',    'Robb Morgan',   'feature/account-redesign', 'qa',   '2026-03-18 14:10', '2m 05s', 'Success',   'Failed',  'Skipped', 'Skipped',  'Skipped'),
  (4818, 1, 'Success',   'Robb Morgan',   'feature/account-redesign', 'qa',   '2026-03-18 11:30', '4m 44s', 'Success',   'Success', 'Success', 'External', 'Success'),
  (4817, 1, 'Cancelled', 'Robb Morgan',   'feature/account-redesign', 'dev',  '2026-03-17 16:55', '0m 48s', 'Cancelled', 'Skipped', 'Skipped', 'Skipped',  'Skipped');

-- Pipeline runs (for billing-api — app_id=2)
INSERT INTO pipeline_runs (
  "Id", "AppId", "Status", "TriggeredBy", "Branch", "Environment",
  "StartedAt", "Duration",
  "StageBuild", "StageTest", "StageScan", "StageInfraDeploy", "StageAppDeploy"
) VALUES
  (4830, 2, 'Running', 'System',        'main',               'prod', '2026-03-20 09:15', NULL,     'Success', 'Success', 'Running', 'Skipped', 'Skipped'),
  (4829, 2, 'Success', 'Robb Morgan',   'feature/refund-flow', 'dev', '2026-03-19 14:00', '3m 55s', 'Success', 'Success', 'Success', 'External', 'Success');

-- Pipeline runs (for outage-tracker — app_id=3)
INSERT INTO pipeline_runs (
  "Id", "AppId", "Status", "TriggeredBy", "Branch", "Environment",
  "StartedAt", "Duration",
  "StageBuild", "StageTest", "StageScan", "StageInfraDeploy", "StageAppDeploy"
) VALUES
  (4835, 3, 'Failed',  'Maxine Bailey', 'feature/realtime-feed', 'test', '2026-03-19 14:30', '1m 45s', 'Success', 'Failed', 'Skipped', 'Skipped', 'Skipped'),
  (4834, 3, 'Success', 'Maxine Bailey', 'feature/realtime-feed', 'dev',  '2026-03-18 10:20', '5m 12s', 'Success', 'Success', 'Success', 'Success', 'Success');

-- Pipeline runs (for grid-dashboard — app_id=4)
INSERT INTO pipeline_runs (
  "Id", "AppId", "Status", "TriggeredBy", "Branch", "Environment",
  "StartedAt", "Duration",
  "StageBuild", "StageTest", "StageScan", "StageInfraDeploy", "StageAppDeploy"
) VALUES
  (4840, 4, 'Success', 'System',      'main',                  'dev', '2026-03-18 16:55', '3m 20s', 'Success', 'Success', 'Success', 'External', 'Success'),
  (4839, 4, 'Success', 'Robb Morgan', 'feature/dark-mode',     'dev', '2026-03-17 11:00', '3m 45s', 'Success', 'Success', 'Success', 'Success',  'Success');

-- Reset sequence
SELECT setval(pg_get_serial_sequence('pipeline_runs', 'Id'), (SELECT MAX("Id") FROM pipeline_runs));

-- ============================================================================
-- User-app tracking (rhmg tracks apps 1-5, 7-8, 10)
-- ============================================================================
INSERT INTO user_apps ("Id", "UserId", "AppId", "AddedAt") VALUES
  (1,  'rhmg', 1,  '2026-01-15'),
  (2,  'rhmg', 2,  '2026-01-20'),
  (3,  'rhmg', 3,  '2026-02-01'),
  (4,  'rhmg', 4,  '2026-02-05'),
  (5,  'rhmg', 5,  '2026-02-10'),
  (6,  'rhmg', 7,  '2026-02-20'),
  (7,  'rhmg', 8,  '2026-02-25'),
  (8,  'rhmg', 10, '2026-03-05'),
  (9,  'maxine.bailey', 3,  '2026-02-01'),
  (10, 'maxine.bailey', 6,  '2026-02-15'),
  (11, 'maxine.bailey', 9,  '2026-03-01');

SELECT setval(pg_get_serial_sequence('user_apps', 'Id'), (SELECT MAX("Id") FROM user_apps));

-- ============================================================================
-- Done
-- ============================================================================
SELECT 'Seed complete: ' || count(*) || ' apps, ' ||
       (SELECT count(*) FROM pipeline_runs) || ' runs, ' ||
       (SELECT count(*) FROM user_apps) || ' user-app links'
FROM apps;
