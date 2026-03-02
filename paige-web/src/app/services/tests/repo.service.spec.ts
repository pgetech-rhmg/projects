import { TestBed } from '@angular/core/testing';
import { RepoService } from '~/services/repo.service';
import { HttpService } from '~/core/services/http.service';
import { Observable, of, throwError } from 'rxjs';

describe('RepoService', () => {
	let service: RepoService;
	let mockHttpService: jest.Mocked<HttpService>;

	beforeEach(() => {
		mockHttpService = {
			Post: jest.fn()
		} as any;

		TestBed.configureTestingModule({
			providers: [
				RepoService,
				{ provide: HttpService, useValue: mockHttpService }
			]
		});

		service = TestBed.inject(RepoService);
	});

	afterEach(() => {
		jest.clearAllMocks();
	});

	//*************************************************************************
	//  Service Initialization
	//*************************************************************************
	describe('Service Initialization', () => {
		it('should be created', () => {
			expect(service).toBeTruthy();
		});

		it('should inject HttpService', () => {
			expect(service['httpService']).toBe(mockHttpService);
		});
	});

	//*************************************************************************
	//  assess
	//*************************************************************************
	describe('assess', () => {
		it('should call httpService.Post with correct endpoint and request', () => {
			const mockRequest = { repositoryId: 'repo-123' };
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.assess(mockRequest);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/assess', mockRequest);
		});

		it('should return Observable from httpService.Post', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			const result = service.assess({ repositoryId: 'repo-123' });

			expect(result).toBeInstanceOf(Observable);
		});

		it('should emit response data on success', (done) => {
			const mockResponse = { success: true, assessmentId: 'assess-123' };
			mockHttpService.Post.mockReturnValue(of(mockResponse));

			service.assess({ repositoryId: 'repo-123' }).subscribe({
				next: (response: any) => {
					expect(response).toEqual(mockResponse);
					done();
				}
			});
		});

		it('should propagate errors from httpService', (done) => {
			const mockError = { status: 500, message: 'Internal server error' };
			mockHttpService.Post.mockReturnValue(throwError(() => mockError));

			service.assess({ repositoryId: 'repo-123' }).subscribe({
				error: (error: any) => {
					expect(error).toBe(mockError);
					done();
				}
			});
		});

		it('should handle null request', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.assess(null);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/assess', null);
		});

		it('should handle undefined request', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.assess(undefined);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/assess', undefined);
		});

		it('should always use /api/repo/assess endpoint', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.assess({ repositoryId: 'repo-1' });
			service.assess({ repositoryId: 'repo-2' });
			service.assess({ repositoryId: 'repo-3' });

			mockHttpService.Post.mock.calls.forEach(call => {
				expect(call[0]).toBe('/api/repo/assess');
			});
		});

		it('should pass request through without modification', () => {
			const mockRequest = { repositoryId: 'repo-123', branch: 'main' };
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.assess(mockRequest);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/assess', mockRequest);
		});
	});

	//*************************************************************************
	//  analyze
	//*************************************************************************
	describe('analyze', () => {
		it('should call httpService.Post with correct endpoint and request', () => {
			const mockRequest = { repositoryId: 'repo-123' };
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.analyze(mockRequest);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/analyze', mockRequest);
		});

		it('should return Observable from httpService.Post', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			const result = service.analyze({ repositoryId: 'repo-123' });

			expect(result).toBeInstanceOf(Observable);
		});

		it('should emit response data on success', (done) => {
			const mockResponse = { success: true, analysisId: 'analysis-123' };
			mockHttpService.Post.mockReturnValue(of(mockResponse));

			service.analyze({ repositoryId: 'repo-123' }).subscribe({
				next: (response: any) => {
					expect(response).toEqual(mockResponse);
					done();
				}
			});
		});

		it('should propagate errors from httpService', (done) => {
			const mockError = { status: 500, message: 'Internal server error' };
			mockHttpService.Post.mockReturnValue(throwError(() => mockError));

			service.analyze({ repositoryId: 'repo-123' }).subscribe({
				error: (error: any) => {
					expect(error).toBe(mockError);
					done();
				}
			});
		});

		it('should handle null request', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.analyze(null);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/analyze', null);
		});

		it('should handle undefined request', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.analyze(undefined);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/analyze', undefined);
		});

		it('should always use /api/repo/analyze endpoint', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.analyze({ repositoryId: 'repo-1' });
			service.analyze({ repositoryId: 'repo-2' });
			service.analyze({ repositoryId: 'repo-3' });

			mockHttpService.Post.mock.calls.forEach(call => {
				expect(call[0]).toBe('/api/repo/analyze');
			});
		});

		it('should pass request through without modification', () => {
			const mockRequest = { repositoryId: 'repo-123', branch: 'main' };
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.analyze(mockRequest);

			expect(mockHttpService.Post).toHaveBeenCalledWith('/api/repo/analyze', mockRequest);
		});
	});

	//*************************************************************************
	//  assess vs analyze isolation
	//*************************************************************************
	describe('Method isolation', () => {
		it('should not mix up assess and analyze endpoints', () => {
			mockHttpService.Post.mockReturnValue(of({ success: true }));

			service.assess({ repositoryId: 'repo-123' });
			service.analyze({ repositoryId: 'repo-123' });

			expect(mockHttpService.Post).toHaveBeenNthCalledWith(1, '/api/repo/assess', expect.anything());
			expect(mockHttpService.Post).toHaveBeenNthCalledWith(2, '/api/repo/analyze', expect.anything());
		});
	});
});