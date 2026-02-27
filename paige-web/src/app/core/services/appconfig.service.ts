import { Injectable } from '@angular/core';
import { HttpClient, HttpBackend } from '@angular/common/http';
import { lastValueFrom } from 'rxjs';

import { AppConfig } from '~/core/models/appconfig';
import { Variables } from '../classes/user/variables';

const FILE = "assets/config.json";
const CONFIG_KEY = "App.Config";

@Injectable({
    providedIn: 'root'
})
export class AppConfigService {
    private readonly http: HttpClient;

    constructor(private readonly httpHandler: HttpBackend) {
        this.http = new HttpClient(this.httpHandler);
    }

    public async init(): Promise<boolean> {
        return new Promise<boolean>((resolve, reject) => {
            const stream$ = this.http.get(FILE);

            lastValueFrom(stream$)
                .then((data: any) => {
                    this.saveConfig(data);
                    resolve(true);
                })
                .catch((error: Error) => {
                    reject(error);
                });
        });
    }

    public async getConfig(): Promise<AppConfig> {
        let storage = Variables.get(CONFIG_KEY);

        if (!storage) {
            await this.init();

            storage = Variables.get(CONFIG_KEY);
        }

        return storage;
    }

    public getConfigKey(value: string): any {
        let storage = Variables.get(CONFIG_KEY);

        if (storage) {
            return storage![value];
        }

        return null;
    }

    public saveConfig(config: AppConfig): Promise<void> {
        return new Promise<void>((resolve) => {
            Variables.set(CONFIG_KEY, config);

            resolve();
        });
    }

    public clearConfig() {
        Variables.clear(CONFIG_KEY);
    }
}