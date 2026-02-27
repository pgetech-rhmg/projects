import { Injectable } from '@angular/core';
import { HttpClient, HttpBackend } from '@angular/common/http';
import { lastValueFrom } from 'rxjs';

import { AppSettings } from '~/core/models/appsettings';
import { Variables } from '../classes/user/variables';

const FILE = "assets/appsettings.json";
const SETTINGS_KEY = "App.Settings";

@Injectable({
    providedIn: 'root'
})
export class AppSettingsService {
    private readonly http: HttpClient;

    constructor(private readonly httpHandler: HttpBackend) {
        this.http = new HttpClient(this.httpHandler);
    }

    public async init(): Promise<boolean> {
        return new Promise<boolean>((resolve, reject) => {
            const stream$ = this.http.get(FILE);

            lastValueFrom(stream$)
                .then((data: any) => {
                    this.saveSettings(data);
                    resolve(true);
                })
                .catch((error: Error) => {
                    reject(error);
                });
        });
    }

    public async getSettings(initialize: boolean = false): Promise<AppSettings> {
        let storage = Variables.get(SETTINGS_KEY);

        if (initialize || !storage) {
            await this.init();

            storage = Variables.get(SETTINGS_KEY);
        }

        return storage;
    }

    public saveSettings(settings: AppSettings): Promise<void> {
        if (!settings.roles) {
            settings.roles = [];
        }

        return new Promise<void>((resolve) => {
            Variables.set(SETTINGS_KEY, settings);

            resolve();
        });
    }

    public clearSettings() {
        Variables.clear(SETTINGS_KEY);
    }
}
