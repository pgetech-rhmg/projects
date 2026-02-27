import { Injectable } from "@angular/core";

import { lastValueFrom } from "rxjs";

import { HttpService } from "~/core/services/http.service";

@Injectable()
export class UserService {
    constructor(
        private readonly httpService: HttpService,
    ) {}

    public async GetUser(roles: string): Promise<any> {
        try {
            let stream$ = this.httpService.Post(`api/User/get-user`, JSON.stringify(roles)).pipe();

            return await lastValueFrom(stream$).then((response: any) => {
                return response;
            });
        } catch (error: any) {
            throw error;
        }
    }
}
