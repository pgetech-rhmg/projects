import { Component, Input, Output, OnChanges, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

import { SDKLoadingModule } from 'sdk-loading';

import { MarkdownService } from '~/services/markdown.service';

import { BaseComponent } from '~/pages/base.component';

export interface TerraformModuleResult {
    module: string;
    files: Record<string, string>;
}

@Component({
    selector: 'tab-analysis',
    standalone: true,
    imports: [
        CommonModule,
        SDKLoadingModule,
    ],
    templateUrl: './tab-analysis.component.html',
    styleUrls: ['./tab-analysis.component.scss']
})

export class TabAnalysisComponent extends BaseComponent implements OnChanges {
    @Input() isAnalyzing: boolean = true;
    @Input() output: any = null;
    @Output() setAiAssessment: EventEmitter<any> = new EventEmitter();

    public data: string = "";

    constructor(
        private readonly markdownService: MarkdownService,
    ) {
        super();
    }

    public ngOnChanges(_args: any): void {
        if (_args.output.currentValue) {
            this.data = this.markdownService.render(this.output);

            this.setAiAssessment.emit(this.output);
        }
    }
}
