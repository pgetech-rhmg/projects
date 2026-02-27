import { TestBed } from '@angular/core/testing';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { of, throwError } from 'rxjs';
import { GraphService } from '~/core/services/graph.service';

describe('GraphService', () => {
    let service: GraphService;
    let mockHttpClient: any;

    beforeEach(() => {
        mockHttpClient = {
            get: jest.fn()
        };

        TestBed.configureTestingModule({
            providers: [
                GraphService,
                { provide: HttpClient, useValue: mockHttpClient }
            ]
        });

        service = TestBed.inject(GraphService);

        // Clear localStorage before each test
        localStorage.clear();
    });

    afterEach(() => {
        jest.clearAllMocks();
        localStorage.clear();
    });

    describe('Service Creation', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });
    });

    describe('getUserPhoto', () => {
        it('should return empty string when no token exists', async () => {
            localStorage.removeItem('msal.idtoken');

            const result = await service.getUserPhoto();

            expect(result).toBe('');
            expect(mockHttpClient.get).not.toHaveBeenCalled();
        });

        it('should call Microsoft Graph API with correct URL and headers', async () => {
            const mockToken = 'mock-token-123';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockBlob = new Blob(['test'], { type: 'image/jpeg' });
            mockHttpClient.get = jest.fn(() => of(mockBlob));

            // Mock FileReader
            const mockFileReader = {
                readAsDataURL: jest.fn(function(this: any) {
                    // Immediately trigger onloadend
                    setTimeout(() => {
                        if (this.onloadend) {
                            this.onloadend();
                        }
                    }, 0);
                }),
                result: 'data:image/jpeg;base64,mockBase64Data',
                onloadend: null as any,
                onerror: null as any
            };

            global.FileReader = jest.fn(() => mockFileReader) as any;

            const result = await service.getUserPhoto();

            expect(mockHttpClient.get).toHaveBeenCalledWith(
                'https://graph.microsoft.com/v1.0/me/photo/$value',
                expect.objectContaining({
                    responseType: 'blob'
                })
            );

            const callArgs = mockHttpClient.get.mock.calls[0];
            const headers = callArgs[1].headers as HttpHeaders;
            expect(headers.get('Authorization')).toBe(`Bearer ${mockToken}`);
        });

        it('should return base64 string when photo exists', async () => {
            const mockToken = 'mock-token-123';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockBlob = new Blob(['test'], { type: 'image/jpeg' });
            mockHttpClient.get = jest.fn(() => of(mockBlob));

            const expectedBase64 = 'data:image/jpeg;base64,mockPhotoData';
            const mockFileReader = {
                readAsDataURL: jest.fn(function(this: any) {
                    // Immediately trigger onloadend
                    setTimeout(() => {
                        if (this.onloadend) {
                            this.onloadend();
                        }
                    }, 0);
                }),
                result: expectedBase64,
                onloadend: null as any,
                onerror: null as any
            };

            global.FileReader = jest.fn(() => mockFileReader) as any;

            const result = await service.getUserPhoto();

            expect(mockFileReader.readAsDataURL).toHaveBeenCalledWith(mockBlob);
            expect(result).toBe(expectedBase64);
        });

        it('should return empty string when response is null', async () => {
            const mockToken = 'mock-token-123';
            localStorage.setItem('msal.idtoken', mockToken);

            mockHttpClient.get = jest.fn(() => of(null));

            const result = await service.getUserPhoto();

            expect(result).toBe('');
        });

        it('should return empty string when response is undefined', async () => {
            const mockToken = 'mock-token-123';
            localStorage.setItem('msal.idtoken', mockToken);

            mockHttpClient.get = jest.fn(() => of(undefined));

            const result = await service.getUserPhoto();

            expect(result).toBe('');
        });

        it('should reject when FileReader fails', async () => {
            const mockToken = 'mock-token-123';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockBlob = new Blob(['test'], { type: 'image/jpeg' });
            mockHttpClient.get = jest.fn(() => of(mockBlob));

            const mockFileReader = {
                readAsDataURL: jest.fn(function(this: any) {
                    // Immediately trigger onerror
                    setTimeout(() => {
                        if (this.onerror) {
                            this.onerror();
                        }
                    }, 0);
                }),
                result: null,
                onloadend: null as any,
                onerror: null as any
            };

            global.FileReader = jest.fn(() => mockFileReader) as any;

            await expect(service.getUserPhoto()).rejects.toThrow('FileReader failed');
        });

        it('should reject when HTTP request fails', async () => {
            const mockToken = 'mock-token-123';
            localStorage.setItem('msal.idtoken', mockToken);

            const errorResponse = { status: 404, message: 'Photo not found' };
            mockHttpClient.get = jest.fn(() => throwError(() => errorResponse));

            await expect(service.getUserPhoto()).rejects.toEqual(errorResponse);
        });

        it('should handle network errors', async () => {
            const mockToken = 'mock-token-123';
            localStorage.setItem('msal.idtoken', mockToken);

            const networkError = new Error('Network error');
            mockHttpClient.get = jest.fn(() => throwError(() => networkError));

            await expect(service.getUserPhoto()).rejects.toThrow('Network error');
        });
    });

    describe('getUserGroups', () => {
        it('should return null when no token exists', async () => {
            localStorage.removeItem('msal.idtoken');

            const result = await service.getUserGroups('TestRole');

            expect(result).toBeNull();
            expect(mockHttpClient.get).not.toHaveBeenCalled();
        });

        it('should call Microsoft Graph API with correct URL and headers', async () => {
            const mockToken = 'mock-token-456';
            const role = 'AdminRole';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockResponse = { value: [{ id: '1', displayName: 'AdminRole-Group1' }] };
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            await service.getUserGroups(role);

            const expectedUrl = `https://graph.microsoft.com/v1.0/me/transitiveMemberOf/microsoft.graph.group?$count=true&$orderby=displayName&$filter=startswith(displayName, '${role}')`;
            
            expect(mockHttpClient.get).toHaveBeenCalledWith(
                expectedUrl,
                expect.objectContaining({
                    headers: expect.any(HttpHeaders)
                })
            );

            const callArgs = mockHttpClient.get.mock.calls[0];
            const headers = callArgs[1].headers as HttpHeaders;
            expect(headers.get('Authorization')).toBe(`Bearer ${mockToken}`);
            expect(headers.get('ConsistencyLevel')).toBe('eventual');
        });

        it('should return groups data on successful request', async () => {
            const mockToken = 'mock-token-456';
            const role = 'DeveloperRole';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockResponse = { 
                value: [
                    { id: '1', displayName: 'DeveloperRole-Team1' },
                    { id: '2', displayName: 'DeveloperRole-Team2' }
                ]
            };
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            const result = await service.getUserGroups(role);

            expect(result).toEqual(mockResponse);
            expect(result.value).toHaveLength(2);
        });

        it('should handle empty groups response', async () => {
            const mockToken = 'mock-token-456';
            const role = 'NonExistentRole';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockResponse = { value: [] };
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            const result = await service.getUserGroups(role);

            expect(result).toEqual(mockResponse);
            expect(result.value).toHaveLength(0);
        });

        it('should handle role with special characters', async () => {
            const mockToken = 'mock-token-456';
            const role = 'Test-Role_123';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockResponse = { value: [{ id: '1', displayName: 'Test-Role_123-Group' }] };
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            await service.getUserGroups(role);

            const expectedUrl = `https://graph.microsoft.com/v1.0/me/transitiveMemberOf/microsoft.graph.group?$count=true&$orderby=displayName&$filter=startswith(displayName, '${role}')`;
            expect(mockHttpClient.get).toHaveBeenCalledWith(
                expectedUrl,
                expect.any(Object)
            );
        });

        it('should throw error when HTTP request fails with 401', async () => {
            const mockToken = 'mock-token-456';
            const role = 'AdminRole';
            localStorage.setItem('msal.idtoken', mockToken);

            const errorResponse = { status: 401, message: 'Unauthorized' };
            mockHttpClient.get = jest.fn(() => throwError(() => errorResponse));

            await expect(service.getUserGroups(role)).rejects.toEqual(errorResponse);
        });

        it('should throw error when HTTP request fails with 403', async () => {
            const mockToken = 'mock-token-456';
            const role = 'AdminRole';
            localStorage.setItem('msal.idtoken', mockToken);

            const errorResponse = { status: 403, message: 'Forbidden' };
            mockHttpClient.get = jest.fn(() => throwError(() => errorResponse));

            await expect(service.getUserGroups(role)).rejects.toEqual(errorResponse);
        });

        it('should throw error when HTTP request fails with 500', async () => {
            const mockToken = 'mock-token-456';
            const role = 'AdminRole';
            localStorage.setItem('msal.idtoken', mockToken);

            const errorResponse = { status: 500, message: 'Internal Server Error' };
            mockHttpClient.get = jest.fn(() => throwError(() => errorResponse));

            await expect(service.getUserGroups(role)).rejects.toEqual(errorResponse);
        });

        it('should handle network errors', async () => {
            const mockToken = 'mock-token-456';
            const role = 'AdminRole';
            localStorage.setItem('msal.idtoken', mockToken);

            const networkError = new Error('Network connection failed');
            mockHttpClient.get = jest.fn(() => throwError(() => networkError));

            await expect(service.getUserGroups(role)).rejects.toThrow('Network connection failed');
        });

        it('should handle null role parameter', async () => {
            const mockToken = 'mock-token-456';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockResponse = { value: [] };
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            await service.getUserGroups(null);

            const expectedUrl = `https://graph.microsoft.com/v1.0/me/transitiveMemberOf/microsoft.graph.group?$count=true&$orderby=displayName&$filter=startswith(displayName, 'null')`;
            expect(mockHttpClient.get).toHaveBeenCalledWith(
                expectedUrl,
                expect.any(Object)
            );
        });

        it('should handle empty string role parameter', async () => {
            const mockToken = 'mock-token-456';
            localStorage.setItem('msal.idtoken', mockToken);

            const mockResponse = { value: [] };
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            await service.getUserGroups('');

            const expectedUrl = `https://graph.microsoft.com/v1.0/me/transitiveMemberOf/microsoft.graph.group?$count=true&$orderby=displayName&$filter=startswith(displayName, '')`;
            expect(mockHttpClient.get).toHaveBeenCalledWith(
                expectedUrl,
                expect.any(Object)
            );
        });
    });
});
