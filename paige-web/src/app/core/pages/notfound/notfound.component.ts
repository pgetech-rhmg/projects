import { Component } from '@angular/core';
import { CommonModule, Location } from "@angular/common";

import { AppSettings } from '~/core/models/appsettings';

@Component({
    selector: 'notfound',
    standalone: true,
    imports: [
        CommonModule,
    ],
    templateUrl: './notfound.component.html',
    styleUrls: ['./notfound.component.scss']
})

export class NotFoundComponent {
    public appSettings: AppSettings = new AppSettings();

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly location: Location
    ) {}

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public goBack() {
        this.location.back();
    }
}
