import { Component, inject } from '@angular/core';

import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';

import { AppConfig } from '~/core/models/appconfig';
import { AppSettings } from '~/core/models/appsettings';

import { Sessions } from '~/core/utils/sessions';

@Component({
    template: '',
    standalone: true
})

export class BaseComponent {
    public appConfig: AppConfig = new AppConfig();
    public appSettings: AppSettings = new AppSettings();
    public permissions: Permissions | undefined;

    public title: string = "";
    public isLoading = false;

    private readonly _appConfigService: AppConfigService = inject(AppConfigService);
    private readonly _appSettingsService: AppSettingsService = inject(AppSettingsService);
    private readonly _activityService: ActivityService = inject(ActivityService);

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public async initAsync(): Promise<void> {
        this.appConfig = await this._appConfigService.getConfig();
        this.appSettings = await this._appSettingsService.getSettings();
    }

    public getPath(): string {
        return globalThis.location.pathname;
    }

    public logActivityEvent(view: string | null = null, action: string = "View", data: string | null = null) {
        let activity: any = {
            View: view ?? this.getPath(),
            Username: this.appSettings.user?.username ?? "Unknown",
            SessionId: Sessions.getSessionId(),
            Event: action,
            Data: data,
            ActivityDt: new Date()
        };

        this._activityService.SaveActivity(activity);
    }
}
