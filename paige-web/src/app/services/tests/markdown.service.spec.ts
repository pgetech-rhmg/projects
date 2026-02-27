import { TestBed } from '@angular/core/testing';
import { MarkdownService } from '~/services/markdown.service';
import markdownit from 'markdown-it';
import DOMPurify from 'dompurify';

// Mock markdown-it
jest.mock('markdown-it');

// Mock DOMPurify
jest.mock('dompurify', () => ({
    sanitize: jest.fn()
}));

describe('MarkdownService', () => {
    let service: MarkdownService;
    let mockMarkdownInstance: any;
    let mockRenderer: any;

    beforeEach(() => {
        // Create mock renderer with rules object
        mockRenderer = {
            rules: {}
        };

        // Create mock markdown-it instance
        mockMarkdownInstance = {
            renderer: mockRenderer,
            render: jest.fn()
        };

        // Mock the markdown-it constructor to return our mock instance
        (markdownit as jest.MockedFunction<typeof markdownit>).mockReturnValue(mockMarkdownInstance);

        // Reset DOMPurify mock
        (DOMPurify.sanitize as jest.Mock).mockClear();

        TestBed.configureTestingModule({
            providers: [MarkdownService]
        });

        service = TestBed.inject(MarkdownService);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('Service Initialization', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });

        it('should initialize markdown-it with correct configuration', () => {
            expect(markdownit).toHaveBeenCalledWith({
                highlight: null,
                html: false,
                linkify: true,
                breaks: true,
                typographer: true
            });
        });

        it('should be provided in root', () => {
            const service1 = TestBed.inject(MarkdownService);
            const service2 = TestBed.inject(MarkdownService);
            
            // Since providedIn: 'root', should be singleton
            expect(service1).toBe(service2);
        });

        it('should have private md property initialized', () => {
            expect(service['md']).toBeDefined();
            expect(service['md']).toBe(mockMarkdownInstance);
        });
    });

    describe('render', () => {
        beforeEach(() => {
            // Default mock implementation for render
            mockMarkdownInstance.render.mockReturnValue('<p>rendered content</p>');
            (DOMPurify.sanitize as jest.Mock).mockReturnValue('sanitized html');
        });

        it('should call md.render with the provided markdown string', () => {
            const markdown = '# Hello World';

            service.render(markdown);

            expect(mockMarkdownInstance.render).toHaveBeenCalledWith(markdown);
            expect(mockMarkdownInstance.render).toHaveBeenCalledTimes(1);
        });

        it('should return the rendered markdown as HTML', () => {
            const markdown = '**bold text**';
            const expectedHtml = '<p><strong>bold text</strong></p>';
            mockMarkdownInstance.render.mockReturnValue(expectedHtml);

            const result = service.render(markdown);

            expect(result).toBe(expectedHtml);
        });

        it('should set html_block renderer rule', () => {
            const markdown = 'test';

            service.render(markdown);

            expect(mockRenderer.rules.html_block).toBeDefined();
            expect(typeof mockRenderer.rules.html_block).toBe('function');
        });

        it('should set html_inline renderer rule', () => {
            const markdown = 'test';

            service.render(markdown);

            expect(mockRenderer.rules.html_inline).toBeDefined();
            expect(typeof mockRenderer.rules.html_inline).toBe('function');
        });

        it('should handle empty string input', () => {
            const markdown = '';
            mockMarkdownInstance.render.mockReturnValue('');

            const result = service.render(markdown);

            expect(mockMarkdownInstance.render).toHaveBeenCalledWith('');
            expect(result).toBe('');
        });

        it('should handle plain text without markdown syntax', () => {
            const markdown = 'This is plain text';
            mockMarkdownInstance.render.mockReturnValue('<p>This is plain text</p>');

            const result = service.render(markdown);

            expect(result).toBe('<p>This is plain text</p>');
        });

        it('should handle markdown with multiple lines', () => {
            const markdown = '# Title\n\nParagraph 1\n\nParagraph 2';
            const expectedHtml = '<h1>Title</h1>\n<p>Paragraph 1</p>\n<p>Paragraph 2</p>';
            mockMarkdownInstance.render.mockReturnValue(expectedHtml);

            const result = service.render(markdown);

            expect(result).toBe(expectedHtml);
        });

        it('should handle markdown with code blocks', () => {
            const markdown = '```javascript\nconst x = 1;\n```';
            const expectedHtml = '<pre><code class="language-javascript">const x = 1;\n</code></pre>';
            mockMarkdownInstance.render.mockReturnValue(expectedHtml);

            const result = service.render(markdown);

            expect(result).toBe(expectedHtml);
        });

        it('should handle markdown with links', () => {
            const markdown = '[Google](https://google.com)';
            const expectedHtml = '<p><a href="https://google.com">Google</a></p>';
            mockMarkdownInstance.render.mockReturnValue(expectedHtml);

            const result = service.render(markdown);

            expect(result).toBe(expectedHtml);
        });

        it('should handle markdown with lists', () => {
            const markdown = '- Item 1\n- Item 2\n- Item 3';
            const expectedHtml = '<ul>\n<li>Item 1</li>\n<li>Item 2</li>\n<li>Item 3</li>\n</ul>';
            mockMarkdownInstance.render.mockReturnValue(expectedHtml);

            const result = service.render(markdown);

            expect(result).toBe(expectedHtml);
        });

        it('should handle special characters', () => {
            const markdown = 'Text with <special> & characters';
            mockMarkdownInstance.render.mockReturnValue('<p>Text with &lt;special&gt; &amp; characters</p>');

            const result = service.render(markdown);

            expect(result).toBe('<p>Text with &lt;special&gt; &amp; characters</p>');
        });

        it('should handle very long markdown strings', () => {
            const markdown = 'a'.repeat(10000);
            const expectedHtml = `<p>${'a'.repeat(10000)}</p>`;
            mockMarkdownInstance.render.mockReturnValue(expectedHtml);

            const result = service.render(markdown);

            expect(result).toBe(expectedHtml);
        });

        describe('html_block renderer rule', () => {
            it('should call sanitizeHtml when html_block is rendered', () => {
                const markdown = 'test';
                const htmlContent = '<div>HTML Block</div>';
                const sanitizedContent = '<p>Sanitized Block</p>';
                
                (DOMPurify.sanitize as jest.Mock).mockReturnValue(sanitizedContent);

                service.render(markdown);

                // Get the html_block rule function
                const htmlBlockRule = mockRenderer.rules.html_block;
                
                // Create mock tokens
                const mockTokens = [{ content: htmlContent }];
                
                // Call the rule
                const result = htmlBlockRule(mockTokens, 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(htmlContent, {
                    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li', 'code', 'pre'],
                    ALLOWED_ATTR: ['href', 'target', 'rel']
                });
                expect(result).toBe(sanitizedContent);
            });

            it('should handle empty html_block content', () => {
                const markdown = 'test';
                (DOMPurify.sanitize as jest.Mock).mockReturnValue('');

                service.render(markdown);

                const htmlBlockRule = mockRenderer.rules.html_block;
                const mockTokens = [{ content: '' }];
                
                const result = htmlBlockRule(mockTokens, 0);

                expect(result).toBe('');
            });

            it('should sanitize malicious html_block content', () => {
                const markdown = 'test';
                const maliciousHtml = '<script>alert("XSS")</script>';
                const sanitizedHtml = '';
                
                (DOMPurify.sanitize as jest.Mock).mockReturnValue(sanitizedHtml);

                service.render(markdown);

                const htmlBlockRule = mockRenderer.rules.html_block;
                const mockTokens = [{ content: maliciousHtml }];
                
                const result = htmlBlockRule(mockTokens, 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(maliciousHtml, expect.any(Object));
                expect(result).toBe(sanitizedHtml);
            });

            it('should use correct token index for html_block', () => {
                const markdown = 'test';
                const htmlContent1 = '<div>Block 1</div>';
                const htmlContent2 = '<div>Block 2</div>';
                
                (DOMPurify.sanitize as jest.Mock)
                    .mockReturnValueOnce('Sanitized 1')
                    .mockReturnValueOnce('Sanitized 2');

                service.render(markdown);

                const htmlBlockRule = mockRenderer.rules.html_block;
                const mockTokens = [
                    { content: htmlContent1 },
                    { content: htmlContent2 }
                ];
                
                const result1 = htmlBlockRule(mockTokens, 0);
                const result2 = htmlBlockRule(mockTokens, 1);

                expect(result1).toBe('Sanitized 1');
                expect(result2).toBe('Sanitized 2');
            });
        });

        describe('html_inline renderer rule', () => {
            it('should call sanitizeHtml when html_inline is rendered', () => {
                const markdown = 'test';
                const htmlContent = '<span>Inline HTML</span>';
                const sanitizedContent = '<strong>Sanitized Inline</strong>';
                
                (DOMPurify.sanitize as jest.Mock).mockReturnValue(sanitizedContent);

                service.render(markdown);

                // Get the html_inline rule function
                const htmlInlineRule = mockRenderer.rules.html_inline;
                
                // Create mock tokens
                const mockTokens = [{ content: htmlContent }];
                
                // Call the rule
                const result = htmlInlineRule(mockTokens, 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(htmlContent, {
                    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li', 'code', 'pre'],
                    ALLOWED_ATTR: ['href', 'target', 'rel']
                });
                expect(result).toBe(sanitizedContent);
            });

            it('should handle empty html_inline content', () => {
                const markdown = 'test';
                (DOMPurify.sanitize as jest.Mock).mockReturnValue('');

                service.render(markdown);

                const htmlInlineRule = mockRenderer.rules.html_inline;
                const mockTokens = [{ content: '' }];
                
                const result = htmlInlineRule(mockTokens, 0);

                expect(result).toBe('');
            });

            it('should sanitize malicious html_inline content', () => {
                const markdown = 'test';
                const maliciousHtml = '<img src=x onerror="alert(1)">';
                const sanitizedHtml = '';
                
                (DOMPurify.sanitize as jest.Mock).mockReturnValue(sanitizedHtml);

                service.render(markdown);

                const htmlInlineRule = mockRenderer.rules.html_inline;
                const mockTokens = [{ content: maliciousHtml }];
                
                const result = htmlInlineRule(mockTokens, 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(maliciousHtml, expect.any(Object));
                expect(result).toBe(sanitizedHtml);
            });

            it('should use correct token index for html_inline', () => {
                const markdown = 'test';
                const htmlContent1 = '<b>Inline 1</b>';
                const htmlContent2 = '<i>Inline 2</i>';
                
                (DOMPurify.sanitize as jest.Mock)
                    .mockReturnValueOnce('Sanitized 1')
                    .mockReturnValueOnce('Sanitized 2');

                service.render(markdown);

                const htmlInlineRule = mockRenderer.rules.html_inline;
                const mockTokens = [
                    { content: htmlContent1 },
                    { content: htmlContent2 }
                ];
                
                const result1 = htmlInlineRule(mockTokens, 0);
                const result2 = htmlInlineRule(mockTokens, 1);

                expect(result1).toBe('Sanitized 1');
                expect(result2).toBe('Sanitized 2');
            });
        });

        it('should set renderer rules on every render call', () => {
            service.render('First call');
            expect(mockRenderer.rules.html_block).toBeDefined();
            expect(mockRenderer.rules.html_inline).toBeDefined();

            // Clear the rules
            mockRenderer.rules = {};

            service.render('Second call');
            expect(mockRenderer.rules.html_block).toBeDefined();
            expect(mockRenderer.rules.html_inline).toBeDefined();
        });
    });

    describe('sanitizeHtml (private method)', () => {
        beforeEach(() => {
            mockMarkdownInstance.render.mockReturnValue('<p>test</p>');
        });

        it('should call DOMPurify.sanitize with correct configuration', () => {
            const html = '<div>Test</div>';
            (DOMPurify.sanitize as jest.Mock).mockReturnValue('sanitized');

            service.render('test');
            const htmlBlockRule = mockRenderer.rules.html_block;
            htmlBlockRule([{ content: html }], 0);

            expect(DOMPurify.sanitize).toHaveBeenCalledWith(html, {
                ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li', 'code', 'pre'],
                ALLOWED_ATTR: ['href', 'target', 'rel']
            });
        });

        it('should allow only specified HTML tags', () => {
            const html = '<b>bold</b> <i>italic</i> <script>bad</script>';
            const sanitized = '<b>bold</b> <i>italic</i> ';
            (DOMPurify.sanitize as jest.Mock).mockReturnValue(sanitized);

            service.render('test');
            const htmlBlockRule = mockRenderer.rules.html_block;
            const result = htmlBlockRule([{ content: html }], 0);

            expect(DOMPurify.sanitize).toHaveBeenCalledWith(
                html,
                expect.objectContaining({
                    ALLOWED_TAGS: expect.arrayContaining(['b', 'i'])
                })
            );
        });

        it('should allow only specified HTML attributes', () => {
            const html = '<a href="url" onclick="bad">link</a>';
            (DOMPurify.sanitize as jest.Mock).mockReturnValue('<a href="url">link</a>');

            service.render('test');
            const htmlInlineRule = mockRenderer.rules.html_inline;
            htmlInlineRule([{ content: html }], 0);

            expect(DOMPurify.sanitize).toHaveBeenCalledWith(
                html,
                expect.objectContaining({
                    ALLOWED_ATTR: ['href', 'target', 'rel']
                })
            );
        });

        it('should handle all allowed tags correctly', () => {
            const allowedTags = ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li', 'code', 'pre'];
            
            allowedTags.forEach((tag: string) => {
                (DOMPurify.sanitize as jest.Mock).mockClear();
                service.render('test');
                const htmlBlockRule = mockRenderer.rules.html_block;
                htmlBlockRule([{ content: `<${tag}>content</${tag}>` }], 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(
                    expect.any(String),
                    expect.objectContaining({
                        ALLOWED_TAGS: expect.arrayContaining([tag])
                    })
                );
            });
        });

        it('should handle all allowed attributes correctly', () => {
            const allowedAttrs = ['href', 'target', 'rel'];
            
            allowedAttrs.forEach((attr: string) => {
                (DOMPurify.sanitize as jest.Mock).mockClear();
                service.render('test');
                const htmlInlineRule = mockRenderer.rules.html_inline;
                htmlInlineRule([{ content: `<a ${attr}="value">link</a>` }], 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(
                    expect.any(String),
                    expect.objectContaining({
                        ALLOWED_ATTR: expect.arrayContaining([attr])
                    })
                );
            });
        });

        it('should return sanitized HTML from DOMPurify', () => {
            const html = '<script>alert("xss")</script><p>safe</p>';
            const sanitized = '<p>safe</p>';
            (DOMPurify.sanitize as jest.Mock).mockReturnValue(sanitized);

            service.render('test');
            const htmlBlockRule = mockRenderer.rules.html_block;
            const result = htmlBlockRule([{ content: html }], 0);

            expect(result).toBe(sanitized);
        });

        it('should handle complex nested HTML', () => {
            const html = '<ul><li><strong><a href="url">nested</a></strong></li></ul>';
            (DOMPurify.sanitize as jest.Mock).mockReturnValue(html);

            service.render('test');
            const htmlBlockRule = mockRenderer.rules.html_block;
            const result = htmlBlockRule([{ content: html }], 0);

            expect(DOMPurify.sanitize).toHaveBeenCalled();
            expect(result).toBe(html);
        });

        it('should handle self-closing tags', () => {
            const html = 'Line 1<br>Line 2<br/>Line 3';
            (DOMPurify.sanitize as jest.Mock).mockReturnValue(html);

            service.render('test');
            const htmlInlineRule = mockRenderer.rules.html_inline;
            const result = htmlInlineRule([{ content: html }], 0);

            expect(result).toBe(html);
        });
    });

    describe('Markdown-it Configuration', () => {
        it('should have highlight set to null', () => {
            expect(markdownit).toHaveBeenCalledWith(
                expect.objectContaining({ highlight: null })
            );
        });

        it('should have html set to false', () => {
            expect(markdownit).toHaveBeenCalledWith(
                expect.objectContaining({ html: false })
            );
        });

        it('should have linkify set to true', () => {
            expect(markdownit).toHaveBeenCalledWith(
                expect.objectContaining({ linkify: true })
            );
        });

        it('should have breaks set to true', () => {
            expect(markdownit).toHaveBeenCalledWith(
                expect.objectContaining({ breaks: true })
            );
        });

        it('should have typographer set to true', () => {
            expect(markdownit).toHaveBeenCalledWith(
                expect.objectContaining({ typographer: true })
            );
        });
    });

    describe('Security', () => {
        it('should sanitize XSS attempts in html_block', () => {
            const xssAttempts = [
                '<script>alert("XSS")</script>',
                '<img src=x onerror="alert(1)">',
                '<iframe src="javascript:alert(1)"></iframe>',
                '<object data="data:text/html,<script>alert(1)</script>"></object>'
            ];

            xssAttempts.forEach((xss: string) => {
                (DOMPurify.sanitize as jest.Mock).mockClear();
                (DOMPurify.sanitize as jest.Mock).mockReturnValue('');

                service.render('test');
                const htmlBlockRule = mockRenderer.rules.html_block;
                htmlBlockRule([{ content: xss }], 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(xss, expect.any(Object));
            });
        });

        it('should sanitize XSS attempts in html_inline', () => {
            const xssAttempts = [
                '<a href="javascript:alert(1)">click</a>',
                '<img src=x onerror=alert(1)>',
                '<svg onload=alert(1)>'
            ];

            xssAttempts.forEach((xss: string) => {
                (DOMPurify.sanitize as jest.Mock).mockClear();
                (DOMPurify.sanitize as jest.Mock).mockReturnValue('');

                service.render('test');
                const htmlInlineRule = mockRenderer.rules.html_inline;
                htmlInlineRule([{ content: xss }], 0);

                expect(DOMPurify.sanitize).toHaveBeenCalledWith(xss, expect.any(Object));
            });
        });
    });
});
