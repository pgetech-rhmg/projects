import { Sessions } from '~/core/utils/sessions';
import { Variables } from '~/core/classes/user/variables';

// Mock the Variables class
jest.mock('~/core/classes/user/variables');

describe('Sessions', () => {
  let mockVariablesGet: jest.Mock;
  let mockVariablesSet: jest.Mock;
  let mockGetRandomValues: jest.SpyInstance;

  beforeEach(() => {
    // Create mocks for Variables static methods
    mockVariablesGet = jest.fn();
    mockVariablesSet = jest.fn();
    
    (Variables.get as jest.Mock) = mockVariablesGet;
    (Variables.set as jest.Mock) = mockVariablesSet;

    // Mock crypto.getRandomValues
    mockGetRandomValues = jest.spyOn(globalThis.crypto, 'getRandomValues');
  });

  afterEach(() => {
    jest.clearAllMocks();
    mockGetRandomValues.mockRestore();
  });

  describe('getSessionId', () => {
    it('should return existing session ID when already set in Variables', () => {
      // Arrange
      const existingSessionId = '12345678-1234-4234-8234-123456789012';
      mockVariablesGet.mockReturnValue(existingSessionId);

      // Act
      const result = Sessions.getSessionId();

      // Assert
      expect(mockVariablesGet).toHaveBeenCalledWith('User.SessionId');
      expect(mockVariablesGet).toHaveBeenCalledTimes(1);
      expect(mockVariablesSet).not.toHaveBeenCalled();
      expect(result).toBe(existingSessionId);
    });

    it('should generate new session ID when not found in Variables', () => {
      // Arrange
      mockVariablesGet.mockReturnValue(null);
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        // Provide deterministic values for testing
        for (let i = 0; i < array.length; i++) {
          array[i] = i % 16;
        }
        return array;
      });

      // Act
      const result = Sessions.getSessionId();

      // Assert
      expect(mockVariablesGet).toHaveBeenCalledWith('User.SessionId');
      expect(mockVariablesSet).toHaveBeenCalledTimes(1);
      expect(mockVariablesSet).toHaveBeenCalledWith('User.SessionId', result);
      expect(result).toBeDefined();
      expect(typeof result).toBe('string');
    });

    it('should generate new session ID when Variables returns undefined', () => {
      // Arrange
      mockVariablesGet.mockReturnValue(undefined);
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        for (let i = 0; i < array.length; i++) {
          array[i] = i % 16;
        }
        return array;
      });

      // Act
      const result = Sessions.getSessionId();

      // Assert
      expect(mockVariablesGet).toHaveBeenCalledWith('User.SessionId');
      expect(mockVariablesSet).toHaveBeenCalledWith('User.SessionId', result);
      expect(result).toBeDefined();
    });

    it('should generate new session ID when Variables returns empty string', () => {
      // Arrange
      mockVariablesGet.mockReturnValue('');
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        for (let i = 0; i < array.length; i++) {
          array[i] = i % 16;
        }
        return array;
      });

      // Act
      const result = Sessions.getSessionId();

      // Assert
      expect(mockVariablesGet).toHaveBeenCalledWith('User.SessionId');
      expect(mockVariablesSet).toHaveBeenCalledWith('User.SessionId', result);
      expect(result).toBeDefined();
      expect(result).not.toBe('');
    });

    it('should store generated session ID in Variables', () => {
      // Arrange
      mockVariablesGet.mockReturnValue(null);
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        for (let i = 0; i < array.length; i++) {
          array[i] = 15; // Maximum value for 4 bits
        }
        return array;
      });

      // Act
      const result = Sessions.getSessionId();

      // Assert
      expect(mockVariablesSet).toHaveBeenCalledWith('User.SessionId', result);
      expect(mockVariablesSet).toHaveBeenCalledTimes(1);
    });

    it('should return same session ID on multiple calls when session exists', () => {
      // Arrange
      const existingSessionId = 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee';
      mockVariablesGet.mockReturnValue(existingSessionId);

      // Act
      const result1 = Sessions.getSessionId();
      const result2 = Sessions.getSessionId();

      // Assert
      expect(result1).toBe(existingSessionId);
      expect(result2).toBe(existingSessionId);
      expect(result1).toBe(result2);
      expect(mockVariablesGet).toHaveBeenCalledTimes(2);
      expect(mockVariablesSet).not.toHaveBeenCalled();
    });

    it('should handle falsy values correctly', () => {
      // Arrange
      mockVariablesGet.mockReturnValue(0);
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        for (let i = 0; i < array.length; i++) {
          array[i] = 10;
        }
        return array;
      });

      // Act
      const result = Sessions.getSessionId();

      // Assert
      expect(mockVariablesSet).toHaveBeenCalledWith('User.SessionId', result);
      expect(result).not.toBe(0);
    });
  });

  describe('generateGUID', () => {
    it('should generate a valid GUID format', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 15; // Will produce 'f' in hex
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      expect(guid).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
    });

    it('should generate GUID with correct length', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 8;
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      expect(guid).toHaveLength(36); // 32 hex chars + 4 hyphens
    });

    it('should generate GUID with version 4 identifier', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 12;
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      expect(guid.charAt(14)).toBe('4'); // Version 4 UUID
    });

    it('should generate GUID with correct variant bits', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 15;
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      const variantChar = guid.charAt(19);
      expect(['8', '9', 'a', 'b']).toContain(variantChar);
    });

    it('should generate unique GUIDs on multiple calls', () => {
      // Arrange
      let callCount = 0;
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = callCount++ % 16;
        return array;
      });

      // Act
      const guid1 = Sessions.generateGUID();
      const guid2 = Sessions.generateGUID();
      const guid3 = Sessions.generateGUID();

      // Assert
      expect(guid1).not.toBe(guid2);
      expect(guid2).not.toBe(guid3);
      expect(guid1).not.toBe(guid3);
    });

    it('should use crypto.getRandomValues for randomness', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 7;
        return array;
      });

      // Act
      Sessions.generateGUID();

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalled();
      expect(mockGetRandomValues.mock.calls[0][0]).toBeInstanceOf(Uint8Array);
    });

    it('should generate GUID with hyphens in correct positions', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 5;
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      expect(guid.charAt(8)).toBe('-');
      expect(guid.charAt(13)).toBe('-');
      expect(guid.charAt(18)).toBe('-');
      expect(guid.charAt(23)).toBe('-');
    });

    it('should handle all possible random values correctly', () => {
      // Arrange - test boundary values
      const testValues = [0, 1, 7, 8, 15];
      const guids: string[] = [];

      testValues.forEach(value => {
        mockGetRandomValues.mockImplementation((array: Uint8Array) => {
          array[0] = value;
          return array;
        });

        // Act
        const guid = Sessions.generateGUID();
        guids.push(guid);

        // Assert
        expect(guid).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
      });

      // Verify all generated GUIDs are valid
      guids.forEach(guid => {
        expect(guid).toHaveLength(36);
      });
    });

    it('should correctly mask random values for x positions', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 0b11111111; // 255 in binary, should be masked to 0xf (15)
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      expect(guid).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
      expect(guid.charAt(14)).toBe('4');
    });

    it('should correctly mask random values for y positions', () => {
      // Arrange
      let isYPosition = false;
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        // Y positions should produce values 8, 9, a, or b
        array[0] = 0b11111111; // Will be masked differently for y positions
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      const variantChar = guid.charAt(19);
      expect(['8', '9', 'a', 'b']).toContain(variantChar);
    });

    it('should call getRandomValues once per character position', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 10;
        return array;
      });

      // Act
      Sessions.generateGUID();

      // Assert
      // 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx' has 30 x's and y's and 1 4 = 31
      expect(mockGetRandomValues).toHaveBeenCalledTimes(31);
    });

    it('should generate lowercase hexadecimal characters only', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = Math.floor(Math.random() * 16);
        return array;
      });

      // Act
      const guid = Sessions.generateGUID();

      // Assert
      const hexPattern = /^[0-9a-f-]+$/;
      expect(guid).toMatch(hexPattern);
      expect(guid).not.toMatch(/[A-F]/); // No uppercase letters
    });
  });

  describe('Integration tests', () => {
    it('should generate and store new session ID when called first time', () => {
      // Arrange
      mockVariablesGet.mockReturnValue(null);
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 11;
        return array;
      });

      // Act
      const sessionId = Sessions.getSessionId();

      // Assert
      expect(mockVariablesGet).toHaveBeenCalledWith('User.SessionId');
      expect(mockVariablesSet).toHaveBeenCalledWith('User.SessionId', sessionId);
      expect(sessionId).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
    });

    it('should use existing session ID on subsequent calls', () => {
      // Arrange
      const firstSessionId = 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee';
      mockVariablesGet
        .mockReturnValueOnce(null)
        .mockReturnValue(firstSessionId);
      
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 3;
        return array;
      });

      // Act
      const sessionId1 = Sessions.getSessionId();
      
      // Simulate that Variables now returns the stored session ID
      mockVariablesGet.mockReturnValue(sessionId1);
      const sessionId2 = Sessions.getSessionId();

      // Assert
      expect(sessionId1).toBe(sessionId2);
    });
  });

  describe('Error handling', () => {
    it('should handle crypto.getRandomValues throwing error gracefully', () => {
      // Arrange
      mockGetRandomValues.mockImplementation(() => {
        throw new Error('Crypto not available');
      });

      // Act & Assert
      expect(() => Sessions.generateGUID()).toThrow('Crypto not available');
    });

    it('should handle Variables.get throwing error', () => {
      // Arrange
      mockVariablesGet.mockImplementation(() => {
        throw new Error('Variables service error');
      });

      // Act & Assert
      expect(() => Sessions.getSessionId()).toThrow('Variables service error');
    });

    it('should handle Variables.set throwing error', () => {
      // Arrange
      mockVariablesGet.mockReturnValue(null);
      mockVariablesSet.mockImplementation(() => {
        throw new Error('Cannot set variable');
      });
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 6;
        return array;
      });

      // Act & Assert
      expect(() => Sessions.getSessionId()).toThrow('Cannot set variable');
    });
  });
});
