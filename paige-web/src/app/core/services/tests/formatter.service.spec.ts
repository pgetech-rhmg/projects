import { TestBed } from '@angular/core/testing';
import { FormatterService } from '~/core/services/formatter.service';

describe('FormatterService', () => {
    let service: FormatterService;

    beforeEach(() => {
        TestBed.configureTestingModule({
            providers: [FormatterService]
        });

        service = TestBed.inject(FormatterService);
    });

    describe('Service Creation', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });
    });

    describe('formatDate', () => {
        it('should format date with default format (yyyy-MM-dd)', () => {
            const date = new Date('2024-03-15T10:30:00');
            const result = service.formatDate(date);
            
            expect(result).toBe('2024-03-15');
        });

        it('should format date with custom format (MM/dd/yyyy)', () => {
            const date = new Date('2024-03-15T10:30:00');
            const result = service.formatDate(date, 'MM/dd/yyyy');
            
            expect(result).toBe('03/15/2024');
        });

        it('should format date with time format (yyyy-MM-dd HH:mm:ss)', () => {
            const date = new Date('2024-03-15T10:30:45');
            const result = service.formatDate(date, 'yyyy-MM-dd HH:mm:ss');
            
            expect(result).toBe('2024-03-15 10:30:45');
        });

        it('should format date with short format (M/d/yy)', () => {
            const date = new Date('2024-03-05T10:30:00');
            const result = service.formatDate(date, 'M/d/yy');
            
            expect(result).toBe('3/5/24');
        });

        it('should format date with medium format (MMM d, y)', () => {
            const date = new Date('2024-03-15T10:30:00');
            const result = service.formatDate(date, 'MMM d, y');
            
            expect(result).toBe('Mar 15, 2024');
        });

        it('should format date with full format (EEEE, MMMM d, y)', () => {
            const date = new Date('2024-03-15T10:30:00');
            const result = service.formatDate(date, 'EEEE, MMMM d, y');
            
            expect(result).toBe('Friday, March 15, 2024');
        });

        it('should handle date string input', () => {
            const dateString = '2024-03-15';
            const result = service.formatDate(dateString);
            
            expect(result).toBe('2024-03-15');
        });

        it('should handle timestamp input', () => {
            const timestamp = new Date('2024-03-15T10:30:00').getTime();
            const result = service.formatDate(timestamp);
            
            expect(result).toBe('2024-03-15');
        });

        it('should return empty string for null input', () => {
            const result = service.formatDate(null);
            
            expect(result).toBe('');
        });

        it('should return empty string for undefined input', () => {
            const result = service.formatDate(undefined);
            
            expect(result).toBe('');
        });

        it('should throw error for invalid date', () => {
            expect(() => service.formatDate('invalid-date')).toThrow();
        });

        it('should handle ISO 8601 date strings', () => {
            const isoDate = '2024-03-15T10:30:00.000Z';
            const result = service.formatDate(isoDate, 'yyyy-MM-dd');
            
            expect(result).toContain('2024-03-15');
        });
    });

    describe('formatNumber', () => {
        it('should format number with default format (1.0-5)', () => {
            const number = 1234.56789;
            const result = service.formatNumber(number);
            
            expect(result).toBe('1,234.56789');
        });

        it('should format number with custom format (1.2-2)', () => {
            const number = 1234.56789;
            const result = service.formatNumber(number, '1.2-2');
            
            expect(result).toBe('1,234.57');
        });

        it('should format number with no decimal places (1.0-0)', () => {
            const number = 1234.56789;
            const result = service.formatNumber(number, '1.0-0');
            
            expect(result).toBe('1,235');
        });

        it('should format number with minimum 3 decimal places (1.3-3)', () => {
            const number = 1234.5;
            const result = service.formatNumber(number, '1.3-3');
            
            expect(result).toBe('1,234.500');
        });

        it('should format zero', () => {
            const number = 0;
            const result = service.formatNumber(number);
            
            expect(result).toBe('0');
        });

        it('should format negative numbers', () => {
            const number = -1234.56;
            const result = service.formatNumber(number);
            
            expect(result).toBe('-1,234.56');
        });

        it('should format very large numbers', () => {
            const number = 1234567890.123;
            const result = service.formatNumber(number);
            
            expect(result).toBe('1,234,567,890.123');
        });

        it('should format very small numbers', () => {
            const number = 0.00001;
            const result = service.formatNumber(number);
            
            expect(result).toBe('0.00001');
        });

        it('should handle string number input', () => {
            const number = '1234.56';
            const result = service.formatNumber(number);
            
            expect(result).toBe('1,234.56');
        });

        it('should return empty string for null input', () => {
            const result = service.formatNumber(null);
            
            expect(result).toBe('');
        });

        it('should return empty string for undefined input', () => {
            const result = service.formatNumber(undefined);
            
            expect(result).toBe('');
        });

        it('should throw error for invalid number', () => {
            expect(() => service.formatNumber('not-a-number')).toThrow();
        });

        it('should format integer without decimal point', () => {
            const number = 1234;
            const result = service.formatNumber(number);
            
            expect(result).toBe('1,234');
        });

        it('should handle format with min and max decimal places (1.1-3)', () => {
            const number1 = 1234.5;
            const result1 = service.formatNumber(number1, '1.1-3');
            expect(result1).toBe('1,234.5');

            const number2 = 1234.56789;
            const result2 = service.formatNumber(number2, '1.1-3');
            expect(result2).toBe('1,234.568');
        });
    });

    describe('formatCurrency', () => {
        it('should format currency with default USD format', () => {
            const value = 1234.56;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$1,234.56');
        });

        it('should format zero as currency', () => {
            const value = 0;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$0.00');
        });

        it('should format negative currency', () => {
            const value = -1234.56;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('-$1,234.56');
        });

        it('should format large currency values', () => {
            const value = 1234567890.12;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$1,234,567,890.12');
        });

        it('should format small currency values', () => {
            const value = 0.99;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$0.99');
        });

        it('should round to 2 decimal places', () => {
            const value = 1234.567;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$1,234.57');
        });

        it('should handle string number input', () => {
            const value = '1234.56';
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$1,234.56');
        });

        it('should handle integer input', () => {
            const value = 1234;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$1,234.00');
        });

        it('should return empty string for null input', () => {
            const result = service.formatCurrency(null);
            
            expect(result).toBe('');
        });

        it('should return empty string for undefined input', () => {
            const result = service.formatCurrency(undefined);
            
            expect(result).toBe('');
        });

        it('should throw error for invalid currency value', () => {
            expect(() => service.formatCurrency('not-a-number')).toThrow();
        });

        it('should format cents correctly', () => {
            const value = 0.01;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$0.01');
        });

        it('should format values less than one dollar', () => {
            const value = 0.50;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$0.50');
        });

        it('should handle very large amounts', () => {
            const value = 999999999.99;
            const result = service.formatCurrency(value);
            
            expect(result).toBe('$999,999,999.99');
        });
    });

    describe('Edge Cases and Integration', () => {
        it('should handle multiple consecutive calls', () => {
            const date = new Date('2024-03-15T10:30:00');
            const number = 1234.56;
            const currency = 9999.99;

            const result1 = service.formatDate(date);
            const result2 = service.formatNumber(number);
            const result3 = service.formatCurrency(currency);

            expect(result1).toBe('2024-03-15');
            expect(result2).toBe('1,234.56');
            expect(result3).toBe('$9,999.99');
        });

        it('should maintain consistent formatting across calls', () => {
            const value = 1234.56;

            const result1 = service.formatNumber(value);
            const result2 = service.formatNumber(value);

            expect(result1).toBe(result2);
        });

        it('should handle empty string inputs', () => {
            const dateResult = service.formatDate('');
            const numberResult = service.formatNumber('');
            const currencyResult = service.formatCurrency('');

            expect(dateResult).toBe('');
            expect(numberResult).toBe('');
            expect(currencyResult).toBe('');
        });

        it('should throw errors for object inputs', () => {
            const obj = { value: 123 };

            expect(() => service.formatDate(obj)).toThrow();
            expect(() => service.formatNumber(obj)).toThrow();
            expect(() => service.formatCurrency(obj)).toThrow();
        });
    });
});
