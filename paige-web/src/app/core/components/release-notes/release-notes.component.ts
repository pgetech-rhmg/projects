import { AfterViewInit, ChangeDetectorRef, Component, ElementRef, EventEmitter, OnInit, Output, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpBackend, HttpClient, HttpHeaders } from '@angular/common/http';

import { lastValueFrom } from 'rxjs';

import MarkdownIt from 'markdown-it';
import markdownItAnchor from 'markdown-it-anchor';

import { SDKLoadingModule } from 'sdk-loading';

// Define slugify as a standalone variable for reuse and testability
export const slugifyFn = (s: string): string => s.toLowerCase().replaceAll(/\s+/g, '-');

// Define callback as a standalone variable for reuse and testability
export const callbackFn = (token: any, info: any): void => {
    if (token.tag === 'a') {
        token.attrSet('href', `#${info.slug}`);
    }
};

@Component({
    selector: 'release-notes',
    standalone: true,
    imports: [
        CommonModule,
        SDKLoadingModule,
    ],
    templateUrl: './release-notes.component.html',
    styleUrls: ['./release-notes.component.scss']
})

export class ReleaseNotesComponent implements OnInit, AfterViewInit {
    @ViewChild("data") data!: ElementRef;
    @Output() closeEvent: EventEmitter<any> = new EventEmitter();

    public isLoading: boolean = true;
    public file: string = "";

    private readonly http: HttpClient;
    private readonly markdown: any;

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly httpHandler: HttpBackend,
        private readonly cdr: ChangeDetectorRef,
    ) { 
        this.http = new HttpClient(this.httpHandler);

        this.markdown = new MarkdownIt()
            .use(markdownItAnchor, {
                slugify: slugifyFn,
                callback: callbackFn,
            });
    }

    public ngOnInit() {
        (async () => {
            await this.loadReleaseNotesFile();

            this.isLoading = false;
        })();
    }

    public ngAfterViewInit() {
        this.setupAnchorLinkHandlers();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public close() {
        this.closeEvent.emit();
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private async loadReleaseNotesFile() {
        const stream$ = this.http.get("assets/release-notes.md", {
            headers: new HttpHeaders({
                "Accept": "text/plain, text/markdown, */*"
            }),
            responseType: 'text'
        });
    
        await lastValueFrom(stream$).then((data: string) => {
            this.file = this.markdown.render(data);
            this.cdr.detectChanges(); // Trigger change detection after setting release notes

            let html = document.querySelectorAll('release-notes')[0];

            if (html) {
                let headers = html.querySelectorAll('h1, h2, h3');

                headers.forEach((header: any) => {
                    header.setAttribute("id", header.innerHTML.toLowerCase().replaceAll(/[^a-z0-9]+/g, '-'));
                });
    
                let paras = html.querySelectorAll('p');
        
                paras.forEach((para: any) => {
                    para.setAttribute("style", "padding-bottom: 20px");
                });
    
                let lis = html.querySelectorAll('li');
        
                lis.forEach((li: any) => {
                    li.setAttribute("style", "padding-bottom: 10px");
                });
    
                let images = html.querySelectorAll('img');
        
                images.forEach((image: any) => {
                    image.style.width = "80%";
                    image.style.padding = "20px";
                });
            }
        }).catch(error => {
            console.error("Failed to load Release Notes:", error);
        });
    }
        
    private setupAnchorLinkHandlers() {
        setTimeout(() => {
            let anchors = document.querySelectorAll('a[href^="#"]');

            anchors.forEach(anchor => {
                let targetId = anchor.getAttribute('href')?.substring(1);

                anchor.addEventListener('click', (event) => {
                    event.preventDefault();

                    if (targetId) {
                        let targetElement = this.data.nativeElement.querySelector(`#${targetId}`);

                        if (targetElement) {
                            targetElement.scrollIntoView({ behavior: 'smooth' });
                        }
                    }
                });
            });
        }, 100);
    }
}
