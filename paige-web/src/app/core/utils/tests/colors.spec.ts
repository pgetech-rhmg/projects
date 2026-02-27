import { Colors } from '~/core/utils/colors';
import { Utils } from '~/core/utils/random';

// Mock the Utils module
jest.mock('~/core/utils/random', () => ({
    Utils: {
        random: jest.fn()
    }
}));

describe('Colors', () => {
    describe('defaultColors', () => {
        it('should have exactly 6 predefined colors', () => {
            expect(Colors.defaultColors).toHaveLength(6);
        });

        it('should contain correct default color values', () => {
            const expectedColors = [
                "#02d8e3",
                "#349ceb",
                "#B2CC34",
                "#00858c",
                "#004d87",
                "#829c03"
            ];
            expect(Colors.defaultColors).toEqual(expectedColors);
        });

        it('should have all colors in hex format', () => {
            Colors.defaultColors.forEach(color => {
                expect(color).toMatch(/^#[0-9a-fA-F]{6}$/);
            });
        });
    });

    describe('getRandomColors', () => {
        let mockRandom: jest.MockedFunction<typeof Utils.random>;

        beforeEach(() => {
            mockRandom = Utils.random as jest.MockedFunction<typeof Utils.random>;
            mockRandom.mockClear();
        });

        afterEach(() => {
            jest.clearAllMocks();
        });

        it('should return 1 color by default when called without parameters', () => {
            // Arrange & Act
            const result = Colors.getRandomColors();

            // Assert
            expect(result).toHaveLength(1);
            expect(result[0]).toBe(Colors.defaultColors[0]);
        });

        it('should return requested number of colors when count is less than default colors length', () => {
            // Arrange
            const count = 3;

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(count);
            expect(result).toEqual([
                Colors.defaultColors[0],
                Colors.defaultColors[1],
                Colors.defaultColors[2]
            ]);
        });

        it('should return all default colors when count equals default colors length', () => {
            // Arrange
            const count = 6;

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(count);
            expect(result).toEqual(Colors.defaultColors);
        });

        it('should return only default colors when count is less than or equal to 6', () => {
            // Arrange
            const count = 4;

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(count);
            expect(mockRandom).not.toHaveBeenCalled();
        });

        it('should handle count of 0', () => {
            // Arrange
            const count = 0;

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(0);
            expect(result).toEqual([]);
            expect(mockRandom).not.toHaveBeenCalled();
        });

        it('should handle edge case with count of 1', () => {
            // Arrange
            const count = 1;

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(1);
            expect(result[0]).toBe(Colors.defaultColors[0]);
            expect(mockRandom).not.toHaveBeenCalled();
        });

        it('should generate random colors when count exceeds default colors length', () => {
            // Arrange
            const count = 8;
            // Mock Utils.random to return predictable values for generating "#0A1B2C" and "#3D4E5F"
            mockRandom
                .mockReturnValueOnce(0)  // '0'
                .mockReturnValueOnce(10) // 'A'
                .mockReturnValueOnce(1)  // '1'
                .mockReturnValueOnce(11) // 'B'
                .mockReturnValueOnce(2)  // '2'
                .mockReturnValueOnce(12) // 'C'
                .mockReturnValueOnce(3)  // '3'
                .mockReturnValueOnce(13) // 'D'
                .mockReturnValueOnce(4)  // '4'
                .mockReturnValueOnce(14) // 'E'
                .mockReturnValueOnce(5)  // '5'
                .mockReturnValueOnce(15); // 'F'

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(count);
            // First 6 should be default colors
            for (let i = 0; i < 6; i++) {
                expect(result[i]).toBe(Colors.defaultColors[i]);
            }
            // Remaining should be randomly generated
            expect(result[6]).toBe('#0A1B2C');
            expect(result[7]).toBe('#3D4E5F');
            expect(mockRandom).toHaveBeenCalledTimes(12); // 6 calls per generated color * 2 colors
            expect(mockRandom).toHaveBeenCalledWith(0, 15);
        });

        it('should generate colors in hex format with # prefix', () => {
            // Arrange
            const count = 10;
            let index = 0;
            mockRandom.mockImplementation(() => {
                const value = (index % 16);
                index++;
                return value;
            });

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(count);
            result.forEach((color: any) => {
                expect(color).toMatch(/^#[0-9a-fA-F]{6}$/);
            });
        });

        it('should call Utils.random with correct parameters for each character', () => {
            // Arrange
            const count = 7; // Need 1 more than default
            mockRandom.mockReturnValue(15); // 'F' - generates #FFFFFF which is not in defaults

            // Act
            Colors.getRandomColors(count);

            // Assert
            // Should be called 6 times (once for each character in the hex color)
            expect(mockRandom).toHaveBeenCalledTimes(6);
            mockRandom.mock.calls.forEach(call => {
                expect(call[0]).toBe(0);
                expect(call[1]).toBe(15);
            });
        });

        it('should generate multiple unique random colors when needed', () => {
            // Arrange
            const count = 10;
            let callCount = 0;
            // Generate different values for each call to ensure unique colors
            mockRandom.mockImplementation(() => {
                return callCount++ % 16;
            });

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(count);
            // First 6 are defaults
            expect(result.slice(0, 6)).toEqual(Colors.defaultColors);
            // Verify no duplicate colors
            const uniqueColors = new Set(result);
            expect(uniqueColors.size).toBe(count);
        });

        it('should handle large count values', () => {
            const count = 20;
            let callIndex = 0;

            mockRandom.mockImplementation(() => {
                // Use a larger cycle to ensure we don't repeat colors
                // Generate varied patterns by using position in sequence
                const value = (callIndex + Math.floor(callIndex / 6)) % 16;
                callIndex++;
                return value;
            });

            const result = Colors.getRandomColors(count);

            expect(result).toHaveLength(count);
            expect(result.slice(0, 6)).toEqual(Colors.defaultColors);
        });

        it('should generate colors using all hex characters', () => {
            // Arrange
            const count = 7;
            const hexChars = '0123456789ABCDEF'.split('');
            // Mock to return each hex character in sequence
            let charIndex = 0;
            mockRandom.mockImplementation(() => {
                const value = charIndex % 16;
                charIndex++;
                return value;
            });

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(7);
            // Verify the generated color uses hex characters
            expect(result[6]).toBe('#' + hexChars.slice(0, 6).join(''));
        });

        it('should continue generating colors until count is reached', () => {
            // Arrange
            const count = 8;
            let callNum = 0;
            mockRandom.mockImplementation(() => {
                const value = callNum % 16;
                callNum++;
                return value;
            });

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(count);
            // Verify colors were generated
            expect(mockRandom).toHaveBeenCalled();
        });

        it('should add generated colors to array correctly', () => {
            // Arrange
            const count = 7;
            mockRandom
                .mockReturnValueOnce(15) // 'F'
                .mockReturnValueOnce(15) // 'F'
                .mockReturnValueOnce(15) // 'F'
                .mockReturnValueOnce(15) // 'F'
                .mockReturnValueOnce(15) // 'F'
                .mockReturnValueOnce(15); // 'F'

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(7);
            expect(result[6]).toBe('#FFFFFF');
        });

        it('should handle randomness in color generation', () => {
            // Arrange
            const count = 8;
            // Create varying values to simulate randomness
            mockRandom
                .mockReturnValueOnce(1).mockReturnValueOnce(2).mockReturnValueOnce(3)
                .mockReturnValueOnce(4).mockReturnValueOnce(5).mockReturnValueOnce(6)
                .mockReturnValueOnce(7).mockReturnValueOnce(8).mockReturnValueOnce(9)
                .mockReturnValueOnce(10).mockReturnValueOnce(11).mockReturnValueOnce(12);

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(8);
            expect(result[6]).toBe('#123456');
            expect(result[7]).toBe('#789ABC');
        });

        it('should not add duplicate colors to the array', () => {
            // Arrange
            const count = 8;
            let callCount = 0;
            // Generate unique colors each time
            mockRandom.mockImplementation(() => {
                // First generated color (7th): #000000
                if (callCount < 6) {
                    callCount++;
                    return 0;
                }
                // Second generated color (8th): #111111
                if (callCount < 12) {
                    callCount++;
                    return 1;
                }
                // Fallback
                callCount++;
                return 2;
            });

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(8);
            expect(result[6]).toBe('#000000');
            expect(result[7]).toBe('#111111');
            // Verify no duplicates
            const uniqueColors = new Set(result);
            expect(uniqueColors.size).toBe(result.length);
        });

        it('should generate unique colors and avoid duplicates within generated colors', () => {
            // Arrange
            const count = 9;
            let colorIndex = 0;
            // Generate incrementing colors: #000000, #111111, #222222, etc.
            mockRandom.mockImplementation(() => {
                const value = Math.floor(colorIndex / 6) % 16;
                colorIndex++;
                return value;
            });

            // Act
            const result = Colors.getRandomColors(count);

            // Assert
            expect(result).toHaveLength(9);
            // First 6 are defaults
            expect(result.slice(0, 6)).toEqual(Colors.defaultColors);
            // Generated colors should be unique
            expect(result[6]).toBe('#000000');
            expect(result[7]).toBe('#111111');
            expect(result[8]).toBe('#222222');
            // Verify no duplicates in entire array
            const uniqueColors = new Set(result);
            expect(uniqueColors.size).toBe(9);
        });
    });
});
