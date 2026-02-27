import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

import { SDKLoadingModule } from 'sdk-loading';

import { GraphService } from '~/core/services/graph.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';

import { AppConfig } from '~/core/models/appconfig';
import { AppSettings } from '~/core/models/appsettings';

@Component({
    selector: 'header',
    standalone: true,
    imports: [
        CommonModule,
        FormsModule,
        SDKLoadingModule,
    ],
    templateUrl: './header.component.html',
    styleUrls: ['./header.component.scss']
})

export class HeaderComponent implements OnInit {
    @Input() title = "Joint Pole Records Tracker";
    @Output() setLayoutCssClass = new EventEmitter();
    @Output() reloadPage = new EventEmitter();

    public appSettings: AppSettings = new AppSettings();
    public env: string = "";
    public itemsClass = "";
    public initials: string = "";
    public showPhoto: boolean = false;

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly router: Router,
        private readonly graphService: GraphService,
        private readonly appConfigService: AppConfigService,
        private readonly appSettingsService: AppSettingsService
    ) {}

    public ngOnInit() {
        (async () => {
            let config: AppConfig = await this.appConfigService.getConfig();

            if (config.environment) {
                this.env = config.environment.toLocaleUpperCase();
            }

            await this.getUserInfo();
        })();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public navigateTo(url: string) {
        this.router.navigateByUrl(url);
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private async getUserInfo() {
        this.appSettings = await this.appSettingsService.getSettings();

        if (this.appSettings.user?.photo === "") {
            this.graphService.getUserPhoto().then((photo: any) => {
                this.appSettings.user.photo = photo;

                if (photo !== "") {
                    this.showPhoto = true;
                }
    
                this.appSettingsService.saveSettings(this.appSettings);
            });
        } else {
            this.showPhoto = true;
        }
    }
}
