import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { AppSettingsService } from '~/core/services/appsettings.service';
import { AppSettings } from '~/core/models/appsettings';

import { appRoutes } from '~/classes/routes/app.routing';
import { Variables } from '~/core/classes/user/variables';

export class NavItem {
    public title: string = "";
    public icon: string = "";
    public Id?: string = "";
    public Count?: number = 0;
    public url: string = "";
    public Selected?: boolean = false;
    public roles?: string[] = [];
    public visible?: boolean = false;
}

@Component({
    selector: 'nav',
    standalone: true,
    imports: [
        CommonModule,
    ],
    templateUrl: './nav.component.html',
    styleUrls: ['./nav.component.scss']
})

export class NavComponent implements OnInit {
    @Input() expand: boolean = false;
    @Output() setLayoutClass = new EventEmitter();
    @Output() reloadPage = new EventEmitter();
    @Output() showSearch: EventEmitter<boolean> = new EventEmitter();

    public appIcon: string = "web_asset";
    public appTitle: string = "Application Mode";

    public menuIcon: string = "keyboard_double_arrow_right";
    public activeItem: NavItem = new NavItem();

    public navItems: any = [];
    public navSubItems: any = [];

    private readonly _routes = [...appRoutes];
    private collapse: boolean = false;

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly router: Router,
        private readonly appSettingsService: AppSettingsService,
    ) { }

    public ngOnInit() {
        (async () => {
            await this.getRoutes();

            let routeUrl = sessionStorage.getItem("_redirect");

            if (!routeUrl || routeUrl === "") {
                if (this.router?.url) {
                    routeUrl = this.router.url.split("?")[0];
                }
            }

            this.setActiveItem(this.navItems, routeUrl);
            this.setActiveItem(this.navSubItems, routeUrl);

            sessionStorage.removeItem("_redirect");
        })();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public toggleMenu(collapse: boolean = false) {
        this.collapse = collapse;
        this.menuIcon = collapse ? "keyboard_double_arrow_left" : "keyboard_double_arrow_right";

        this.setLayoutClass.emit();
    }

    public navigateTo(item: NavItem) {
        let allowNavigate: boolean = true;
        let storage = Variables.get("__allowNavigate__");

        if (storage && storage === "false") {
            allowNavigate = confirm('WARNING: Changes have been made. Are you sure you want to leave without saving these changes?');
        }

        if (this.collapse) {
            this.collapse = false;
            this.setLayoutClass.emit();
        }

        if (allowNavigate) {
            Variables.clear("__allowNavigate__");

            this.router.navigateByUrl(item.url);
            this.activeItem = item;
        }
    }

    public toggleFullscreen() {
        if (document.fullscreenElement) {
            document.exitFullscreen();
            this.appIcon = "web_asset";
            this.appTitle = "Application Mode";
        } else {
            document.documentElement.requestFullscreen();
            this.appIcon = "iframe";
            this.appTitle = "Web Mode";
        }
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private async getRoutes() {
        this.navItems = [];
        this.navSubItems = [];

        await this.appSettingsService.getSettings().then((appSettings: AppSettings) => {
            this._routes.forEach((route: any) => {
                if (route.data?.isNav) {
                    let addItem: boolean = false;

                    if (route.data.roles) {
                        if (route.data.roles.some((r: any) => appSettings.roles.includes(r))) {
                            addItem = true;
                        }
                    } else {
                        addItem = true;
                    }

                    if (addItem) {
                        this.navItems.push(
                            {
                                "title": route.title,
                                "icon": route.data.icon,
                                "url": route.path
                            }
                        )

                        this.getSubRoutes(route, appSettings.roles);
                    }
                }
            })
        });
    }

    private getSubRoutes(parent: any, roles: any) {
        this._routes.forEach((route: any) => {
            if (route.data?.isSubNav && route.path.startsWith(`${parent.path}/`)) {
                let addItem: boolean = false;

                if (route.data.roles) {
                    if (route.data.roles.some((r: any) => roles.includes(r))) {
                        addItem = true;
                    }
                } else {
                    addItem = true;
                }

                if (addItem) {
                    this.navSubItems.push(
                        {
                            "parent": parent.title,
                            "title": route.title,
                            "icon": route.data.icon,
                            "url": route.path
                        }
                    )
                }
            }
        });
    }

    private setActiveItem(items: any, routeUrl: any) {
        for (let item of items) {
            if (`/${item.url}` === routeUrl) {
                this.activeItem = item;
                break;
            }
        }
    }
}
