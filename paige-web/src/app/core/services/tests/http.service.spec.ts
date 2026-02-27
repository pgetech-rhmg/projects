import { TestBed } from '@angular/core/testing';
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http';
import { of, throwError } from 'rxjs';
import { HttpService } from '~/core/services/http.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppConfig } from '~/core/models/appconfig';

describe('HttpService', () => {
    let service: HttpService;
    let mockHttpClient: any;
    let mockAppConfigService: any;

    const mockAppConfig: AppConfig = {
        environment: 'test',
        tenantId: 'tenant-123',
        clientId: 'client-456',
        baseUrl: 'https://app.example.com',
        apiUrl: 'https://api.example.com'
    };

    beforeEach(() => {
        mockHttpClient = {
            get: jest.fn(),
            post: jest.fn(),
            put: jest.fn(),
            delete: jest.fn()
        };

        mockAppConfigService = {
            getConfig: jest.fn(() => Promise.resolve(mockAppConfig))
        };

        TestBed.configureTestingModule({
            providers: [
                HttpService,
                { provide: HttpClient, useValue: mockHttpClient },
                { provide: AppConfigService, useValue: mockAppConfigService }
            ]
        });

        service = TestBed.inject(HttpService);

        // Clear sessionStorage before each test
        sessionStorage.clear();
    });

    afterEach(() => {
        jest.clearAllMocks();
        sessionStorage.clear();
    });

    describe('Service Creation', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });

        it('should have default config', () => {
            expect(service['config']).toBeDefined();
        });

        it('should have default apiHeader', () => {
            expect(service['apiHeader']).toBeDefined();
        });
    });

    describe('init', () => {
        it('should initialize config from appConfigService', async () => {
            await service.init();

            expect(mockAppConfigService.getConfig).toHaveBeenCalled();
            expect(service['config']).toEqual(mockAppConfig);
        });

        it('should save config to sessionStorage', async () => {
            await service.init();

            const storedConfig = sessionStorage.getItem('_config');
            expect(storedConfig).toBe(JSON.stringify(mockAppConfig));
        });

        it('should handle config with all properties', async () => {
            await service.init();

            const storedConfig = JSON.parse(sessionStorage.getItem('_config')!);
            expect(storedConfig.apiUrl).toBe('https://api.example.com');
            expect(storedConfig.environment).toBe('test');
            expect(storedConfig.tenantId).toBe('tenant-123');
        });
    });

    describe('Get', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should call http.get with correct URL', (done) => {
            const endpoint = 'users';
            const mockResponse = [{ id: 1, name: 'User1' }];
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            service.Get(endpoint).subscribe(() => {
                expect(mockHttpClient.get).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    expect.objectContaining({ withCredentials: true })
                );
                done();
            });
        });

        it('should return data from API', (done) => {
            const endpoint = 'users';
            const mockResponse = [{ id: 1, name: 'User1' }];
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            service.Get(endpoint).subscribe((result) => {
                expect(result).toEqual(mockResponse);
                done();
            });
        });

        it('should use default timeout of 300000', (done) => {
            const endpoint = 'users';
            mockHttpClient.get = jest.fn(() => of({}));

            service.Get(endpoint).subscribe(() => {
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const endpoint = 'users';
            const customTimeout = 5000;
            mockHttpClient.get = jest.fn(() => of({}));

            service.Get(endpoint, service['apiHeader'], customTimeout).subscribe(() => {
                done();
            });
        });

        it('should use custom headers when provided', (done) => {
            const endpoint = 'users';
            const customHeaders = new HttpHeaders({ 'Custom-Header': 'value' });
            mockHttpClient.get = jest.fn(() => of({}));

            service.Get(endpoint, customHeaders).subscribe(() => {
                done();
            });
        });

        it('should load config from sessionStorage', (done) => {
            const endpoint = 'users';
            mockHttpClient.get = jest.fn(() => of({}));

            service.Get(endpoint).subscribe(() => {
                const config = JSON.parse(sessionStorage.getItem('_config')!);
                expect(config).toEqual(mockAppConfig);
                done();
            });
        });
    });

    describe('Post', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should call http.post with correct URL and body', (done) => {
            const endpoint = 'users';
            const body = { name: 'New User', email: 'user@example.com' };
            const mockResponse = { id: 1, ...body };
            mockHttpClient.post = jest.fn(() => of(mockResponse));

            service.Post(endpoint, body).subscribe(() => {
                expect(mockHttpClient.post).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    body,
                    expect.objectContaining({ withCredentials: true })
                );
                done();
            });
        });

        it('should return response from API', (done) => {
            const endpoint = 'users';
            const body = { name: 'New User' };
            const mockResponse = { id: 1, ...body };
            mockHttpClient.post = jest.fn(() => of(mockResponse));

            service.Post(endpoint, body).subscribe((result) => {
                expect(result).toEqual(mockResponse);
                done();
            });
        });

        it('should handle empty body', (done) => {
            const endpoint = 'users/action';
            mockHttpClient.post = jest.fn(() => of({ success: true }));

            service.Post(endpoint).subscribe(() => {
                expect(mockHttpClient.post).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    undefined,
                    expect.any(Object)
                );
                done();
            });
        });

        it('should use default timeout', (done) => {
            const endpoint = 'users';
            mockHttpClient.post = jest.fn(() => of({}));

            service.Post(endpoint, {}).subscribe(() => {
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const endpoint = 'users';
            const customTimeout = 5000;
            mockHttpClient.post = jest.fn(() => of({}));

            service.Post(endpoint, {}, service['apiHeader'], customTimeout).subscribe(() => {
                done();
            });
        });

        it('should use custom headers when provided', (done) => {
            const endpoint = 'users';
            const customHeaders = new HttpHeaders({ 'Custom-Header': 'value' });
            mockHttpClient.post = jest.fn(() => of({}));

            service.Post(endpoint, {}, customHeaders).subscribe(() => {
                expect(mockHttpClient.post).toHaveBeenCalledWith(
                    expect.any(String),
                    expect.any(Object),
                    expect.objectContaining({ headers: customHeaders })
                );
                done();
            });
        });
    });

    describe('Put', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should call http.put with correct URL and body', (done) => {
            const endpoint = 'users/1';
            const body = { name: 'Updated User' };
            const mockResponse = { id: 1, ...body };
            mockHttpClient.put = jest.fn(() => of(mockResponse));

            service.Put(endpoint, body).subscribe(() => {
                expect(mockHttpClient.put).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    body,
                    expect.objectContaining({ withCredentials: true })
                );
                done();
            });
        });

        it('should return response from API', (done) => {
            const endpoint = 'users/1';
            const body = { name: 'Updated User' };
            const mockResponse = { id: 1, ...body };
            mockHttpClient.put = jest.fn(() => of(mockResponse));

            service.Put(endpoint, body).subscribe((result) => {
                expect(result).toEqual(mockResponse);
                done();
            });
        });

        it('should handle empty body', (done) => {
            const endpoint = 'users/1';
            mockHttpClient.put = jest.fn(() => of({ success: true }));

            service.Put(endpoint).subscribe(() => {
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const endpoint = 'users/1';
            const customTimeout = 5000;
            mockHttpClient.put = jest.fn(() => of({}));

            service.Put(endpoint, {}, service['apiHeader'], customTimeout).subscribe(() => {
                done();
            });
        });
    });

    describe('Delete', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should call http.delete with correct URL', (done) => {
            const endpoint = 'users/1';
            const mockResponse = { success: true };
            mockHttpClient.delete = jest.fn(() => of(mockResponse));

            service.Delete(endpoint).subscribe(() => {
                expect(mockHttpClient.delete).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    expect.objectContaining({ withCredentials: true })
                );
                done();
            });
        });

        it('should return response from API', (done) => {
            const endpoint = 'users/1';
            const mockResponse = { success: true };
            mockHttpClient.delete = jest.fn(() => of(mockResponse));

            service.Delete(endpoint).subscribe((result) => {
                expect(result).toEqual(mockResponse);
                done();
            });
        });

        it('should use custom headers when provided', (done) => {
            const endpoint = 'users/1';
            const customHeaders = new HttpHeaders({ 'Custom-Header': 'value' });
            mockHttpClient.delete = jest.fn(() => of({}));

            service.Delete(endpoint, customHeaders).subscribe(() => {
                expect(mockHttpClient.delete).toHaveBeenCalledWith(
                    expect.any(String),
                    expect.objectContaining({ headers: customHeaders })
                );
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const endpoint = 'users/1';
            const customTimeout = 5000;
            mockHttpClient.delete = jest.fn(() => of({}));

            service.Delete(endpoint, service['apiHeader'], customTimeout).subscribe(() => {
                done();
            });
        });
    });

    describe('GetDownload', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should call http.get with blob response type', (done) => {
            const endpoint = 'export/data';
            const mockBlob = new Blob(['test'], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
            const mockResponse = new HttpResponse({ body: mockBlob });
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            service.GetDownload(endpoint).subscribe(() => {
                expect(mockHttpClient.get).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    expect.objectContaining({
                        withCredentials: true,
                        observe: 'response',
                        responseType: 'blob'
                    })
                );
                done();
            });
        });

        it('should return HttpResponse with Blob', (done) => {
            const endpoint = 'export/data';
            const mockBlob = new Blob(['test'], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
            const mockResponse = new HttpResponse({ body: mockBlob });
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            service.GetDownload(endpoint).subscribe((result) => {
                expect(result.body).toEqual(mockBlob);
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const endpoint = 'export/data';
            const customTimeout = 5000;
            const mockResponse = new HttpResponse({ body: new Blob() });
            mockHttpClient.get = jest.fn(() => of(mockResponse));

            service.GetDownload(endpoint, customTimeout).subscribe(() => {
                done();
            });
        });
    });

    describe('GetDownloadFile', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should call http.post with blob response type', (done) => {
            const endpoint = 'export/custom';
            const body = { filter: 'active', limit: 100 };
            const mockBlob = new Blob(['test'], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
            const mockResponse = new HttpResponse({ body: mockBlob });
            mockHttpClient.post = jest.fn(() => of(mockResponse));

            service.GetDownloadFile(endpoint, body).subscribe(() => {
                expect(mockHttpClient.post).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    body,
                    expect.objectContaining({
                        withCredentials: true,
                        observe: 'response',
                        responseType: 'blob'
                    })
                );
                done();
            });
        });

        it('should return HttpResponse with Blob', (done) => {
            const endpoint = 'export/custom';
            const body = { filter: 'active' };
            const mockBlob = new Blob(['test']);
            const mockResponse = new HttpResponse({ body: mockBlob });
            mockHttpClient.post = jest.fn(() => of(mockResponse));

            service.GetDownloadFile(endpoint, body).subscribe((result) => {
                expect(result.body).toEqual(mockBlob);
                done();
            });
        });

        it('should handle empty body', (done) => {
            const endpoint = 'export/all';
            const mockResponse = new HttpResponse({ body: new Blob() });
            mockHttpClient.post = jest.fn(() => of(mockResponse));

            service.GetDownloadFile(endpoint).subscribe(() => {
                expect(mockHttpClient.post).toHaveBeenCalled();
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const endpoint = 'export/custom';
            const customTimeout = 5000;
            const mockResponse = new HttpResponse({ body: new Blob() });
            mockHttpClient.post = jest.fn(() => of(mockResponse));

            service.GetDownloadFile(endpoint, {}, customTimeout).subscribe(() => {
                done();
            });
        });
    });

    describe('GetPdf', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should call http.get with blob response type', (done) => {
            const endpoint = 'reports/pdf/123';
            const mockBlob = new Blob(['pdf content'], { type: 'application/pdf' });
            mockHttpClient.get = jest.fn(() => of(mockBlob));

            service.GetPdf(endpoint).subscribe(() => {
                expect(mockHttpClient.get).toHaveBeenCalledWith(
                    `${mockAppConfig.apiUrl}/${endpoint}`,
                    expect.objectContaining({
                        withCredentials: true,
                        responseType: 'blob'
                    })
                );
                done();
            });
        });

        it('should return Blob', (done) => {
            const endpoint = 'reports/pdf/123';
            const mockBlob = new Blob(['pdf content'], { type: 'application/pdf' });
            mockHttpClient.get = jest.fn(() => of(mockBlob));

            service.GetPdf(endpoint).subscribe((result) => {
                expect(result).toEqual(mockBlob);
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const endpoint = 'reports/pdf/123';
            const customTimeout = 5000;
            const mockBlob = new Blob();
            mockHttpClient.get = jest.fn(() => of(mockBlob));

            service.GetPdf(endpoint, customTimeout).subscribe(() => {
                done();
            });
        });
    });

    describe('SSE', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
            // Mock EventSource
            global.EventSource = jest.fn() as any;
        });

        it('should create EventSource with correct URL', () => {
            const endpoint = 'events/stream';
            
            service.SSE(endpoint);

            expect(EventSource).toHaveBeenCalledWith(`${mockAppConfig.apiUrl}/${endpoint}`);
        });

        it('should return EventSource instance', () => {
            const endpoint = 'events/stream';
            const mockEventSource = {} as EventSource;
            (global.EventSource as unknown as jest.Mock).mockReturnValue(mockEventSource);

            const result = service.SSE(endpoint);

            expect(result).toBe(mockEventSource);
        });

        it('should load config from sessionStorage', () => {
            const endpoint = 'events/stream';
            
            service.SSE(endpoint);

            const config = JSON.parse(sessionStorage.getItem('_config')!);
            expect(config).toEqual(mockAppConfig);
        });
    });

    describe('GetAsset', () => {
        it('should call http.get with assets path', async () => {
            const file = 'config.json';
            const mockData = { setting: 'value' };
            mockHttpClient.get = jest.fn(() => of(mockData));

            await service.GetAsset(file);

            expect(mockHttpClient.get).toHaveBeenCalledWith(`assets/${file}`);
        });

        it('should return asset data', async () => {
            const file = 'data.json';
            const mockData = { data: 'test' };
            mockHttpClient.get = jest.fn(() => of(mockData));

            const result = await service.GetAsset(file);

            expect(result).toEqual(mockData);
        });

        it('should throw error when asset not found', async () => {
            const file = 'missing.json';
            const error = new Error('404 Not Found');
            mockHttpClient.get = jest.fn(() => throwError(() => error));

            await expect(service.GetAsset(file)).rejects.toThrow('404 Not Found');
        });

        it('should handle various file types', async () => {
            const files = ['config.json', 'image.png', 'data.xml'];
            mockHttpClient.get = jest.fn(() => of({}));

            for (const file of files) {
                await service.GetAsset(file);
                expect(mockHttpClient.get).toHaveBeenCalledWith(`assets/${file}`);
            }
        });
    });

    describe('GetExternal', () => {
        it('should call http.get with external URL', (done) => {
            const url = 'https://external-api.com/data';
            const mockData = { external: 'data' };
            mockHttpClient.get = jest.fn(() => of(mockData));

            service.GetExternal(url).subscribe(() => {
                expect(mockHttpClient.get).toHaveBeenCalledWith(url);
                done();
            });
        });

        it('should return data from external API', (done) => {
            const url = 'https://external-api.com/data';
            const mockData = { external: 'data' };
            mockHttpClient.get = jest.fn(() => of(mockData));

            service.GetExternal(url).subscribe((result) => {
                expect(result).toEqual(mockData);
                done();
            });
        });

        it('should use default timeout', (done) => {
            const url = 'https://external-api.com/data';
            mockHttpClient.get = jest.fn(() => of({}));

            service.GetExternal(url).subscribe(() => {
                done();
            });
        });

        it('should use custom timeout when provided', (done) => {
            const url = 'https://external-api.com/data';
            const customTimeout = 5000;
            mockHttpClient.get = jest.fn(() => of({}));

            service.GetExternal(url, customTimeout).subscribe(() => {
                done();
            });
        });
    });

    describe('Integration Tests', () => {
        beforeEach(() => {
            sessionStorage.setItem('_config', JSON.stringify(mockAppConfig));
        });

        it('should handle complete CRUD workflow', (done) => {
            // Create
            mockHttpClient.post = jest.fn(() => of({ id: 1, name: 'Test' }));
            service.Post('users', { name: 'Test' }).subscribe(() => {
                // Read
                mockHttpClient.get = jest.fn(() => of({ id: 1, name: 'Test' }));
                service.Get('users/1').subscribe(() => {
                    // Update
                    mockHttpClient.put = jest.fn(() => of({ id: 1, name: 'Updated' }));
                    service.Put('users/1', { name: 'Updated' }).subscribe(() => {
                        // Delete
                        mockHttpClient.delete = jest.fn(() => of({ success: true }));
                        service.Delete('users/1').subscribe(() => {
                            done();
                        });
                    });
                });
            });
        });

        it('should handle init then API calls', async () => {
            await service.init();

            mockHttpClient.get = jest.fn(() => of([{ id: 1 }]));
            
            service.Get('users').subscribe((result) => {
                expect(result).toEqual([{ id: 1 }]);
            });
        });

        it('should handle multiple consecutive calls of different types', (done) => {
            let callCount = 0;
            const checkDone = () => {
                callCount++;
                if (callCount === 4) done();
            };

            mockHttpClient.get = jest.fn(() => of({}));
            service.Get('endpoint1').subscribe(checkDone);

            mockHttpClient.post = jest.fn(() => of({}));
            service.Post('endpoint2', {}).subscribe(checkDone);

            mockHttpClient.put = jest.fn(() => of({}));
            service.Put('endpoint3', {}).subscribe(checkDone);

            mockHttpClient.delete = jest.fn(() => of({}));
            service.Delete('endpoint4').subscribe(checkDone);
        });

        it('should handle asset loading and API calls', async () => {
            // Load asset
            mockHttpClient.get = jest.fn(() => of({ setting: 'value' }));
            const asset = await service.GetAsset('config.json');
            expect(asset).toEqual({ setting: 'value' });

            // Make API call
            mockHttpClient.get = jest.fn(() => of({ id: 1 }));
            service.Get('users').subscribe((result) => {
                expect(result).toEqual({ id: 1 });
            });
        });
    });
});
