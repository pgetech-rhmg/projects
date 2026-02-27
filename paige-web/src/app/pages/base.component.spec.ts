import { TestBed } from '@angular/core/testing';
import { BaseComponent } from './base.component';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';
import { AppConfig } from '~/core/models/appconfig';
import { AppSettings } from '~/core/models/appsettings';
import { Sessions } from '~/core/utils/sessions';

// Mock the Sessions utility
jest.mock('~/core/utils/sessions', () => ({
  Sessions: {
    getSessionId: jest.fn()
  }
}));

describe('BaseComponent', () => {
  let component: BaseComponent;
  let mockAppConfigService: jest.Mocked<AppConfigService>;
  let mockAppSettingsService: jest.Mocked<AppSettingsService>;
  let mockActivityService: jest.Mocked<ActivityService>;
  let mockAppConfig: AppConfig;
  let mockAppSettings: AppSettings;

  beforeEach(async () => {
    // Create mock app config
    mockAppConfig = {
      environment: "",
      tenantId: "",
      clientId: "",
      baseUrl: "",
      apiUrl: ""
    } as AppConfig;

    // Create mock app settings with user
    mockAppSettings = {
      title: "",
      version: "",
      openAccess: true,
      showNav: true,
      showFooter: true,
      supportLink: "",
      user: {
        username: "testuser"
      },
      roles: []
    } as AppSettings;

    // Create mock services
    mockAppConfigService = {
      getConfig: jest.fn().mockResolvedValue(mockAppConfig)
    } as any;

    mockAppSettingsService = {
      getSettings: jest.fn().mockResolvedValue(mockAppSettings)
    } as any;

    mockActivityService = {
      SaveActivity: jest.fn()
    } as any;

    // Configure TestBed
    await TestBed.configureTestingModule({
      imports: [BaseComponent],
      providers: [
        { provide: AppConfigService, useValue: mockAppConfigService },
        { provide: AppSettingsService, useValue: mockAppSettingsService },
        { provide: ActivityService, useValue: mockActivityService }
      ]
    }).compileComponents();

    // Create component instance
    const fixture = TestBed.createComponent(BaseComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Initialization', () => {
    it('should create the component', () => {
      expect(component).toBeTruthy();
    });

    it('should initialize with default values', () => {
      expect(component.appConfig).toBeInstanceOf(AppConfig);
      expect(component.appSettings).toBeInstanceOf(AppSettings);
      expect(component.permissions).toBeUndefined();
      expect(component.title).toBe('');
      expect(component.isLoading).toBe(false);
    });
  });

  describe('initAsync', () => {
    it('should load app config successfully', async () => {
      await component.initAsync();

      expect(mockAppConfigService.getConfig).toHaveBeenCalledTimes(1);
      expect(component.appConfig).toEqual(mockAppConfig);
    });

    it('should load app settings successfully', async () => {
      await component.initAsync();

      expect(mockAppSettingsService.getSettings).toHaveBeenCalledTimes(1);
      expect(component.appSettings).toEqual(mockAppSettings);
    });

    it('should load both config and settings in correct order', async () => {
      await component.initAsync();

      expect(mockAppConfigService.getConfig).toHaveBeenCalledTimes(1);
      expect(mockAppSettingsService.getSettings).toHaveBeenCalledTimes(1);
      expect(component.appConfig).toEqual(mockAppConfig);
      expect(component.appSettings).toEqual(mockAppSettings);
    });

    it('should handle config service errors', async () => {
      const error = new Error('Config loading failed');
      mockAppConfigService.getConfig.mockRejectedValueOnce(error);

      await expect(component.initAsync()).rejects.toThrow('Config loading failed');
    });

    it('should handle settings service errors', async () => {
      const error = new Error('Settings loading failed');
      mockAppSettingsService.getSettings.mockRejectedValueOnce(error);

      await expect(component.initAsync()).rejects.toThrow('Settings loading failed');
    });

    it('should update component properties with loaded data', async () => {
      const customConfig = { ...mockAppConfig, environment: 'production' } as AppConfig;
      const customSettings = {
        ...mockAppSettings,
        user: { username: 'customuser', email: 'custom@test.com' }
      } as AppSettings;

      mockAppConfigService.getConfig.mockResolvedValueOnce(customConfig);
      mockAppSettingsService.getSettings.mockResolvedValueOnce(customSettings);

      await component.initAsync();

      expect(component.appConfig).toEqual(customConfig);
      expect(component.appSettings).toEqual(customSettings);
    });
  });

  describe('getPath', () => {
    it('should return current pathname from window location', () => {
      const mockPathname = '/test/path';
      Object.defineProperty(globalThis, 'location', {
        value: { pathname: mockPathname },
        writable: true,
        configurable: true
      });

      const result = component.getPath();

      expect(result).toBe(mockPathname);
    });

    it('should return root path when at root', () => {
      Object.defineProperty(globalThis, 'location', {
        value: { pathname: '/' },
        writable: true,
        configurable: true
      });

      const result = component.getPath();

      expect(result).toBe('/');
    });

    it('should return complex path with query parameters path', () => {
      Object.defineProperty(globalThis, 'location', {
        value: { pathname: '/dashboard/analytics' },
        writable: true,
        configurable: true
      });

      const result = component.getPath();

      expect(result).toBe('/dashboard/analytics');
    });
  });

  describe('logActivityEvent', () => {
    beforeEach(() => {
      // Set up component with initialized settings
      component.appSettings = mockAppSettings;

      // Mock Sessions.getSessionId
      (Sessions.getSessionId as jest.Mock).mockReturnValue('test-session-123');

      // Mock location pathname
      Object.defineProperty(globalThis, 'location', {
        value: { pathname: '/current/path' },
        writable: true,
        configurable: true
      });

      // Mock Date
      jest.useFakeTimers();
      jest.setSystemTime(new Date('2024-02-06T10:30:00Z'));
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it('should log activity with all parameters provided', () => {
      const view = '/custom/view';
      const action = 'Click';
      const data = 'button-submit';

      component.logActivityEvent(view, action, data);

      expect(mockActivityService.SaveActivity).toHaveBeenCalledTimes(1);
      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith({
        View: view,
        Username: 'testuser',
        SessionId: 'test-session-123',
        Event: action,
        Data: data,
        ActivityDt: new Date('2024-02-06T10:30:00Z')
      });
    });

    it('should use current path when view is null', () => {
      component.logActivityEvent(null, 'View', null);

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          View: '/current/path'
        })
      );
    });

    it('should use default action "View" when not provided', () => {
      component.logActivityEvent('/test/view');

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          Event: 'View'
        })
      );
    });

    it('should use null data when not provided', () => {
      component.logActivityEvent('/test/view', 'Click');

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          Data: null
        })
      );
    });

    it('should use "Unknown" username when user is not set', () => {
      component.appSettings = { user: undefined } as AppSettings;

      component.logActivityEvent('/test/view', 'View', null);

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          Username: 'Unknown'
        })
      );
    });

    it('should use "Unknown" username when user.username is undefined', () => {
      component.appSettings = { user: { email: 'test@test.com' } } as AppSettings;

      component.logActivityEvent('/test/view', 'View', null);

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          Username: 'Unknown'
        })
      );
    });

    it('should retrieve session ID from Sessions utility', () => {
      component.logActivityEvent('/test', 'View', null);

      expect(Sessions.getSessionId).toHaveBeenCalledTimes(1);
      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          SessionId: 'test-session-123'
        })
      );
    });

    it('should set ActivityDt to current date and time', () => {
      const currentDate = new Date('2024-02-06T10:30:00Z');

      component.logActivityEvent('/test', 'View', null);

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          ActivityDt: currentDate
        })
      );
    });

    it('should handle various action types', () => {
      const actions = ['View', 'Click', 'Submit', 'Delete', 'Update'];

      actions.forEach(action => {
        mockActivityService.SaveActivity.mockClear();

        component.logActivityEvent('/test', action, null);

        expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
          expect.objectContaining({
            Event: action
          })
        );
      });
    });

    it('should handle complex data payloads', () => {
      const complexData = JSON.stringify({
        formId: 'form-123',
        fieldCount: 5,
        isValid: true
      });

      component.logActivityEvent('/form/submit', 'Submit', complexData);

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          Data: complexData
        })
      );
    });

    it('should handle empty string view parameter', () => {
      component.logActivityEvent();

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
        expect.objectContaining({
        })
      );
    });

    it('should create complete activity object with all properties', () => {
      const expectedActivity = {
        View: '/dashboard',
        Username: 'testuser',
        SessionId: 'test-session-123',
        Event: 'Navigate',
        Data: 'navigation-data',
        ActivityDt: new Date('2024-02-06T10:30:00Z')
      };

      component.logActivityEvent('/dashboard', 'Navigate', 'navigation-data');

      expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(expectedActivity);
    });
  });

  describe('Service Injection', () => {
    it('should inject AppConfigService', () => {
      expect(component['_appConfigService']).toBe(mockAppConfigService);
    });

    it('should inject AppSettingsService', () => {
      expect(component['_appSettingsService']).toBe(mockAppSettingsService);
    });

    it('should inject ActivityService', () => {
      expect(component['_activityService']).toBe(mockActivityService);
    });
  });

  describe('Property Accessibility', () => {
    it('should have public appConfig property', () => {
      expect(component.appConfig).toBeDefined();
      expect(component.appConfig).toBeInstanceOf(AppConfig);
    });

    it('should have public appSettings property', () => {
      expect(component.appSettings).toBeDefined();
      expect(component.appSettings).toBeInstanceOf(AppSettings);
    });

    it('should have public permissions property', () => {
      expect(component.permissions).toBeUndefined();
    });

    it('should have public title property', () => {
      expect(component.title).toBe('');
    });

    it('should have public isLoading property', () => {
      expect(component.isLoading).toBe(false);
    });

    it('should allow updating public properties', () => {
      component.title = 'Test Title';
      component.isLoading = true;

      expect(component.title).toBe('Test Title');
      expect(component.isLoading).toBe(true);
    });
  });
});
