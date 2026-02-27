import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { SDKLoadingModule } from 'sdk-loading';

@Component({
    selector: 'auth',
    standalone: true,
    imports: [
        CommonModule,
        SDKLoadingModule,
    ],
    templateUrl: './auth.component.html',
    styleUrls: ['./auth.component.scss']
})

export class AuthComponent implements OnInit {
    public isLoading: boolean = true;

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly router: Router
    ) {
    }

    public async ngOnInit() {
        let redirect = sessionStorage.getItem("_redirect");

        if (redirect && redirect !== "") {
            await this.router.navigate([redirect]);
		} else {
            await this.router.navigate(["/"]);
        }

        this.isLoading = false;
    }
}
