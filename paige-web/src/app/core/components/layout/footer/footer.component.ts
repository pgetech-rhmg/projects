import { Component, EventEmitter, Input, OnChanges, Output } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';

import { AppComponent } from '~/core/app.component';
import { Variables, VariableType } from '~/core/classes/user/variables';

import { ReleaseNotesComponent } from '~/core/components/release-notes/release-notes.component';

@Component({
	selector: 'footer',
	standalone: true,
    imports: [
        CommonModule,
        DatePipe,
    ],
	templateUrl: './footer.component.html',
	styleUrls: ['./footer.component.scss']
})

export class FooterComponent implements OnChanges {
	@Input() version: any = "0.0.0";
    @Input() expand: boolean = false;
	@Output() setLayoutCssClass = new EventEmitter();

	public date = new Date();

	public appIcon: string = "web_asset";
	public appTitle: string = "Application Mode";

	//*************************************************************************
	//  Component Life-Cycle Methods
	//*************************************************************************
	constructor(
		private readonly app: AppComponent,
	) { }

	public ngOnChanges(_args: any) {
		if (_args.version?.currentValue && _args.version?.firstChange) {
			this.isNewRelease(_args.version.currentValue);
		}

		if (_args.expand) {
			document.documentElement.style.setProperty('--left-padding', this.expand ? '250px' : '50px');
		}
	}

	//*************************************************************************
	//  Public Methods
	//*************************************************************************
	public showReleaseNotes() {
		this.app.modal = {
			type: <any>ReleaseNotesComponent,
			inputs: {},
			outputs: {
				closeEvent: () => {
					this.app.modal = undefined;
				}
			}
		}
	}

	//*************************************************************************
	//  Private Methods
	//*************************************************************************
	public isNewRelease(version: any) {
		let showWindow: boolean = false;
		let lastVersion = Variables.get("App.Version", VariableType.Local);
		let versionDiff = [];
		let lastVersionDiff = [];

		if (lastVersion) {
			versionDiff = version.split(".");
			lastVersionDiff = lastVersion.split(".");

			if ((versionDiff.length >= 2 && lastVersionDiff.length >= 2)
				&& (versionDiff[0] !== lastVersionDiff[0] || versionDiff[1] !== lastVersionDiff[1])) {
				showWindow = true;
			}
		} else {
			showWindow = true;
		}

		if (showWindow) {
			const check = setInterval(() => {
				if (!this.app.modal) {
					clearInterval(check);

					this.showReleaseNotes();
				}
			}, 1000);
		}

		Variables.set("App.Version", version, VariableType.Local);
	}
}
