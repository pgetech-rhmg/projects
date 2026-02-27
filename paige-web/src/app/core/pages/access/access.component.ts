import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';

import { AppSettingsService } from '~/core/services/appsettings.service';
import { AppSettings } from '~/core/models/appsettings';

@Component({
    selector: 'access',
    standalone: true,
    imports: [
        CommonModule,
    ],
    templateUrl: './access.component.html',
    styleUrls: ['./access.component.scss']
})

export class AccessComponent implements OnInit {
    private appSettings: AppSettings = new AppSettings();

    public title: string = "";
    public type: string = "application";
    public supportLink = "";

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly appSettingsService: AppSettingsService
    ) { }

    public ngOnInit() {
        (async () => {
            if (globalThis.history.state?.type && globalThis.history.state.type !== "") {
                this.type = globalThis.history.state.type;
            }
            this.appSettings = await this.appSettingsService.getSettings();
            this.title = this.appSettings.title;
            this.supportLink = this.appSettings.supportLink;
        })();
    }
}
