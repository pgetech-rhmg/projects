import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpBackend } from '@angular/common/http';
import { ChangeDetectorRef, ElementRef, EventEmitter, NO_ERRORS_SCHEMA } from '@angular/core';
import { of } from 'rxjs';

import { ReleaseNotesComponent, slugifyFn, callbackFn } from './release-notes.component';

// Mock MarkdownIt
const mockMarkdownIt = {
    use: jest.fn().mockReturnThis(),
    render: jest.fn()
};

jest.mock('markdown-it', () => {
    return jest.fn(() => mockMarkdownIt);
});

jest.mock('markdown-it-anchor', () => jest.fn());

// Mock lastValueFrom
jest.mock('rxjs', () => {
    const actual = jest.requireActual('rxjs');
    return {
        ...actual,
        lastValueFrom: jest.fn()
    };
});

import { lastValueFrom } from 'rxjs';

describe('ReleaseNotesComponent', () => {
    let component: ReleaseNotesComponent;
    let fixture: ComponentFixture<ReleaseNotesComponent>;
    let mockHttpBackend: any;
    let mockChangeDetectorRef: any;
    let mockHttpClient: any;

    beforeEach(async () => {
        // Create mock HttpBackend
        mockHttpBackend = {};

        // Create mock ChangeDetectorRef
        mockChangeDetectorRef = {
            detectChanges: jest.fn()
        };

        // Create mock HttpClient
        mockHttpClient = {
            get: jest.fn()
        };

        await TestBed.configureTestingModule({
            imports: [ReleaseNotesComponent],
            providers: [
                { provide: HttpBackend, useValue: mockHttpBackend },
                { provide: ChangeDetectorRef, useValue: mockChangeDetectorRef }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();

        // Reset all mocks before each test
        jest.clearAllMocks();
        mockMarkdownIt.render.mockReturnValue('<h1>Test Release Notes</h1>');
    });

    describe('Exported Functions', () => {
        describe('slugifyFn', () => {
            it('should convert string to lowercase', () => {
                // Act
                const result = slugifyFn('HELLO WORLD');

                // Assert
                expect(result).toBe('hello-world');
            });

            it('should replace spaces with hyphens', () => {
                // Act
                const result = slugifyFn('hello world test');

                // Assert
                expect(result).toBe('hello-world-test');
            });

            it('should replace multiple spaces with single hyphen', () => {
                // Act
                const result = slugifyFn('hello    world');

                // Assert
                expect(result).toBe('hello-world');
            });

            it('should handle empty string', () => {
                // Act
                const result = slugifyFn('');

                // Assert
                expect(result).toBe('');
            });

            it('should handle string with mixed case and spaces', () => {
                // Act
                const result = slugifyFn('My Test String');

                // Assert
                expect(result).toBe('my-test-string');
            });
        });

        describe('callbackFn', () => {
            it('should set href attribute when token tag is "a"', () => {
                // Arrange
                const token = {
                    tag: 'a',
                    attrSet: jest.fn()
                };
                const info = { slug: 'test-slug' };

                // Act
                callbackFn(token, info);

                // Assert
                expect(token.attrSet).toHaveBeenCalledWith('href', '#test-slug');
            });

            it('should not set href attribute when token tag is not "a"', () => {
                // Arrange
                const token = {
                    tag: 'div',
                    attrSet: jest.fn()
                };
                const info = { slug: 'test-slug' };

                // Act
                callbackFn(token, info);

                // Assert
                expect(token.attrSet).not.toHaveBeenCalled();
            });

            it('should handle different slugs', () => {
                // Arrange
                const token = {
                    tag: 'a',
                    attrSet: jest.fn()
                };
                const info = { slug: 'another-slug' };

                // Act
                callbackFn(token, info);

                // Assert
                expect(token.attrSet).toHaveBeenCalledWith('href', '#another-slug');
            });
        });
    });

    describe('Constructor', () => {
        it('should create component', () => {
            // Act
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
        });

        it('should initialize isLoading as true', () => {
            // Act
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.isLoading).toBe(true);
        });

        it('should initialize file as empty string', () => {
            // Act
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.file).toBe("");
        });

        it('should initialize HttpClient with HttpBackend', () => {
            // Act
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component['http']).toBeDefined();
        });

        it('should initialize MarkdownIt with anchor plugin', () => {
            // Act
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockMarkdownIt.use).toHaveBeenCalled();
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;
        });

        it('should call loadReleaseNotesFile and set isLoading to false', async () => {
            // Arrange
            jest.spyOn(component as any, 'loadReleaseNotesFile').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).loadReleaseNotesFile).toHaveBeenCalled();
            expect(component.isLoading).toBe(false);
        });
    });

    describe('ngAfterViewInit', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;
        });

        it('should call setupAnchorLinkHandlers', () => {
            // Arrange
            jest.spyOn(component as any, 'setupAnchorLinkHandlers');

            // Act
            component.ngAfterViewInit();

            // Assert
            expect((component as any).setupAnchorLinkHandlers).toHaveBeenCalled();
        });
    });

    describe('close', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;
        });

        it('should emit closeEvent', (done) => {
            // Arrange
            component.closeEvent.subscribe(() => {
                // Assert
                done();
            });

            // Act
            component.close();
        });
    });

    describe('loadReleaseNotesFile (private method)', () => {
        let testComponent: ReleaseNotesComponent;

        beforeEach(() => {
            // Create component instance directly without fixture
            testComponent = new ReleaseNotesComponent(mockHttpBackend, mockChangeDetectorRef);
            // Spy on the http.get method
            jest.spyOn(testComponent['http'], 'get').mockImplementation(mockHttpClient.get);
        });

        it('should load and render markdown file', async () => {
            // Arrange
            const mockMarkdown = '# Release Notes\n\nTest content';
            const mockRendered = '<h1>Release Notes</h1><p>Test content</p>';
            mockMarkdownIt.render.mockReturnValue(mockRendered);
            mockHttpClient.get.mockReturnValue(of(mockMarkdown));
            (lastValueFrom as jest.Mock).mockResolvedValue(mockMarkdown);

            // Mock document.querySelectorAll
            const mockReleaseNotesElement = {
                querySelectorAll: jest.fn().mockReturnValue([])
            };
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockReleaseNotesElement] as any);

            // Act
            await (testComponent as any).loadReleaseNotesFile();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(mockHttpClient.get).toHaveBeenCalledWith('assets/release-notes.md', expect.any(Object));
            expect(mockMarkdownIt.render).toHaveBeenCalledWith(mockMarkdown);
            expect(testComponent.file).toBe(mockRendered);
            expect(mockChangeDetectorRef.detectChanges).toHaveBeenCalled();

            querySelectorAllSpy.mockRestore();
        });

        it('should set attributes on h1, h2, h3 headers', async () => {
            // Arrange
            const mockHeader1 = { innerHTML: 'Test Header', setAttribute: jest.fn() };
            const mockHeader2 = { innerHTML: 'Another Header', setAttribute: jest.fn() };
            const mockReleaseNotesElement = {
                querySelectorAll: jest.fn((selector: string) => {
                    if (selector === 'h1, h2, h3') return [mockHeader1, mockHeader2];
                    return [];
                })
            };

            mockHttpClient.get.mockReturnValue(of('# Test'));
            (lastValueFrom as jest.Mock).mockResolvedValue('# Test');
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockReleaseNotesElement] as any);

            // Act
            await (testComponent as any).loadReleaseNotesFile();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(mockHeader1.setAttribute).toHaveBeenCalledWith('id', 'test-header');
            expect(mockHeader2.setAttribute).toHaveBeenCalledWith('id', 'another-header');

            querySelectorAllSpy.mockRestore();
        });

        it('should set style on paragraphs', async () => {
            // Arrange
            const mockPara1 = { setAttribute: jest.fn() };
            const mockPara2 = { setAttribute: jest.fn() };
            const mockReleaseNotesElement = {
                querySelectorAll: jest.fn((selector: string) => {
                    if (selector === 'p') return [mockPara1, mockPara2];
                    if (selector === 'h1, h2, h3') return [];
                    return [];
                })
            };

            mockHttpClient.get.mockReturnValue(of('Test'));
            (lastValueFrom as jest.Mock).mockResolvedValue('Test');
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockReleaseNotesElement] as any);

            // Act
            await (testComponent as any).loadReleaseNotesFile();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(mockPara1.setAttribute).toHaveBeenCalledWith('style', 'padding-bottom: 20px');
            expect(mockPara2.setAttribute).toHaveBeenCalledWith('style', 'padding-bottom: 20px');

            querySelectorAllSpy.mockRestore();
        });

        it('should set style on list items', async () => {
            // Arrange
            const mockLi1 = { setAttribute: jest.fn() };
            const mockLi2 = { setAttribute: jest.fn() };
            const mockReleaseNotesElement = {
                querySelectorAll: jest.fn((selector: string) => {
                    if (selector === 'li') return [mockLi1, mockLi2];
                    if (selector === 'h1, h2, h3') return [];
                    if (selector === 'p') return [];
                    return [];
                })
            };

            mockHttpClient.get.mockReturnValue(of('Test'));
            (lastValueFrom as jest.Mock).mockResolvedValue('Test');
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockReleaseNotesElement] as any);

            // Act
            await (testComponent as any).loadReleaseNotesFile();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(mockLi1.setAttribute).toHaveBeenCalledWith('style', 'padding-bottom: 10px');
            expect(mockLi2.setAttribute).toHaveBeenCalledWith('style', 'padding-bottom: 10px');

            querySelectorAllSpy.mockRestore();
        });

        it('should set style on images', async () => {
            // Arrange
            const mockImage1 = { style: { width: '', padding: '' } };
            const mockImage2 = { style: { width: '', padding: '' } };
            const mockReleaseNotesElement = {
                querySelectorAll: jest.fn((selector: string) => {
                    if (selector === 'img') return [mockImage1, mockImage2];
                    if (selector === 'h1, h2, h3') return [];
                    if (selector === 'p') return [];
                    if (selector === 'li') return [];
                    return [];
                })
            };

            mockHttpClient.get.mockReturnValue(of('Test'));
            (lastValueFrom as jest.Mock).mockResolvedValue('Test');
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockReleaseNotesElement] as any);

            // Act
            await (testComponent as any).loadReleaseNotesFile();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(mockImage1.style.width).toBe('80%');
            expect(mockImage1.style.padding).toBe('20px');
            expect(mockImage2.style.width).toBe('80%');
            expect(mockImage2.style.padding).toBe('20px');

            querySelectorAllSpy.mockRestore();
        });

        it('should handle when release-notes element is not found', async () => {
            // Arrange
            mockHttpClient.get.mockReturnValue(of('Test'));
            (lastValueFrom as jest.Mock).mockResolvedValue('Test');
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([] as any);

            // Act & Assert - should not throw
            await expect((testComponent as any).loadReleaseNotesFile()).resolves.toBeUndefined();

            querySelectorAllSpy.mockRestore();
        });

        it('should handle http error and log to console', async () => {
            // Arrange
            const mockError = new Error('HTTP Error');
            mockHttpClient.get.mockReturnValue(of(null));
            (lastValueFrom as jest.Mock).mockRejectedValue(mockError);
            const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

            // Act
            await (testComponent as any).loadReleaseNotesFile();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(consoleErrorSpy).toHaveBeenCalledWith('Failed to load Release Notes:', mockError);

            consoleErrorSpy.mockRestore();
        });

        it('should handle special characters in header innerHTML', async () => {
            // Arrange
            const mockHeader = { innerHTML: 'Test: Header & Title!', setAttribute: jest.fn() };
            const mockReleaseNotesElement = {
                querySelectorAll: jest.fn((selector: string) => {
                    if (selector === 'h1, h2, h3') return [mockHeader];
                    return [];
                })
            };

            mockHttpClient.get.mockReturnValue(of('Test'));
            (lastValueFrom as jest.Mock).mockResolvedValue('Test');
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockReleaseNotesElement] as any);

            // Act
            await (testComponent as any).loadReleaseNotesFile();
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(mockHeader.setAttribute).toHaveBeenCalledWith('id', 'test-header-title-');

            querySelectorAllSpy.mockRestore();
        });
    });

    describe('setupAnchorLinkHandlers (private method)', () => {
        let testComponent: ReleaseNotesComponent;

        beforeEach(() => {
            testComponent = new ReleaseNotesComponent(mockHttpBackend, mockChangeDetectorRef);
            jest.useFakeTimers({ doNotFake: ['Date'] });
        });

        afterEach(() => {
            jest.useRealTimers();
        });

        it('should set up click handlers for anchor links', () => {
            // Arrange
            const mockAnchor = {
                getAttribute: jest.fn().mockReturnValue('#test-section'),
                addEventListener: jest.fn()
            };
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockAnchor] as any);

            // Act
            (testComponent as any).setupAnchorLinkHandlers();
            jest.advanceTimersByTime(100);

            // Assert
            expect(document.querySelectorAll).toHaveBeenCalledWith('a[href^="#"]');
            expect(mockAnchor.getAttribute).toHaveBeenCalledWith('href');
            expect(mockAnchor.addEventListener).toHaveBeenCalledWith('click', expect.any(Function));

            querySelectorAllSpy.mockRestore();
        });

        it('should handle click on anchor link and scroll to target', () => {
            // Arrange
            const mockTargetElement = {
                scrollIntoView: jest.fn()
            };
            const mockDataElement = {
                querySelector: jest.fn().mockReturnValue(mockTargetElement)
            };
            testComponent.data = { nativeElement: mockDataElement } as any;

            const mockEvent = { preventDefault: jest.fn() };
            const mockAnchor = {
                getAttribute: jest.fn().mockReturnValue('#test-section'),
                addEventListener: jest.fn((event, handler) => {
                    // Immediately call the handler with mockEvent to test the click behavior
                    handler(mockEvent);
                })
            };
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockAnchor] as any);

            // Act
            (testComponent as any).setupAnchorLinkHandlers();
            jest.advanceTimersByTime(100);

            // Assert
            expect(mockEvent.preventDefault).toHaveBeenCalled();
            expect(mockDataElement.querySelector).toHaveBeenCalledWith('#test-section');
            expect(mockTargetElement.scrollIntoView).toHaveBeenCalledWith({ behavior: 'smooth' });

            querySelectorAllSpy.mockRestore();
        });

        it('should handle click when target element is not found', () => {
            // Arrange
            const mockDataElement = {
                querySelector: jest.fn().mockReturnValue(null)
            };
            testComponent.data = { nativeElement: mockDataElement } as any;

            const mockEvent = { preventDefault: jest.fn() };
            const mockAnchor = {
                getAttribute: jest.fn().mockReturnValue('#missing-section'),
                addEventListener: jest.fn((event, handler) => {
                    handler(mockEvent);
                })
            };
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockAnchor] as any);

            // Act
            (testComponent as any).setupAnchorLinkHandlers();
            jest.advanceTimersByTime(100);

            // Assert
            expect(mockEvent.preventDefault).toHaveBeenCalled();
            expect(mockDataElement.querySelector).toHaveBeenCalledWith('#missing-section');

            querySelectorAllSpy.mockRestore();
        });

        it('should handle anchor without href attribute', () => {
            // Arrange
            const mockEvent = { preventDefault: jest.fn() };
            const mockAnchor = {
                getAttribute: jest.fn().mockReturnValue(null),
                addEventListener: jest.fn((event, handler) => {
                    handler(mockEvent);
                })
            };
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockAnchor] as any);

            // Act
            (testComponent as any).setupAnchorLinkHandlers();
            jest.advanceTimersByTime(100);

            // Assert
            expect(mockEvent.preventDefault).toHaveBeenCalled();

            querySelectorAllSpy.mockRestore();
        });

        it('should handle empty href attribute', () => {
            // Arrange
            const mockEvent = { preventDefault: jest.fn() };
            const mockAnchor = {
                getAttribute: jest.fn().mockReturnValue('#'),
                addEventListener: jest.fn((event, handler) => {
                    handler(mockEvent);
                })
            };
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockAnchor] as any);

            // Act
            (testComponent as any).setupAnchorLinkHandlers();
            jest.advanceTimersByTime(100);

            // Assert
            expect(mockEvent.preventDefault).toHaveBeenCalled();
            // Should handle the empty string after substring(1)

            querySelectorAllSpy.mockRestore();
        });

        it('should handle multiple anchor links', () => {
            // Arrange
            const mockAnchor1 = {
                getAttribute: jest.fn().mockReturnValue('#section1'),
                addEventListener: jest.fn()
            };
            const mockAnchor2 = {
                getAttribute: jest.fn().mockReturnValue('#section2'),
                addEventListener: jest.fn()
            };
            const querySelectorAllSpy = jest.spyOn(document, 'querySelectorAll').mockReturnValue([mockAnchor1, mockAnchor2] as any);

            // Act
            (testComponent as any).setupAnchorLinkHandlers();
            jest.advanceTimersByTime(100);

            // Assert
            expect(mockAnchor1.addEventListener).toHaveBeenCalled();
            expect(mockAnchor2.addEventListener).toHaveBeenCalled();

            querySelectorAllSpy.mockRestore();
        });
    });

    describe('Output Events', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReleaseNotesComponent);
            component = fixture.componentInstance;
        });

        it('should have closeEvent output', () => {
            // Assert
            expect(component.closeEvent).toBeDefined();
            expect(component.closeEvent).toBeInstanceOf(EventEmitter);
        });
    });

    // describe('ViewChild', () => {
    //     beforeEach(() => {
    //         fixture = TestBed.createComponent(ReleaseNotesComponent);
    //         component = fixture.componentInstance;
    //     });

    //     it('should have data ViewChild defined', () => {
    //         // Assert
    //         expect(component.data).toBeDefined();
    //     });
    // });
});
