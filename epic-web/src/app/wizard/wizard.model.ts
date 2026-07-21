export type AppType =
  | 'angular'
  | 'react'
  | 'dotnet'
  | 'node'
  | 'python'
  | 'java'
  | 'go'
  | 'html'
  | 'php'
  | 'ami'
  | 'cap'
  | 'btp'
  | 'infra';

export type CloudProvider = 'aws' | 'azure' | 'sap';

export type FrontendAuthMode = 'none' | 'oidc-entra' | 'msal';

export type BackendStyle = 'rest-api' | 'lambda-per-endpoint' | 'graphql';

export type BackendAuthStyle = 'none' | 'jwt-validator' | 'api-key';

export type DbEngine = 'postgres' | 'dynamodb' | 'sqlserver' | 'sqlite-local-dev-only';

export type DbScale = 'single-instance' | 'multi-az';

export type QueueKind = 'sqs' | 'sns' | 'eventbridge' | 'servicebus';

export type StorageKind = 's3' | 'azure-blob';

// Pre-existing deploy-target fields. Used only when `includeInfra === false` — the wizard
// asks the user where the already-provisioned infrastructure is so the EPIC deploy stage
// knows where to push artifacts. The keys here mirror the `cloud.*` keys read by
// `epic-pipeline/deploy/main.yml` (and friends) so they flow straight into `epic.json`.
export interface DeployTarget {
  // SPA on AWS (angular/react/html): S3 + CloudFront
  s3: string;
  cloudfront: string;
  // Server runtime on AWS (node/dotnet/python/java/php): EC2 instance + executable name
  ec2InstanceId: string;
  appExecutable: string;
  // Anything on Azure: App Service + RG
  appServiceName: string;
  resourceGroupName: string;
  // AMI deploy (post-image SSM document prefixes read by deploy/aws/ami/main.yml)
  configDocPrefix: string;
  testDocPrefix: string;
  // Deployed URL — used by integration tests when no Terraform `app_url` output is available
  appUrl: string;
}

export interface FrontendArchitecture {
  authMode: FrontendAuthMode;
  authClientId: string;
  apiBaseUrlNeeded: boolean;
}

export interface BackendArchitecture {
  style: BackendStyle;
  runtime: string;
  authStyle: BackendAuthStyle;
  authClientId: string;
}

export const ENTRA_TENANT_ID = '44ae661a-ece6-41aa-bc96-7c2c85a08941';

export interface DatabaseArchitecture {
  engine: DbEngine;
  scale: DbScale;
}

export interface QueueArchitecture {
  kind: QueueKind;
}

export interface StorageArchitecture {
  kind: StorageKind;
}

// app.appName must be kebab-case: starts with a lowercase letter, then 2–40 more
// lowercase letters/digits/hyphens (3–41 chars total). It becomes the EPIC app
// identity — the repo/directory name, the ADO build tag matched by the engine, and a
// component of cloud resource names (e.g. the S3 key `<appName>.zip`). Several of those
// sinks are case-sensitive or case-folding (S3 keys, DNS-style names), so a single
// lowercase form keeps the name stable end-to-end and collision checks unambiguous.
export const APP_NAME_PATTERN = /^[a-z][a-z0-9-]{2,40}$/;
export const APP_NAME_RULE = 'App name must be kebab-case, 3–41 chars, starting with a letter.';

// AWS account IDs are exactly 12 digits; Azure subscription IDs are canonical lowercase UUIDs.
export const AWS_ACCOUNT_ID_PATTERN = /^\d{12}$/;
export const AZURE_SUBSCRIPTION_ID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

// Live input normalizers — applied on every keystroke so the typed value is steered toward
// a valid shape instead of silently rejected. Each is idempotent and safe to call mid-typing.

// Lowercase and fold runs of whitespace/underscores into a single hyphen, so "My App" and
// "my_app" become "my-app". Leading-hyphen / too-short cases are left for the inline error.
export function normalizeAppName(value: string): string {
  return value.toLowerCase().replace(/[\s_]+/g, '-');
}

// Strip everything that isn't a digit and cap at 12, so a pasted "1234-5678-9012" or
// "1234 5678 9012" cleans up to "123456789012".
export function normalizeAwsAccountId(value: string): string {
  return value.replace(/\D/g, '').slice(0, 12);
}

// UUIDs are case-insensitive but canonically lowercase; trim stray paste whitespace.
export function normalizeAzureSubscriptionId(value: string): string {
  return value.trim().toLowerCase();
}

export interface WizardAnswers {
  // Step 1
  appName: string;
  appType: AppType | '';
  scanTool: string;
  buildTestTool: string;
  integrationTestTool: string;

  // Step 3 — Cloud target
  cloudProvider: CloudProvider;
  awsAccountId: string;
  awsRegion: string;
  azureSubscriptionId: string;
  azureResourceGroup: string;
  // Cloud Foundry deploy target — CAP apps only.
  cfApi: string;
  cfOrg: string;
  cfSpace: string;
  cfOrigin: string;
  // AWS Secrets Manager — BTP and CAP apps pull their credentials from here.
  secretsManagerName: string;
  secretsManagerKeys: string[];
  // EC2 Image Builder component names — AMI apps only (required: cloud.components).
  amiComponents: string[];
  // Deploy target — collected only when includeInfra === false. When the user is generating
  // .infra/, the AI derives all of this from the architecture answers, so the wizard stays out.
  deployTarget: DeployTarget;

  // Step 3
  hasFrontend: boolean;
  frontend: FrontendArchitecture | null;
  hasBackend: boolean;
  backend: BackendArchitecture | null;
  needsDatabase: boolean;
  database: DatabaseArchitecture | null;
  needsQueue: boolean;
  queue: QueueArchitecture | null;
  needsScheduler: boolean;
  schedulerCron: string;
  needsStorage: boolean;
  storage: StorageArchitecture | null;
  includeInfra: boolean;

  // Step 4
  acceptanceCriteria: string;
  extraNotes: string;

  // Stamp metadata — supplied at render time, not collected from the user
  generatedAt: string;
  generatedBy: string;
}

export const APP_TYPE_LABELS: Record<AppType, string> = {
  angular: 'Angular',
  react: 'React',
  dotnet: '.NET',
  node: 'Node.js',
  python: 'Python',
  java: 'Java',
  go: 'Go',
  html: 'HTML / Static',
  php: 'PHP',
  ami: 'AMI',
  cap: 'SAP CAP',
  btp: 'SAP BTP',
  infra: 'Infrastructure',
};

// Mirrors epic-engine.yml `defaultRuntimeVersion` (dispatched by appType). Keep in sync.
export const DEFAULT_RUNTIME_VERSION: Record<AppType, string> = {
  angular: '20',
  react: '20',
  dotnet: '9.x',
  node: '20',
  python: '3.11',
  java: '17',
  go: '1.23',
  html: '20',
  php: '8.3',
  ami: '',
  cap: '20',
  btp: '',
  infra: '',
};

export const SCAN_TOOL_OPTIONS = ['sonarqube', 'wiz'] as const;

export const BUILD_TEST_TOOL_OPTIONS: Record<AppType, string[]> = {
  angular: ['karma', 'jest'],
  react: ['jest', 'vitest'],
  dotnet: ['xunit', 'nunit'],
  node: ['jest', 'vitest', 'mocha'],
  python: ['pytest'],
  java: ['junit'],
  go: ['gotestsum'],
  php: ['phpunit'],
  html: [],
  ami: [],
  cap: [],
  btp: [],
  infra: [],
};

export const INTEGRATION_TEST_TOOL_OPTIONS: Record<AppType, string[]> = {
  angular: ['playwright'],
  react: ['playwright'],
  html: ['playwright'],
  node: ['playwright'],
  dotnet: ['playwright'],
  python: ['playwright'],
  java: ['playwright'],
  go: ['playwright'],
  php: ['playwright'],
  ami: [],
  cap: ['playwright'],
  btp: [],
  infra: [],
};

// Preferred-tool defaults: the first option in each list is the recommended choice for an
// appType. Returns '' when the appType has no tools of that kind (btp/infra/ami, etc.), which
// keeps the "None" option selected. Used to prefill the tool dropdowns when an appType is picked.
export function defaultScanTool(appType: AppType): string {
  // Scan options are universal, but only code-bearing appTypes render the scan field at all.
  if (appType === 'btp' || appType === 'infra' || appType === 'ami') return '';
  return SCAN_TOOL_OPTIONS[0];
}

export function defaultBuildTestTool(appType: AppType): string {
  return BUILD_TEST_TOOL_OPTIONS[appType]?.[0] ?? '';
}

export const FRONTEND_APP_TYPES: AppType[] = ['angular', 'react', 'html'];
export const BACKEND_APP_TYPES: AppType[] = ['dotnet', 'node', 'python', 'java', 'go', 'php'];
export const NO_ARCHITECTURE_APP_TYPES: AppType[] = ['cap', 'btp', 'infra', 'ami'];

export function appTypesForCloud(provider: CloudProvider): AppType[] {
  if (provider === 'azure') {
    return (Object.keys(APP_TYPE_LABELS) as AppType[]).filter(
      (t) => t !== 'ami' && t !== 'btp' && t !== 'cap',
    );
  }
  return Object.keys(APP_TYPE_LABELS) as AppType[];
}

// Every appType currently defaults to AWS (BTP/CAP still use AWS-side state and
// Secrets Manager), so this is unconditional today. Kept as a seam for when an
// appType needs a different default cloud.
export function defaultCloudForAppType(_appType: AppType): CloudProvider {
  return 'aws';
}

export function emptyDeployTarget(): DeployTarget {
  return {
    s3: '',
    cloudfront: '',
    ec2InstanceId: '',
    appExecutable: '',
    appServiceName: '',
    resourceGroupName: '',
    configDocPrefix: '',
    testDocPrefix: '',
    appUrl: '',
  };
}

// Returns the (snake- or camel-case) `cloud.*` keys that the EPIC deploy stage actually reads
// for a given (appType, cloudProvider) — i.e. which DeployTarget fields are relevant.
export function relevantDeployTargetKeys(
  appType: AppType,
  cloudProvider: CloudProvider,
): (keyof DeployTarget)[] {
  if (cloudProvider === 'azure') return ['appServiceName', 'resourceGroupName', 'appUrl'];
  if (appType === 'ami') return ['configDocPrefix', 'testDocPrefix'];
  if (appType === 'angular' || appType === 'react' || appType === 'html') return ['s3', 'cloudfront', 'appUrl'];
  if (appType === 'dotnet' || appType === 'node' || appType === 'python' || appType === 'java' || appType === 'go' || appType === 'php') {
    return ['ec2InstanceId', 'appExecutable', 'appUrl'];
  }
  return [];
}

export function emptyAnswers(generatedBy: string): WizardAnswers {
  return {
    appName: '',
    appType: '',
    scanTool: '',
    buildTestTool: '',
    integrationTestTool: '',

    cloudProvider: 'aws',
    awsAccountId: '',
    awsRegion: 'us-west-2',
    azureSubscriptionId: '',
    azureResourceGroup: '',
    cfApi: '',
    cfOrg: '',
    cfSpace: '',
    cfOrigin: '',
    secretsManagerName: '',
    secretsManagerKeys: [],
    amiComponents: [],
    deployTarget: emptyDeployTarget(),

    hasFrontend: false,
    frontend: null,
    hasBackend: false,
    backend: null,
    needsDatabase: false,
    database: null,
    needsQueue: false,
    queue: null,
    needsScheduler: false,
    schedulerCron: '',
    needsStorage: false,
    storage: null,
    includeInfra: true,

    acceptanceCriteria: '',
    extraNotes: '',

    generatedAt: '',
    generatedBy,
  };
}
