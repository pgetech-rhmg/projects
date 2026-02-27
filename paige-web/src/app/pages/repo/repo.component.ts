import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

import { SDKLoadingModule } from 'sdk-loading';

import { RepoService } from '~/services/repo.service';

import { BaseComponent } from '~/pages/base.component';

@Component({
    selector: 'repo',
    standalone: true,
    imports: [
        CommonModule,
        FormsModule,
        SDKLoadingModule,
    ],
    templateUrl: './repo.component.html',
    styleUrls: ['./repo.component.scss']
})

export class RepoComponent extends BaseComponent implements OnInit {
    public repository = ""; //"sample-pipeline-artifacts"; //'pge-dotcom-aem';
    public branch = ""; //"main"; //'main';

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly router: Router,
        private readonly repoService: RepoService,
    ) {
        super();

        const nav = this.router.currentNavigation();

        if (nav?.extras.state?.["data"]) {
            this.repository = nav?.extras.state?.["data"].repository;
            this.branch = nav?.extras.state?.["data"].branch;
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
    public scan() {
        if (this.repository === "" || this.branch === "") {
            return;
        }

        this.isLoading = true;

        let request = {
            RepoName: this.repository,
            branch: this.branch
        };

        this.repoService.assess(request).subscribe({
            next: (response: any) => {
                this.isLoading = false;

                this.router.navigate(["/repo-results"], { state: { data: response } });
            },
            error: (error: any) => {
                this.isLoading = false;
            }
        });
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
}
