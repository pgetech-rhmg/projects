import { TestBed } from '@angular/core/testing';
import { ChatStreamService } from '~/services/chat.service';
import { HttpService } from '~/core/services/http.service';
import { Observable, of, throwError } from 'rxjs';

describe('ChatStreamService', () => {
    let service: ChatStreamService;
    let mockHttpService: jest.Mocked<HttpService>;
    let mockEventSource: jest.Mocked<EventSource>;

    beforeEach(() => {
        // Create mock EventSource
        mockEventSource = {
            close: jest.fn(),
            addEventListener: jest.fn(),
            removeEventListener: jest.fn(),
            dispatchEvent: jest.fn(),
            onopen: null,
            onmessage: null,
            onerror: null,
            readyState: 0,
            url: '',
            withCredentials: false,
            CONNECTING: 0,
            OPEN: 1,
            CLOSED: 2
        } as any;

        // Create mock HttpService
        mockHttpService = {
            Post: jest.fn(),
            SSE: jest.fn().mockReturnValue(mockEventSource)
        } as any;

        // Configure TestBed
        TestBed.configureTestingModule({
            providers: [
                ChatStreamService,
                { provide: HttpService, useValue: mockHttpService }
            ]
        });

        service = TestBed.inject(ChatStreamService);

        // Spy on console.log
        jest.spyOn(console, 'log').mockImplementation();
    });

    afterEach(() => {
        jest.clearAllMocks();
        jest.restoreAllMocks();
    });

    describe('Service Initialization', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });

        it('should inject HttpService', () => {
            expect(service['httpService']).toBe(mockHttpService);
        });

        it('should initialize without activeJob', () => {
            expect(service['activeJob']).toBeUndefined();
        });
    });

    describe('startChat', () => {
        it('should call httpService.Post with correct endpoint and request', () => {
            const mockRequest = { message: 'Hello', userId: 'user-123' };
            const mockResponse = { jobId: 'job-123' };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.startChat(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledTimes(1);
            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/chat/start',
                mockRequest
            );
        });

        it('should return Observable from httpService.Post', () => {
            const mockRequest = { message: 'test' };
            mockHttpService.Post.mockReturnValue(of({ jobId: 'job-456' }));

            const result = service.startChat(mockRequest);

            expect(result).toBeInstanceOf(Observable);
        });

        it('should emit jobId when HTTP call succeeds', (done) => {
            const mockRequest = { message: 'Test message', context: 'chat' };
            const mockResponse = { jobId: 'job-789' };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.startChat(mockRequest).subscribe({
                next: (response: any) => {
                    expect(response).toEqual(mockResponse);
                    expect(response.jobId).toBe('job-789');
                    done();
                }
            });
        });

        it('should log the request to console', () => {
            const mockRequest = { message: 'Test', metadata: { key: 'value' } };
            mockHttpService.Post.mockReturnValue(of({ jobId: 'job-111' }));

            service.startChat(mockRequest);

            expect(console.log).toHaveBeenCalledWith(mockRequest);
            expect(console.log).toHaveBeenCalledTimes(1);
        });

        it('should handle empty request object', () => {
            const mockRequest = {};
            mockHttpService.Post.mockReturnValue(of({ jobId: 'job-222' }));

            service.startChat(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/chat/start',
                {}
            );
            expect(console.log).toHaveBeenCalledWith({});
        });

        it('should handle null request', () => {
            const mockRequest = null;
            mockHttpService.Post.mockReturnValue(of({ jobId: 'job-333' }));

            service.startChat(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/chat/start',
                null
            );
            expect(console.log).toHaveBeenCalledWith(null);
        });

        it('should handle undefined request', () => {
            const mockRequest = undefined;
            mockHttpService.Post.mockReturnValue(of({ jobId: 'job-444' }));

            service.startChat(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/chat/start',
                undefined
            );
            expect(console.log).toHaveBeenCalledWith(undefined);
        });

        it('should handle complex nested request', () => {
            const mockRequest = {
                message: 'Complex message',
                context: {
                    conversation: ['msg1', 'msg2'],
                    user: { id: 'user-1', name: 'Test' }
                }
            };
            mockHttpService.Post.mockReturnValue(of({ jobId: 'job-555' }));

            service.startChat(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/chat/start',
                mockRequest
            );
            expect(console.log).toHaveBeenCalledWith(mockRequest);
        });

        it('should propagate HTTP errors', (done) => {
            const mockRequest = { message: 'test' };
            const mockError = new Error('Network error');
            mockHttpService.Post.mockReturnValue(throwError(() => mockError));

            service.startChat(mockRequest).subscribe({
                error: (error: any) => {
                    expect(error).toBe(mockError);
                    done();
                }
            });
        });

        it('should always use the same endpoint', () => {
            const requests = [
                { message: 'msg1' },
                { message: 'msg2' },
                { message: 'msg3' }
            ];
            mockHttpService.Post.mockReturnValue(of({ jobId: 'job-test' }));

            requests.forEach((request: any) => {
                service.startChat(request);
            });

            expect(mockHttpService.Post).toHaveBeenCalledTimes(3);
            mockHttpService.Post.mock.calls.forEach((call: any) => {
                expect(call[0]).toBe('api/chat/start');
            });
        });
    });

    describe('chatStream', () => {
        it('should call httpService.SSE with correct endpoint', () => {
            const jobId = 'job-stream-123';

            service.chatStream(jobId);

            expect(mockHttpService.SSE).toHaveBeenCalledTimes(1);
            expect(mockHttpService.SSE).toHaveBeenCalledWith('api/chat/stream/job-stream-123');
        });

        it('should return EventSource from httpService.SSE', () => {
            const jobId = 'job-stream-456';

            const result = service.chatStream(jobId);

            expect(result).toBe(mockEventSource);
        });

        it('should handle different jobId formats', () => {
            const jobIds = ['job-123', 'abc-def-ghi', 'job_underscore', '12345'];

            jobIds.forEach((jobId: string) => {
                mockHttpService.SSE.mockClear();
                
                service.chatStream(jobId);

                expect(mockHttpService.SSE).toHaveBeenCalledWith(`api/chat/stream/${jobId}`);
            });
        });

        it('should handle empty string jobId', () => {
            const jobId = '';

            service.chatStream(jobId);

            expect(mockHttpService.SSE).toHaveBeenCalledWith('api/chat/stream/');
        });

        it('should create new EventSource for each call', () => {
            const jobId1 = 'job-1';
            const jobId2 = 'job-2';

            service.chatStream(jobId1);
            service.chatStream(jobId2);

            expect(mockHttpService.SSE).toHaveBeenCalledTimes(2);
            expect(mockHttpService.SSE).toHaveBeenNthCalledWith(1, 'api/chat/stream/job-1');
            expect(mockHttpService.SSE).toHaveBeenNthCalledWith(2, 'api/chat/stream/job-2');
        });

        it('should return EventSource with expected properties', () => {
            const jobId = 'job-test';

            const result = service.chatStream(jobId);

            expect(result).toHaveProperty('close');
            expect(result).toHaveProperty('addEventListener');
            expect(result).toHaveProperty('removeEventListener');
            expect(result.readyState).toBeDefined();
        });
    });

    describe('setActiveJob', () => {
        it('should set activeJob property', () => {
            const jobId = 'job-active-123';

            service.setActiveJob(jobId);

            expect(service['activeJob']).toBe(jobId);
        });

        it('should overwrite previous activeJob', () => {
            service.setActiveJob('job-1');
            expect(service['activeJob']).toBe('job-1');

            service.setActiveJob('job-2');
            expect(service['activeJob']).toBe('job-2');
        });

        it('should accept empty string', () => {
            service.setActiveJob('');

            expect(service['activeJob']).toBe('');
        });

        it('should not call any HTTP methods', () => {
            service.setActiveJob('job-no-http');

            expect(mockHttpService.Post).not.toHaveBeenCalled();
            expect(mockHttpService.SSE).not.toHaveBeenCalled();
        });
    });

    describe('cancel', () => {
        it('should return Observable of undefined when no activeJob is set', (done) => {
            service.cancel().subscribe({
                next: (result: any) => {
                    expect(result).toBeUndefined();
                    expect(mockHttpService.Post).not.toHaveBeenCalled();
                    done();
                }
            });
        });

        it('should not call httpService.Post when activeJob is undefined', (done) => {
            service.cancel().subscribe({
                next: (result: any) => {
                    expect(mockHttpService.Post).not.toHaveBeenCalled();
                    done();
                }
            });
        });

        it('should call httpService.Post when activeJob is set', () => {
            const jobId = 'job-to-cancel';
            service.setActiveJob(jobId);
            mockHttpService.Post.mockReturnValue(of(undefined));

            service.cancel();

            expect(mockHttpService.Post).toHaveBeenCalledTimes(1);
            expect(mockHttpService.Post).toHaveBeenCalledWith(
                `api/cfn/cancel/${jobId}`,
                {}
            );
        });

        it('should use correct endpoint with activeJob', () => {
            service.setActiveJob('job-cancel-123');
            mockHttpService.Post.mockReturnValue(of(undefined));

            service.cancel();

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/cfn/cancel/job-cancel-123',
                {}
            );
        });

        it('should emit undefined when cancel succeeds', (done) => {
            service.setActiveJob('job-success-cancel');
            mockHttpService.Post.mockReturnValue(of(undefined));

            service.cancel().subscribe({
                next: (result: any) => {
                    expect(result).toBeUndefined();
                    done();
                }
            });
        });

        it('should handle HTTP errors during cancel', (done) => {
            service.setActiveJob('job-error-cancel');
            const mockError = new Error('Cancel failed');
            mockHttpService.Post.mockReturnValue(throwError(() => mockError));

            service.cancel().subscribe({
                error: (error: any) => {
                    expect(error).toBe(mockError);
                    done();
                }
            });
        });

        it('should pass empty object as request body', () => {
            service.setActiveJob('job-empty-body');
            mockHttpService.Post.mockReturnValue(of(undefined));

            service.cancel();

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                expect.any(String),
                {}
            );
        });

        it('should work with different activeJob values', () => {
            const jobIds = ['job-1', 'job-abc-def', 'job_underscore'];

            jobIds.forEach((jobId: string) => {
                mockHttpService.Post.mockClear();
                service.setActiveJob(jobId);
                mockHttpService.Post.mockReturnValue(of(undefined));

                service.cancel();

                expect(mockHttpService.Post).toHaveBeenCalledWith(
                    `api/cfn/cancel/${jobId}`,
                    {}
                );
            });
        });

        it('should return Observable<void> type', () => {
            service.setActiveJob('job-void-type');
            mockHttpService.Post.mockReturnValue(of(undefined));

            const result = service.cancel();

            expect(result).toBeInstanceOf(Observable);
        });

        it('should handle empty string activeJob as falsy and return early', (done) => {
            service.setActiveJob('');

            service.cancel().subscribe({
                next: (result: any) => {
                    expect(result).toBeUndefined();
                    expect(mockHttpService.Post).not.toHaveBeenCalled();
                    done();
                }
            });
        });
    });

    describe('Integration', () => {
        it('should support typical workflow: startChat -> setActive -> stream -> cancel', (done) => {
            const mockRequest = { message: 'test' };
            const mockResponse = { jobId: 'job-workflow' };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.startChat(mockRequest).subscribe({
                next: (response: any) => {
                    expect(response.jobId).toBe('job-workflow');

                    service.setActiveJob(response.jobId);
                    expect(service['activeJob']).toBe('job-workflow');

                    const eventSource = service.chatStream(response.jobId);
                    expect(eventSource).toBe(mockEventSource);

                    mockHttpService.Post.mockReturnValue(of(undefined));
                    service.cancel().subscribe({
                        next: (cancelResult: any) => {
                            expect(cancelResult).toBeUndefined();
                            done();
                        }
                    });
                }
            });
        });

        it('should handle multiple concurrent chat sessions', () => {
            const job1 = 'job-1';
            const job2 = 'job-2';

            mockHttpService.Post.mockReturnValue(of({ jobId: job1 }));
            service.startChat({ message: 'msg1' });

            mockHttpService.Post.mockReturnValue(of({ jobId: job2 }));
            service.startChat({ message: 'msg2' });

            service.chatStream(job1);
            service.chatStream(job2);

            expect(mockHttpService.SSE).toHaveBeenCalledTimes(2);
            expect(mockHttpService.SSE).toHaveBeenCalledWith(`api/chat/stream/${job1}`);
            expect(mockHttpService.SSE).toHaveBeenCalledWith(`api/chat/stream/${job2}`);
        });
    });
});
