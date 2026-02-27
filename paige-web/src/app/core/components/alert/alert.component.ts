import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'alert',
    standalone: true,
    imports: [
        CommonModule,
    ],
    templateUrl: './alert.component.html',
    styleUrls: ['./alert.component.scss']
})

export class AlertComponent {
    @Input() title: string = "";
    @Input() message: string = "";
    @Input() list: string = "";
    @Input() continueText: string = "";
    @Input() cancelText: string = "";
    @Output() continueEvent: EventEmitter<any> = new EventEmitter();
    @Output() cancelEvent: EventEmitter<any> = new EventEmitter();

    public process: any;

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public continue() {
        this.continueEvent.emit();
    }

    public cancel() {
        this.cancelEvent.emit();
    }
}
