import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { EventEmitter, NO_ERRORS_SCHEMA } from '@angular/core';

import { NavComponent, NavItem } from './nav.component';

// Mock the imports
jest.mock('~/core/services/appsettings.service', () => ({
    AppSettingsService: jest.fn().mockImplementation(() => ({
        getSettings: jest.fn()
    }))
}));

jest.mock('~/core/models/appsettings', () => ({
    AppSettings: jest.fn().mockImplementation(() => ({
        roles: []
    }))
}));

jest.mock('~/classes/routes/app.routing', () => ({
    appRoutes: []
}));

jest.mock('~/core/classes/user/variables', () => ({
    Variables: {
        get: jest.fn(),
        clear: jest.fn(),
        set: jest.fn()
    }
}));

// Import the mocked classes
import { AppSettingsService } from '~/core/services/appsettings.service';
import { Variables } from '~/core/classes/user/variables';

describe('NavComponent', () => {
    let component: NavComponent;
    let fixture: ComponentFixture<NavComponent>;
    let mockRouter: any;
    let mockAppSettingsService: any;

    const mockRoutes = [
        {
            path: 'home',
            title: 'Home',
            data: { isNav: true, icon: 'home' }
        },
        {
            path: 'admin',
            title: 'Admin',
            data: { isNav: true, icon: 'admin_panel_settings', roles: ['Admin'] }
        },
        {
            path: 'admin/users',
            title: 'Users',
            data: { isSubNav: true, icon: 'people', roles: ['Admin'] }
        },
        {
            path: 'settings',
            title: 'Settings',
            data: { isNav: true, icon: 'settings' }
        },
        {
            path: 'settings/profile',
            title: 'Profile',
            data: { isSubNav: true, icon: 'person' }
        },
        {
            path: 'hidden',
            title: 'Hidden',
            data: { isNav: false, icon: 'visibility_off' }
        }
    ];

    beforeEach(async () => {
        // Create mock router
        mockRouter = {
            navigateByUrl: jest.fn().mockResolvedValue(true),
            url: '/home'
        };

        // Create mock AppSettingsService
        mockAppSettingsService = {
            getSettings: jest.fn()
        };

        // Mock sessionStorage
        const sessionStorageMock = (() => {
            let store: Record<string, string> = {};
            return {
                getItem: jest.fn((key: string) => store[key] || null),
                setItem: jest.fn((key: string, value: string) => { store[key] = value; }),
                removeItem: jest.fn((key: string) => { delete store[key]; }),
                clear: jest.fn(() => { store = {}; })
            };
        })();
        Object.defineProperty(global, 'sessionStorage', { value: sessionStorageMock, writable: true });

        // Mock window.confirm
        global.confirm = jest.fn(() => true);

        // Mock document fullscreen APIs
        Object.defineProperty(document, 'fullscreenElement', {
            writable: true,
            value: null
        });
        document.exitFullscreen = jest.fn().mockResolvedValue(undefined);
        Object.defineProperty(document.documentElement, 'requestFullscreen', {
            writable: true,
            value: jest.fn().mockResolvedValue(undefined)
        });

        await TestBed.configureTestingModule({
            imports: [NavComponent],
            providers: [
                { provide: Router, useValue: mockRouter },
                { provide: AppSettingsService, useValue: mockAppSettingsService }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();

        // Reset all mocks before each test
        jest.clearAllMocks();
        (Variables.get as jest.Mock).mockReturnValue(null);
        (Variables.clear as jest.Mock).mockImplementation();
        sessionStorage.clear();
    });

    describe('Constructor', () => {
        it('should create component', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
        });

        it('should initialize expand as false', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.expand).toBe(false);
        });

        it('should initialize appIcon as "web_asset"', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.appIcon).toBe("web_asset");
        });

        it('should initialize appTitle as "Application Mode"', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.appTitle).toBe("Application Mode");
        });

        it('should initialize menuIcon as "keyboard_double_arrow_right"', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.menuIcon).toBe("keyboard_double_arrow_right");
        });

        it('should initialize activeItem as new NavItem', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.activeItem).toBeInstanceOf(NavItem);
        });

        it('should initialize empty navItems array', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.navItems).toEqual([]);
        });

        it('should initialize empty navSubItems array', () => {
            // Act
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.navSubItems).toEqual([]);
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
            (component as any)._routes = [...mockRoutes];
        });

        it('should call getRoutes and set active item from router url', async () => {
            // Arrange
            mockRouter.url = '/home';
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: [] });
            jest.spyOn(component as any, 'getRoutes').mockResolvedValue(undefined);
            jest.spyOn(component as any, 'setActiveItem').mockImplementation();

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).getRoutes).toHaveBeenCalled();
            expect((component as any).setActiveItem).toHaveBeenCalledTimes(2);
        });

        it('should use sessionStorage redirect when available', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/settings');
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: [] });
            jest.spyOn(component as any, 'getRoutes').mockResolvedValue(undefined);
            jest.spyOn(component as any, 'setActiveItem').mockImplementation();

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(sessionStorage.getItem).toHaveBeenCalledWith('_redirect');
            expect(sessionStorage.removeItem).toHaveBeenCalledWith('_redirect');
            expect((component as any).setActiveItem).toHaveBeenCalledWith(component.navItems, '/settings');
        });

        it('should use router url when no redirect in sessionStorage', async () => {
            // Arrange
            mockRouter.url = '/admin?tab=users';
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: ['Admin'] });
            jest.spyOn(component as any, 'getRoutes').mockResolvedValue(undefined);
            jest.spyOn(component as any, 'setActiveItem').mockImplementation();

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).setActiveItem).toHaveBeenCalledWith(component.navItems, '/admin');
        });

        it('should handle empty sessionStorage redirect', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '');
            mockRouter.url = '/settings';
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: [] });
            jest.spyOn(component as any, 'getRoutes').mockResolvedValue(undefined);
            jest.spyOn(component as any, 'setActiveItem').mockImplementation();

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).setActiveItem).toHaveBeenCalledWith(component.navItems, '/settings');
        });
    });

    describe('toggleMenu', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
        });

        it('should toggle menu to collapsed state', () => {
            // Arrange
            component.setLayoutClass.subscribe = jest.fn();

            // Act
            component.toggleMenu(true);

            // Assert
            expect(component['collapse']).toBe(true);
            expect(component.menuIcon).toBe("keyboard_double_arrow_left");
        });

        it('should toggle menu to expanded state', () => {
            // Arrange
            component['collapse'] = true;

            // Act
            component.toggleMenu();

            // Assert
            expect(component['collapse']).toBe(false);
            expect(component.menuIcon).toBe("keyboard_double_arrow_right");
        });

        it('should emit setLayoutClass event', (done) => {
            // Arrange
            component.setLayoutClass.subscribe(() => {
                // Assert
                done();
            });

            // Act
            component.toggleMenu(true);
        });
    });

    describe('navigateTo', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
        });

        it('should navigate to item url when navigation is allowed', () => {
            // Arrange
            const testItem: NavItem = { title: 'Test', icon: 'test', url: '/test' };
            (Variables.get as jest.Mock).mockReturnValue(null);

            // Act
            component.navigateTo(testItem);

            // Assert
            expect(mockRouter.navigateByUrl).toHaveBeenCalledWith('/test');
            expect(component.activeItem).toBe(testItem);
        });

        it('should show confirmation when __allowNavigate__ is false', () => {
            // Arrange
            const testItem: NavItem = { title: 'Test', icon: 'test', url: '/test' };
            (Variables.get as jest.Mock).mockReturnValue('false');
            (global.confirm as jest.Mock).mockReturnValue(true);

            // Act
            component.navigateTo(testItem);

            // Assert
            expect(global.confirm).toHaveBeenCalledWith('WARNING: Changes have been made. Are you sure you want to leave without saving these changes?');
            expect(mockRouter.navigateByUrl).toHaveBeenCalledWith('/test');
        });

        it('should not navigate when user cancels confirmation', () => {
            // Arrange
            const testItem: NavItem = { title: 'Test', icon: 'test', url: '/test' };
            (Variables.get as jest.Mock).mockReturnValue('false');
            (global.confirm as jest.Mock).mockReturnValue(false);

            // Act
            component.navigateTo(testItem);

            // Assert
            expect(global.confirm).toHaveBeenCalled();
            expect(mockRouter.navigateByUrl).not.toHaveBeenCalled();
            expect(component.activeItem).not.toBe(testItem);
        });

        it('should clear __allowNavigate__ variable when navigating', () => {
            // Arrange
            const testItem: NavItem = { title: 'Test', icon: 'test', url: '/test' };
            (Variables.get as jest.Mock).mockReturnValue(null);

            // Act
            component.navigateTo(testItem);

            // Assert
            expect(Variables.clear).toHaveBeenCalledWith('__allowNavigate__');
        });

        it('should collapse menu if expanded when navigating', (done) => {
            // Arrange
            const testItem: NavItem = { title: 'Test', icon: 'test', url: '/test' };
            component['collapse'] = true;
            (Variables.get as jest.Mock).mockReturnValue(null);

            component.setLayoutClass.subscribe(() => {
                // Assert
                expect(component['collapse']).toBe(false);
                done();
            });

            // Act
            component.navigateTo(testItem);
        });

        it('should not emit setLayoutClass when menu is not collapsed', () => {
            // Arrange
            const testItem: NavItem = { title: 'Test', icon: 'test', url: '/test' };
            component['collapse'] = false;
            (Variables.get as jest.Mock).mockReturnValue(null);
            const emitSpy = jest.spyOn(component.setLayoutClass, 'emit');

            // Act
            component.navigateTo(testItem);

            // Assert
            expect(emitSpy).not.toHaveBeenCalled();
        });
    });

    describe('toggleFullscreen', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
        });

        it('should exit fullscreen when already in fullscreen', () => {
            // Arrange
            Object.defineProperty(document, 'fullscreenElement', {
                writable: true,
                value: document.documentElement
            });

            // Act
            component.toggleFullscreen();

            // Assert
            expect(document.exitFullscreen).toHaveBeenCalled();
            expect(component.appIcon).toBe("web_asset");
            expect(component.appTitle).toBe("Application Mode");
        });

        it('should enter fullscreen when not in fullscreen', () => {
            // Arrange
            Object.defineProperty(document, 'fullscreenElement', {
                writable: true,
                value: null
            });

            // Act
            component.toggleFullscreen();

            // Assert
            expect(document.documentElement.requestFullscreen).toHaveBeenCalled();
            expect(component.appIcon).toBe("iframe");
            expect(component.appTitle).toBe("Web Mode");
        });
    });

    describe('getRoutes (private method)', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
            (component as any)._routes = [...mockRoutes];
        });

        it('should populate navItems with routes that have isNav true', async () => {
            // Arrange
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: [] });

            // Act
            await (component as any).getRoutes();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.navItems).toHaveLength(2); // home and settings (admin needs role)
            expect(component.navItems[0].title).toBe('Home');
            expect(component.navItems[1].title).toBe('Settings');
        });

        it('should include routes with matching roles', async () => {
            // Arrange
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: ['Admin'] });

            // Act
            await (component as any).getRoutes();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.navItems).toHaveLength(3); // home, admin, and settings
            expect(component.navItems.some((item: any) => item.title === 'Admin')).toBe(true);
        });

        it('should exclude routes without matching roles', async () => {
            // Arrange
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: ['User'] });

            // Act
            await (component as any).getRoutes();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.navItems).toHaveLength(2); // home and settings only
            expect(component.navItems.some((item: any) => item.title === 'Admin')).toBe(false);
        });

        it('should not include routes with isNav false', async () => {
            // Arrange
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: [] });

            // Act
            await (component as any).getRoutes();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.navItems.some((item: any) => item.title === 'Hidden')).toBe(false);
        });

        it('should populate navSubItems with sub routes', async () => {
            // Arrange
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: [] });

            // Act
            await (component as any).getRoutes();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.navSubItems).toHaveLength(1); // settings/profile (admin/users needs role)
            expect(component.navSubItems[0].title).toBe('Profile');
            expect(component.navSubItems[0].parent).toBe('Settings');
        });

        it('should include sub routes with matching roles', async () => {
            // Arrange
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: ['Admin'] });

            // Act
            await (component as any).getRoutes();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.navSubItems).toHaveLength(2); // admin/users and settings/profile
            expect(component.navSubItems.some((item: any) => item.title === 'Users')).toBe(true);
        });

        it('should reset navItems and navSubItems before populating', async () => {
            // Arrange
            component.navItems = [{ title: 'Old', icon: 'old', url: '/old' }];
            component.navSubItems = [{ title: 'OldSub', icon: 'old', url: '/old/sub' }];
            mockAppSettingsService.getSettings.mockResolvedValue({ roles: [] });

            // Act
            await (component as any).getRoutes();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.navItems).not.toContainEqual({ title: 'Old', icon: 'old', url: '/old' });
            expect(component.navSubItems).not.toContainEqual({ title: 'OldSub', icon: 'old', url: '/old/sub' });
        });
    });

    describe('getSubRoutes (private method)', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
            (component as any)._routes = [...mockRoutes];
        });

        it('should add sub routes that match parent path', () => {
            // Arrange
            const parent = { path: 'settings', title: 'Settings' };
            const roles: any[] = [];

            // Act
            (component as any).getSubRoutes(parent, roles);

            // Assert
            expect(component.navSubItems).toHaveLength(1);
            expect(component.navSubItems[0].title).toBe('Profile');
        });

        it('should filter sub routes by roles', () => {
            // Arrange
            const parent = { path: 'admin', title: 'Admin' };
            const roles = ['Admin'];

            // Act
            (component as any).getSubRoutes(parent, roles);

            // Assert
            expect(component.navSubItems).toHaveLength(1);
            expect(component.navSubItems[0].title).toBe('Users');
        });

        it('should not add sub routes without matching roles', () => {
            // Arrange
            const parent = { path: 'admin', title: 'Admin' };
            const roles = ['User'];

            // Act
            (component as any).getSubRoutes(parent, roles);

            // Assert
            expect(component.navSubItems).toHaveLength(0);
        });

        it('should not add routes that are not sub routes', () => {
            // Arrange
            const parent = { path: 'home', title: 'Home' };
            const roles: any[] = [];

            // Act
            (component as any).getSubRoutes(parent, roles);

            // Assert
            expect(component.navSubItems).toHaveLength(0);
        });
    });

    describe('setActiveItem (private method)', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
        });

        it('should set active item when url matches', () => {
            // Arrange
            const items = [
                { url: 'home', title: 'Home' },
                { url: 'settings', title: 'Settings' }
            ];

            // Act
            (component as any).setActiveItem(items, '/settings');

            // Assert
            expect(component.activeItem).toEqual({ url: 'settings', title: 'Settings' });
        });

        it('should not set active item when no url matches', () => {
            // Arrange
            const items = [
                { url: 'home', title: 'Home' },
                { url: 'settings', title: 'Settings' }
            ];
            const originalActiveItem = component.activeItem;

            // Act
            (component as any).setActiveItem(items, '/admin');

            // Assert
            expect(component.activeItem).toBe(originalActiveItem);
        });

        it('should handle empty items array', () => {
            // Arrange
            const items: any[] = [];
            const originalActiveItem = component.activeItem;

            // Act
            (component as any).setActiveItem(items, '/home');

            // Assert
            expect(component.activeItem).toBe(originalActiveItem);
        });

        it('should match first occurrence when multiple items have same url', () => {
            // Arrange
            const items = [
                { url: 'home', title: 'Home 1' },
                { url: 'home', title: 'Home 2' }
            ];

            // Act
            (component as any).setActiveItem(items, '/home');

            // Assert
            expect(component.activeItem.title).toBe('Home 1');
        });
    });

    describe('Output Events', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
        });

        it('should have setLayoutClass output', () => {
            // Assert
            expect(component.setLayoutClass).toBeDefined();
            expect(component.setLayoutClass).toBeInstanceOf(EventEmitter);
        });

        it('should have reloadPage output', () => {
            // Assert
            expect(component.reloadPage).toBeDefined();
            expect(component.reloadPage).toBeInstanceOf(EventEmitter);
        });

        it('should have showSearch output', () => {
            // Assert
            expect(component.showSearch).toBeDefined();
            expect(component.showSearch).toBeInstanceOf(EventEmitter);
        });

        it('should emit showSearch event', (done) => {
            // Arrange
            component.showSearch.subscribe((value: boolean) => {
                // Assert
                expect(value).toBe(true);
                done();
            });

            // Act
            component.showSearch.emit(true);
        });
    });

    describe('Input Properties', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(NavComponent);
            component = fixture.componentInstance;
        });

        it('should accept expand input', () => {
            // Act
            component.expand = true;

            // Assert
            expect(component.expand).toBe(true);
        });
    });

    describe('NavItem Class', () => {
        it('should create NavItem with default values', () => {
            // Act
            const navItem = new NavItem();

            // Assert
            expect(navItem.title).toBe("");
            expect(navItem.icon).toBe("");
            expect(navItem.Id).toBe("");
            expect(navItem.Count).toBe(0);
            expect(navItem.url).toBe("");
            expect(navItem.Selected).toBe(false);
            expect(navItem.roles).toEqual([]);
            expect(navItem.visible).toBe(false);
        });
    });
});
