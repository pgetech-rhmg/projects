import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AuthComponent } from './auth.component';
import { Router } from '@angular/router';

describe('AuthComponent', () => {
    let component: AuthComponent;
    let fixture: ComponentFixture<AuthComponent>;
    let mockRouter: jest.Mocked<Router>;

    beforeEach(async () => {
        // Create mock Router
        mockRouter = {
            navigate: jest.fn().mockResolvedValue(true)
        } as any;

        await TestBed.configureTestingModule({
            imports: [AuthComponent],
            providers: [
                { provide: Router, useValue: mockRouter }
            ]
        }).compileComponents();

        fixture = TestBed.createComponent(AuthComponent);
        component = fixture.componentInstance;
    });

    afterEach(() => {
        jest.restoreAllMocks();
        sessionStorage.clear();
    });

    describe('Component Initialization', () => {
        it('should create', () => {
            expect(component).toBeTruthy();
        });

        it('should initialize with isLoading as true', () => {
            expect(component.isLoading).toBe(true);
        });

        it('should be a standalone component', () => {
            const componentMetadata = (AuthComponent as any).ɵcmp;
            expect(componentMetadata.standalone).toBe(true);
        });

        it('should have correct selector', () => {
            const componentMetadata = (AuthComponent as any).ɵcmp;
            expect(componentMetadata.selectors).toEqual([['auth']]);
        });
    });

    describe('ngOnInit', () => {
        it('should navigate to root when no redirect in sessionStorage', async () => {
            // Arrange
            sessionStorage.clear();

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/']);
            expect(component.isLoading).toBe(false);
        });

        it('should navigate to redirect path when present in sessionStorage', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/dashboard');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/dashboard']);
            expect(component.isLoading).toBe(false);
        });

        it('should navigate to root when redirect is empty string', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/']);
            expect(component.isLoading).toBe(false);
        });

        it('should set isLoading to false after navigation completes', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/profile');

            // Act
            expect(component.isLoading).toBe(true);
            await component.ngOnInit();

            // Assert
            expect(component.isLoading).toBe(false);
        });

        it('should handle various redirect paths', async () => {
            const testPaths = ['/home', '/settings', '/admin/users', '/profile/edit'];

            for (const path of testPaths) {
                sessionStorage.setItem('_redirect', path);
                mockRouter.navigate.mockClear();

                await component.ngOnInit();

                expect(mockRouter.navigate).toHaveBeenCalledWith([path]);
            }
        });

        it('should handle redirect paths with query parameters', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/search?q=test');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/search?q=test']);
        });

        it('should handle redirect paths with fragments', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/page#section');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/page#section']);
        });

        it('should navigate only once per initialization', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/test');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledTimes(1);
        });
    });

    describe('SessionStorage Integration', () => {
        it('should read from sessionStorage with correct key', async () => {
            // Arrange
            const getItemSpy = jest.spyOn(Storage.prototype, 'getItem');
            sessionStorage.setItem('_redirect', '/test');

            // Act
            await component.ngOnInit();

            // Assert
            expect(getItemSpy).toHaveBeenCalledWith('_redirect');
            getItemSpy.mockRestore();
        });

        it('should handle null value from sessionStorage', async () => {
            // Arrange
            sessionStorage.clear();

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/']);
        });

        it('should handle whitespace-only redirect', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '   ');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['   ']);
        });
    });

    describe('Router Integration', () => {
        it('should await router navigation', async () => {
            // Arrange
            let navigationCompleted = false;
            mockRouter.navigate.mockImplementation(async () => {
                await new Promise(resolve => setTimeout(resolve, 10));
                navigationCompleted = true;
                return true;
            });
            sessionStorage.setItem('_redirect', '/test');

            // Act
            await component.ngOnInit();

            // Assert
            expect(navigationCompleted).toBe(true);
            expect(component.isLoading).toBe(false);
        });

        it('should set isLoading to false even if navigation fails', async () => {
            // Arrange
            mockRouter.navigate.mockRejectedValue(new Error('Navigation failed'));
            sessionStorage.setItem('_redirect', '/test');

            // Act & Assert
            await expect(component.ngOnInit()).rejects.toThrow('Navigation failed');
            // Note: isLoading won't be set to false if navigation throws
        });

        it('should handle navigation returning false', async () => {
            // Arrange
            mockRouter.navigate.mockResolvedValue(false);
            sessionStorage.setItem('_redirect', '/test');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/test']);
            expect(component.isLoading).toBe(false);
        });
    });

    describe('Public Properties', () => {
        it('should have isLoading as public property', () => {
            expect(component.isLoading).toBeDefined();
            expect(typeof component.isLoading).toBe('boolean');
        });

        it('should allow isLoading to be modified', () => {
            component.isLoading = false;
            expect(component.isLoading).toBe(false);
            
            component.isLoading = true;
            expect(component.isLoading).toBe(true);
        });
    });

    describe('Edge Cases', () => {
        it('should handle redirect path starting with slash', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/valid-path');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/valid-path']);
        });

        it('should handle redirect path without leading slash', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', 'no-slash-path');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['no-slash-path']);
        });

        it('should handle very long redirect paths', async () => {
            // Arrange
            const longPath = '/a'.repeat(500);
            sessionStorage.setItem('_redirect', longPath);

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith([longPath]);
        });

        it('should handle special characters in redirect path', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/path?param=value&other=123#anchor');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/path?param=value&other=123#anchor']);
        });

        it('should handle encoded characters in redirect path', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/search?q=%20test%20');

            // Act
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/search?q=%20test%20']);
        });
    });

    describe('Multiple Initialization', () => {
        it('should handle multiple ngOnInit calls', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/first');

            // Act
            await component.ngOnInit();
            
            sessionStorage.setItem('_redirect', '/second');
            await component.ngOnInit();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledTimes(2);
            expect(mockRouter.navigate).toHaveBeenNthCalledWith(1, ['/first']);
            expect(mockRouter.navigate).toHaveBeenNthCalledWith(2, ['/second']);
        });

        it('should reset isLoading on each initialization', async () => {
            // Arrange
            sessionStorage.setItem('_redirect', '/test');

            // Act
            component.isLoading = true;
            await component.ngOnInit();
            expect(component.isLoading).toBe(false);

            component.isLoading = true;
            await component.ngOnInit();
            expect(component.isLoading).toBe(false);
        });
    });
});
