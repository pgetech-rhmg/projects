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
    selector: 'tab-summary',
    standalone: true,
    imports: [
        CommonModule,
        SDKLoadingModule,
    ],
    templateUrl: './tab-summary.component.html',
    styleUrls: ['./tab-summary.component.scss']
})

export class TabSummaryComponent extends BaseComponent {
    @Input() repoData: any = null;

    public isAnalyzing: boolean = false;

    constructor(
        private readonly router: Router,
        private readonly scanService: ScanService,
    ) {
        super();

    }

    public convert(): void {
        this.isAnalyzing = true;

        let request = {
            repoName: this.repoData.summary.structure.repoName,
            branch: this.repoData.summary.structure.branch
        };

        this.scanService.scan(request).subscribe({
            next: (response: any) => {
                this.isAnalyzing = false;

                this.router.navigate(["/cfn"], { state: { repoData: this.repoData, data: response } });
            },
            error: (error: any) => {
                this.isAnalyzing = false;
            }
        });
    }
}
