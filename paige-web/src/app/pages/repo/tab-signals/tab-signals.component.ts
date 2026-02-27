import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { SDKLoadingModule } from 'sdk-loading';

import { ScanService } from '~/services/scan.service';

import { BaseComponent } from '~/pages/base.component';

export interface TerraformModuleResult {
    module: string;
    files: Record<string, string>;
}

@Component({
    selector: 'tab-signals',
    standalone: true,
    imports: [
        CommonModule,
        SDKLoadingModule,
    ],
    templateUrl: './tab-signals.component.html',
    styleUrls: ['./tab-signals.component.scss']
})

export class TabSignalsComponent extends BaseComponent {
    @Input() repoData: any = null;

    public isAnalyzing: boolean = false;

    constructor(
        private readonly router: Router,
        private readonly scanService: ScanService,
    ) {
        super();

    }
}
