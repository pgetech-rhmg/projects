 import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AlertComponent } from './alert.component';
import { EventEmitter } from '@angular/core';

describe('AlertComponent', () => {
    let component: AlertComponent;
    let fixture: ComponentFixture<AlertComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [AlertComponent]
        }).compileComponents();

        fixture = TestBed.createComponent(AlertComponent);
        component = fixture.componentInstance;
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    describe('Component Initialization', () => {
        it('should create', () => {
            expect(component).toBeTruthy();
        });

        it('should initialize with empty title', () => {
            expect(component.title).toBe('');
        });

        it('should initialize with empty message', () => {
            expect(component.message).toBe('');
        });

        it('should initialize with empty list', () => {
            expect(component.list).toBe('');
        });

        it('should initialize with empty continueText', () => {
            expect(component.continueText).toBe('');
        });

        it('should initialize with empty cancelText', () => {
            expect(component.cancelText).toBe('');
        });

        it('should initialize with undefined process property', () => {
            expect(component.process).toBeUndefined();
        });

        it('should be a standalone component', () => {
            const componentMetadata = (AlertComponent as any).ɵcmp;
            expect(componentMetadata.standalone).toBe(true);
        });

        it('should have correct selector', () => {
            const componentMetadata = (AlertComponent as any).ɵcmp;
            expect(componentMetadata.selectors).toEqual([['alert']]);
        });
    });

    describe('Input Properties', () => {
        it('should accept title input', () => {
            component.title = 'Alert Title';
            expect(component.title).toBe('Alert Title');
        });

        it('should accept message input', () => {
            component.message = 'This is an alert message';
            expect(component.message).toBe('This is an alert message');
        });

        it('should accept list input', () => {
            component.list = 'Item 1, Item 2, Item 3';
            expect(component.list).toBe('Item 1, Item 2, Item 3');
        });

        it('should accept continueText input', () => {
            component.continueText = 'OK';
            expect(component.continueText).toBe('OK');
        });

        it('should accept cancelText input', () => {
            component.cancelText = 'Cancel';
            expect(component.cancelText).toBe('Cancel');
        });

        it('should handle all inputs being set simultaneously', () => {
            component.title = 'Confirm Action';
            component.message = 'Are you sure?';
            component.list = 'Action 1, Action 2';
            component.continueText = 'Yes';
            component.cancelText = 'No';

            expect(component.title).toBe('Confirm Action');
            expect(component.message).toBe('Are you sure?');
            expect(component.list).toBe('Action 1, Action 2');
            expect(component.continueText).toBe('Yes');
            expect(component.cancelText).toBe('No');
        });

        it('should handle long text inputs', () => {
            const longText = 'a'.repeat(1000);
            component.title = longText;
            component.message = longText;
            component.list = longText;

            expect(component.title).toBe(longText);
            expect(component.message).toBe(longText);
            expect(component.list).toBe(longText);
        });

        it('should handle special characters in inputs', () => {
            component.title = 'Alert <>&"';
            component.message = 'Special chars: !@#$%^&*()';
            
            expect(component.title).toBe('Alert <>&"');
            expect(component.message).toBe('Special chars: !@#$%^&*()');
        });

        it('should handle multiline text in inputs', () => {
            const multiline = 'Line 1\nLine 2\nLine 3';
            component.message = multiline;
            
            expect(component.message).toBe(multiline);
        });
    });

    describe('Output Events', () => {
        it('should have continueEvent as EventEmitter', () => {
            expect(component.continueEvent).toBeDefined();
            expect(component.continueEvent).toBeInstanceOf(EventEmitter);
        });

        it('should have cancelEvent as EventEmitter', () => {
            expect(component.cancelEvent).toBeDefined();
            expect(component.cancelEvent).toBeInstanceOf(EventEmitter);
        });

        it('should emit continueEvent when continue is called', () => {
            const emitSpy = jest.spyOn(component.continueEvent, 'emit');

            component.continue();

            expect(emitSpy).toHaveBeenCalledTimes(1);
        });

        it('should emit cancelEvent when cancel is called', () => {
            const emitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.cancel();

            expect(emitSpy).toHaveBeenCalledTimes(1);
        });

        it('should emit continueEvent with no arguments', () => {
            const emitSpy = jest.spyOn(component.continueEvent, 'emit');

            component.continue();

            expect(emitSpy).toHaveBeenCalledWith();
        });

        it('should emit cancelEvent with no arguments', () => {
            const emitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.cancel();

            expect(emitSpy).toHaveBeenCalledWith();
        });

        it('should allow subscribing to continueEvent', (done) => {
            component.continueEvent.subscribe(() => {
                expect(true).toBe(true);
                done();
            });

            component.continue();
        });

        it('should allow subscribing to cancelEvent', (done) => {
            component.cancelEvent.subscribe(() => {
                expect(true).toBe(true);
                done();
            });

            component.cancel();
        });
    });

    describe('continue method', () => {
        it('should be defined', () => {
            expect(component.continue).toBeDefined();
            expect(typeof component.continue).toBe('function');
        });

        it('should not throw error when called', () => {
            expect(() => component.continue()).not.toThrow();
        });

        it('should handle multiple consecutive calls', () => {
            const emitSpy = jest.spyOn(component.continueEvent, 'emit');

            component.continue();
            component.continue();
            component.continue();

            expect(emitSpy).toHaveBeenCalledTimes(3);
        });

        it('should emit event regardless of input values', () => {
            const emitSpy = jest.spyOn(component.continueEvent, 'emit');

            component.title = 'Test';
            component.continue();

            expect(emitSpy).toHaveBeenCalled();
        });

        it('should work after component initialization', () => {
            fixture.detectChanges();
            const emitSpy = jest.spyOn(component.continueEvent, 'emit');

            component.continue();

            expect(emitSpy).toHaveBeenCalled();
        });
    });

    describe('cancel method', () => {
        it('should be defined', () => {
            expect(component.cancel).toBeDefined();
            expect(typeof component.cancel).toBe('function');
        });

        it('should not throw error when called', () => {
            expect(() => component.cancel()).not.toThrow();
        });

        it('should handle multiple consecutive calls', () => {
            const emitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.cancel();
            component.cancel();
            component.cancel();

            expect(emitSpy).toHaveBeenCalledTimes(3);
        });

        it('should emit event regardless of input values', () => {
            const emitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.message = 'Test';
            component.cancel();

            expect(emitSpy).toHaveBeenCalled();
        });

        it('should work after component initialization', () => {
            fixture.detectChanges();
            const emitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.cancel();

            expect(emitSpy).toHaveBeenCalled();
        });
    });

    describe('process property', () => {
        it('should allow assignment of values', () => {
            component.process = 'test';
            expect(component.process).toBe('test');
        });

        it('should accept any value', () => {
            component.process = 'test';
            expect(component.process).toBe('test');

            component.process = 123;
            expect(component.process).toBe(123);

            component.process = { key: 'value' };
            expect(component.process).toEqual({ key: 'value' });

            component.process = ['array'];
            expect(component.process).toEqual(['array']);
        });

        it('should allow null assignment', () => {
            component.process = null;
            expect(component.process).toBeNull();
        });

        it('should maintain value through change detection', () => {
            component.process = 'test value';
            fixture.detectChanges();

            expect(component.process).toBe('test value');
        });
    });

    describe('Event Interactions', () => {
        it('should handle both events being called in sequence', () => {
            const continueEmitSpy = jest.spyOn(component.continueEvent, 'emit');
            const cancelEmitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.continue();
            component.cancel();

            expect(continueEmitSpy).toHaveBeenCalledTimes(1);
            expect(cancelEmitSpy).toHaveBeenCalledTimes(1);
        });

        it('should handle events being called in reverse order', () => {
            const continueEmitSpy = jest.spyOn(component.continueEvent, 'emit');
            const cancelEmitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.cancel();
            component.continue();

            expect(cancelEmitSpy).toHaveBeenCalledTimes(1);
            expect(continueEmitSpy).toHaveBeenCalledTimes(1);
        });

        it('should not affect component state when events are emitted', () => {
            component.title = 'Original Title';
            component.message = 'Original Message';

            component.continue();

            expect(component.title).toBe('Original Title');
            expect(component.message).toBe('Original Message');

            component.cancel();

            expect(component.title).toBe('Original Title');
            expect(component.message).toBe('Original Message');
        });
    });

    describe('Integration Scenarios', () => {
        it('should support typical confirmation dialog workflow', () => {
            // Setup alert
            component.title = 'Delete Item';
            component.message = 'Are you sure you want to delete this item?';
            component.continueText = 'Delete';
            component.cancelText = 'Cancel';

            fixture.detectChanges();

            // User clicks continue
            const continueEmitSpy = jest.spyOn(component.continueEvent, 'emit');
            component.continue();

            expect(continueEmitSpy).toHaveBeenCalled();
        });

        it('should support warning dialog workflow', () => {
            // Setup warning
            component.title = 'Warning';
            component.message = 'This action cannot be undone';
            component.list = 'File 1, File 2, File 3';
            component.continueText = 'Proceed';
            component.cancelText = 'Go Back';

            fixture.detectChanges();

            // User clicks cancel
            const cancelEmitSpy = jest.spyOn(component.cancelEvent, 'emit');
            component.cancel();

            expect(cancelEmitSpy).toHaveBeenCalled();
        });

        it('should handle rapid user interactions', () => {
            const continueEmitSpy = jest.spyOn(component.continueEvent, 'emit');
            const cancelEmitSpy = jest.spyOn(component.cancelEvent, 'emit');

            component.continue();
            component.cancel();
            component.continue();
            component.cancel();

            expect(continueEmitSpy).toHaveBeenCalledTimes(2);
            expect(cancelEmitSpy).toHaveBeenCalledTimes(2);
        });

        it('should maintain state through multiple interactions', () => {
            component.title = 'Test Alert';
            
            component.continue();
            expect(component.title).toBe('Test Alert');
            
            component.cancel();
            expect(component.title).toBe('Test Alert');
            
            component.title = 'Updated Alert';
            component.continue();
            expect(component.title).toBe('Updated Alert');
        });
    });

    describe('Edge Cases', () => {
        it('should handle empty strings for all inputs', () => {
            component.title = '';
            component.message = '';
            component.list = '';
            component.continueText = '';
            component.cancelText = '';

            expect(() => component.continue()).not.toThrow();
            expect(() => component.cancel()).not.toThrow();
        });

        it('should handle whitespace-only inputs', () => {
            component.title = '   ';
            component.message = '\n\t';

            expect(component.title).toBe('   ');
            expect(component.message).toBe('\n\t');
        });

        it('should handle HTML content in inputs', () => {
            component.message = '<script>alert("test")</script>';
            expect(component.message).toBe('<script>alert("test")</script>');
        });

        it('should handle JSON strings in inputs', () => {
            component.list = '{"items": ["a", "b", "c"]}';
            expect(component.list).toBe('{"items": ["a", "b", "c"]}');
        });

        it('should handle Unicode characters', () => {
            component.title = '警告 🚨 تحذير';
            expect(component.title).toBe('警告 🚨 تحذير');
        });
    });

    describe('Component Lifecycle', () => {
        it('should maintain event emitters through change detection', () => {
            const originalContinueEvent = component.continueEvent;
            const originalCancelEvent = component.cancelEvent;

            fixture.detectChanges();

            expect(component.continueEvent).toBe(originalContinueEvent);
            expect(component.cancelEvent).toBe(originalCancelEvent);
        });

        it('should handle input changes after initialization', () => {
            fixture.detectChanges();

            component.title = 'New Title';
            fixture.detectChanges();

            expect(component.title).toBe('New Title');
        });

        it('should support event emission after multiple change detections', () => {
            fixture.detectChanges();
            fixture.detectChanges();
            fixture.detectChanges();

            const emitSpy = jest.spyOn(component.continueEvent, 'emit');
            component.continue();

            expect(emitSpy).toHaveBeenCalled();
        });
    });
});
