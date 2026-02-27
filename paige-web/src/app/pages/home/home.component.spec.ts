import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { NgZone, NO_ERRORS_SCHEMA } from '@angular/core';
import { of, throwError } from 'rxjs';
import { HomeComponent } from './home.component';

// Mock the imports
jest.mock('~/core/app.component', () => ({
    AppComponent: jest.fn().mockImplementation(() => ({}))
}));

jest.mock('~/services/chat.service', () => ({
    ChatStreamService: jest.fn().mockImplementation(() => ({
        startChat: jest.fn(),
        setActiveJob: jest.fn(),
        chatStream: jest.fn()
    }))
}));

jest.mock('~/services/markdown.service', () => ({
    MarkdownService: jest.fn().mockImplementation(() => ({
        render: jest.fn((text: string) => text)
    }))
}));

jest.mock('~/core/services/appconfig.service', () => ({
    AppConfigService: jest.fn().mockImplementation(() => ({
        getConfig: jest.fn()
    }))
}));

jest.mock('~/core/services/appsettings.service', () => ({
    AppSettingsService: jest.fn().mockImplementation(() => ({
        getSettings: jest.fn()
    }))
}));

jest.mock('~/core/services/activity.service', () => ({
    ActivityService: jest.fn().mockImplementation(() => ({
        SaveActivity: jest.fn()
    }))
}));

jest.mock('~/pages/base.component', () => ({
    BaseComponent: class {
        isLoading = false;
        async initAsync() { }
    }
}));

// Import the mocked classes
import { AppComponent } from '~/core/app.component';
import { ChatStreamService } from '~/services/chat.service';
import { MarkdownService } from '~/services/markdown.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';

describe('HomeComponent', () => {
    let component: HomeComponent;
    let fixture: ComponentFixture<HomeComponent>;
    let mockRouter: any;
    let mockNgZone: any;
    let mockChatStreamService: any;
    let mockMarkdownService: any;

    beforeEach(async () => {
        // Create mock router
        mockRouter = {
            navigate: jest.fn().mockResolvedValue(true),
            url: '/home'
        };

        // Create mock ChatStreamService
        mockChatStreamService = {
            startChat: jest.fn(),
            setActiveJob: jest.fn(),
            chatStream: jest.fn()
        };

        // Create mock MarkdownService
        mockMarkdownService = {
            render: jest.fn((text: string) => `<p>${text}</p>`)
        };

        await TestBed.configureTestingModule({
            imports: [HomeComponent],
            providers: [
                { provide: Router, useValue: mockRouter },
                { provide: AppComponent, useValue: {} },
                { provide: ChatStreamService, useValue: mockChatStreamService },
                { provide: MarkdownService, useValue: mockMarkdownService },
                { provide: AppConfigService, useValue: { getConfig: jest.fn() } },
                { provide: AppSettingsService, useValue: { getSettings: jest.fn() } },
                { provide: ActivityService, useValue: { SaveActivity: jest.fn() } }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();

        fixture = TestBed.createComponent(HomeComponent);
        component = fixture.componentInstance;
        
        // Get the real NgZone instance from the component
        mockNgZone = (component as any).zone;
    });

    describe('Constructor', () => {
        it('should create component', () => {
            expect(component).toBeTruthy();
        });

        it('should initialize messages as empty array', () => {
            expect(component.messages).toEqual([]);
        });

        it('should initialize isStreaming as false', () => {
            expect(component.isStreaming).toBe(false);
        });
    });

    describe('ngOnInit', () => {
        it('should call initAsync and focus textarea', async () => {
            // Arrange
            const mockTextarea = { focus: jest.fn() };
            component.textareaContainer = { nativeElement: mockTextarea } as any;
            jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).initAsync).toHaveBeenCalled();
            expect(mockTextarea.focus).toHaveBeenCalled();
        });
    });

    describe('ngOnDestroy', () => {
        it('should close eventSource if it exists', () => {
            // Arrange
            const mockEventSource = { close: jest.fn() };
            (component as any).eventSource = mockEventSource;

            // Act
            component.ngOnDestroy();

            // Assert
            expect(mockEventSource.close).toHaveBeenCalled();
        });

        it('should not throw error if eventSource does not exist', () => {
            // Arrange
            (component as any).eventSource = undefined;

            // Act & Assert
            expect(() => component.ngOnDestroy()).not.toThrow();
        });
    });

    describe('scrolling', () => {
        it('should add hide class to scroller when at bottom and not streaming', () => {
            // Arrange
            const mockMessages = { scrollTop: 900, clientHeight: 100, scrollHeight: 1000 };
            const mockScroller = { classList: { add: jest.fn(), remove: jest.fn() } };
            component.messageareaContainer = { nativeElement: mockMessages } as any;
            component.scrollerContainer = { nativeElement: mockScroller } as any;
            component.isStreaming = false;

            // Act
            component.scrolling({});

            // Assert
            expect(mockScroller.classList.add).toHaveBeenCalledWith('hide');
        });

        it('should remove hide class from scroller when not at bottom and not streaming', () => {
            // Arrange
            const mockMessages = { scrollTop: 500, clientHeight: 100, scrollHeight: 1000 };
            const mockScroller = { classList: { add: jest.fn(), remove: jest.fn() } };
            component.messageareaContainer = { nativeElement: mockMessages } as any;
            component.scrollerContainer = { nativeElement: mockScroller } as any;
            component.isStreaming = false;

            // Act
            component.scrolling({});

            // Assert
            expect(mockScroller.classList.remove).toHaveBeenCalledWith('hide');
        });

        it('should not modify scroller classes when streaming', () => {
            // Arrange
            const mockMessages = { scrollTop: 500, clientHeight: 100, scrollHeight: 1000 };
            const mockScroller = { classList: { add: jest.fn(), remove: jest.fn() } };
            component.messageareaContainer = { nativeElement: mockMessages } as any;
            component.scrollerContainer = { nativeElement: mockScroller } as any;
            component.isStreaming = true;

            // Act
            component.scrolling({});

            // Assert
            expect(mockScroller.classList.add).not.toHaveBeenCalled();
            expect(mockScroller.classList.remove).not.toHaveBeenCalled();
        });
    });

    describe('scrollToBottom', () => {
        it('should scroll messages to bottom and update scrollPosition', () => {
            // Arrange
            const mockScrollTo = jest.fn();
            const mockMessages = { scrollHeight: 1500, scrollTo: mockScrollTo };
            component.messageareaContainer = { nativeElement: mockMessages } as any;

            // Act
            component.scrollToBottom();

            // Assert
            expect((component as any).scrollPosition).toBe(1500);
            expect(mockScrollTo).toHaveBeenCalledWith({
                top: 1500,
                behavior: 'smooth'
            });
        });

        it('should do nothing when messages element is null/undefined', () => {
            // Arrange
            const mockMessages = null;
            component.messageareaContainer = { nativeElement: mockMessages } as any;

            // Act & Assert
            expect(() => component.scrollToBottom()).not.toThrow();
        });
    });

    describe('autoResize', () => {
        it('should resize textarea based on content and show send button', () => {
            // Arrange
            const mockTextarea = {
                style: { height: '', overflowY: '' },
                scrollHeight: 50,
                value: 'Some text'
            };
            const mockSend = { classList: { add: jest.fn(), remove: jest.fn() } };
            component.sendContainer = { nativeElement: mockSend } as any;

            // Act
            component.autoResize(mockTextarea as any);

            // Assert
            expect(mockTextarea.style.height).toBe('50px');
            expect(mockTextarea.style.overflowY).toBe('hidden');
            expect(mockSend.classList.remove).toHaveBeenCalledWith('hide');
        });

        it('should limit textarea height to max and add scrollbar', () => {
            // Arrange
            const mockTextarea = {
                style: { height: '', overflowY: '' },
                scrollHeight: 100,
                value: 'Long text'
            };
            const mockSend = { classList: { add: jest.fn(), remove: jest.fn() } };
            component.sendContainer = { nativeElement: mockSend } as any;

            // Act
            component.autoResize(mockTextarea as any);

            // Assert
            expect(mockTextarea.style.height).toBe('75px'); // 3 lines * 25px
            expect(mockTextarea.style.overflowY).toBe('auto');
        });

        it('should hide send button when textarea is empty', () => {
            // Arrange
            const mockTextarea = {
                style: { height: '', overflowY: '' },
                scrollHeight: 25,
                value: '   '
            };
            const mockSend = { classList: { add: jest.fn(), remove: jest.fn() } };
            component.sendContainer = { nativeElement: mockSend } as any;

            // Act
            component.autoResize(mockTextarea as any);

            // Assert
            expect(mockSend.classList.add).toHaveBeenCalledWith('hide');
        });

        it('should do nothing with send button when sendContainer element is null', () => {
            // Arrange
            const mockTextarea = {
                style: { height: '', overflowY: '' },
                scrollHeight: 50,
                value: 'Some text'
            };
            component.sendContainer = { nativeElement: null } as any;

            // Act & Assert
            expect(() => component.autoResize(mockTextarea as any)).not.toThrow();
            expect(mockTextarea.style.height).toBe('50px');
        });
    });

    describe('onEnter', () => {
        it('should return early when shift key is pressed', () => {
            // Arrange
            const mockEvent = { shiftKey: true, preventDefault: jest.fn() } as any;
            const mockTextarea = { value: 'test message' } as any;
            jest.spyOn(component as any, 'sendMessage');

            // Act
            component.onEnter(mockEvent, mockTextarea);

            // Assert
            expect(mockEvent.preventDefault).not.toHaveBeenCalled();
            expect((component as any).sendMessage).not.toHaveBeenCalled();
        });

        it('should send message and clear textarea when enter is pressed', () => {
            // Arrange
            const mockEvent = { shiftKey: false, preventDefault: jest.fn() } as any;
            const mockTextarea = { 
                value: 'test message',
                style: { height: '', overflowY: '' },
                scrollHeight: 25
            } as any;
            const mockSend = { classList: { add: jest.fn(), remove: jest.fn() } };
            component.sendContainer = { nativeElement: mockSend } as any;
            jest.spyOn(component as any, 'sendMessage').mockImplementation(() => {});

            // Act
            component.onEnter(mockEvent, mockTextarea);

            // Assert
            expect(mockEvent.preventDefault).toHaveBeenCalled();
            expect((component as any).sendMessage).toHaveBeenCalledWith('test message');
            expect(mockTextarea.value).toBe('');
        });
    });

    describe('cancelStream', () => {
        it('should close eventSource and update last message', (done) => {
            // Arrange
            const mockEventSource = { close: jest.fn() };
            const mockTextarea = { focus: jest.fn() };
            (component as any).eventSource = mockEventSource;
            component.textareaContainer = { nativeElement: mockTextarea } as any;
            component.messages = [
                { type: 'user', text: 'Hello' },
                { type: 'system', text: 'Response in progress' }
            ];
            component.isStreaming = true;

            // Act
            component.cancelStream();

            // Assert
            expect(mockEventSource.close).toHaveBeenCalled();
            expect((component as any).eventSource).toBeUndefined();
            expect(component.messages[1].text).toContain('[Request cancelled by user]');
            expect(component.isStreaming).toBe(false);

            setTimeout(() => {
                expect(mockTextarea.focus).toHaveBeenCalled();
                done();
            }, 150);
        });

        it('should handle missing textareaContainer gracefully', (done) => {
            // Arrange
            const mockEventSource = { close: jest.fn() };
            (component as any).eventSource = mockEventSource;
            component.textareaContainer = undefined as any;
            component.messages = [{ type: 'system', text: 'Response' }];

            // Act
            component.cancelStream();

            // Assert
            setTimeout(() => {
                expect(() => component.cancelStream()).not.toThrow();
                done();
            }, 150);
        });
    });

    describe('isAtBottom (private method)', () => {
        it('should return true when at bottom within threshold', () => {
            // Arrange
            const mockElement = {
                scrollTop: 890,
                clientHeight: 100,
                scrollHeight: 1000
            } as HTMLElement;

            // Act
            const result = (component as any).isAtBottom(mockElement);

            // Assert
            expect(result).toBe(true);
        });

        it('should return false when not at bottom', () => {
            // Arrange
            const mockElement = {
                scrollTop: 500,
                clientHeight: 100,
                scrollHeight: 1000
            } as HTMLElement;

            // Act
            const result = (component as any).isAtBottom(mockElement);

            // Assert
            expect(result).toBe(false);
        });
    });

    describe('sendMessage (private method)', () => {
        beforeEach(() => {
            jest.useFakeTimers();
        });

        afterEach(() => {
            jest.useRealTimers();
        });

        it('should return early when message is empty', () => {
            // Act
            (component as any).sendMessage('   ');

            // Assert
            expect(mockChatStreamService.startChat).not.toHaveBeenCalled();
            expect(component.messages).toHaveLength(0);
        });

        it('should add user and system messages and start chat', () => {
            // Arrange
            const jobId = { jobId: 'test-job-123' };
            mockChatStreamService.startChat.mockReturnValue(of(jobId));
            
            const mockEventSource = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };
            mockChatStreamService.chatStream.mockReturnValue(mockEventSource);

            // Act
            (component as any).sendMessage('Hello AI');

            // Assert
            expect(component.messages).toHaveLength(2);
            expect(component.messages[0]).toEqual({ type: 'user', text: 'Hello AI' });
            expect(component.messages[1]).toEqual({ type: 'system', text: '...' });
            expect(component.isStreaming).toBe(true);
            expect(mockChatStreamService.startChat).toHaveBeenCalled();
        });

        it('should handle chat stream messages and update display', () => {
            // Arrange
            const jobId = { jobId: 'test-job-123' };
            mockChatStreamService.startChat.mockReturnValue(of(jobId));
            
            const mockEventSource: any = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };
            mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
            jest.spyOn(component, 'scrollToBottom').mockImplementation();

            // Act
            (component as any).sendMessage('Hello');

            // Wait for onmessage to be assigned, then simulate SSE message
            setTimeout(() => {
                const messageEvent = { data: 'Response chunk' } as MessageEvent;
                mockEventSource.onmessage(messageEvent);

                // Assert
                expect(mockMarkdownService.render).toHaveBeenCalled();
                expect(component.messages[1].text).toContain('Response chunk');
                expect(component.scrollToBottom).toHaveBeenCalled();
            }, 10);
        });

        it('should handle empty SSE data', () => {
            // Arrange
            const jobId = { jobId: 'test-job-123' };
            mockChatStreamService.startChat.mockReturnValue(of(jobId));
            
            const mockEventSource: any = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };
            mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
            component.messages = [
                { type: 'user', text: 'Hello' },
                { type: 'system', text: '...' }
            ];

            // Act
            (component as any).sendMessage('Hello');
            
            // Wait for onmessage to be assigned
            setTimeout(() => {
                const messageEvent = { data: '' } as MessageEvent;
                mockEventSource.onmessage(messageEvent);

                // Assert
                expect(component.messages[1].text).toBe('...');
            }, 10);
        });

        it('should handle chat service error', () => {
            // Arrange
            const error = new Error('Chat service failed');
            mockChatStreamService.startChat.mockReturnValue(throwError(() => error));
            
            const mockTextarea = { focus: jest.fn() };
            component.textareaContainer = { nativeElement: mockTextarea } as any;
            const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
            component.messages = [];

            // Act
            (component as any).sendMessage('Hello');

            // Assert
            expect(consoleErrorSpy).toHaveBeenCalledWith('Chat failed:', error);
            expect(component.messages[1].text).toContain(error.toString());
            expect(component.isStreaming).toBe(false);
            
            consoleErrorSpy.mockRestore();
        });

        it('should include message history in chat request', () => {
            // Arrange
            const jobId = { jobId: 'test-job-123' };
            mockChatStreamService.startChat.mockReturnValue(of(jobId));
            
            const mockEventSource = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };
            mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
            
            component.messages = [
                { type: 'user', text: 'First message' },
                { type: 'system', text: 'First response' },
                { type: 'user', text: 'Second message' },
                { type: 'system', text: 'Second response' }
            ];

            // Act
            (component as any).sendMessage('Third message');

            // Assert
            expect(mockChatStreamService.startChat).toHaveBeenCalledWith({
                prompt: 'Third message',
                history: [
                    { role: 'user', content: 'First message' },
                    { role: 'assistant', content: 'First response' },
                    { role: 'user', content: 'Second message' },
                    { role: 'assistant', content: 'Second response' }
                ]
            });
        });
    });

    describe('normalizeTables (private method)', () => {
        it('should normalize table syntax with || to separate lines', () => {
            // Arrange
            const markdown = 'Header 1 || Header 2 || Header 3';

            // Act
            const result = (component as any).normalizeTables(markdown);

            // Assert
            // The regex replaces "|| " (with space) or "||" with "|\n|"
            expect(result).toBe('Header 1 |\n|Header 2 |\n|Header 3');
        });

        it('should handle markdown without tables', () => {
            // Arrange
            const markdown = 'Regular text without tables';

            // Act
            const result = (component as any).normalizeTables(markdown);

            // Assert
            expect(result).toBe('Regular text without tables');
        });
    });

    describe('wrapTables (private method)', () => {
        it('should wrap table tags in scroll wrapper div', () => {
            // Arrange
            const html = '<p>Text</p><table><tr><td>Cell</td></tr></table><p>More text</p>';

            // Act
            const result = (component as any).wrapTables(html);

            // Assert
            expect(result).toContain('<div class="table-scroll-wrapper">');
            expect(result).toContain('</div>');
            expect(result).toContain('<table>');
        });

        it('should handle HTML without tables', () => {
            // Arrange
            const html = '<p>Text without tables</p>';

            // Act
            const result = (component as any).wrapTables(html);

            // Assert
            expect(result).toBe('<p>Text without tables</p>');
        });

        it('should wrap multiple tables', () => {
            // Arrange
            const html = '<table>Table 1</table><p>Text</p><table>Table 2</table>';

            // Act
            const result = (component as any).wrapTables(html);

            // Assert
            const wrapperCount = (result.match(/<div class="table-scroll-wrapper">/g) || []).length;
            expect(wrapperCount).toBe(2);
        });
    });
});
