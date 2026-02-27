import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { Router } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { Subject } from 'rxjs';
import { MsalBroadcastService, MsalService } from '@azure/msal-angular';
import { InteractionStatus, AccountInfo } from '@azure/msal-browser';
import { HttpClientTestingModule } from '@angular/common/http/testing';

import { AppComponent } from '~/core/app.component';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';
import { GraphService } from '~/core/services/graph.service';
import { AppSettings } from '~/core/models/appsettings';
import { AppConfig } from '~/core/models/appconfig';

// Mock Variables and Sessions utilities
jest.mock('~/core/classes/user/variables', () => ({
    Variables: {
        clear: jest.fn(),
        get: jest.fn(),
        set: jest.fn()
    }
}));

jest.mock('~/core/utils/sessions', () => ({
    Sessions: {
        getSessionId: jest.fn().mockReturnValue('session-123')
    }
}));

import { Variables } from '~/core/classes/user/variables';
import { Sessions } from '~/core/utils/sessions';

describe('AppComponent', () => {
    let component: AppComponent;
    let fixture: ComponentFixture<AppComponent>;
    let mockRouter: any;
    let mockAuthService: any;
    let mockMsalBroadcastService: any;
    let mockGraphService: any;
    let mockAppConfigService: any;
    let mockAppSettingsService: any;
    let mockActivityService: any;
    let inProgressSubject: Subject<InteractionStatus>;

    const mockAppConfig: AppConfig = new AppConfig();
    mockAppConfig.environment = 'test';
    mockAppConfig.tenantId = 'tenant-123';
    mockAppConfig.clientId = 'client-123';
    mockAppConfig.baseUrl = 'https://test.pge.com';
    mockAppConfig.apiUrl = 'https://api.test.pge.com';

    const mockAppSettings: AppSettings = new AppSettings();
    mockAppSettings.title = 'PAIGE';
    mockAppSettings.version = '1.0.0';
    mockAppSettings.openAccess = false;
    mockAppSettings.showNav = true;
    mockAppSettings.showFooter = true;
    mockAppSettings.supportLink = 'https://support.test.com';
    mockAppSettings.user = null;
    mockAppSettings.roles = ['role1', 'role2'];

    const mockAccount: AccountInfo = {
        homeAccountId: '123',
        environment: 'test',
        tenantId: 'tenant123',
        username: 'test@pge.com',
        localAccountId: 'local123',
        name: 'Doe, John (Contractor)',
        idToken: 'mock-token-value'
    } as AccountInfo;

    beforeEach(async () => {
        inProgressSubject = new Subject<InteractionStatus>();

        // Mock Router
        mockRouter = {
            navigate: jest.fn().mockResolvedValue(true),
            url: '/dashboard'
        };

        // Mock MSAL services
        mockAuthService = {
            instance: {
                getActiveAccount: jest.fn(),
                getAllAccounts: jest.fn(),
                setActiveAccount: jest.fn()
            }
        };

        mockMsalBroadcastService = {
            inProgress$: inProgressSubject.asObservable()
        };

        // Mock other services
        mockGraphService = {
            getUserGroups: jest.fn()
        };

        mockAppConfigService = {
            getConfig: jest.fn().mockResolvedValue({ ...mockAppConfig })
        };

        mockAppSettingsService = {
            getSettings: jest.fn().mockResolvedValue({ ...mockAppSettings }),
            saveSettings: jest.fn().mockResolvedValue(undefined)
        };

        mockActivityService = {
            SaveActivity: jest.fn().mockResolvedValue(undefined)
        };

        await TestBed.configureTestingModule({
            imports: [AppComponent, HttpClientTestingModule],
            providers: [
                { provide: Router, useValue: mockRouter },
                { provide: MsalService, useValue: mockAuthService },
                { provide: MsalBroadcastService, useValue: mockMsalBroadcastService },
                { provide: GraphService, useValue: mockGraphService },
                { provide: AppConfigService, useValue: mockAppConfigService },
                { provide: AppSettingsService, useValue: mockAppSettingsService },
                { provide: ActivityService, useValue: mockActivityService }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        })
        .overrideComponent(AppComponent, {
            set: {
                providers: [
                    { provide: ActivityService, useValue: mockActivityService },
                    { provide: AppSettingsService, useValue: mockAppSettingsService },
                    { provide: GraphService, useValue: mockGraphService }
                ]
            }
        })
        .compileComponents();

        // Reset mocks
        (Variables.clear as jest.Mock).mockClear();
        (Variables.get as jest.Mock).mockReturnValue(null);
        (Variables.set as jest.Mock).mockClear();
        (Sessions.getSessionId as jest.Mock).mockReturnValue('session-123');

        // Mock sessionStorage
        const configData = JSON.stringify(mockAppConfig);
        jest.spyOn(Storage.prototype, 'setItem').mockImplementation();
        jest.spyOn(Storage.prototype, 'getItem').mockImplementation((key: string) => {
            if (key === '_config') return configData;
            return null;
        });
    });

    afterEach(() => {
        jest.clearAllMocks();
        jest.restoreAllMocks();
    });

    describe('Constructor', () => {
        it('should create the component', () => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;

            expect(component).toBeTruthy();
        });

        it('should initialize with default values', () => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;

            expect(component.env).toBe('');
            expect(component.error).toBe('');
            expect(component.title).toBe('');
            expect(component.version).toBe('');
            expect(component.expand).toBe(false);
            expect(component.showNav).toBe(true);
            expect(component.showFooter).toBe(true);
            expect(component.layoutCssClass).toBe('');
            expect(component.isLoggedIn).toBe(false);
            expect(component.isLoading).toBe(true);
        });

        it('should clear __allowNavigate__ variable on construction', () => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;

            expect(Variables.clear).toHaveBeenCalledWith('__allowNavigate__');
        });

        it('should set globalThis.onbeforeunload to null', () => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;

            expect(globalThis.onbeforeunload).toBeNull();
        });
    });

    describe('ngOnDestroy', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;
        });

        it('should complete the destroying subject', () => {
            const nextSpy = jest.spyOn(component['_destroying$'], 'next');
            const completeSpy = jest.spyOn(component['_destroying$'], 'complete');

            component.ngOnDestroy();

            expect(nextSpy).toHaveBeenCalledWith(undefined);
            expect(completeSpy).toHaveBeenCalled();
        });
    });

    describe('onBeforeUnload', () => {
        let mockEvent: Event;

        beforeEach(() => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;
            mockEvent = new Event('beforeunload');
            jest.spyOn(mockEvent, 'preventDefault');
            globalThis.confirm = jest.fn();
            component['appSettings'] = { ...mockAppSettings };
            component['appSettings'].user = { ...mockAccount };
        });

        it('should prevent navigation when __allowNavigate__ is false and user cancels', () => {
            (Variables.get as jest.Mock).mockReturnValue('false');
            (globalThis.confirm as jest.Mock).mockReturnValue(false);

            component.onBeforeUnload(mockEvent);

            expect(mockEvent.preventDefault).toHaveBeenCalled();
            expect(mockActivityService.SaveActivity).not.toHaveBeenCalled();
        });

        it('should allow navigation when __allowNavigate__ is false and user confirms', () => {
            (Variables.get as jest.Mock).mockReturnValue('false');
            (globalThis.confirm as jest.Mock).mockReturnValue(true);

            component.onBeforeUnload(mockEvent);

            expect(Variables.clear).toHaveBeenCalledWith('__allowNavigate__');
            expect(mockActivityService.SaveActivity).toHaveBeenCalled();
        });

        it('should allow navigation when __allowNavigate__ is not set', () => {
            (Variables.get as jest.Mock).mockReturnValue(null);

            component.onBeforeUnload(mockEvent);

            expect(Variables.clear).toHaveBeenCalledWith('__allowNavigate__');
            expect(mockActivityService.SaveActivity).toHaveBeenCalled();
            expect(mockEvent.preventDefault).not.toHaveBeenCalled();
        });

        it('should use "Unknown" username when user is null', () => {
            (Variables.get as jest.Mock).mockReturnValue(null);
            component['appSettings'].user = null;

            component.onBeforeUnload(mockEvent);

            expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
                expect.objectContaining({
                    Username: 'Unknown'
                })
            );
        });

        it('should save activity with username when user exists', () => {
            (Variables.get as jest.Mock).mockReturnValue(null);

            component.onBeforeUnload(mockEvent);

            expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
                expect.objectContaining({
                    Username: 'test@pge.com',
                    SessionId: 'session-123',
                    Event: '_exit_',
                    Data: null
                })
            );
        });

        it('should include ActivityDt in saved activity', () => {
            (Variables.get as jest.Mock).mockReturnValue(null);

            component.onBeforeUnload(mockEvent);

            expect(mockActivityService.SaveActivity).toHaveBeenCalledWith(
                expect.objectContaining({
                    ActivityDt: expect.any(Date)
                })
            );
        });
    });

    describe('setLayoutClass', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;
        });

        it('should set layout class to expand when empty and change is true', () => {
            component.layoutCssClass = '';

            component.setLayoutClass(true);

            expect(component.layoutCssClass).toBe('expand');
            expect(Variables.set).toHaveBeenCalledWith('Nav.LayoutCssClass', 'expand');
        });

        it('should clear layout class when expand and change is true', () => {
            component.layoutCssClass = 'expand';

            component.setLayoutClass(true);

            expect(component.layoutCssClass).toBe('');
            expect(component.expand).toBe(false);
        });

        it('should not change layout class when change is false', () => {
            component.layoutCssClass = 'test-class';

            component.setLayoutClass(false);

            expect(component.layoutCssClass).toBe('test-class');
        });

        it('should set expand to false immediately when layout class is empty', () => {
            component.layoutCssClass = 'expand';
            component.expand = true;

            component.setLayoutClass(true);

            expect(component.expand).toBe(false);
        });

        it('should set expand to true after timeout when layout class is not empty', fakeAsync(() => {
            component.layoutCssClass = '';
            component.expand = false;

            component.setLayoutClass(true);

            expect(component.expand).toBe(false);

            tick(100);

            expect(component.expand).toBe(true);
        }));
    });

    describe('reloadPage', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;
        });

        it('should navigate to current URL when no page specified', async () => {
            Object.defineProperty(mockRouter, 'url', {
                value: '/current-page',
                writable: false,
                configurable: true
            });

            await component.reloadPage();

            expect(mockRouter.navigate).toHaveBeenCalledWith(['/current-page']);
        });

        it('should navigate to specified page', async () => {
            await component.reloadPage('/specific-page');

            expect(mockRouter.navigate).toHaveBeenCalledWith(['/specific-page']);
        });
    });

    describe('Alert Methods', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;
        });

        it('should reset all alert properties to defaults', () => {
            component.showAlert = true;
            component.alertTitle = 'Custom Title';
            component.alertMessage = 'Custom Message';
            component.alertList = 'Item 1, Item 2';
            component.alertContinueText = 'Continue';
            component.alertCancelText = 'Cancel';

            component.alertReset();

            expect(component.showAlert).toBe(false);
            expect(component.alertTitle).toBe('Alert');
            expect(component.alertMessage).toBe('');
            expect(component.alertList).toBe('');
            expect(component.alertContinueText).toBe('OK');
            expect(component.alertCancelText).toBe('');
        });

        it('should call alertReset on alertContinue', () => {
            const resetSpy = jest.spyOn(component, 'alertReset');

            component.alertContinue();

            expect(resetSpy).toHaveBeenCalled();
        });

        it('should call alertReset on alertCancel', () => {
            const resetSpy = jest.spyOn(component, 'alertReset');

            component.alertCancel();

            expect(resetSpy).toHaveBeenCalled();
        });
    });

    describe('Modal Property', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(AppComponent);
            component = fixture.componentInstance;
        });

        it('should initialize modal as undefined', () => {
            expect(component.modal).toBeUndefined();
        });

        it('should allow setting modal', () => {
            const mockModal = {
                type: {} as any,
                inputs: { test: 'value' },
                outputs: { close: jest.fn() }
            };

            component.modal = mockModal;

            expect(component.modal).toBe(mockModal);
        });
    });
});
