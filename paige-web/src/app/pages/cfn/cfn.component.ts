import { Component, Input, NgZone, OnInit, TemplateRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { SDKDatagridModule, SDKDataGridColumn, SDKDataGridOptions, StorageType } from 'sdk-datagrid';
import { SDKLoadingModule } from 'sdk-loading';

import { BaseComponent } from '~/pages/base.component';

import { CfnService } from '~/services/cfn.service';

export interface TerraformModuleResult {
    module: string;
    files: Record<string, string>;
}

@Component({
    selector: 'cfn',
    standalone: true,
    imports: [
        CommonModule,
        SDKDatagridModule,
        SDKLoadingModule,
    ],
    templateUrl: './cfn.component.html',
    styleUrls: ['./cfn.component.scss']
})

export class CfnComponent extends BaseComponent implements OnInit {
    @Input() username: string = "";

    @ViewChild('default') defaultTemplate!: TemplateRef<any>;
    @ViewChild('processing') processingTemplate!: TemplateRef<any>;
    @ViewChild('resources') resourcesTemplate!: TemplateRef<any>;
    @ViewChild('values') valuesTemplate!: TemplateRef<any>;

    public repoData: any = null;
    public response: any = null;
    public modules: TerraformModuleResult[] = [];

    public isProcessing: boolean = false;
    public processingMessage: string = "";

    public showGrid: boolean = false;
    public updateGrid: boolean = false;

    public columns: SDKDataGridColumn[] = [
        { Name: 'status', DisplayName: 'Status', dataTemplate: () => this.processingTemplate },
        { Name: 'path', DisplayName: 'Path' },
        { Name: 'format', DisplayName: 'Format' },
        { Name: 'classification', DisplayName: 'Classification', formatData: (value: any) => { return this.getClassificationLabel(value) } },
        { Name: 'resourceTypes', DisplayName: 'Resource Types', dataTemplate: () => this.resourcesTemplate },
        { Name: 'parameterDefaults', DisplayName: 'Default Values', dataTemplate: () => this.valuesTemplate },
    ];

    public options: SDKDataGridOptions = {
        header: false,
        footer: false,
        options: false,
        formulas: false,
        nowrap: true,
        settingsStorage: StorageType.Session
    };

    public data: any;
    public rows: number | undefined;
    public page: number | undefined;
    public total: number | undefined;
    public error: string = "";

    public messageStyle: string = "";

    private eventSource?: EventSource;

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly zone: NgZone,
        private readonly router: Router,
        private readonly cfnService: CfnService,
    ) {
        super();

        let nav = this.router.currentNavigation();

        if (nav?.extras.state?.["data"]) {
            this.isLoading = true;
            this.repoData = nav?.extras.state?.["repoData"];
            this.response = nav?.extras.state?.["data"];
            this.data = this.response["cloudFormationFiles"];
            this.total = this.response["cloudFormationFiles"].length;

            this.data = this.data.map((item: any) => ({
                status: "",
                ...item
            }));

            setTimeout(() => {
                this.updateGrid = true;
                this.showGrid = true;
            }, 100);
        } else {
            this.router.navigate(["/repo"], { state: { data: null } });
        }
    }

    public ngOnInit(): void {
        (async () => {
            await this.initAsync();
        })();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public async loadData(event: any = null) {
        if (event === null) return;

        try {
            this.isLoading = true;
            this.error = "";

            setTimeout(() => {
                this.updateGrid = true;
                this.showGrid = true;
            }, 100);

        } catch (error: any) {
            this.error = error.message || "Error loading data";
        }

        this.isLoading = false;
    }

    public generateTerraform() {
        if (this.isProcessing) return;

        this.isProcessing = true;

        this.modules = [];

        let cfns = this.response.cloudFormationFiles.map((cfn: any) => ({
            module: this.getModuleNameFromPath(cfn.path),
            rawCfn: cfn.rawCfn
        }));

        this.data = this.data.map((item: any) => ({
            ...item,
            status: "processing"
        }));

        this.updateGrid = true;

        this.processingMessage = `Processing files: (0/${cfns.length})`

        this.cfnService.generate(cfns).subscribe({
            next: (jobId: any) => {
                this.cfnService.setActiveJob(jobId);

                this.eventSource = this.cfnService.generateStream(jobId.jobId);

                this.eventSource.onmessage = (event) => {
                    let result = JSON.parse(event.data) as TerraformModuleResult;

                    this.zone.run(() => {
                        this.modules.push(result);

                        let ndx = this.getIndex(result.module);

                        if (ndx > -1) {
                            this.data[ndx].status = "fin";
                            let ele = document.getElementById(`status.${result.module}`)!;
                            ele.innerHTML = "<div class=\"icon green\">check</div>";
                        }

                        this.processingMessage = `Processing (${this.modules.length}/${cfns.length})...`
                    });
                };

                this.eventSource.addEventListener('complete', () => {
                    this.eventSource?.close();
                    this.isLoading = false;
                    this.isProcessing = false;

                    this.router.navigate(['/terraform'], { state: { repoData: this.repoData, data: this.response, modules: this.modules } });
                });

                this.eventSource.onerror = (err) => {
                    this.eventSource?.close();
                    this.isLoading = false;
                    this.isProcessing = false;
                };
            },
            error: (error: any) => {
                this.isLoading = false;
            }
        });
    }

    public cancel() {
        this.eventSource?.close();
        this.eventSource = undefined;

        this.cfnService.cancel().subscribe(() => {
            this.isLoading = false;
            this.isProcessing = false;
        });

        this.data.filter((item: any) => item.status === "processing").forEach((item: any) => {
            item.status = "";
        });

        this.updateGrid = true;
    }

    public getModuleNameFromPath(path: string): string {
        let fileName = path.split('/').pop()!;
        return fileName.replace(/\.(yaml|yml|json)$/i, '');
    }

    public back() {
        this.router.navigate(["/repo-results"], { state: { data: this.repoData } });
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private getClassificationLabel(classification: number) {
        switch (classification) {
            case 0: return "root";
            case 1: return "nested";
            case 2: return "partial";
            default: return "unknown";
        }
    }

    private getIndex(module: string): number {
        return this.data.findIndex((item: any) => this.getModuleNameFromPath(item.path) === module);
    }
}
