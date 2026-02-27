import { TestBed } from '@angular/core/testing';
import { RepoService } from '~/services/repo.service';
import { HttpService } from '~/core/services/http.service';
import { Observable, of, throwError } from 'rxjs';

describe('RepoService', () => {
    let service: RepoService;
    let mockHttpService: jest.Mocked<HttpService>;

    beforeEach(() => {
        // Create mock HttpService
        mockHttpService = {
            Post: jest.fn()
        } as any;

        // Configure TestBed
        TestBed.configureTestingModule({
            providers: [
                RepoService,
                { provide: HttpService, useValue: mockHttpService }
            ]
        });

        // Inject the service
        service = TestBed.inject(RepoService);
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

    describe('assess', () => {
        it('should call httpService.Post with correct endpoint and request', () => {
            const mockRequest = {
                repositoryId: 'repo-123',
                assessmentType: 'security'
            };
            const mockResponse = { success: true, assessmentId: 'assess-456' };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledTimes(1);
            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should return Observable from httpService.Post', () => {
            const mockRequest = { repositoryId: 'repo-123' };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            const result = service.assess(mockRequest);

            expect(result).toBeInstanceOf(Observable);
        });

        it('should emit response data when HTTP call succeeds', (done) => {
            const mockRequest = {
                repositoryId: 'repo-789',
                assessmentType: 'code-quality',
                options: {
                    includeMetrics: true,
                    checkCompliance: true
                }
            };
            const mockResponse = {
                success: true,
                assessmentId: 'assess-789',
                score: 85,
                timestamp: '2024-02-06T10:30:00Z'
            };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest).subscribe({
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

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                {}
            );
        });

        it('should handle null request', () => {
            const mockRequest = null;
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                null
            );
        });

        it('should handle undefined request', () => {
            const mockRequest = undefined;
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                undefined
            );
        });

        it('should handle complex nested request object', () => {
            const mockRequest = {
                repositoryId: 'repo-complex',
                assessmentType: 'comprehensive',
                criteria: {
                    security: {
                        checkVulnerabilities: true,
                        scanDependencies: true
                    },
                    quality: {
                        codeSmells: true,
                        testCoverage: 80
                    }
                },
                metadata: {
                    userId: 'user-456',
                    timestamp: new Date().toISOString()
                }
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should propagate HTTP errors from httpService', (done) => {
            const mockRequest = { repositoryId: 'repo-error' };
            const mockError = new Error('Network error');
            mockHttpService.Post.mockReturnValue(throwError(() => mockError));

            service.assess(mockRequest).subscribe({
                error: (error: any) => {
                    expect(error).toBe(mockError);
                    done();
                }
            });
        });

        it('should handle HTTP 404 error', (done) => {
            const mockRequest = { repositoryId: 'nonexistent-repo' };
            const mockError = {
                status: 404,
                message: 'Repository not found'
            };
            mockHttpService.Post.mockReturnValue(throwError(() => mockError));

            service.assess(mockRequest).subscribe({
                error: (error: any) => {
                    expect(error.status).toBe(404);
                    expect(error.message).toBe('Repository not found');
                    done();
                }
            });
        });

        it('should handle HTTP 500 error', (done) => {
            const mockRequest = { repositoryId: 'repo-123' };
            const mockError = {
                status: 500,
                message: 'Internal server error'
            };
            mockHttpService.Post.mockReturnValue(throwError(() => mockError));

            service.assess(mockRequest).subscribe({
                error: (error: any) => {
                    expect(error.status).toBe(500);
                    done();
                }
            });
        });

        it('should handle HTTP 401 unauthorized error', (done) => {
            const mockRequest = { repositoryId: 'repo-123' };
            const mockError = {
                status: 401,
                message: 'Unauthorized'
            };
            mockHttpService.Post.mockReturnValue(throwError(() => mockError));

            service.assess(mockRequest).subscribe({
                error: (error: any) => {
                    expect(error.status).toBe(401);
                    done();
                }
            });
        });

        it('should handle HTTP 403 forbidden error', (done) => {
            const mockRequest = { repositoryId: 'restricted-repo' };
            const mockError = {
                status: 403,
                message: 'Access forbidden'
            };
            mockHttpService.Post.mockReturnValue(throwError(() => mockError));

            service.assess(mockRequest).subscribe({
                error: (error: any) => {
                    expect(error.status).toBe(403);
                    expect(error.message).toBe('Access forbidden');
                    done();
                }
            });
        });

        it('should return Observable that can be subscribed to multiple times', (done) => {
            const mockRequest = { repositoryId: 'repo-123' };
            const mockResponse = { success: true, assessmentId: 'assess-999' };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            const observable = service.assess(mockRequest);

            // Post is called once when assess() is invoked
            expect(mockHttpService.Post).toHaveBeenCalledTimes(1);

            let subscriptionCount = 0;

            // First subscription
            observable.subscribe({
                next: (response: any) => {
                    expect(response).toEqual(mockResponse);
                    subscriptionCount++;
                }
            });

            // Second subscription - same observable can be subscribed to multiple times
            observable.subscribe({
                next: (response: any) => {
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
                { repositoryId: 'repo1' },
                { repositoryId: 'repo2' }
            ];
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should handle request with special characters', () => {
            const mockRequest = {
                repositoryId: 'repo-with-special!@#$%',
                branch: 'feature/assessment-v2.0',
                pattern: '*.ts'
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should pass through request without modification', () => {
            const mockRequest = {
                repositoryId: 'repo-123',
                sensitiveData: 'api-key-xyz'
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            // Verify the exact same object reference is passed
            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should handle request with boolean values', () => {
            const mockRequest = {
                repositoryId: 'repo-123',
                includeTests: true,
                skipCache: false,
                validateSchema: true
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should handle request with numeric values', () => {
            const mockRequest = {
                repositoryId: 'repo-123',
                timeout: 5000,
                minScore: 75,
                version: 3.2
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should always use the same endpoint URL', () => {
            const requests = [
                { repositoryId: 'repo1' },
                { repositoryId: 'repo2' },
                { repositoryId: 'repo3' }
            ];
            mockHttpService.Post.mockReturnValue(of({ success: true }));

            requests.forEach(request => {
                service.assess(request);
            });

            // Verify all calls used the same endpoint
            expect(mockHttpService.Post).toHaveBeenCalledTimes(3);
            mockHttpService.Post.mock.calls.forEach(call => {
                expect(call[0]).toBe('api/repo/assess');
            });
        });

        it('should not modify the response from httpService', (done) => {
            const mockRequest = { repositoryId: 'repo-123' };
            const mockResponse = {
                success: true,
                data: {
                    assessmentId: 'assess-888',
                    findings: [
                        { severity: 'high', count: 2 },
                        { severity: 'medium', count: 5 }
                    ],
                    metadata: { totalIssues: 7 }
                }
            };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest).subscribe({
                next: (response: any) => {
                    expect(response).toEqual(mockResponse);
                    expect(response).toBe(mockResponse);
                    done();
                }
            });
        });

        it('should handle synchronous errors from httpService', (done) => {
            const mockRequest = { repositoryId: 'repo-123' };
            const syncError = new Error('Synchronous error');
            mockHttpService.Post.mockImplementation(() => {
                throw syncError;
            });

            try {
                service.assess(mockRequest);
                done.fail('Should have thrown an error');
            } catch (error) {
                expect(error).toBe(syncError);
                done();
            }
        });

        it('should handle request with Date objects', () => {
            const mockRequest = {
                repositoryId: 'repo-123',
                startDate: new Date('2024-01-01'),
                endDate: new Date('2024-12-31')
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should handle request with null values in nested objects', () => {
            const mockRequest = {
                repositoryId: 'repo-123',
                options: {
                    threshold: null,
                    pattern: null,
                    enabled: true
                }
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });

        it('should handle empty array request', () => {
            const mockRequest: any = [];
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                []
            );
        });

        it('should handle request with deeply nested objects', () => {
            const mockRequest = {
                repositoryId: 'repo-123',
                config: {
                    level1: {
                        level2: {
                            level3: {
                                value: 'deep'
                            }
                        }
                    }
                }
            };
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/repo/assess',
                mockRequest
            );
        });
    });

    describe('Method Signature', () => {
        it('should accept any type of request parameter', () => {
            const mockResponse = { success: true };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            // Test with different types
            service.assess({ repositoryId: 'string-based' });
            service.assess(12345);
            service.assess(true);
            service.assess(['array', 'data']);

            expect(mockHttpService.Post).toHaveBeenCalledTimes(4);
        });

        it('should return Observable<any> type', () => {
            const mockRequest = { repositoryId: 'repo-123' };
            const mockResponse = { anyProperty: 'anyValue' };
            mockHttpService.Post.mockReturnValue(of(mockResponse));

            const result = service.assess(mockRequest);

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
            const mockRequest = { repositoryId: 'repo-123' };
            mockHttpService.Post.mockReturnValue(of({ success: true }));

            service.assess(mockRequest);

            expect(mockHttpService.Post).toHaveBeenCalled();
            expect(mockHttpService.Post).toBeDefined();
        });
    });
});
