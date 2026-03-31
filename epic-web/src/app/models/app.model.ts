export type RunStatus = 'Success' | 'Failed' | 'Running' | 'Cancelled' | 'Skipped' | 'External' | 'Pending';

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
  technology: string;
  lastPipelineRun: string | null;
  branch: string | null;
  runStatus: RunStatus | null;
  triggeredBy: string | null;
  cloud: string;
  environment: string;
  successRate: number | null;
}

export interface PipelineRun {
  id: number;
  status: RunStatus;
  triggeredBy: string;
  branch: string;
  environment: string;
  startedAt: string;
  duration: string | null;
  stages: {
    build: RunStatus;
    test: RunStatus;
    scan: RunStatus;
    infraDeploy: RunStatus;
    appDeploy: RunStatus;
    integrationTest: RunStatus;
  };
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
  runs: PipelineRun[];
}
