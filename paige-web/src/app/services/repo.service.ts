import { Injectable } from "@angular/core";

import { Observable } from 'rxjs';

import { HttpService } from "~/core/services/http.service";

@Injectable()
export class RepoService {
    constructor(
        private readonly httpService: HttpService,
    ) { }

    public assess(request: any): Observable<any> {
        return this.httpService.Post(
            "/api/repo/assess",
            request
        );
    }

    public analyze(request: any): Observable<any> {
        return this.httpService.Post(
            "/api/repo/analyze",
            request
        );
    }
}
