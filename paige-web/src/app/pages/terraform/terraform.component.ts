import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { SDKLoadingModule } from 'sdk-loading';

import { CfnService } from '~/services/cfn.service';

import { BaseComponent } from '~/pages/base.component';

@Component({
    selector: 'terraform',
    standalone: true,
    imports: [
        CommonModule,
        SDKLoadingModule,
    ],
    templateUrl: './terraform.component.html',
    styleUrls: ['./terraform.component.scss']
})

export class TerraformComponent extends BaseComponent implements OnInit {
    public repoData: any = null;
    public data: any = null;
    public modules: any = null;
    public parsedFiles: Array<{
        module: string | null;
        files: Array<{ name: string; content: string }>;
    }> = [];


    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly router: Router,
        private readonly cfnService: CfnService,
    ) {
        super();

        let nav = this.router.currentNavigation();

        if (nav?.extras.state?.["modules"]) {
            this.isLoading = true;
            this.repoData = nav?.extras.state?.["repoData"];
            this.data = nav?.extras.state?.["data"];
            this.modules = nav?.extras.state?.["modules"];
        } else {
            this.router.navigate(["/repo"], { state: { data: null } });
        }
    }

    public ngOnInit(): void {
        (async () => {
            await this.initAsync();

            if (this.data) {
                this.createProject();
            } else {
                this.router.navigate(["/repo"], { state: { data: null } });
            }
        })();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public back() {
        this.router.navigate(["/cfn"], { state: { repoData: this.repoData, data: this.data } });
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private createProject() {
        this.isLoading = true;

        this.cfnService.createProject(this.modules).subscribe({
            next: (response: any) => {
                this.hydrateTerraformOutput(response);

                this.isLoading = false;
            },
            error: (error: any) => {
                this.isLoading = false;
            }
        });
    }

    private hydrateTerraformOutput(response: any): void {
        this.parsedFiles = [];

        if (!response) {
            return;
        }

        try {
            // Step 1: Normalize response
            let parsedOutput: any;

            if (typeof response === 'string') {
                parsedOutput = JSON.parse(response);
            }
            else if (typeof response === 'object') {
                parsedOutput = response;
            }
            else {
                return;
            }

            // Step 2: Validate Terraform response
            if (!parsedOutput.files || typeof parsedOutput.files !== 'object') {
                return;
            }

            const files = parsedOutput.files as Record<string, string>;

            // Step 3: Group files by module
            const rootFiles: Array<{ name: string; content: string }> = [];
            const modules: Record<string, Array<{ name: string; content: string }>> = {};

            for (const [path, content] of Object.entries(files)) {
                if (path.startsWith('modules/')) {
                    const [, moduleName, fileName] = path.split('/', 3);

                    if (!modules[moduleName]) {
                        modules[moduleName] = [];
                    }

                    modules[moduleName].push({
                        name: fileName,
                        content
                    });
                }
                else {
                    rootFiles.push({
                        name: path,
                        content
                    });
                }
            }

            // Step 4: Build UI model
            if (rootFiles.length) {
                this.parsedFiles.push({
                    module: null,
                    files: rootFiles
                });
            }

            for (const [module, files] of Object.entries(modules)) {
                this.parsedFiles.push({
                    module,
                    files
                });
            }
        }
        catch {
            this.parsedFiles = [];
        }
    }
}
