import { Component, EventEmitter, OnInit, Output, ViewChild } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';

import Chart from 'chart.js/auto'

import { SDKLoadingModule } from 'sdk-loading';
import { SDKSelectModule } from 'sdk-select';
import { SDKTextboxModule } from 'sdk-textbox';

import { ActivityService } from '~/core/services/activity.service';

import { Colors } from '~/core/utils/colors';

@Component({
    selector: 'report',
    standalone: true,
    imports: [
        CommonModule,
        DatePipe,
        SDKLoadingModule,
        SDKSelectModule,
        SDKTextboxModule,
    ],
    templateUrl: './report.component.html',
    styleUrls: ['./report.component.scss']
})

export class ReportComponent implements OnInit {
    @Output() closeEvent: EventEmitter<any> = new EventEmitter();

    @ViewChild('chartCanvas') chartCanvas!: { nativeElement: any };

    public types: any = ["Activities", "Sessions", "Users"];
    public timeframes: any = ["[Custom]", "Last 30 days", "Last 60 days", "Last 90 days", "Last 120 days", "YTD"];
    public selectedType: any = ["Activities"];
    public selectedTimeframe: any = "Last 30 days";
    public startDate: any = "";
    public endDate: any = "";
    public showDates: boolean = false;

    public showFilters: boolean = false;
    public filterType: any = "Activities";
    public filterStartDate: any = "";
    public filterEndDate: any = "";

    public total: number | null = null;

    public isLoading: boolean = false;
    public error: string = "";

    private data: any;
    private canvas: any;
    private ctx: any;
    private chartjs: any;

    private readonly datePipe = new DatePipe("en-US");

    constructor(
        private readonly activityService: ActivityService,
    ) {
    }

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    public ngOnInit() {
        (async () => {
            this.setTimeframe(["Last 30 days"]);

            await this.loadData();
        })();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public setTimeframe(event: any) {
        this.selectedTimeframe = event[0];
        this.showDates = false;

        let sdt = new Date(new Date().setMonth(new Date().getMonth() - 1));
        let edt = new Date(new Date().setDate(new Date().getDate() + 1));

        switch (this.selectedTimeframe) {
            case "[Custom]":
                this.showDates = true;
                break;

            case "Last 30 days":
                sdt = new Date(new Date().setMonth(new Date().getMonth() - 1));
                break;

            case "Last 60 days":
                sdt = new Date(new Date().setMonth(new Date().getMonth() - 2));
                break;

            case "Last 90 days":
                sdt = new Date(new Date().setMonth(new Date().getMonth() - 3));
                break;

            case "Last 120 days":
                sdt = new Date(new Date().setMonth(new Date().getMonth() - 4));
                break;

            default:
                sdt = new Date(new Date(new Date().getFullYear(), 0, 1));
                break;
        }

        this.startDate = this.datePipe.transform(sdt, 'MM/dd/yyyy 00:00:00');
        this.endDate = this.datePipe.transform(edt, 'MM/dd/yyyy 23:59:59');
    }

    public validateDates(field: string) {
        if (this.startDate !== "" && this.endDate !== "") {
            let sdt = new Date(this.startDate).getTime();
            let edt = new Date(this.endDate).getTime();

            if (field === "start" && sdt > edt) {
                setTimeout(() => {
                    this.startDate = this.endDate;
                }, 1);
            }
            if (field === "end" && edt < sdt) {
                setTimeout(() => {
                    this.endDate = this.startDate;
                }, 1);
            }
        }
    }

    public closeFilters() {
        this.showFilters = false;
    }

    public close() {
        this.closeEvent.emit();
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    public async loadData() {
        try {
            this.isLoading = true;

            let sdt = this.datePipe.transform(this.startDate, 'MM/dd/yyyy 00:00:00');
            let edt = this.datePipe.transform(this.endDate, 'MM/dd/yyyy 23:59:59');

            this.filterType = this.selectedType;
            this.filterStartDate = sdt;
            this.filterEndDate = edt;

            await this.activityService.GetActivity(this.selectedType[0].toLocaleLowerCase(), sdt, edt).then((response: any) => {
                if (response) {
                    this.data = response;

                    switch (this.selectedType[0].toLocaleLowerCase()) {
                        case "sessions":
                        case "users": {
                            let values = this.data.flatMap((item: any) => item.value);
                            let uniqueValues = new Set(values);
                            this.total = uniqueValues.size;
                            break;
                        }

                        default:
                            this.total = null;
                    };

                    this.createChart();
                } else {
                    this.data = null;
                    this.total = null;
                }

                this.error = "";
                this.isLoading = false;
            });

        } catch (error: any) {
            this.error = error.message;

            this.isLoading = false;
        }
    }

    private createChart() {
        let labels: any[] = this.data.map((d: any) => {
            switch (d.event) {
                case "File":
                    return "Files Viewed";

                case "Search":
                    return "Searches";

                case "View":
                    return "Visits";
            }

            return d.event;
        });
        let datasets: any[] = [];
        let colors: any[] = Colors.getRandomColors(labels.length);

        datasets = [
            {
                data: this.data.map((d: any) => d.count),
                label: this.data.map((d: any) => d.event),
                backgroundColor: colors
            }
        ]

        this.destroyChart();

        this.canvas = this.chartCanvas.nativeElement;

        this.ctx = this.canvas.getContext('2d');

        this.chartjs = new Chart(this.ctx, {
            type: "bar",
            data: {
                labels: labels,
                datasets: datasets
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio: 1,
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: "Counts"
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: "Events"
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: (context: any) => {
                                return `${context.raw}`;
                            }
                        }
                    }
                }
            }
        });
    }

    private destroyChart() {
        if (this.chartjs) {
            this.chartjs.destroy();
            this.chartjs = undefined;
        }
    }
}
