export type RunStatus = 'Success' | 'Failed' | 'Running' | 'Canceled' | 'Canceling' | 'Skipped' | 'External' | 'Pending';

export interface AppLookup {
  name: string;
  displayName: string;
  technology: string;
  cloud: string;
  environment: string;
  github: { repo: string };
}

export interface RepoCheckResult {
  status: 'available' | 'in-epic-not-mine' | 'already-mine' | 'not-found';
  masterApp?: AppLookup;
}

export interface ManagedApp {
  name: string;
  appName: string | null;
  technology: string;
  lastPipelineRun: string | null;
  branch: string | null;
  runId: number | null;
  runStatus: RunStatus | null;
  triggeredBy: string | null;
  cloud: string;
  environment: string;
  successRate: number | null;
  avgDuration: string | null;
}

export interface PipelineRun {
  id: number;
  orchestratorId: number | null;
  status: RunStatus;
  triggeredBy: string;
  branch: string;
  cloud: string;
  environment: string;
  appName: string | null;
  startedAt: string;
  duration: string | null;
  stages: {
    prepare: RunStatus;
    download: RunStatus;
    build: RunStatus;
    test: RunStatus;
    scan: RunStatus;
    infraDeploy: RunStatus;
    appDeploy: RunStatus;
    integrationTest: RunStatus;
  };
}

export interface StageStep {
  name: string;
  status: RunStatus;
  duration: string | null;
  logId: number | null;
}

export interface StageJob {
  name: string;
  status: RunStatus;
  duration: string | null;
  steps: StageStep[];
}

export interface StageDetail {
  stageName: string;
  status: RunStatus;
  duration: string | null;
  jobs: StageJob[];
}

export interface AppDetail {
  name: string;
  displayName: string;
  description: string;
  appType: string;
  technology: string;
  nodeVersion?: string;
  pythonVersion?: string;
  javaVersion?: string;
  dotnetVersion?: string;
  cloud: string;
  environment: string;
  team: string;
  lastUpdatedBy: string;
  domain: string;
  github: {
    repo: string;
    branch: string;
  };
  hasInfra: boolean;
  aws?: {
    accountId: string;
    s3?: string;
    cloudfront?: string;
    ec2InstanceId?: string;
  };
  azure?: {
    subscription: string;
    resourceGroup: string;
  };
  successRate: number | null;
  avgDuration: string | null;
}

export interface PipelineRunPage {
  total: number;
  page: number;
  pageSize: number;
  runs: PipelineRun[];
}
