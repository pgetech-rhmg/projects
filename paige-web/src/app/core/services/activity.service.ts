import { Injectable } from "@angular/core";

import { lastValueFrom } from "rxjs";

import { HttpService } from "~/core/services/http.service";

@Injectable()
export class ActivityService {
    constructor(
        private readonly httpService: HttpService,
    ) {}

    public async GetActivity(type: any, startDate: any, endDate: any): Promise<any> {
        try {
            let stream$ = this.httpService.Get(`api/Activity?type=${type}&startDate=${startDate}&endDate=${endDate}`).pipe();

            return await lastValueFrom(stream$).then((response: any) => {
                return response;
            });
        } catch (error: any) {
            throw error;
        }
    }

    public async SaveActivity(activity: any): Promise<any> {
        try {
            let stream$ = this.httpService.Post(`api/Activity/create-activity`, activity).pipe();

            return await lastValueFrom(stream$).then((response: any) => {
                return response;
            });
        } catch (error: any) {
            throw error;
        }
    }
}
