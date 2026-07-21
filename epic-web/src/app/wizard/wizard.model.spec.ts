import {
  APP_NAME_PATTERN,
  APP_TYPE_LABELS,
  AWS_ACCOUNT_ID_PATTERN,
  AZURE_SUBSCRIPTION_ID_PATTERN,
  AppType,
  BUILD_TEST_TOOL_OPTIONS,
  SCAN_TOOL_OPTIONS,
  appTypesForCloud,
  defaultBuildTestTool,
  defaultCloudForAppType,
  defaultScanTool,
  emptyAnswers,
  emptyDeployTarget,
  normalizeAppName,
  normalizeAwsAccountId,
  normalizeAzureSubscriptionId,
  relevantDeployTargetKeys,
} from './wizard.model';

const ALL_APP_TYPES = Object.keys(APP_TYPE_LABELS) as AppType[];

describe('normalizeAppName', () => {
  it('lowercases capitals', () => {
    expect(normalizeAppName('MyApp')).toBe('myapp');
  });

  it('folds spaces and underscores into single hyphens', () => {
    expect(normalizeAppName('My New_App')).toBe('my-new-app');
    expect(normalizeAppName('a   b')).toBe('a-b');
    expect(normalizeAppName('a___b')).toBe('a-b');
  });

  it('is idempotent', () => {
    const once = normalizeAppName('My New App');
    expect(normalizeAppName(once)).toBe(once);
  });

  it('produces a value that satisfies APP_NAME_PATTERN for a typical name', () => {
    expect(APP_NAME_PATTERN.test(normalizeAppName('My New App'))).toBe(true);
  });
});

describe('APP_NAME_PATTERN', () => {
  it('accepts kebab-case starting with a letter, 3–41 chars', () => {
    expect(APP_NAME_PATTERN.test('abc')).toBe(true);
    expect(APP_NAME_PATTERN.test('my-new-app')).toBe(true);
    expect(APP_NAME_PATTERN.test('a' + '-b'.repeat(20))).toBe(true); // 41 chars
  });

  it('rejects too-short, leading non-letter, and over-length names', () => {
    expect(APP_NAME_PATTERN.test('ab')).toBe(false);
    expect(APP_NAME_PATTERN.test('-abc')).toBe(false);
    expect(APP_NAME_PATTERN.test('1abc')).toBe(false);
    expect(APP_NAME_PATTERN.test('a'.repeat(42))).toBe(false);
  });
});

describe('normalizeAwsAccountId', () => {
  it('strips non-digits', () => {
    expect(normalizeAwsAccountId('1234-5678-9012')).toBe('123456789012');
    expect(normalizeAwsAccountId('1234 5678 9012')).toBe('123456789012');
  });

  it('caps at 12 digits', () => {
    expect(normalizeAwsAccountId('1234567890123456')).toBe('123456789012');
  });

  it('produces a value that satisfies AWS_ACCOUNT_ID_PATTERN once 12 digits are present', () => {
    expect(AWS_ACCOUNT_ID_PATTERN.test(normalizeAwsAccountId('1234-5678-9012'))).toBe(true);
  });
});

describe('normalizeAzureSubscriptionId', () => {
  it('trims and lowercases', () => {
    const id = '  ABCDEF00-1111-2222-3333-444455556666  ';
    const normalized = normalizeAzureSubscriptionId(id);
    expect(normalized).toBe('abcdef00-1111-2222-3333-444455556666');
    expect(AZURE_SUBSCRIPTION_ID_PATTERN.test(normalized)).toBe(true);
  });

  it('does not coerce a non-UUID into a valid one', () => {
    expect(AZURE_SUBSCRIPTION_ID_PATTERN.test(normalizeAzureSubscriptionId('not-a-uuid'))).toBe(false);
  });
});

describe('defaultScanTool', () => {
  it('returns the first scan tool for code-bearing app types', () => {
    expect(defaultScanTool('angular')).toBe(SCAN_TOOL_OPTIONS[0]);
    expect(defaultScanTool('dotnet')).toBe(SCAN_TOOL_OPTIONS[0]);
  });

  it('returns empty string for app types with no scan field', () => {
    for (const t of ['btp', 'infra', 'ami'] as AppType[]) {
      expect(defaultScanTool(t)).toBe('');
    }
  });
});

describe('defaultBuildTestTool', () => {
  it('returns the first configured runner for an app type', () => {
    expect(defaultBuildTestTool('angular')).toBe('karma');
    expect(defaultBuildTestTool('react')).toBe('jest');
    expect(defaultBuildTestTool('go')).toBe('gotestsum');
  });

  it('returns empty string when the app type has no runners', () => {
    for (const t of ['html', 'ami', 'cap', 'btp', 'infra'] as AppType[]) {
      expect(defaultBuildTestTool(t)).toBe('');
    }
  });

  it('never returns a tool absent from the option list', () => {
    for (const t of ALL_APP_TYPES) {
      const tool = defaultBuildTestTool(t);
      if (tool) expect(BUILD_TEST_TOOL_OPTIONS[t]).toContain(tool);
    }
  });
});

describe('appTypesForCloud', () => {
  it('returns every app type for aws and sap', () => {
    expect(appTypesForCloud('aws')).toEqual(ALL_APP_TYPES);
    expect(appTypesForCloud('sap')).toEqual(ALL_APP_TYPES);
  });

  it('excludes ami/btp/cap for azure', () => {
    const azure = appTypesForCloud('azure');
    expect(azure).not.toContain('ami');
    expect(azure).not.toContain('btp');
    expect(azure).not.toContain('cap');
    expect(azure).toContain('angular');
  });
});

describe('defaultCloudForAppType', () => {
  it('always defaults to aws', () => {
    for (const t of ALL_APP_TYPES) {
      expect(defaultCloudForAppType(t)).toBe('aws');
    }
  });
});

describe('emptyDeployTarget', () => {
  it('returns an all-empty-string deploy target', () => {
    const dt = emptyDeployTarget();
    expect(Object.values(dt).every((v) => v === '')).toBe(true);
    expect(Object.keys(dt)).toContain('s3');
    expect(Object.keys(dt)).toContain('appUrl');
  });
});

describe('relevantDeployTargetKeys', () => {
  it('returns Azure App Service keys for any azure app', () => {
    expect(relevantDeployTargetKeys('dotnet', 'azure')).toEqual([
      'appServiceName',
      'resourceGroupName',
      'appUrl',
    ]);
  });

  it('returns SSM doc prefixes for ami on aws', () => {
    expect(relevantDeployTargetKeys('ami', 'aws')).toEqual(['configDocPrefix', 'testDocPrefix']);
  });

  it('returns S3/CloudFront keys for SPA app types on aws', () => {
    for (const t of ['angular', 'react', 'html'] as AppType[]) {
      expect(relevantDeployTargetKeys(t, 'aws')).toEqual(['s3', 'cloudfront', 'appUrl']);
    }
  });

  it('returns EC2 keys for server runtimes on aws', () => {
    for (const t of ['dotnet', 'node', 'python', 'java', 'go', 'php'] as AppType[]) {
      expect(relevantDeployTargetKeys(t, 'aws')).toEqual(['ec2InstanceId', 'appExecutable', 'appUrl']);
    }
  });

  it('returns no keys for aws app types without a flat deploy target', () => {
    expect(relevantDeployTargetKeys('btp', 'aws')).toEqual([]);
    expect(relevantDeployTargetKeys('infra', 'aws')).toEqual([]);
    expect(relevantDeployTargetKeys('cap', 'aws')).toEqual([]);
  });
});

describe('emptyAnswers', () => {
  it('stamps generatedBy and leaves collected fields blank/default', () => {
    const a = emptyAnswers('rhmg');
    expect(a.generatedBy).toBe('rhmg');
    expect(a.generatedAt).toBe('');
    expect(a.appName).toBe('');
    expect(a.appType).toBe('');
    expect(a.cloudProvider).toBe('aws');
    expect(a.awsRegion).toBe('us-west-2');
    expect(a.includeInfra).toBe(true);
    expect(a.secretsManagerKeys).toEqual([]);
    expect(a.frontend).toBeNull();
    expect(a.deployTarget).toEqual(emptyDeployTarget());
  });
});
