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
	let mockChatStreamService: any;
	let mockMarkdownService: any;

	beforeEach(async () => {
		mockRouter = {
			navigate: jest.fn().mockResolvedValue(true),
			url: '/home'
		};

		mockChatStreamService = {
			startChat: jest.fn(),
			setActiveJob: jest.fn(),
			chatStream: jest.fn()
		};

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
	});

	//*************************************************************************
	//  Constructor
	//*************************************************************************
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

	//*************************************************************************
	//  ngOnInit
	//*************************************************************************
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

	//*************************************************************************
	//  ngOnDestroy
	//*************************************************************************
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

	//*************************************************************************
	//  scrolling
	//*************************************************************************
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

	//*************************************************************************
	//  scrollToBottom
	//*************************************************************************
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
			component.messageareaContainer = { nativeElement: null } as any;

			// Act & Assert
			expect(() => component.scrollToBottom()).not.toThrow();
		});
	});

	//*************************************************************************
	//  autoResize
	//*************************************************************************
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
			expect(mockTextarea.style.height).toBe('75px');
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

		it('should not throw when sendContainer nativeElement is null', () => {
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

	//*************************************************************************
	//  onEnter
	//*************************************************************************
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

	//*************************************************************************
	//  cancelStream
	//*************************************************************************
	describe('cancelStream', () => {
		beforeEach(() => {
			jest.useFakeTimers();
		});

		afterEach(() => {
			jest.useRealTimers();
		});

		it('should close eventSource, update last message, and focus textarea', () => {
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

			// Advance timer for focus
			jest.advanceTimersByTime(150);
			expect(mockTextarea.focus).toHaveBeenCalled();
		});

		it('should handle missing textareaContainer gracefully after cancel', () => {
			// Arrange
			const mockEventSource = { close: jest.fn() };
			(component as any).eventSource = mockEventSource;
			component.textareaContainer = undefined as any;
			component.messages = [{ type: 'system', text: 'Response' }];

			// Act
			component.cancelStream();

			// Assert -- setTimeout fires but textareaContainer is undefined, no crash
			jest.advanceTimersByTime(150);
			expect(mockEventSource.close).toHaveBeenCalled();
		});
	});

	//*************************************************************************
	//  isAtBottom (private)
	//*************************************************************************
	describe('isAtBottom (private method)', () => {
		it('should return true when at bottom within threshold', () => {
			const mockElement = { scrollTop: 890, clientHeight: 100, scrollHeight: 1000 } as HTMLElement;
			expect((component as any).isAtBottom(mockElement)).toBe(true);
		});

		it('should return true when exactly at bottom', () => {
			const mockElement = { scrollTop: 900, clientHeight: 100, scrollHeight: 1000 } as HTMLElement;
			expect((component as any).isAtBottom(mockElement)).toBe(true);
		});

		it('should return false when not at bottom', () => {
			const mockElement = { scrollTop: 500, clientHeight: 100, scrollHeight: 1000 } as HTMLElement;
			expect((component as any).isAtBottom(mockElement)).toBe(false);
		});
	});

	//*************************************************************************
	//  sendMessage (private) -- full SSE lifecycle
	//*************************************************************************
	describe('sendMessage (private method)', () => {
		let mockEventSource: any;

		beforeEach(() => {
			jest.useFakeTimers();

			mockEventSource = {
				onmessage: null as any,
				onerror: null as any,
				addEventListener: jest.fn(),
				close: jest.fn()
			};
		});

		afterEach(() => {
			jest.useRealTimers();
		});

		it('should return early when message is empty or whitespace', () => {
			(component as any).sendMessage('   ');

			expect(mockChatStreamService.startChat).not.toHaveBeenCalled();
			expect(component.messages).toHaveLength(0);
		});

		it('should add user and system messages, set streaming, and call startChat', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);

			// Act
			(component as any).sendMessage('Hello AI');

			// Assert
			expect(component.messages).toHaveLength(2);
			expect(component.messages[0]).toEqual({ type: 'user', text: 'Hello AI' });
			expect(component.messages[1]).toEqual({ type: 'system', text: '...' });
			expect(component.isStreaming).toBe(true);
			expect(mockChatStreamService.startChat).toHaveBeenCalledWith({
				prompt: 'Hello AI',
				history: []
			});
			expect(mockChatStreamService.setActiveJob).toHaveBeenCalledWith(jobId);
			expect(mockChatStreamService.chatStream).toHaveBeenCalledWith('job-1');
		});

		it('should call scrollToBottom via setTimeout after sendMessage', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
			jest.spyOn(component, 'scrollToBottom').mockImplementation();
			component.messageareaContainer = { nativeElement: { scrollHeight: 500, scrollTo: jest.fn() } } as any;

			// Act
			(component as any).sendMessage('Hello');
			jest.advanceTimersByTime(150);

			// Assert
			expect(component.scrollToBottom).toHaveBeenCalled();
		});

		it('should handle SSE onmessage events and render markdown', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
			jest.spyOn(component, 'scrollToBottom').mockImplementation();

			// Act
			(component as any).sendMessage('Hello');

			// Simulate SSE message
			mockEventSource.onmessage({ data: 'Response chunk' } as MessageEvent);

			// Assert
			expect(mockMarkdownService.render).toHaveBeenCalled();
			expect(component.scrollToBottom).toHaveBeenCalled();
		});

		it('should skip processing when SSE event data is empty', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);

			// Act
			(component as any).sendMessage('Hello');
			mockMarkdownService.render.mockClear();

			// Simulate empty SSE message
			mockEventSource.onmessage({ data: '' } as MessageEvent);

			// Assert -- render should not have been called for empty data
			expect(mockMarkdownService.render).not.toHaveBeenCalled();
		});

		it('should accumulate multiple SSE messages into buffer', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
			jest.spyOn(component, 'scrollToBottom').mockImplementation();

			// Act
			(component as any).sendMessage('Hello');
			mockEventSource.onmessage({ data: 'First ' } as MessageEvent);
			mockEventSource.onmessage({ data: 'Second' } as MessageEvent);

			// Assert -- render called with accumulated content
			expect(mockMarkdownService.render).toHaveBeenCalledTimes(2);
			const lastCallArg = mockMarkdownService.render.mock.calls[1][0];
			expect(lastCallArg).toContain('First ');
			expect(lastCallArg).toContain('Second');
		});

		it('should handle SSE complete event: update links, stop streaming, focus textarea', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
			const mockTextarea = { focus: jest.fn() };
			component.textareaContainer = { nativeElement: mockTextarea } as any;
			jest.spyOn(component, 'scrollToBottom').mockImplementation();

			// Act
			(component as any).sendMessage('Hello');

			// Simulate a message first so last message has rendered content
			mockEventSource.onmessage({ data: 'Check <a href="test">link</a>' } as MessageEvent);

			// Capture and invoke the 'complete' event listener
			const completeCallback = mockEventSource.addEventListener.mock.calls.find(
				(call: any[]) => call[0] === 'complete'
			)[1];
			completeCallback();

			// Assert
			expect(component.isStreaming).toBe(false);
			expect(mockEventSource.close).toHaveBeenCalled();
			expect(component.messages.at(-1)!.text).toContain('target="_blank"');

			// Focus happens via setTimeout
			jest.advanceTimersByTime(150);
			expect(mockTextarea.focus).toHaveBeenCalled();
		});

		it('should handle SSE complete when textareaContainer is undefined', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
			component.textareaContainer = undefined as any;
			jest.spyOn(component, 'scrollToBottom').mockImplementation();

			// Act
			(component as any).sendMessage('Hello');

			const completeCallback = mockEventSource.addEventListener.mock.calls.find(
				(call: any[]) => call[0] === 'complete'
			)[1];

			// Assert -- should not throw
			expect(() => {
				completeCallback();
				jest.advanceTimersByTime(150);
			}).not.toThrow();
		});

		it('should handle SSE onerror: log error, update message, stop streaming, focus', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
			const mockTextarea = { focus: jest.fn() };
			component.textareaContainer = { nativeElement: mockTextarea } as any;
			jest.spyOn(component, 'scrollToBottom').mockImplementation();
			const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

			// Act
			(component as any).sendMessage('Hello');

			const sseError = { type: 'error' };
			mockEventSource.onerror(sseError);

			// Assert
			expect(consoleErrorSpy).toHaveBeenCalledWith('SSE error', sseError);
			expect(component.isStreaming).toBe(false);
			expect(mockEventSource.close).toHaveBeenCalled();
			expect(component.messages.at(-1)!.text).toContain(sseError.toString());

			jest.advanceTimersByTime(150);
			expect(mockTextarea.focus).toHaveBeenCalled();

			consoleErrorSpy.mockRestore();
		});

		it('should handle SSE onerror when textareaContainer is undefined', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
			component.textareaContainer = undefined as any;
			jest.spyOn(component, 'scrollToBottom').mockImplementation();
			const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

			// Act
			(component as any).sendMessage('Hello');
			mockEventSource.onerror({ type: 'error' });

			// Assert -- no crash on setTimeout
			expect(() => jest.advanceTimersByTime(150)).not.toThrow();

			consoleErrorSpy.mockRestore();
		});

		// it('should handle chat service subscription error', () => {
		// 	// Arrange
		// 	const error = new Error('Chat service failed');
		// 	mockChatStreamService.startChat.mockReturnValue(throwError(() => error));
		// 	const mockTextarea = { focus: jest.fn() };
		// 	component.textareaContainer = { nativeElement: mockTextarea } as any;
		// 	const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

		// 	// Act
		// 	(component as any).sendMessage('Hello');

		// 	// Assert
		// 	expect(consoleErrorSpy).toHaveBeenCalledWith('Chat failed:', error);
		// 	expect(component.messages.at(-1)!.text).toContain(error.toString());
		// 	expect(component.isStreaming).toBe(false);

		// 	jest.advanceTimersByTime(150);
		// 	expect(mockTextarea.focus).toHaveBeenCalled();

		// 	consoleErrorSpy.mockRestore();
		// });

		// it('should handle chat service error when textareaContainer is undefined', () => {
		// 	// Arrange
		// 	const error = new Error('Chat service failed');
		// 	mockChatStreamService.startChat.mockReturnValue(throwError(() => error));
		// 	component.textareaContainer = undefined as any;
		// 	const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

		// 	// Act
		// 	(component as any).sendMessage('Hello');

		// 	// Assert -- no crash on setTimeout
		// 	expect(() => jest.advanceTimersByTime(150)).not.toThrow();

		// 	consoleErrorSpy.mockRestore();
		// });

		it('should include message history and map system role to assistant', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
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

		it('should limit history to MAX_HISTORY (20) messages', () => {
			// Arrange
			const jobId = { jobId: 'job-1' };
			mockChatStreamService.startChat.mockReturnValue(of(jobId));
			mockChatStreamService.chatStream.mockReturnValue(mockEventSource);

			// Build 30 messages (exceeds MAX_HISTORY of 20)
			component.messages = [];
			for (let i = 0; i < 30; i++) {
				component.messages.push({
					type: i % 2 === 0 ? 'user' : 'system',
					text: `Message ${i}`
				});
			}

			// Act
			(component as any).sendMessage('New message');

			// Assert -- history should only contain last 20 messages (indices 10-29)
			const callArgs = mockChatStreamService.startChat.mock.calls[0][0];
			expect(callArgs.history).toHaveLength(20);
			expect(callArgs.history[0].content).toBe('Message 10');
			expect(callArgs.history[19].content).toBe('Message 29');
		});

		// it('should process table normalization and wrapping in SSE messages', () => {
		// 	// Arrange
		// 	const jobId = { jobId: 'job-1' };
		// 	mockChatStreamService.startChat.mockReturnValue(of(jobId));
		// 	mockChatStreamService.chatStream.mockReturnValue(mockEventSource);
		// 	jest.spyOn(component, 'scrollToBottom').mockImplementation();
		// 	jest.spyOn(component as any, 'normalizeTables').mockImplementation((s: string) => s);
		// 	jest.spyOn(component as any, 'wrapTables').mockImplementation((s: string) => s);

		// 	// Act
		// 	(component as any).sendMessage('Hello');
		// 	mockEventSource.onmessage({ data: '| Col1 || Col2 |' } as MessageEvent);

		// 	// Assert
		// 	expect((component as any).normalizeTables).toHaveBeenCalled();
		// 	expect((component as any).wrapTables).toHaveBeenCalled();
		// });
	});

	//*************************************************************************
	//  normalizeTables (private)
	//*************************************************************************
	describe('normalizeTables (private method)', () => {
		it('should normalize table syntax with || to separate lines', () => {
			const markdown = 'Header 1 || Header 2 || Header 3';
			const result = (component as any).normalizeTables(markdown);
			expect(result).toBe('Header 1 |\n|Header 2 |\n|Header 3');
		});

		it('should handle || without trailing space', () => {
			const markdown = 'A||B';
			const result = (component as any).normalizeTables(markdown);
			expect(result).toBe('A|\n|B');
		});

		it('should handle markdown without tables', () => {
			const markdown = 'Regular text without tables';
			const result = (component as any).normalizeTables(markdown);
			expect(result).toBe('Regular text without tables');
		});
	});

	//*************************************************************************
	//  wrapTables (private)
	//*************************************************************************
	describe('wrapTables (private method)', () => {
		it('should wrap table tags in scroll wrapper div', () => {
			const html = '<p>Text</p><table><tr><td>Cell</td></tr></table><p>More</p>';
			const result = (component as any).wrapTables(html);
			expect(result).toContain('<div class="table-scroll-wrapper">');
			expect(result).toContain('<table>');
			expect(result).toContain('</div>');
		});

		it('should handle HTML without tables', () => {
			const html = '<p>Text without tables</p>';
			const result = (component as any).wrapTables(html);
			expect(result).toBe('<p>Text without tables</p>');
		});

		it('should wrap multiple tables', () => {
			const html = '<table>Table 1</table><p>Text</p><table>Table 2</table>';
			const result = (component as any).wrapTables(html);
			const wrapperCount = (result.match(/<div class="table-scroll-wrapper">/g) || []).length;
			expect(wrapperCount).toBe(2);
		});
	});
});