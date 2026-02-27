import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';

import { HttpService } from "~/core/services/http.service";

export interface ChatStreamEvent {
    data: string;
}

@Injectable({
    providedIn: 'root'
})
export class ChatStreamService {
    private activeJob?: string;

    constructor(
        private readonly httpService: HttpService,
    ) { }

    public startChat(request: any): Observable<{ jobId: string }> {
        console.log(request);

        return this.httpService.Post<{ jobId: string }>(
            "/api/chat/start",
            request
        );
    }

    public chatStream(jobId: string): EventSource {
        return this.httpService.SSE(`/api/chat/stream/${jobId}`);
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

