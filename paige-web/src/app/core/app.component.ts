import { Component, ComponentRef, HostListener, NO_ERRORS_SCHEMA, OnDestroy, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterOutlet } from '@angular/router';
import { filter, Subject, takeUntil } from 'rxjs';
import { MsalBroadcastService, MsalService } from '@azure/msal-angular';
import { AccountInfo, InteractionStatus } from '@azure/msal-browser';

import { DynamicModule } from 'ng-dynamic-component';

import { Variables } from '~/core/classes/user/variables';

import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';
import { GraphService } from '~/core/services/graph.service';
import { FormatterService } from '~/core/services/formatter.service';
import { HttpService } from '~/core/services/http.service';

import { ChatStreamService } from "~/services/chat.service";
import { MarkdownService } from "~/services/markdown.service";
import { ScanService } from "~/services/scan.service";
import { CfnService } from "~/services/cfn.service";
import { RepoService } from "~/services/repo.service";

import { AppSettings } from '~/core/models/appsettings';
import { AppConfig } from '~/core/models/appconfig';

import { HeaderComponent } from '~/core/components/layout/header/header.component';
import { NavComponent } from '~/core/components/layout/nav/nav.component';
import { FooterComponent } from '~/core/components/layout/footer/footer.component';
import { AccessComponent } from '~/core/pages/access/access.component';
import { AlertComponent } from '~/core/components/alert/alert.component';
import { ErrorComponent } from '~/core/pages/error/error.component';

import { Sessions } from '~/core/utils/sessions';

export interface Modal {
    type?: ComponentRef<any>;
    inputs?: any;
    outputs?: any
}

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [
        RouterOutlet,
        CommonModule,
        DynamicModule,
        HeaderComponent,
        NavComponent,
        FooterComponent,
        AccessComponent,
        AlertComponent,
        ErrorComponent,
    ],
    providers: [
        AppSettingsService,
        GraphService,
        FormatterService,
        ActivityService,
        HttpService,

        ChatStreamService,
        MarkdownService,
        ScanService,
        CfnService,
        RepoService,
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ],
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit, OnDestroy {
    private appConfig: AppConfig = new AppConfig();
    private appSettings: AppSettings = new AppSettings();

    public env: string = "";
    public error: string = "";
    public title: string = "";
    public version: string = "";
    public expand: boolean = false;

    public showNav: boolean = true;
    public showFooter: boolean = true;

    public layoutCssClass: string = "";

    public isLoggedIn: boolean = false;
    public isLoading: boolean = true;

    // Alert
    public showAlert: boolean = false;
    public alertTitle: string = "Alert";
    public alertMessage: string = "";
    public alertList: string = "";
    public alertContinueText: string = "OK";
    public alertCancelText: string = "";

    // Modals
    public modal: Modal | undefined;

    private readonly _destroying$ = new Subject<void>();

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly authService: MsalService,
        private readonly msalBroadcastService: MsalBroadcastService,
        private readonly graphService: GraphService,
        private readonly router: Router,
        private readonly appConfigService: AppConfigService,
        private readonly appSettingsService: AppSettingsService,
        private readonly activityService: ActivityService,
    ) {
        globalThis.onbeforeunload = null;
        Variables.clear("__allowNavigate__");

        setTimeout(() => {
            if (this.isLoggedIn) {
                this.layoutCssClass = Variables.get("Nav.LayoutCssClass") ?? "";
                this.setLayoutClass(false);
            }
        }, 1500);
    }

    public ngOnInit() {
        (async () => {
            await this.initializeSettings();
        })();
    }

    public ngOnDestroy() {
        this._destroying$.next(undefined);
        this._destroying$.complete();
    }

    @HostListener("window:beforeunload", ["$event"])
    onBeforeUnload($event: Event): void {
        let allowNavigate: boolean = true;
        let storage = Variables.get("__allowNavigate__");

        if (storage && storage === "false") {
            allowNavigate = confirm();
        }

        if (allowNavigate) {
            Variables.clear("__allowNavigate__");

            let activity: any = {
                View: globalThis.location.pathname,
                Username: this.appSettings.user?.username ?? "Unknown",
                SessionId: Sessions.getSessionId(),
                Event: "_exit_",
                Data: null,
                ActivityDt: new Date()
            };

            this.activityService.SaveActivity(activity);
        } else {
            $event.preventDefault();
        }
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public setLayoutClass(change: boolean = true) {
        if (change) {
            if (this.layoutCssClass === "") {
                this.layoutCssClass = "expand";
            } else {
                this.layoutCssClass = "";
            }
        }

        if (this.layoutCssClass === "") {
            this.expand = false;
        } else {
            setTimeout(() => {
                this.expand = true;
            }, 100);
        }

        Variables.set("Nav.LayoutCssClass", this.layoutCssClass);
    }

    public async reloadPage(page = "") {
        let currentUrl = page === "" ? this.router.url : page;

        this.router.navigate([currentUrl]);
    }

    //*************************************************************************
    //  Alert Methods
    //*************************************************************************
    public alertReset() {
        this.showAlert = false;
        this.alertTitle = "Alert";
        this.alertMessage = "";
        this.alertList = "";
        this.alertContinueText = "OK";
        this.alertCancelText = "";
    }

    public alertContinue() {
        this.alertReset();
    }

    public alertCancel() {
        this.alertReset();
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private async initializeSettings() {
        this.appConfig = await this.appConfigService.getConfig();
        this.appSettings = await this.appSettingsService.getSettings();

        this.isLoggedIn = false;
        this.isLoading = true;

        if (this.appSettings) {
            if (this.appSettings.user) {
                this.isLoggedIn = true;
                this.isLoading = false;
            } else {
                await this.router.navigate(["/auth"]);

                if (!this.isLoggedIn) {
                    this.getMSALAccounts();
                }
            }

            await this.setUI();
        } else {
            this.error = "Unable to load application settings.";
            this.isLoading = false;
        }
    }

    private getMSALAccounts() {
        this.msalBroadcastService.inProgress$
            .pipe(
                filter((status: InteractionStatus) => status === InteractionStatus.None),
                takeUntil(this._destroying$)
            )
            .subscribe(() => {
                let account: AccountInfo | null = this.authService.instance.getActiveAccount();

                if (account === null) {
                    account = this.getAccountInfo();
                }

                this.setAccountInfo(account);
            });
    }

    private getAccountInfo() {
        let accounts = this.authService.instance.getAllAccounts();
        let account: AccountInfo | null = null;

        if (accounts.length > 0) {
            this.authService.instance.setActiveAccount(accounts[0]);
            account = accounts[0];
        }

        return account;
    }

    private async setAccountInfo(account: AccountInfo | null) {
        let allowAccess: boolean = this.appSettings.openAccess;

        let roles: any = [];

        for (let role of this.appSettings.roles) {
            let groupAccess: any = await this.graphService.getUserGroups(role);

            if (groupAccess?.value.length > 0) {
                roles.push(role);
            }
        }

        if (!this.appSettings.openAccess && roles.length > 0) {
            allowAccess = true;
        }

        if (account) {
            await this.setUserInfo(account, roles);
            await this.appSettingsService.saveSettings(this.appSettings);
        }

        if (allowAccess) {
            this.layoutCssClass = "";
            this.isLoggedIn = true;
        } else {
            this.layoutCssClass = "noaccess";
            this.isLoggedIn = false;
        }

        let idToken = account?.idToken ?? "";

        sessionStorage.setItem("_idToken", idToken);

        this.isLoading = false;
    }

    private async setUserInfo(account: any, roles: any) {
        account.photo = "";

        if (account.name) {
            const name: string[] = account.name.split(", ");

            if (name?.length > 1) {
                const firstName: string = name[1].split(" (")[0].split(" [")[0];
                const lastName: string = name[0];

                account.firstName = firstName;
                account.lastName = lastName;
                account.name = `${firstName} ${lastName}`;
                account.initials = firstName.substring(0, 1).toUpperCase() + lastName.substring(0, 1).toUpperCase();
            }
        }

        account.roles = roles;

        this.appSettings.user = account;
    }

    private async setUI() {
        this.title = this.appSettings.title;
        this.version = this.appSettings.version;
        this.showNav = this.appSettings.showNav;
        this.showFooter = this.appSettings.showFooter;
    }
}
