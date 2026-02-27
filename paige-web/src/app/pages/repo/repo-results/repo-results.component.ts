import { Component, Input, OnInit, TemplateRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { SDKLoadingModule } from 'sdk-loading';
import { SDKTab, SDKTabsModule } from 'sdk-tabs';

import { RepoService } from '~/services/repo.service';

import { BaseComponent } from '~/pages/base.component';

import { TabSummaryComponent } from '~/pages/repo/tab-summary/tab-summary.component';
import { TabAnalysisComponent } from '~/pages/repo/tab-analysis/tab-analysis.component';
import { TabSignalsComponent } from '../tab-signals/tab-signals.component';

export interface TerraformModuleResult {
    module: string;
    files: Record<string, string>;
}

@Component({
    selector: 'repo-results',
    standalone: true,
    imports: [
        CommonModule,
        SDKLoadingModule,
        SDKTabsModule,
    ],
    templateUrl: './repo-results.component.html',
    styleUrls: ['./repo-results.component.scss']
})

export class RepoResultsComponent extends BaseComponent implements OnInit {
    @Input() username: string = "";

    @ViewChild('default') defaultTemplate!: TemplateRef<any>;
    @ViewChild('processing') processingTemplate!: TemplateRef<any>;
    @ViewChild('resources') resourcesTemplate!: TemplateRef<any>;
    @ViewChild('values') valuesTemplate!: TemplateRef<any>;

    public tabs: SDKTab[] = [
        {
            title: "Summary",
            type: <any>TabSummaryComponent,
            inputs: {},
            outputs: {},
            urlParams: ""
        },
        {
            title: "Signals",
            type: <any>TabSignalsComponent,
            inputs: {},
            outputs: {},
            urlParams: ""
        },
        {
            title: "Analysis",
            type: <any>TabAnalysisComponent,
            inputs: {},
            outputs: {},
            urlParams: ""
        },
    ];
    public activeTab: SDKTab = this.tabs[0];
    public urlParams: string = "";

    public analysisRan: boolean = false;
    public response: any = null;

    public groupedEntries: Record<string, any[]> = {};

    public messageStyle: string = "";

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly router: Router,
        private readonly repoService: RepoService,
    ) {
        super();

        let nav = this.router.currentNavigation();

        if (nav?.extras.state?.["data"]) {
            this.isLoading = true;
            this.response = nav?.extras.state?.["data"];

            this.tabs[0].inputs = {
                repoData: this.response
            }

            this.tabs[1].inputs = {
                repoData: this.response
            }

            var output = this.response.analysis ? this.response.analysis : null;

            this.tabs[2].inputs = {
                isAnalyzing: output ? false : true,
                output: output
            }

            this.tabs[2].outputs = {
                setAiAssessment: (output: any) => {
                    this.response.aiAssessment = { output: output };

                    this.tabs[0].inputs = {
                        repoData: this.response
                    }
                }
            };
        } else {
            this.router.navigate(["/repo"], { state: { data: null } });
        }
    }

    public ngOnInit(): void {
        (async () => {
            await this.initAsync();

            this.isLoading = false;
        })();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public setActiveTab(event: any) {
        if (event.to.title === "Analysis") {
            if (!this.analysisRan && !this.response.analysis) {
                this.analysisRan = true;
                this.analyze();
            } else {
                var output = this.response.analysis ? this.response.analysis : null;

                this.tabs[2].inputs = {
                    isAnalyzing: output ? false : true,
                    output: output
                }
            }
        }

        this.activeTab = event.to;
    }

    public back(): void {
        this.router.navigate(["/repo"], { state: { data: { repository: this.response.repo.repoName, branch: this.response.repo.branch } } });
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private analyze() {
        if (this.response.repo.repoName === "" || this.response.repo.branch === "") {
            this.isLoading = false;
            return;
        }

        let request = this.response;

        this.repoService.analyze(request).subscribe({
            next: (response: any) => {
                this.isLoading = false;

                this.response.analysis = response.output;

                if (response?.output) {
                    this.tabs[0].inputs = {
                        repoData: this.response
                    }

                    this.tabs[1].inputs = {
                        repoData: this.response
                    }

                    this.tabs[2].inputs = {
                        isAnalyzing: false,
                        output: response?.output
                    }
                }
            },
            error: (error: any) => {
                this.isLoading = false;
            }
        });
    }
}
