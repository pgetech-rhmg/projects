export type AppType =
  | 'angular'
  | 'react'
  | 'dotnet'
  | 'node'
  | 'python'
  | 'java'
  | 'html'
  | 'php'
  | 'ami'
  | 'btp'
  | 'infra';

export type CloudProvider = 'aws' | 'azure' | 'btp';

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
  // AMI build pipeline
  configDocPrefix: string;
  testDocPrefix: string;
  imageRecipeName: string;
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
  html: 'HTML / Static',
  php: 'PHP',
  ami: 'AMI',
  btp: 'SAP BTP',
  infra: 'Infrastructure',
};

export const DEFAULT_RUNTIME_VERSION: Record<AppType, string> = {
  angular: '20',
  react: '20',
  dotnet: '10.x',
  node: '20.x',
  python: '3.11',
  java: '17',
  html: '18',
  php: '8.3',
  ami: '',
  btp: '',
  infra: '',
};

export const SCAN_TOOL_OPTIONS = ['sonarqube', 'wiz'] as const;

export const BUILD_TEST_TOOL_OPTIONS: Record<AppType, string[]> = {
  angular: ['jest'],
  react: ['jest', 'vitest'],
  dotnet: ['xunit', 'nunit'],
  node: ['jest', 'vitest', 'mocha'],
  python: ['pytest'],
  java: ['junit'],
  php: ['phpunit'],
  html: [],
  ami: [],
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
  php: ['playwright'],
  ami: [],
  btp: [],
  infra: [],
};

export const FRONTEND_APP_TYPES: AppType[] = ['angular', 'react', 'html'];
export const BACKEND_APP_TYPES: AppType[] = ['dotnet', 'node', 'python', 'java', 'php'];
export const NO_ARCHITECTURE_APP_TYPES: AppType[] = ['btp', 'infra', 'ami'];

export function appTypesForCloud(provider: CloudProvider): AppType[] {
  if (provider === 'azure') {
    return (Object.keys(APP_TYPE_LABELS) as AppType[]).filter(
      (t) => t !== 'ami' && t !== 'btp',
    );
  }
  return Object.keys(APP_TYPE_LABELS) as AppType[];
}

export function defaultCloudForAppType(appType: AppType): CloudProvider {
  return appType === 'btp' ? 'aws' : 'aws';
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
    imageRecipeName: '',
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
  if (appType === 'ami') return ['configDocPrefix', 'testDocPrefix', 'imageRecipeName'];
  if (appType === 'angular' || appType === 'react' || appType === 'html') return ['s3', 'cloudfront', 'appUrl'];
  if (appType === 'dotnet' || appType === 'node' || appType === 'python' || appType === 'java' || appType === 'php') {
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
