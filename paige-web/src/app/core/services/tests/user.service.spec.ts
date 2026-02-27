import { TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { UserService } from '~/core/services/user.service';
import { HttpService } from '~/core/services/http.service';

describe('UserService', () => {
    let service: UserService;
    let mockHttpService: any;

    beforeEach(() => {
        mockHttpService = {
            Post: jest.fn()
        };

        TestBed.configureTestingModule({
            providers: [
                UserService,
                { provide: HttpService, useValue: mockHttpService }
            ]
        });

        service = TestBed.inject(UserService);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('GetUser', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });

        it('should call httpService.Post with correct parameters', async () => {
            const roles = 'admin,user';
            const mockResponse = { id: 1, name: 'John Doe', roles: ['admin', 'user'] };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            await service.GetUser(roles);

            expect(mockHttpService.Post).toHaveBeenCalledWith('api/User/get-user', JSON.stringify(roles));
        });

        it('should return user data on successful request', async () => {
            const roles = 'admin,user';
            const mockResponse = { id: 1, name: 'John Doe', roles: ['admin', 'user'] };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.GetUser(roles);

            expect(result).toEqual(mockResponse);
        });

        it('should return response with multiple properties', async () => {
            const roles = 'viewer';
            const mockResponse = { 
                id: 2, 
                name: 'Jane Smith', 
                email: 'jane@example.com',
                roles: ['viewer'],
                active: true
            };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.GetUser(roles);

            expect(result).toEqual(mockResponse);
            expect(result.id).toBe(2);
            expect(result.name).toBe('Jane Smith');
            expect(result.email).toBe('jane@example.com');
            expect(result.active).toBe(true);
        });

        it('should handle empty roles string', async () => {
            const roles = '';
            const mockResponse = { id: 3, name: 'Guest User', roles: [] };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            const result = await service.GetUser(roles);

            expect(mockHttpService.Post).toHaveBeenCalledWith('api/User/get-user', JSON.stringify(roles));
            expect(result).toEqual(mockResponse);
        });

        it('should throw error when http request fails', async () => {
            const roles = 'admin';
            const errorResponse = { status: 500, message: 'Internal Server Error' };
            
            mockHttpService.Post = jest.fn(() => throwError(() => errorResponse));

            await expect(service.GetUser(roles)).rejects.toEqual(errorResponse);
        });

        it('should throw error when http returns 404', async () => {
            const roles = 'nonexistent';
            const errorResponse = { status: 404, message: 'User not found' };
            
            mockHttpService.Post = jest.fn(() => throwError(() => errorResponse));

            await expect(service.GetUser(roles)).rejects.toEqual(errorResponse);
        });

        it('should throw error when http returns 401 unauthorized', async () => {
            const roles = 'admin';
            const errorResponse = { status: 401, message: 'Unauthorized' };
            
            mockHttpService.Post = jest.fn(() => throwError(() => errorResponse));

            await expect(service.GetUser(roles)).rejects.toEqual(errorResponse);
        });

        it('should handle network errors', async () => {
            const roles = 'admin';
            const networkError = new Error('Network connection failed');
            
            mockHttpService.Post = jest.fn(() => throwError(() => networkError));

            await expect(service.GetUser(roles)).rejects.toThrow('Network connection failed');
        });

        it('should call pipe() on the observable', async () => {
            const roles = 'admin';
            const mockResponse = { id: 1, name: 'Test' };
            const mockPipe = jest.fn(() => of(mockResponse));
            
            mockHttpService.Post = jest.fn(() => ({
                pipe: mockPipe
            }));

            await service.GetUser(roles);

            expect(mockPipe).toHaveBeenCalled();
        });

        it('should handle null response', async () => {
            const roles = 'admin';
            
            mockHttpService.Post = jest.fn(() => of(null));

            const result = await service.GetUser(roles);

            expect(result).toBeNull();
        });

        it('should handle undefined response', async () => {
            const roles = 'admin';
            
            mockHttpService.Post = jest.fn(() => of(undefined));

            const result = await service.GetUser(roles);

            expect(result).toBeUndefined();
        });

        it('should stringify roles parameter correctly', async () => {
            const roles = 'admin,moderator,user';
            const expectedStringified = '"admin,moderator,user"';
            const mockResponse = { id: 1 };
            
            mockHttpService.Post = jest.fn(() => of(mockResponse));

            await service.GetUser(roles);

            const callArgs = mockHttpService.Post.mock.calls[0];
            expect(callArgs[1]).toBe(expectedStringified);
        });
    });
});
