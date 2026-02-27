import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ErrorComponent } from './error.component';

describe('ErrorComponent', () => {
    let component: ErrorComponent;
    let fixture: ComponentFixture<ErrorComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [ErrorComponent]
        }).compileComponents();

        fixture = TestBed.createComponent(ErrorComponent);
        component = fixture.componentInstance;
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    describe('Component Initialization', () => {
        it('should create', () => {
            expect(component).toBeTruthy();
        });

        it('should initialize with empty message', () => {
            expect(component.message).toBe('');
        });

        it('should be a standalone component', () => {
            const componentMetadata = (ErrorComponent as any).ɵcmp;
            expect(componentMetadata.standalone).toBe(true);
        });

        it('should have correct selector', () => {
            const componentMetadata = (ErrorComponent as any).ɵcmp;
            expect(componentMetadata.selectors).toEqual([['error']]);
        });
    });

    describe('Input Properties', () => {
        it('should have message as an input property', () => {
            expect(component.message).toBeDefined();
            expect(typeof component.message).toBe('string');
        });

        it('should accept message input', () => {
            component.message = 'Test error message';
            expect(component.message).toBe('Test error message');
        });

        it('should handle empty string message', () => {
            component.message = '';
            expect(component.message).toBe('');
        });

        it('should handle long error messages', () => {
            const longMessage = 'This is a very long error message that contains a lot of detail about what went wrong. '.repeat(10);
            component.message = longMessage;
            expect(component.message).toBe(longMessage);
        });

        it('should handle multiline error messages', () => {
            const multilineMessage = 'Error line 1\nError line 2\nError line 3';
            component.message = multilineMessage;
            expect(component.message).toBe(multilineMessage);
        });

        it('should handle special characters in message', () => {
            const specialMessage = 'Error: <script>alert("test")</script> & special chars!';
            component.message = specialMessage;
            expect(component.message).toBe(specialMessage);
        });

        it('should handle HTML entities in message', () => {
            const htmlMessage = 'Error &lt;div&gt; &amp; &quot;quotes&quot;';
            component.message = htmlMessage;
            expect(component.message).toBe(htmlMessage);
        });

        it('should handle Unicode characters in message', () => {
            const unicodeMessage = 'Error: 你好 🚨 مرحبا';
            component.message = unicodeMessage;
            expect(component.message).toBe(unicodeMessage);
        });

        it('should handle whitespace-only message', () => {
            component.message = '   ';
            expect(component.message).toBe('   ');
        });

        it('should handle message with leading/trailing whitespace', () => {
            const message = '  Error message  ';
            component.message = message;
            expect(component.message).toBe(message);
        });
    });

    describe('Input Binding', () => {
        it('should update message when input changes', () => {
            // Initial value
            component.message = 'First message';
            fixture.detectChanges();
            expect(component.message).toBe('First message');

            // Changed value
            component.message = 'Second message';
            fixture.detectChanges();
            expect(component.message).toBe('Second message');
        });

        it('should handle rapid message changes', () => {
            const messages = ['Error 1', 'Error 2', 'Error 3', 'Error 4', 'Error 5'];
            
            messages.forEach(msg => {
                component.message = msg;
                fixture.detectChanges();
                expect(component.message).toBe(msg);
            });
        });

        it('should reflect input changes in component instance', () => {
            fixture.componentRef.setInput('message', 'Input test');
            fixture.detectChanges();
            expect(component.message).toBe('Input test');
        });
    });

    describe('Edge Cases', () => {
        it('should handle null-like string values', () => {
            component.message = 'null';
            expect(component.message).toBe('null');

            component.message = 'undefined';
            expect(component.message).toBe('undefined');
        });

        it('should handle numeric string messages', () => {
            component.message = '404';
            expect(component.message).toBe('404');

            component.message = '500';
            expect(component.message).toBe('500');
        });

        it('should handle JSON string messages', () => {
            const jsonMessage = '{"error": "Something went wrong", "code": 500}';
            component.message = jsonMessage;
            expect(component.message).toBe(jsonMessage);
        });

        it('should handle URL-encoded messages', () => {
            const encodedMessage = 'Error%3A%20Something%20went%20wrong';
            component.message = encodedMessage;
            expect(component.message).toBe(encodedMessage);
        });

        it('should handle messages with newlines and tabs', () => {
            const formattedMessage = 'Error:\n\tSomething went wrong\n\tPlease try again';
            component.message = formattedMessage;
            expect(component.message).toBe(formattedMessage);
        });

        it('should handle very long single-word messages', () => {
            const longWord = 'a'.repeat(1000);
            component.message = longWord;
            expect(component.message).toBe(longWord);
        });

        it('should handle messages with mixed quotes', () => {
            const quotedMessage = 'Error: "Something\'s wrong" with the \'system"';
            component.message = quotedMessage;
            expect(component.message).toBe(quotedMessage);
        });
    });

    describe('Type Safety', () => {
        it('should only accept string type for message', () => {
            component.message = 'Valid string';
            expect(typeof component.message).toBe('string');
        });

        it('should maintain message as string after multiple assignments', () => {
            component.message = 'First';
            component.message = 'Second';
            component.message = 'Third';
            expect(typeof component.message).toBe('string');
            expect(component.message).toBe('Third');
        });
    });

    describe('Common Error Messages', () => {
        it('should handle generic error message', () => {
            component.message = 'An error occurred';
            expect(component.message).toBe('An error occurred');
        });

        it('should handle network error message', () => {
            component.message = 'Network request failed';
            expect(component.message).toBe('Network request failed');
        });

        it('should handle authentication error message', () => {
            component.message = 'Authentication failed. Please log in again.';
            expect(component.message).toBe('Authentication failed. Please log in again.');
        });

        it('should handle validation error message', () => {
            component.message = 'Validation failed: Invalid email format';
            expect(component.message).toBe('Validation failed: Invalid email format');
        });

        it('should handle permission error message', () => {
            component.message = 'You do not have permission to perform this action';
            expect(component.message).toBe('You do not have permission to perform this action');
        });

        it('should handle timeout error message', () => {
            component.message = 'Request timed out. Please try again.';
            expect(component.message).toBe('Request timed out. Please try again.');
        });

        it('should handle server error message', () => {
            component.message = 'Internal server error (500)';
            expect(component.message).toBe('Internal server error (500)');
        });
    });

    describe('Component Lifecycle', () => {
        it('should maintain message through change detection cycles', () => {
            component.message = 'Persistent message';
            
            fixture.detectChanges();
            expect(component.message).toBe('Persistent message');
            
            fixture.detectChanges();
            expect(component.message).toBe('Persistent message');
            
            fixture.detectChanges();
            expect(component.message).toBe('Persistent message');
        });

        it('should preserve message after component re-initialization', () => {
            component.message = 'Test message';
            expect(component.message).toBe('Test message');
            
            // Simulate re-initialization
            const newFixture = TestBed.createComponent(ErrorComponent);
            const newComponent = newFixture.componentInstance;
            newComponent.message = 'Test message';
            
            expect(newComponent.message).toBe('Test message');
        });
    });
});
