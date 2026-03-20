export type RunStatus = 'Success' | 'Failed' | 'Running' | 'Cancelled' | 'Skipped';

export interface ManagedApp {
  name: string;
  technology: string;
  lastPipelineRun: string;
  runStatus: RunStatus;
  triggeredBy: string;
  cloud: string;
  environment: string;
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
    deploy: RunStatus;
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
