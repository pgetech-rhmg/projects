import { TestBed } from '@angular/core/testing';
import { SecurityContext } from '@angular/core';
import { DomSanitizer } from '@angular/platform-browser';
import { SafePipe } from '~/core/pipes/safe.pipe';

describe('SafePipe', () => {
  let pipe: SafePipe;
  let mockSanitizer: jest.Mocked<DomSanitizer>;

  beforeEach(() => {
    // Create mock DomSanitizer with jest.fn()
    mockSanitizer = {
      sanitize: jest.fn(),
      bypassSecurityTrustHtml: jest.fn(),
      bypassSecurityTrustStyle: jest.fn(),
      bypassSecurityTrustScript: jest.fn(),
      bypassSecurityTrustUrl: jest.fn(),
      bypassSecurityTrustResourceUrl: jest.fn(),
    } as any;

    TestBed.configureTestingModule({
      providers: [
        SafePipe,
        { provide: DomSanitizer, useValue: mockSanitizer }
      ]
    });

    pipe = TestBed.inject(SafePipe);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Initialization', () => {
    it('should create the pipe instance', () => {
      expect(pipe).toBeTruthy();
    });

    it('should inject DomSanitizer dependency', () => {
      expect(mockSanitizer).toBeDefined();
    });
  });

  describe('transform method - html type', () => {
    it('should sanitize HTML content with SecurityContext.HTML', () => {
      // Arrange
      const htmlContent = '<div>Test Content</div>';
      const sanitizedResult = '<div>Test Content</div>';
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(htmlContent, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        htmlContent
      );
      expect(result).toBe(sanitizedResult);
    });

    it('should handle potentially malicious HTML content', () => {
      // Arrange
      const maliciousHtml = '<script>alert("XSS")</script><div>Content</div>';
      const sanitizedResult = '<div>Content</div>';
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(maliciousHtml, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        maliciousHtml
      );
      expect(result).toBe(sanitizedResult);
    });

    it('should handle empty HTML string', () => {
      // Arrange
      const emptyHtml = '';
      mockSanitizer.sanitize.mockReturnValue('');

      // Act
      const result = pipe.transform(emptyHtml, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        emptyHtml
      );
      expect(result).toBe('');
    });

    it('should handle null HTML value', () => {
      // Arrange
      mockSanitizer.sanitize.mockReturnValue(null);

      // Act
      const result = pipe.transform(null, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        null
      );
      expect(result).toBeNull();
    });
  });

  describe('transform method - style type', () => {
    it('should sanitize style content with SecurityContext.STYLE', () => {
      // Arrange
      const styleContent = 'color: red; font-size: 14px;';
      const sanitizedResult = 'color: red; font-size: 14px;';
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(styleContent, 'style');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.STYLE,
        styleContent
      );
      expect(result).toBe(sanitizedResult);
    });

    it('should handle potentially malicious style content', () => {
      // Arrange
      const maliciousStyle = 'expression(alert("XSS"))';
      const sanitizedResult = '';
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(maliciousStyle, 'style');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.STYLE,
        maliciousStyle
      );
      expect(result).toBe(sanitizedResult);
    });
  });

  describe('transform method - script type', () => {
    it('should sanitize script content with SecurityContext.SCRIPT', () => {
      // Arrange
      const scriptContent = 'console.log("test");';
      const sanitizedResult = null; // Scripts are typically sanitized to null
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(scriptContent, 'script');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.SCRIPT,
        scriptContent
      );
      expect(result).toBeNull();
    });

    it('should handle malicious script content', () => {
      // Arrange
      const maliciousScript = 'alert(document.cookie);';
      mockSanitizer.sanitize.mockReturnValue(null);

      // Act
      const result = pipe.transform(maliciousScript, 'script');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.SCRIPT,
        maliciousScript
      );
      expect(result).toBeNull();
    });
  });

  describe('transform method - url type', () => {
    it('should sanitize URL content with SecurityContext.URL', () => {
      // Arrange
      const urlContent = 'https://www.pge.com/api/data';
      const sanitizedResult = 'https://www.pge.com/api/data';
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(urlContent, 'url');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.URL,
        urlContent
      );
      expect(result).toBe(sanitizedResult);
    });

    it('should handle potentially unsafe URLs', () => {
      // Arrange
      const unsafeUrl = 'javascript:alert("XSS")';
      const sanitizedResult = 'unsafe:javascript:alert("XSS")';
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(unsafeUrl, 'url');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.URL,
        unsafeUrl
      );
      expect(result).toBe(sanitizedResult);
    });

    it('should handle relative URLs', () => {
      // Arrange
      const relativeUrl = '/api/endpoint';
      mockSanitizer.sanitize.mockReturnValue(relativeUrl);

      // Act
      const result = pipe.transform(relativeUrl, 'url');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.URL,
        relativeUrl
      );
      expect(result).toBe(relativeUrl);
    });
  });

  describe('transform method - resourceUrl type', () => {
    it('should sanitize resource URL content with SecurityContext.RESOURCE_URL', () => {
      // Arrange
      const resourceUrl = 'https://cdn.pge.com/assets/image.png';
      const sanitizedResult = 'https://cdn.pge.com/assets/image.png';
      mockSanitizer.sanitize.mockReturnValue(sanitizedResult);

      // Act
      const result = pipe.transform(resourceUrl, 'resourceUrl');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.RESOURCE_URL,
        resourceUrl
      );
      expect(result).toBe(sanitizedResult);
    });

    it('should handle untrusted resource URLs', () => {
      // Arrange
      const untrustedUrl = 'http://malicious-site.com/script.js';
      mockSanitizer.sanitize.mockReturnValue(null);

      // Act
      const result = pipe.transform(untrustedUrl, 'resourceUrl');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.RESOURCE_URL,
        untrustedUrl
      );
      expect(result).toBeNull();
    });
  });

  describe('transform method - invalid type handling', () => {
    it('should return null for invalid type', () => {
      // Arrange
      const content = '<div>Test</div>';
      const invalidType = 'invalid' as any;

      // Act
      const result = pipe.transform(content, invalidType);

      // Assert
      expect(result).toBeNull();
      expect(mockSanitizer.sanitize).not.toHaveBeenCalled();
    });

    it('should return null for undefined type', () => {
      // Arrange
      const content = '<div>Test</div>';

      // Act
      const result = pipe.transform(content, undefined as any);

      // Assert
      expect(result).toBeNull();
      expect(mockSanitizer.sanitize).not.toHaveBeenCalled();
    });
  });

  describe('transform method - edge cases', () => {
    it('should handle undefined value', () => {
      // Arrange
      mockSanitizer.sanitize.mockReturnValue(null);

      // Act
      const result = pipe.transform(undefined, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        undefined
      );
    });

    it('should handle numeric values', () => {
      // Arrange
      const numericValue = 12345;
      mockSanitizer.sanitize.mockReturnValue('12345');

      // Act
      const result = pipe.transform(numericValue, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        numericValue
      );
      expect(result).toBe('12345');
    });

    it('should handle boolean values', () => {
      // Arrange
      const booleanValue = true;
      mockSanitizer.sanitize.mockReturnValue('true');

      // Act
      const result = pipe.transform(booleanValue, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        booleanValue
      );
      expect(result).toBe('true');
    });

    it('should handle object values', () => {
      // Arrange
      const objectValue = { key: 'value' };
      mockSanitizer.sanitize.mockReturnValue('[object Object]');

      // Act
      const result = pipe.transform(objectValue, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledWith(
        SecurityContext.HTML,
        objectValue
      );
    });
  });

  describe('sanitize method calls', () => {
    it('should call sanitize exactly once per transform call', () => {
      // Arrange
      const content = '<div>Test</div>';
      mockSanitizer.sanitize.mockReturnValue(content);

      // Act
      pipe.transform(content, 'html');

      // Assert
      expect(mockSanitizer.sanitize).toHaveBeenCalledTimes(1);
    });

    it('should not call sanitize for invalid types', () => {
      // Arrange
      const content = '<div>Test</div>';

      // Act
      pipe.transform(content, 'invalidType' as any);

      // Assert
      expect(mockSanitizer.sanitize).not.toHaveBeenCalled();
    });
  });
});
