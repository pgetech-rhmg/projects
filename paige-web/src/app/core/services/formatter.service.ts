import { DatePipe, DecimalPipe, CurrencyPipe } from '@angular/common';
import { Injectable } from '@angular/core';

const LOCALE = "en-US";

@Injectable()
export class FormatterService {
    private readonly _datePipe = new DatePipe(LOCALE);
    private readonly _decimalPipe = new DecimalPipe(LOCALE);
    private readonly _currencyPipe = new CurrencyPipe(LOCALE);

    public formatDate(value: any, format: string = "yyyy-MM-dd"): string {
        return this._datePipe.transform(value, format) ?? "";
    }

    public formatNumber(value: any, format: string = "1.0-5"): string {
        return  this._decimalPipe.transform(value, format) ?? "";
    }

    public formatCurrency(value: any): string {
        return this._currencyPipe.transform(value) ?? "";
    }
}
