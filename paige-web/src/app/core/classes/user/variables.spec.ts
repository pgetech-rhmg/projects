import { Variables, VariableType } from '~/core/classes/user/variables';

describe('Variables', () => {
    beforeEach(() => {
        // Clear both storages before each test
        sessionStorage.clear();
        localStorage.clear();
    });

    afterEach(() => {
        // Clean up after each test
        sessionStorage.clear();
        localStorage.clear();
        jest.restoreAllMocks();
    });

    describe('VariableType Enum', () => {
        it('should have Session type with value 1', () => {
            expect(VariableType.Session).toBe(1);
        });

        it('should have Local type with value 2', () => {
            expect(VariableType.Local).toBe(2);
        });
    });

    describe('get method', () => {
        describe('Session storage', () => {
            it('should return null when no storage exists', () => {
                const result = Variables.get('testKey', VariableType.Session);
                expect(result).toBeNull();
            });

            it('should return null when key does not exist', () => {
                Variables.set('existingKey', 'value', VariableType.Session);
                const result = Variables.get('nonExistentKey', VariableType.Session);
                expect(result).toBeNull();
            });

            it('should retrieve existing value', () => {
                Variables.set('testKey', 'testValue', VariableType.Session);
                const result = Variables.get('testKey', VariableType.Session);
                expect(result).toBe('testValue');
            });

            it('should use Session as default type', () => {
                Variables.set('testKey', 'sessionValue');
                const result = Variables.get('testKey');
                expect(result).toBe('sessionValue');
            });

            it('should retrieve string values', () => {
                Variables.set('stringKey', 'string value', VariableType.Session);
                expect(Variables.get('stringKey', VariableType.Session)).toBe('string value');
            });

            it('should retrieve number values', () => {
                Variables.set('numberKey', 42, VariableType.Session);
                expect(Variables.get('numberKey', VariableType.Session)).toBe(42);
            });

            it('should retrieve boolean values', () => {
                Variables.set('boolKey', true, VariableType.Session);
                expect(Variables.get('boolKey', VariableType.Session)).toBe(true);
            });

            it('should retrieve object values', () => {
                const obj = { name: 'test', value: 123 };
                Variables.set('objKey', obj, VariableType.Session);
                expect(Variables.get('objKey', VariableType.Session)).toEqual(obj);
            });

            it('should retrieve array values', () => {
                const arr = [1, 2, 3, 'test'];
                Variables.set('arrKey', arr, VariableType.Session);
                expect(Variables.get('arrKey', VariableType.Session)).toEqual(arr);
            });

            it('should retrieve null values', () => {
                Variables.set('nullKey', null, VariableType.Session);
                expect(Variables.get('nullKey', VariableType.Session)).toBeNull();
            });

            it('should handle multiple variables', () => {
                Variables.set('key1', 'value1', VariableType.Session);
                Variables.set('key2', 'value2', VariableType.Session);
                Variables.set('key3', 'value3', VariableType.Session);

                expect(Variables.get('key1', VariableType.Session)).toBe('value1');
                expect(Variables.get('key2', VariableType.Session)).toBe('value2');
                expect(Variables.get('key3', VariableType.Session)).toBe('value3');
            });
        });

        describe('Local storage', () => {
            it('should return null when no storage exists', () => {
                const result = Variables.get('testKey', VariableType.Local);
                expect(result).toBeNull();
            });

            it('should return null when key does not exist', () => {
                Variables.set('existingKey', 'value', VariableType.Local);
                const result = Variables.get('nonExistentKey', VariableType.Local);
                expect(result).toBeNull();
            });

            it('should retrieve existing value', () => {
                Variables.set('testKey', 'testValue', VariableType.Local);
                const result = Variables.get('testKey', VariableType.Local);
                expect(result).toBe('testValue');
            });

            it('should retrieve complex objects', () => {
                const complex = { nested: { data: [1, 2, 3] }, flag: true };
                Variables.set('complexKey', complex, VariableType.Local);
                expect(Variables.get('complexKey', VariableType.Local)).toEqual(complex);
            });
        });

        describe('Storage isolation', () => {
            it('should not retrieve Session variable from Local storage', () => {
                Variables.set('key', 'sessionValue', VariableType.Session);
                const result = Variables.get('key', VariableType.Local);
                expect(result).toBeNull();
            });

            it('should not retrieve Local variable from Session storage', () => {
                Variables.set('key', 'localValue', VariableType.Local);
                const result = Variables.get('key', VariableType.Session);
                expect(result).toBeNull();
            });
        });
    });

    describe('set method', () => {
        describe('Session storage', () => {
            it('should create new storage when none exists', () => {
                Variables.set('testKey', 'testValue', VariableType.Session);
                
                const stored = sessionStorage.getItem('DASH_AppSession');
                expect(stored).not.toBeNull();
                
                const data = JSON.parse(stored!);
                expect(data.variables).toHaveLength(1);
                expect(data.variables[0].testKey).toBe('testValue');
            });

            it('should add new variable to existing storage', () => {
                Variables.set('key1', 'value1', VariableType.Session);
                Variables.set('key2', 'value2', VariableType.Session);
                
                const stored = sessionStorage.getItem('DASH_AppSession');
                const data = JSON.parse(stored!);
                
                expect(data.variables).toHaveLength(2);
            });

            it('should update existing variable', () => {
                Variables.set('key', 'originalValue', VariableType.Session);
                Variables.set('key', 'updatedValue', VariableType.Session);
                
                const result = Variables.get('key', VariableType.Session);
                expect(result).toBe('updatedValue');
                
                const stored = sessionStorage.getItem('DASH_AppSession');
                const data = JSON.parse(stored!);
                expect(data.variables).toHaveLength(1);
            });

            it('should use Session as default type', () => {
                Variables.set('defaultKey', 'defaultValue');
                
                const stored = sessionStorage.getItem('DASH_AppSession');
                expect(stored).not.toBeNull();
            });

            it('should handle various data types', () => {
                Variables.set('string', 'text', VariableType.Session);
                Variables.set('number', 123, VariableType.Session);
                Variables.set('boolean', false, VariableType.Session);
                Variables.set('object', { key: 'val' }, VariableType.Session);
                Variables.set('array', [1, 2, 3], VariableType.Session);
                
                expect(Variables.get('string', VariableType.Session)).toBe('text');
                expect(Variables.get('number', VariableType.Session)).toBe(123);
                expect(Variables.get('boolean', VariableType.Session)).toBe(false);
                expect(Variables.get('object', VariableType.Session)).toEqual({ key: 'val' });
                expect(Variables.get('array', VariableType.Session)).toEqual([1, 2, 3]);
            });

            it('should handle numeric keys', () => {
                Variables.set(123, 'numericKey', VariableType.Session);
                expect(Variables.get(123, VariableType.Session)).toBe('numericKey');
            });

            it('should handle special characters in keys', () => {
                Variables.set('key-with-dash', 'value1', VariableType.Session);
                Variables.set('key.with.dot', 'value2', VariableType.Session);
                Variables.set('key_with_underscore', 'value3', VariableType.Session);
                
                expect(Variables.get('key-with-dash', VariableType.Session)).toBe('value1');
                expect(Variables.get('key.with.dot', VariableType.Session)).toBe('value2');
                expect(Variables.get('key_with_underscore', VariableType.Session)).toBe('value3');
            });
        });

        describe('Local storage', () => {
            it('should create new storage when none exists', () => {
                Variables.set('testKey', 'testValue', VariableType.Local);
                
                const stored = localStorage.getItem('DASH_AppLocal');
                expect(stored).not.toBeNull();
                
                const data = JSON.parse(stored!);
                expect(data.variables).toHaveLength(1);
                expect(data.variables[0].testKey).toBe('testValue');
            });

            it('should add new variable to existing storage', () => {
                Variables.set('key1', 'value1', VariableType.Local);
                Variables.set('key2', 'value2', VariableType.Local);
                
                const stored = localStorage.getItem('DASH_AppLocal');
                const data = JSON.parse(stored!);
                
                expect(data.variables).toHaveLength(2);
            });

            it('should update existing variable', () => {
                Variables.set('key', 'originalValue', VariableType.Local);
                Variables.set('key', 'updatedValue', VariableType.Local);
                
                const result = Variables.get('key', VariableType.Local);
                expect(result).toBe('updatedValue');
                
                const stored = localStorage.getItem('DASH_AppLocal');
                const data = JSON.parse(stored!);
                expect(data.variables).toHaveLength(1);
            });
        });

        describe('Storage isolation', () => {
            it('should not affect Local storage when setting Session variable', () => {
                Variables.set('key', 'sessionValue', VariableType.Session);
                
                expect(localStorage.getItem('DASH_AppLocal')).toBeNull();
            });

            it('should not affect Session storage when setting Local variable', () => {
                Variables.set('key', 'localValue', VariableType.Local);
                
                expect(sessionStorage.getItem('DASH_AppSession')).toBeNull();
            });
        });
    });

    describe('clear method', () => {
        describe('Clear all - Session storage', () => {
            it('should clear all Session variables', () => {
                Variables.set('key1', 'value1', VariableType.Session);
                Variables.set('key2', 'value2', VariableType.Session);
                
                Variables.clear('all', VariableType.Session);
                
                expect(sessionStorage.getItem('DASH_AppSession')).toBeNull();
                expect(Variables.get('key1', VariableType.Session)).toBeNull();
                expect(Variables.get('key2', VariableType.Session)).toBeNull();
            });

            it('should use Session as default type', () => {
                Variables.set('key', 'value');
                Variables.clear('all');
                
                expect(sessionStorage.getItem('DASH_AppSession')).toBeNull();
            });

            it('should use "all" as default key', () => {
                Variables.set('key', 'value', VariableType.Session);
                Variables.clear();
                
                expect(sessionStorage.getItem('DASH_AppSession')).toBeNull();
            });

            it('should not affect Local storage when clearing Session', () => {
                Variables.set('sessionKey', 'sessionValue', VariableType.Session);
                Variables.set('localKey', 'localValue', VariableType.Local);
                
                Variables.clear('all', VariableType.Session);
                
                expect(Variables.get('localKey', VariableType.Local)).toBe('localValue');
            });
        });

        describe('Clear all - Local storage', () => {
            it('should clear all Local variables', () => {
                Variables.set('key1', 'value1', VariableType.Local);
                Variables.set('key2', 'value2', VariableType.Local);
                
                Variables.clear('all', VariableType.Local);
                
                expect(localStorage.getItem('DASH_AppLocal')).toBeNull();
                expect(Variables.get('key1', VariableType.Local)).toBeNull();
                expect(Variables.get('key2', VariableType.Local)).toBeNull();
            });

            it('should not affect Session storage when clearing Local', () => {
                Variables.set('sessionKey', 'sessionValue', VariableType.Session);
                Variables.set('localKey', 'localValue', VariableType.Local);
                
                Variables.clear('all', VariableType.Local);
                
                expect(Variables.get('sessionKey', VariableType.Session)).toBe('sessionValue');
            });
        });

        describe('Clear specific key - Session storage', () => {
            it('should clear specific Session variable', () => {
                Variables.set('key1', 'value1', VariableType.Session);
                Variables.set('key2', 'value2', VariableType.Session);
                Variables.set('key3', 'value3', VariableType.Session);
                
                Variables.clear('key2', VariableType.Session);
                
                expect(Variables.get('key1', VariableType.Session)).toBe('value1');
                expect(Variables.get('key2', VariableType.Session)).toBeNull();
                expect(Variables.get('key3', VariableType.Session)).toBe('value3');
            });

            it('should handle clearing non-existent key', () => {
                Variables.set('key1', 'value1', VariableType.Session);
                
                expect(() => Variables.clear('nonExistent', VariableType.Session)).not.toThrow();
                
                expect(Variables.get('key1', VariableType.Session)).toBe('value1');
            });

            it('should handle clearing when storage is empty', () => {
                expect(() => Variables.clear('someKey', VariableType.Session)).not.toThrow();
            });

            it('should preserve other variables when clearing specific key', () => {
                Variables.set('keep1', 'value1', VariableType.Session);
                Variables.set('remove', 'value2', VariableType.Session);
                Variables.set('keep2', 'value3', VariableType.Session);
                
                Variables.clear('remove', VariableType.Session);
                
                const stored = sessionStorage.getItem('DASH_AppSession');
                const data = JSON.parse(stored!);
                expect(data.variables).toHaveLength(2);
            });
        });

        describe('Clear specific key - Local storage', () => {
            it('should clear specific Local variable', () => {
                Variables.set('key1', 'value1', VariableType.Local);
                Variables.set('key2', 'value2', VariableType.Local);
                Variables.set('key3', 'value3', VariableType.Local);
                
                Variables.clear('key2', VariableType.Local);
                
                expect(Variables.get('key1', VariableType.Local)).toBe('value1');
                expect(Variables.get('key2', VariableType.Local)).toBeNull();
                expect(Variables.get('key3', VariableType.Local)).toBe('value3');
            });

            it('should handle clearing non-existent key', () => {
                Variables.set('key1', 'value1', VariableType.Local);
                
                expect(() => Variables.clear('nonExistent', VariableType.Local)).not.toThrow();
                
                expect(Variables.get('key1', VariableType.Local)).toBe('value1');
            });
        });
    });

    describe('Integration Scenarios', () => {
        it('should handle complete lifecycle for Session storage', () => {
            // Set
            Variables.set('user', { name: 'John', id: 123 }, VariableType.Session);
            expect(Variables.get('user', VariableType.Session)).toEqual({ name: 'John', id: 123 });
            
            // Update
            Variables.set('user', { name: 'Jane', id: 456 }, VariableType.Session);
            expect(Variables.get('user', VariableType.Session)).toEqual({ name: 'Jane', id: 456 });
            
            // Clear
            Variables.clear('user', VariableType.Session);
            expect(Variables.get('user', VariableType.Session)).toBeNull();
        });

        it('should handle complete lifecycle for Local storage', () => {
            // Set
            Variables.set('settings', { theme: 'dark' }, VariableType.Local);
            expect(Variables.get('settings', VariableType.Local)).toEqual({ theme: 'dark' });
            
            // Update
            Variables.set('settings', { theme: 'light' }, VariableType.Local);
            expect(Variables.get('settings', VariableType.Local)).toEqual({ theme: 'light' });
            
            // Clear
            Variables.clear('settings', VariableType.Local);
            expect(Variables.get('settings', VariableType.Local)).toBeNull();
        });

        it('should handle mixed storage types', () => {
            Variables.set('sessionData', 'session', VariableType.Session);
            Variables.set('localStorage', 'local', VariableType.Local);
            
            expect(Variables.get('sessionData', VariableType.Session)).toBe('session');
            expect(Variables.get('localStorage', VariableType.Local)).toBe('local');
            
            Variables.clear('all', VariableType.Session);
            
            expect(Variables.get('sessionData', VariableType.Session)).toBeNull();
            expect(Variables.get('localStorage', VariableType.Local)).toBe('local');
        });

        it('should handle rapid successive operations', () => {
            for (let i = 0; i < 100; i++) {
                Variables.set(`key${i}`, `value${i}`, VariableType.Session);
            }
            
            for (let i = 0; i < 100; i++) {
                expect(Variables.get(`key${i}`, VariableType.Session)).toBe(`value${i}`);
            }
            
            Variables.clear('all', VariableType.Session);
            
            for (let i = 0; i < 100; i++) {
                expect(Variables.get(`key${i}`, VariableType.Session)).toBeNull();
            }
        });

        it('should handle edge case values', () => {
            Variables.set('empty', '', VariableType.Session);
            Variables.set('zero', 0, VariableType.Session);
            Variables.set('false', false, VariableType.Session);
            Variables.set('null', null, VariableType.Session);
            Variables.set('undefined', undefined, VariableType.Session);
            
            expect(Variables.get('empty', VariableType.Session)).toBe('');
            expect(Variables.get('zero', VariableType.Session)).toBe(0);
            expect(Variables.get('false', VariableType.Session)).toBe(false);
            expect(Variables.get('null', VariableType.Session)).toBeNull();
            // undefined becomes null when JSON stringified
            expect(Variables.get('undefined', VariableType.Session)).toBeNull();
        });
    });

    describe('Error Handling', () => {
        it('should handle corrupted storage gracefully', () => {
            sessionStorage.setItem('DASH_AppSession', 'invalid json');
            
            expect(() => Variables.get('key', VariableType.Session)).toThrow();
        });

        it('should handle empty storage object', () => {
            sessionStorage.setItem('DASH_AppSession', '{}');
            
            expect(() => Variables.get('key', VariableType.Session)).toThrow();
        });
    });
});
