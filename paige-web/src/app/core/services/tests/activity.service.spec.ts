import { TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { ActivityService } from '~/core/services/activity.service';
import { HttpService } from '~/core/services/http.service';

describe('ActivityService', () => {
    let service: ActivityService;
    let mockHttpService: any;

    beforeEach(() => {
        mockHttpService = {
            Get: jest.fn(),
            Post: jest.fn()
        };

        TestBed.configureTestingModule({
            providers: [
                ActivityService,
                { provide: HttpService, useValue: mockHttpService }
            ]
        });

        service = TestBed.inject(ActivityService);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('Service Creation', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });
    });

    describe('GetActivity', () => {
        it('should call httpService.Get with correct parameters', async () => {
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const mockResponse = [
                { id: 1, type: 'login', date: '2024-01-15' },
                { id: 2, type: 'login', date: '2024-01-20' }
            ];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            await service.GetActivity(type, startDate, endDate);

            expect(mockHttpService.Get).toHaveBeenCalledWith(
                `api/Activity?type=${type}&startDate=${startDate}&endDate=${endDate}`
            );
        });

        it('should return activity data on successful request', async () => {
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const mockResponse = [
                { id: 1, type: 'login', date: '2024-01-15', username: 'user1' },
                { id: 2, type: 'login', date: '2024-01-20', username: 'user2' }
            ];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            const result = await service.GetActivity(type, startDate, endDate);

            expect(result).toEqual(mockResponse);
            expect(result).toHaveLength(2);
        });

        it('should handle different activity types', async () => {
            const type = 'view';
            const startDate = '2024-02-01';
            const endDate = '2024-02-28';
            const mockResponse = [
                { id: 3, type: 'view', page: '/dashboard' }
            ];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            const result = await service.GetActivity(type, startDate, endDate);

            expect(result).toEqual(mockResponse);
            expect(mockHttpService.Get).toHaveBeenCalledWith(
                `api/Activity?type=${type}&startDate=${startDate}&endDate=${endDate}`
            );
        });

        it('should handle empty activity response', async () => {
            const type = 'export';
            const startDate = '2024-03-01';
            const endDate = '2024-03-31';
            const mockResponse: any[] = [];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            const result = await service.GetActivity(type, startDate, endDate);

            expect(result).toEqual([]);
            expect(result).toHaveLength(0);
        });

        it('should handle null type parameter', async () => {
            const type = null;
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const mockResponse = [{ id: 1 }];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            const result = await service.GetActivity(type, startDate, endDate);

            expect(mockHttpService.Get).toHaveBeenCalledWith(
                `api/Activity?type=${type}&startDate=${startDate}&endDate=${endDate}`
            );
            expect(result).toEqual(mockResponse);
        });

        it('should handle undefined date parameters', async () => {
            const type = 'login';
            const startDate = undefined;
            const endDate = undefined;
            const mockResponse = [{ id: 1 }];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            const result = await service.GetActivity(type, startDate, endDate);

            expect(mockHttpService.Get).toHaveBeenCalledWith(
                `api/Activity?type=${type}&startDate=${startDate}&endDate=${endDate}`
            );
            expect(result).toEqual(mockResponse);
        });

        it('should throw error when HTTP request fails', async () => {
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const errorResponse = { status: 500, message: 'Internal Server Error' };
            
            mockHttpService.Get = jest.fn(() => throwError(() => errorResponse));

            await expect(service.GetActivity(type, startDate, endDate)).rejects.toEqual(errorResponse);
        });

        it('should throw error when HTTP returns 404', async () => {
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const errorResponse = { status: 404, message: 'Not Found' };
            
            mockHttpService.Get = jest.fn(() => throwError(() => errorResponse));

            await expect(service.GetActivity(type, startDate, endDate)).rejects.toEqual(errorResponse);
        });

        it('should throw error when HTTP returns 401 unauthorized', async () => {
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const errorResponse = { status: 401, message: 'Unauthorized' };
            
            mockHttpService.Get = jest.fn(() => throwError(() => errorResponse));

            await expect(service.GetActivity(type, startDate, endDate)).rejects.toEqual(errorResponse);
        });

        it('should handle network errors', async () => {
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const networkError = new Error('Network connection failed');
            
            mockHttpService.Get = jest.fn(() => throwError(() => networkError));

            await expect(service.GetActivity(type, startDate, endDate)).rejects.toThrow('Network connection failed');
        });

        it('should call pipe() on the observable', async () => {
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const mockResponse = [{ id: 1 }];
            const mockPipe = jest.fn(() => of(mockResponse));
            
            mockHttpService.Get = jest.fn(() => ({
                pipe: mockPipe
            }));

            await service.GetActivity(type, startDate, endDate);

            expect(mockPipe).toHaveBeenCalled();
        });

        it('should handle date objects as parameters', async () => {
            const type = 'login';
            const startDate = new Date('2024-01-01');
            const endDate = new Date('2024-01-31');
            const mockResponse = [{ id: 1 }];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            const result = await service.GetActivity(type, startDate, endDate);

            expect(result).toEqual(mockResponse);
        });

        it('should handle special characters in type parameter', async () => {
            const type = 'user-login/test';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const mockResponse = [{ id: 1 }];
            
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            await service.GetActivity(type, startDate, endDate);

            expect(mockHttpService.Get).toHaveBeenCalledWith(
                `api/Activity?type=${type}&startDate=${startDate}&endDate=${endDate}`
            );
        });
    });

    describe('SaveActivity', () => {
        it('should call httpService.Post with correct parameters', async () => {
            const activity = {
                type: 'login',
                username: 'testuser',
                timestamp: '2024-01-15T10:30:00'
            };
            const mockResponse = { id: 1, ...activity };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            await service.SaveActivity(activity);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/Activity/create-activity',
                activity
            );
        });

        it('should return saved activity data on successful request', async () => {
            const activity = {
                type: 'view',
                page: '/dashboard',
                username: 'user1',
                timestamp: '2024-01-15T10:30:00'
            };
            const mockResponse = { id: 2, ...activity, created: true };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.SaveActivity(activity);

            expect(result).toEqual(mockResponse);
            expect(result.id).toBe(2);
            expect(result.created).toBe(true);
        });

        it('should handle activity with multiple properties', async () => {
            const activity = {
                type: 'export',
                username: 'admin',
                data: { format: 'csv', rows: 100 },
                timestamp: '2024-01-15T10:30:00',
                metadata: { browser: 'Chrome', os: 'Windows' }
            };
            const mockResponse = { id: 3, success: true };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.SaveActivity(activity);

            expect(result).toEqual(mockResponse);
            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/Activity/create-activity',
                activity
            );
        });

        it('should handle empty activity object', async () => {
            const activity = {};
            const mockResponse = { id: 4, success: true };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.SaveActivity(activity);

            expect(result).toEqual(mockResponse);
            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/Activity/create-activity',
                activity
            );
        });

        it('should handle null activity', async () => {
            const activity = null;
            const mockResponse = { error: 'Invalid activity' };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.SaveActivity(activity);

            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/Activity/create-activity',
                activity
            );
        });

        it('should throw error when HTTP request fails', async () => {
            const activity = { type: 'login', username: 'user1' };
            const errorResponse = { status: 500, message: 'Internal Server Error' };
            
            mockHttpService.Post = jest.fn(() => throwError(() => errorResponse));

            await expect(service.SaveActivity(activity)).rejects.toEqual(errorResponse);
        });

        it('should throw error when HTTP returns 400 bad request', async () => {
            const activity = { type: 'invalid' };
            const errorResponse = { status: 400, message: 'Bad Request' };
            
            mockHttpService.Post = jest.fn(() => throwError(() => errorResponse));

            await expect(service.SaveActivity(activity)).rejects.toEqual(errorResponse);
        });

        it('should throw error when HTTP returns 401 unauthorized', async () => {
            const activity = { type: 'login', username: 'user1' };
            const errorResponse = { status: 401, message: 'Unauthorized' };
            
            mockHttpService.Post = jest.fn(() => throwError(() => errorResponse));

            await expect(service.SaveActivity(activity)).rejects.toEqual(errorResponse);
        });

        it('should throw error when HTTP returns 403 forbidden', async () => {
            const activity = { type: 'admin-action' };
            const errorResponse = { status: 403, message: 'Forbidden' };
            
            mockHttpService.Post = jest.fn(() => throwError(() => errorResponse));

            await expect(service.SaveActivity(activity)).rejects.toEqual(errorResponse);
        });

        it('should handle network errors', async () => {
            const activity = { type: 'login', username: 'user1' };
            const networkError = new Error('Network connection failed');
            
            mockHttpService.Post = jest.fn(() => throwError(() => networkError));

            await expect(service.SaveActivity(activity)).rejects.toThrow('Network connection failed');
        });

        it('should call pipe() on the observable', async () => {
            const activity = { type: 'login', username: 'user1' };
            const mockResponse = { id: 1, success: true };
            const mockPipe = jest.fn(() => of(mockResponse));
            
            mockHttpService.Post = jest.fn(() => ({
                pipe: mockPipe
            }));

            await service.SaveActivity(activity);

            expect(mockPipe).toHaveBeenCalled();
        });

        it('should handle activity with Date objects', async () => {
            const activity = {
                type: 'login',
                timestamp: new Date('2024-01-15T10:30:00'),
                expiresAt: new Date('2024-01-15T11:30:00')
            };
            const mockResponse = { id: 5, success: true };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.SaveActivity(activity);

            expect(result).toEqual(mockResponse);
        });

        it('should handle activity with nested objects', async () => {
            const activity = {
                type: 'complex',
                data: {
                    user: { id: 1, name: 'Test' },
                    settings: { theme: 'dark' }
                }
            };
            const mockResponse = { id: 6, success: true };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.SaveActivity(activity);

            expect(result).toEqual(mockResponse);
            expect(mockHttpService.Post).toHaveBeenCalledWith(
                'api/Activity/create-activity',
                activity
            );
        });

        it('should handle activity with arrays', async () => {
            const activity = {
                type: 'bulk-action',
                items: [1, 2, 3, 4, 5],
                tags: ['important', 'urgent']
            };
            const mockResponse = { id: 7, processed: 5 };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.SaveActivity(activity);

            expect(result).toEqual(mockResponse);
        });
    });

    describe('Integration Tests', () => {
        it('should handle complete activity workflow: get -> save', async () => {
            // Get activities
            const type = 'login';
            const startDate = '2024-01-01';
            const endDate = '2024-01-31';
            const getResponse = [
                { id: 1, type: 'login', username: 'user1' }
            ];
            
            mockHttpService.Get = jest.fn(() => of(getResponse));
            const activities = await service.GetActivity(type, startDate, endDate);
            expect(activities).toEqual(getResponse);

            // Save new activity
            const newActivity = {
                type: 'login',
                username: 'user2',
                timestamp: '2024-01-15T10:30:00'
            };
            const postResponse = { id: 2, success: true };
            
            mockHttpService.Post = jest.fn(() => of(postResponse));
            const saved = await service.SaveActivity(newActivity);
            expect(saved).toEqual(postResponse);
        });

        it('should handle multiple consecutive GetActivity calls', async () => {
            const mockResponse = [{ id: 1 }];
            mockHttpService.Get = jest.fn(() => of(mockResponse));

            await service.GetActivity('login', '2024-01-01', '2024-01-31');
            await service.GetActivity('view', '2024-02-01', '2024-02-28');
            await service.GetActivity('export', '2024-03-01', '2024-03-31');

            expect(mockHttpService.Get).toHaveBeenCalledTimes(3);
        });

        it('should handle multiple consecutive SaveActivity calls', async () => {
            const mockResponse = { id: 1, success: true };
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            await service.SaveActivity({ type: 'login' });
            await service.SaveActivity({ type: 'view' });
            await service.SaveActivity({ type: 'export' });

            expect(mockHttpService.Post).toHaveBeenCalledTimes(3);
        });

        it('should handle error in get followed by successful save', async () => {
            // Get fails
            mockHttpService.Get = jest.fn(() => throwError(() => new Error('Get failed')));
            await expect(service.GetActivity('login', '2024-01-01', '2024-01-31'))
                .rejects.toThrow('Get failed');

            // Save succeeds
            mockHttpService.Post = jest.fn(() => of({ id: 1, success: true }));
            const result = await service.SaveActivity({ type: 'login' });
            expect(result).toEqual({ id: 1, success: true });
        });

        it('should handle successful get followed by failed save', async () => {
            // Get succeeds
            mockHttpService.Get = jest.fn(() => of([{ id: 1 }]));
            const activities = await service.GetActivity('login', '2024-01-01', '2024-01-31');
            expect(activities).toEqual([{ id: 1 }]);

            // Save fails
            mockHttpService.Post = jest.fn(() => throwError(() => new Error('Save failed')));
            await expect(service.SaveActivity({ type: 'login' }))
                .rejects.toThrow('Save failed');
        });
    });
});
