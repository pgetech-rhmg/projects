import { TestBed } from '@angular/core/testing';
import { CfnService } from '~/services/cfn.service';
import { HttpService } from '~/core/services/http.service';
import { Observable, of, throwError } from 'rxjs';

describe('CfnService', () => {
  let service: CfnService;
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
        CfnService,
        { provide: HttpService, useValue: mockHttpService }
      ]
    });

    service = TestBed.inject(CfnService);
  });

  afterEach(() => {
    jest.clearAllMocks();
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

  describe('generate', () => {
    it('should call httpService.Post with correct endpoint and wrapped request', () => {
      const mockRequest = { template: 'vpc', region: 'us-east-1' };
      const mockResponse = { jobId: 'job-123' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.generate(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledTimes(1);
      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/generate',
        { Cfns: mockRequest }
      );
    });

    it('should wrap request in Cfns property', () => {
      const mockRequest = { stack: 'test-stack' };
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-456' }));

      service.generate(mockRequest);

      const callArgs = mockHttpService.Post.mock.calls[0];
      expect(callArgs[1]).toEqual({ Cfns: mockRequest });
      expect(callArgs[1]).toHaveProperty('Cfns');
    });

    it('should return Observable from httpService.Post', () => {
      const mockRequest = { template: 'test' };
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-789' }));

      const result = service.generate(mockRequest);

      expect(result).toBeInstanceOf(Observable);
    });

    it('should emit jobId when HTTP call succeeds', (done) => {
      const mockRequest = { template: 'ec2', params: { instanceType: 't2.micro' } };
      const mockResponse = { jobId: 'job-success-123' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.generate(mockRequest).subscribe({
        next: (response: any) => {
          expect(response).toEqual(mockResponse);
          expect(response.jobId).toBe('job-success-123');
          done();
        }
      });
    });

    it('should handle empty request object', () => {
      const mockRequest = {};
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-empty' }));

      service.generate(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/generate',
        { Cfns: {} }
      );
    });

    it('should handle null request', () => {
      const mockRequest = null;
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-null' }));

      service.generate(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/generate',
        { Cfns: null }
      );
    });

    it('should handle undefined request', () => {
      const mockRequest = undefined;
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-undefined' }));

      service.generate(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/generate',
        { Cfns: undefined }
      );
    });

    it('should handle array request', () => {
      const mockRequest = [{ template: 'vpc' }, { template: 's3' }];
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-array' }));

      service.generate(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/generate',
        { Cfns: mockRequest }
      );
    });

    it('should handle complex nested request', () => {
      const mockRequest = {
        templates: ['vpc', 's3', 'ec2'],
        config: {
          region: 'us-west-2',
          tags: { environment: 'production', team: 'infra' }
        }
      };
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-complex' }));

      service.generate(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/generate',
        { Cfns: mockRequest }
      );
    });

    it('should propagate HTTP errors', (done) => {
      const mockRequest = { template: 'test' };
      const mockError = new Error('Generation failed');
      mockHttpService.Post.mockReturnValue(throwError(() => mockError));

      service.generate(mockRequest).subscribe({
        error: (error: any) => {
          expect(error).toBe(mockError);
          done();
        }
      });
    });

    it('should always use the same endpoint', () => {
      const requests = [{ t1: 'a' }, { t2: 'b' }, { t3: 'c' }];
      mockHttpService.Post.mockReturnValue(of({ jobId: 'job-test' }));

      requests.forEach((request: any) => {
        service.generate(request);
      });

      expect(mockHttpService.Post).toHaveBeenCalledTimes(3);
      mockHttpService.Post.mock.calls.forEach((call: any) => {
        expect(call[0]).toBe('api/cfn/generate');
      });
    });
  });

  describe('generateStream', () => {
    it('should call httpService.SSE with correct endpoint', () => {
      const jobId = 'job-stream-123';

      service.generateStream(jobId);

      expect(mockHttpService.SSE).toHaveBeenCalledTimes(1);
      expect(mockHttpService.SSE).toHaveBeenCalledWith('api/cfn/generate-stream/job-stream-123');
    });

    it('should return EventSource from httpService.SSE', () => {
      const jobId = 'job-stream-456';

      const result = service.generateStream(jobId);

      expect(result).toBe(mockEventSource);
    });

    it('should handle different jobId formats', () => {
      const jobIds = ['job-123', 'abc-def-ghi', 'job_underscore', '12345'];

      jobIds.forEach((jobId: string) => {
        mockHttpService.SSE.mockClear();

        service.generateStream(jobId);

        expect(mockHttpService.SSE).toHaveBeenCalledWith(`api/cfn/generate-stream/${jobId}`);
      });
    });

    it('should handle empty string jobId', () => {
      const jobId = '';

      service.generateStream(jobId);

      expect(mockHttpService.SSE).toHaveBeenCalledWith('api/cfn/generate-stream/');
    });

    it('should create new EventSource for each call', () => {
      const jobId1 = 'job-1';
      const jobId2 = 'job-2';

      service.generateStream(jobId1);
      service.generateStream(jobId2);

      expect(mockHttpService.SSE).toHaveBeenCalledTimes(2);
      expect(mockHttpService.SSE).toHaveBeenNthCalledWith(1, 'api/cfn/generate-stream/job-1');
      expect(mockHttpService.SSE).toHaveBeenNthCalledWith(2, 'api/cfn/generate-stream/job-2');
    });
  });

  describe('createProject', () => {
    it('should call httpService.Post with correct endpoint and wrapped request', () => {
      const mockRequest = { projectName: 'my-project', resources: ['vpc', 's3'] };
      const mockResponse = { success: true, projectId: 'proj-123' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.createProject(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledTimes(1);
      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/create-project',
        { CfnResults: mockRequest }
      );
    });

    it('should wrap request in CfnResults property', () => {
      const mockRequest = { project: 'test' };
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      service.createProject(mockRequest);

      const callArgs = mockHttpService.Post.mock.calls[0];
      expect(callArgs[1]).toEqual({ CfnResults: mockRequest });
      expect(callArgs[1]).toHaveProperty('CfnResults');
    });

    it('should return Observable from httpService.Post', () => {
      const mockRequest = { project: 'test' };
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      const result = service.createProject(mockRequest);

      expect(result).toBeInstanceOf(Observable);
    });

    it('should emit response when HTTP call succeeds', (done) => {
      const mockRequest = { projectName: 'infra-project', stacks: ['vpc', 'rds'] };
      const mockResponse = { success: true, projectId: 'proj-456', url: 'https://example.com' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.createProject(mockRequest).subscribe({
        next: (response: any) => {
          expect(response).toEqual(mockResponse);
          expect(response.success).toBe(true);
          expect(response.projectId).toBe('proj-456');
          done();
        }
      });
    });

    it('should handle empty request object', () => {
      const mockRequest = {};
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      service.createProject(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/create-project',
        { CfnResults: {} }
      );
    });

    it('should handle null request', () => {
      const mockRequest = null;
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      service.createProject(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/create-project',
        { CfnResults: null }
      );
    });

    it('should handle undefined request', () => {
      const mockRequest = undefined;
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      service.createProject(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/create-project',
        { CfnResults: undefined }
      );
    });

    it('should handle array request', () => {
      const mockRequest = [{ stack: 'vpc' }, { stack: 's3' }];
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      service.createProject(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/create-project',
        { CfnResults: mockRequest }
      );
    });

    it('should handle complex nested request', () => {
      const mockRequest = {
        project: {
          name: 'production-infra',
          stacks: [
            { type: 'vpc', config: { cidr: '10.0.0.0/16' } },
            { type: 's3', config: { bucket: 'data-lake' } }
          ]
        },
        metadata: { owner: 'team-infra', region: 'us-east-1' }
      };
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      service.createProject(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/cfn/create-project',
        { CfnResults: mockRequest }
      );
    });

    it('should propagate HTTP errors', (done) => {
      const mockRequest = { project: 'test' };
      const mockError = new Error('Project creation failed');
      mockHttpService.Post.mockReturnValue(throwError(() => mockError));

      service.createProject(mockRequest).subscribe({
        error: (error: any) => {
          expect(error).toBe(mockError);
          done();
        }
      });
    });

    it('should always use the same endpoint', () => {
      const requests = [{ p1: 'a' }, { p2: 'b' }, { p3: 'c' }];
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      requests.forEach((request: any) => {
        service.createProject(request);
      });

      expect(mockHttpService.Post).toHaveBeenCalledTimes(3);
      mockHttpService.Post.mock.calls.forEach((call: any) => {
        expect(call[0]).toBe('api/cfn/create-project');
      });
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
    it('should support typical workflow: generate -> setActive -> stream -> cancel', (done) => {
      const mockRequest = { template: 'vpc' };
      const mockResponse = { jobId: 'job-workflow' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.generate(mockRequest).subscribe({
        next: (response: any) => {
          expect(response.jobId).toBe('job-workflow');

          service.setActiveJob(response.jobId);
          expect(service['activeJob']).toBe('job-workflow');

          const eventSource = service.generateStream(response.jobId);
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

    it('should support workflow: generate -> createProject', (done) => {
      const generateRequest = { template: 'vpc' };
      const generateResponse = { jobId: 'job-gen-123' };
      mockHttpService.Post.mockReturnValueOnce(of(generateResponse));

      service.generate(generateRequest).subscribe({
        next: (response: any) => {
          const projectRequest = { jobId: response.jobId, stacks: ['vpc', 's3'] };
          const projectResponse = { success: true, projectId: 'proj-123' };
          mockHttpService.Post.mockReturnValueOnce(of(projectResponse));

          service.createProject(projectRequest).subscribe({
            next: (projResponse: any) => {
              expect(projResponse.success).toBe(true);
              expect(projResponse.projectId).toBe('proj-123');
              done();
            }
          });
        }
      });
    });
  });
});
