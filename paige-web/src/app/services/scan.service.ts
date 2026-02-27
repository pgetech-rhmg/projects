import { Injectable } from "@angular/core";

import { Observable } from 'rxjs';

import { HttpService } from "~/core/services/http.service";

@Injectable()
export class ScanService {
    constructor(
        private readonly httpService: HttpService,
    ) { }

    public scan(request: any): Observable<any> {
        return this.httpService.Post(
            "/api/scan/repo",
            request
        );
    }
}
