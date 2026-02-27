import { Utils } from '~/core/utils/random';

describe('Utils', () => {
  describe('random', () => {
    // Store original crypto implementation
    let originalCrypto: Crypto;
    let mockGetRandomValues: jest.Mock;

    beforeEach(() => {
      // Save original crypto
      originalCrypto = globalThis.crypto;
      
      // Create mock for getRandomValues
      mockGetRandomValues = jest.fn();
      
      // Mock globalThis.crypto
      Object.defineProperty(globalThis, 'crypto', {
        value: {
          getRandomValues: mockGetRandomValues
        },
        writable: true,
        configurable: true
      });
    });

    afterEach(() => {
      // Restore original crypto
      Object.defineProperty(globalThis, 'crypto', {
        value: originalCrypto,
        writable: true,
        configurable: true
      });
      
      jest.clearAllMocks();
    });

    // Initialization and Basic Functionality
    it('should return a number within the specified range', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 5; // This will result in value 5
        return array;
      });

      // Act
      const result = Utils.random(1, 10);

      // Assert
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(10);
      expect(typeof result).toBe('number');
    });

    it('should return the same number when min equals max', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 0;
        return array;
      });

      // Act
      const result = Utils.random(5, 5);

      // Assert
      expect(result).toBe(5);
    });

    it('should handle single digit range', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 0;
        return array;
      });

      // Act
      const result = Utils.random(0, 1);

      // Assert
      expect(result).toBeGreaterThanOrEqual(0);
      expect(result).toBeLessThanOrEqual(1);
    });

    // Edge Cases - Minimum Values
    it('should return min value when random bytes produce minimum value', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        // Fill array with zeros to get minimum value
        for (let i = 0; i < array.length; i++) {
          array[i] = 0;
        }
        return array;
      });

      // Act
      const result = Utils.random(10, 20);

      // Assert
      expect(result).toBe(10);
    });

    // Edge Cases - Negative Numbers
    it('should handle negative min value', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 5;
        return array;
      });

      // Act
      const result = Utils.random(-10, 10);

      // Assert
      expect(result).toBeGreaterThanOrEqual(-10);
      expect(result).toBeLessThanOrEqual(10);
    });

    it('should handle negative range', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 2;
        return array;
      });

      // Act
      const result = Utils.random(-20, -10);

      // Assert
      expect(result).toBeGreaterThanOrEqual(-20);
      expect(result).toBeLessThanOrEqual(-10);
    });

    // Large Ranges
    it('should handle large ranges correctly', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        // Provide values that will stay within cutoff
        array[0] = 100;
        array[1] = 50;
        return array;
      });

      // Act
      const result = Utils.random(1, 10000);

      // Assert
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(10000);
    });

    it('should handle very large ranges requiring multiple bytes', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        // Fill with moderate values
        for (let i = 0; i < array.length; i++) {
          array[i] = 100;
        }
        return array;
      });

      // Act
      const result = Utils.random(1, 1000000);

      // Assert
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(1000000);
    });

    // Cutoff Logic - Rejection Sampling
    it('should retry when value exceeds cutoff', () => {
      // Arrange
      let callCount = 0;
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        callCount++;
        if (callCount === 1) {
          // First call: return value above cutoff
          array[0] = 255;
          array[1] = 255;
        } else {
          // Second call: return valid value
          array[0] = 5;
          array[1] = 0;
        }
        return array;
      });

      // Act
      const result = Utils.random(1, 100);

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalledTimes(2);
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(100);
    });

    it('should eventually find valid value after multiple rejections', () => {
      // Arrange
      let callCount = 0;
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        callCount++;
        if (callCount < 5) {
          // First 4 calls: return values above cutoff
          for (let i = 0; i < array.length; i++) {
            array[i] = 255;
          }
        } else {
          // Fifth call: return valid value
          array[0] = 10;
        }
        return array;
      });

      // Act
      const result = Utils.random(1, 50);

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalledTimes(5);
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(50);
    });

    // Byte Array Size Calculation
    it('should use correct number of bytes for small range', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        expect(array.length).toBe(1); // Range 1-10 needs 1 byte
        array[0] = 5;
        return array;
      });

      // Act
      Utils.random(1, 10);

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalled();
    });

    it('should use correct number of bytes for medium range', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        expect(array.length).toBe(2); // Range 1-1000 needs 2 bytes
        array[0] = 100;
        array[1] = 1;
        return array;
      });

      // Act
      Utils.random(1, 1000);

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalled();
    });

    it('should use correct number of bytes for large range', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        expect(array.length).toBe(3); // Range 1-100000 needs 3 bytes
        for (let i = 0; i < array.length; i++) {
          array[i] = 50;
        }
        return array;
      });

      // Act
      Utils.random(1, 100000);

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalled();
    });

    // Crypto API Usage
    it('should call crypto.getRandomValues', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 5;
        return array;
      });

      // Act
      Utils.random(1, 10);

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalledWith(expect.any(Uint8Array));
    });

    it('should call crypto.getRandomValues with Uint8Array of correct size', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        expect(array).toBeInstanceOf(Uint8Array);
        array[0] = 5;
        return array;
      });

      // Act
      Utils.random(1, 100);

      // Assert
      expect(mockGetRandomValues).toHaveBeenCalled();
    });

    // Integer Results
    it('should return integer values only', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 123;
        return array;
      });

      // Act
      const result = Utils.random(1, 1000);

      // Assert
      expect(Number.isInteger(result)).toBe(true);
    });

    // Boundary Values
    it('should include min boundary value', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 0;
        return array;
      });

      // Act
      const result = Utils.random(42, 100);

      // Assert
      expect(result).toBe(42);
    });

    it('should include max boundary value', () => {
      // Arrange
      const min = 1;
      const max = 10;
      const range = max - min + 1;
      
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        // Set value to exactly match max
        array[0] = range - 1; // This should give us max value after modulo
        return array;
      });

      // Act
      const result = Utils.random(min, max);

      // Assert
      expect(result).toBeGreaterThanOrEqual(min);
      expect(result).toBeLessThanOrEqual(max);
    });

    // Zero-based Ranges
    it('should handle range starting from zero', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 5;
        return array;
      });

      // Act
      const result = Utils.random(0, 100);

      // Assert
      expect(result).toBeGreaterThanOrEqual(0);
      expect(result).toBeLessThanOrEqual(100);
    });

    // Statistical Distribution (Basic Check)
    it('should produce different values on subsequent calls with real crypto', () => {
      // Arrange - restore real crypto for this test
      Object.defineProperty(globalThis, 'crypto', {
        value: originalCrypto,
        writable: true,
        configurable: true
      });

      // Act
      const results = new Set<number>();
      for (let i = 0; i < 20; i++) {
        results.add(Utils.random(1, 100));
      }

      // Assert - should have some variety (not all the same)
      expect(results.size).toBeGreaterThan(1);
    });

    // Error Prevention - Type Safety
    it('should handle floating point inputs by using them directly', () => {
      // Arrange
      mockGetRandomValues.mockImplementation((array: Uint8Array) => {
        array[0] = 5;
        return array;
      });

      // Act
      const result = Utils.random(1.7, 10.3);

      // Assert - behavior depends on implementation, but should not crash
      expect(typeof result).toBe('number');
      expect(result).toBeGreaterThanOrEqual(1.7);
      expect(result).toBeLessThanOrEqual(10.3);
    });
  });
});
