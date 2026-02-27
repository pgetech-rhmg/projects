import { TestBed } from '@angular/core/testing';
import { ScanService } from '~/services/scan.service';
import { HttpService } from '~/core/services/http.service';
import { Observable, of, throwError } from 'rxjs';

describe('ScanService', () => {
  let service: ScanService;
  let mockHttpService: jest.Mocked<HttpService>;

  beforeEach(() => {
    // Create mock HttpService
    mockHttpService = {
      Post: jest.fn()
    } as any;

    // Configure TestBed
    TestBed.configureTestingModule({
      providers: [
        ScanService,
        { provide: HttpService, useValue: mockHttpService }
      ]
    });

    // Inject the service
    service = TestBed.inject(ScanService);
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
  });

  describe('scan', () => {
    it('should call httpService.Post with correct endpoint and request', () => {
      const mockRequest = {
        repository: 'test-repo',
        branch: 'main'
      };
      const mockResponse = { success: true, scanId: '123' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledTimes(1);
      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        mockRequest
      );
    });

    it('should return Observable from httpService.Post', () => {
      const mockRequest = { repository: 'test-repo' };
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      const result = service.scan(mockRequest);

      expect(result).toBeInstanceOf(Observable);
    });

    it('should emit response data when HTTP call succeeds', (done) => {
      const mockRequest = {
        repository: 'my-repo',
        branch: 'develop',
        scanType: 'full'
      };
      const mockResponse = {
        success: true,
        scanId: 'scan-456',
        timestamp: '2024-02-06T10:30:00Z'
      };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest).subscribe({
        next: (response: any) => {
          expect(response).toEqual(mockResponse);
          done();
        }
      });
    });

    it('should handle empty request object', () => {
      const mockRequest = {};
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        {}
      );
    });

    it('should handle null request', () => {
      const mockRequest = null;
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        null
      );
    });

    it('should handle undefined request', () => {
      const mockRequest = undefined;
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        undefined
      );
    });

    it('should handle complex nested request object', () => {
      const mockRequest = {
        repository: 'test-repo',
        branch: 'main',
        options: {
          scanDepth: 'deep',
          includeTests: true,
          excludePatterns: ['*.test.ts', '*.spec.ts']
        },
        metadata: {
          userId: 'user123',
          timestamp: new Date().toISOString()
        }
      };
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        mockRequest
      );
    });

    it('should propagate HTTP errors from httpService', (done) => {
      const mockRequest = { repository: 'test-repo' };
      const mockError = new Error('Network error');
      mockHttpService.Post.mockReturnValue(throwError(() => mockError));

      service.scan(mockRequest).subscribe({
        error: (error: any) => {
          expect(error).toBe(mockError);
          done();
        }
      });
    });

    it('should handle HTTP 404 error', (done) => {
      const mockRequest = { repository: 'nonexistent-repo' };
      const mockError = {
        status: 404,
        message: 'Repository not found'
      };
      mockHttpService.Post.mockReturnValue(throwError(() => mockError));

      service.scan(mockRequest).subscribe({
        error: (error: any) => {
          expect(error.status).toBe(404);
          expect(error.message).toBe('Repository not found');
          done();
        }
      });
    });

    it('should handle HTTP 500 error', (done) => {
      const mockRequest = { repository: 'test-repo' };
      const mockError = {
        status: 500,
        message: 'Internal server error'
      };
      mockHttpService.Post.mockReturnValue(throwError(() => mockError));

      service.scan(mockRequest).subscribe({
        error: (error: any) => {
          expect(error.status).toBe(500);
          done();
        }
      });
    });

    it('should handle HTTP 401 unauthorized error', (done) => {
      const mockRequest = { repository: 'test-repo' };
      const mockError = {
        status: 401,
        message: 'Unauthorized'
      };
      mockHttpService.Post.mockReturnValue(throwError(() => mockError));

      service.scan(mockRequest).subscribe({
        error: (error: any) => {
          expect(error.status).toBe(401);
          done();
        }
      });
    });

    it('should return Observable that can be subscribed to multiple times', (done) => {
      const mockRequest = { repository: 'test-repo' };
      const mockResponse = { success: true, scanId: '789' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      const observable = service.scan(mockRequest);

      // Post is called once when scan() is invoked
      expect(mockHttpService.Post).toHaveBeenCalledTimes(1);

      let subscriptionCount = 0;

      // First subscription
      observable.subscribe({
        next: (response) => {
          expect(response).toEqual(mockResponse);
          subscriptionCount++;
        }
      });

      // Second subscription - same observable can be subscribed to multiple times
      observable.subscribe({
        next: (response) => {
          expect(response).toEqual(mockResponse);
          subscriptionCount++;

          // Verify both subscriptions received data
          expect(subscriptionCount).toBe(2);
          // Post is still only called once
          expect(mockHttpService.Post).toHaveBeenCalledTimes(1);
          done();
        }
      });
    });

    it('should handle array request data', () => {
      const mockRequest = [
        { repository: 'repo1' },
        { repository: 'repo2' }
      ];
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        mockRequest
      );
    });

    it('should handle request with special characters', () => {
      const mockRequest = {
        repository: 'repo-with-special-chars!@#$%',
        branch: 'feature/bug-fix',
        path: '/src/components/*.ts'
      };
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        mockRequest
      );
    });

    it('should pass through request without modification', () => {
      const mockRequest = {
        repository: 'test-repo',
        sensitiveData: 'password123'
      };
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      // Verify the exact same object reference is passed
      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        mockRequest
      );
    });

    it('should handle request with boolean values', () => {
      const mockRequest = {
        repository: 'test-repo',
        includeArchived: true,
        skipCache: false
      };
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        mockRequest
      );
    });

    it('should handle request with numeric values', () => {
      const mockRequest = {
        repository: 'test-repo',
        timeout: 3000,
        maxResults: 100,
        version: 2.5
      };
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalledWith(
        'api/scan/repo',
        mockRequest
      );
    });

    it('should always use the same endpoint URL', () => {
      const requests = [
        { repository: 'repo1' },
        { repository: 'repo2' },
        { repository: 'repo3' }
      ];
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      requests.forEach(request => {
        service.scan(request);
      });

      // Verify all calls used the same endpoint
      expect(mockHttpService.Post).toHaveBeenCalledTimes(3);
      mockHttpService.Post.mock.calls.forEach(call => {
        expect(call[0]).toBe('api/scan/repo');
      });
    });

    it('should not modify the response from httpService', (done) => {
      const mockRequest = { repository: 'test-repo' };
      const mockResponse = {
        success: true,
        data: {
          scanId: 'scan-999',
          results: [1, 2, 3],
          metadata: { count: 3 }
        }
      };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      service.scan(mockRequest).subscribe({
        next: (response: any) => {
          expect(response).toEqual(mockResponse);
          expect(response).toBe(mockResponse);
          done();
        }
      });
    });

    it('should handle synchronous errors from httpService', (done) => {
      const mockRequest = { repository: 'test-repo' };
      const syncError = new Error('Synchronous error');
      mockHttpService.Post.mockImplementation(() => {
        throw syncError;
      });

      try {
        service.scan(mockRequest);
        done.fail('Should have thrown an error');
      } catch (error) {
        expect(error).toBe(syncError);
        done();
      }
    });
  });

  describe('Method Signature', () => {
    it('should accept any type of request parameter', () => {
      const mockResponse = { success: true };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      // Test with different types
      service.scan({ repository: 'string-based' });
      service.scan(12345);
      service.scan(true);
      service.scan(['array', 'data']);

      expect(mockHttpService.Post).toHaveBeenCalledTimes(4);
    });

    it('should return Observable<any> type', () => {
      const mockRequest = { repository: 'test-repo' };
      const mockResponse = { anyProperty: 'anyValue' };
      mockHttpService.Post.mockReturnValue(of(mockResponse));

      const result = service.scan(mockRequest);

      expect(result).toBeInstanceOf(Observable);
      result.subscribe((response: any) => {
        // Can be any type
        expect(response).toBeDefined();
      });
    });
  });

  describe('Integration with HttpService', () => {
    it('should depend only on HttpService', () => {
      // Verify service has no other dependencies
      expect(service['httpService']).toBeDefined();
      expect(Object.keys(service).length).toBe(1);
    });

    it('should use HttpService.Post method specifically', () => {
      const mockRequest = { repository: 'test-repo' };
      mockHttpService.Post.mockReturnValue(of({ success: true }));

      service.scan(mockRequest);

      expect(mockHttpService.Post).toHaveBeenCalled();
      expect(mockHttpService.Post).toBeDefined();
    });
  });
});
