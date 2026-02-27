import { Injectable } from "@angular/core";

import { Observable, of } from 'rxjs';

import { HttpService } from "~/core/services/http.service";

@Injectable()
export class CfnService {
    private activeJob?: string;

    constructor(
        private readonly httpService: HttpService,
    ) { }

    public generate(request: any): Observable<{ jobId: string }> {
        return this.httpService.Post<{ jobId: string }>(
            "/api/cfn/generate",
            { Cfns : request }
        );
    }

    public generateStream(jobId: string): EventSource {
        return this.httpService.SSE(`/api/cfn/generate-stream/${jobId}`);
    }

    public createProject(request: any): Observable<any> {
        return this.httpService.Post(
            "/api/cfn/create-project",
            { CfnResults: request }
        );
    }

    public setActiveJob(jobId: string): void {
        this.activeJob = jobId;
    }

    public cancel(): Observable<void> {
        if (!this.activeJob) {
            return of(undefined);
        }

        return this.httpService.Post<void>(
            `/api/cfn/cancel/${this.activeJob}`,
            {}
        );
    }
}
