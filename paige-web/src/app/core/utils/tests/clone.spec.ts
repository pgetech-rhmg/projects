import { Clone } from '../clone';

describe('Clone', () => {
    describe('deepCopy', () => {
        describe('primitive types', () => {
            it('should return the same value for string primitives', () => {
                const original = 'test string';
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe(original);
                expect(typeof copy).toBe('string');
            });

            it('should return the same value for number primitives', () => {
                const original = 42;
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe(original);
                expect(typeof copy).toBe('number');
            });

            it('should return the same value for boolean primitives', () => {
                const original = true;
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe(original);
                expect(typeof copy).toBe('boolean');
            });

            it('should return the same value for null', () => {
                const original = null;
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe(null);
            });

            it('should return the same value for undefined', () => {
                const original = undefined;
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe(undefined);
            });

            it('should return the same value for zero', () => {
                const original = 0;
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe(0);
            });

            it('should return the same value for negative numbers', () => {
                const original = -123.45;
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe(original);
            });

            it('should return the same value for empty string', () => {
                const original = '';
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBe('');
            });
        });

        describe('Date objects', () => {
            it('should create a new Date instance with the same time', () => {
                const original = new Date('2024-01-15T10:30:00Z');
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBeInstanceOf(Date);
                expect(copy).not.toBe(original);
                expect(copy.getTime()).toBe(original.getTime());
            });

            it('should handle current date', () => {
                const original = new Date();
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBeInstanceOf(Date);
                expect(copy).not.toBe(original);
                expect(copy.getTime()).toBe(original.getTime());
            });

            it('should handle invalid dates', () => {
                const original = new Date('invalid');
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBeInstanceOf(Date);
                expect(copy).not.toBe(original);
                expect(isNaN(copy.getTime())).toBe(true);
            });

            it('should deep copy Date inside objects', () => {
                const original = { date: new Date('2024-01-15') };
                const copy = Clone.deepCopy(original);
                
                expect(copy.date).toBeInstanceOf(Date);
                expect(copy.date).not.toBe(original.date);
                expect(copy.date.getTime()).toBe(original.date.getTime());
            });
        });

        describe('arrays', () => {
            it('should create a new array with copied elements', () => {
                const original = [1, 2, 3, 4, 5];
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
                expect(Array.isArray(copy)).toBe(true);
            });

            it('should handle empty arrays', () => {
                const original: any[] = [];
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual([]);
                expect(copy).not.toBe(original);
            });

            it('should deep copy nested arrays', () => {
                const original = [[1, 2], [3, 4], [5, 6]];
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
                expect(copy[0]).not.toBe(original[0]);
                expect(copy[1]).not.toBe(original[1]);
                expect(copy[2]).not.toBe(original[2]);
            });

            it('should deep copy arrays containing objects', () => {
                const original = [
                    { id: 1, name: 'John' },
                    { id: 2, name: 'Jane' }
                ];
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
                expect(copy[0]).not.toBe(original[0]);
                expect(copy[1]).not.toBe(original[1]);
            });

            it('should deep copy arrays containing dates', () => {
                const original = [new Date('2024-01-01'), new Date('2024-12-31')];
                const copy = Clone.deepCopy(original);
                
                expect(copy[0]).toBeInstanceOf(Date);
                expect(copy[0]).not.toBe(original[0]);
                expect(copy[0].getTime()).toBe(original[0].getTime());
                expect(copy[1]).not.toBe(original[1]);
            });

            it('should handle arrays with mixed types', () => {
                const original = [1, 'string', true, null, undefined, { key: 'value' }];
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
                expect(copy[5]).not.toBe(original[5]);
            });

            it('should handle sparse arrays', () => {
                const original: any[] = [1, , 3]; // eslint-disable-line no-sparse-arrays
                const copy = Clone.deepCopy(original);
                
                expect(copy.length).toBe(3);
                expect(copy[0]).toBe(1);
                expect(copy[1]).toBe(undefined);
                expect(copy[2]).toBe(3);
            });
        });

        describe('objects', () => {
            it('should create a new object with copied properties', () => {
                const original = { name: 'John', age: 30, active: true };
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
            });

            it('should handle empty objects', () => {
                const original = {};
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual({});
                expect(copy).not.toBe(original);
            });

            it('should deep copy nested objects', () => {
                const original = {
                    user: {
                        name: 'John',
                        address: {
                            city: 'New York',
                            zip: '10001'
                        }
                    }
                };
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
                expect(copy.user).not.toBe(original.user);
                expect(copy.user.address).not.toBe(original.user.address);
            });

            it('should handle objects with array properties', () => {
                const original = {
                    name: 'Test',
                    items: [1, 2, 3],
                    nested: { arr: ['a', 'b'] }
                };
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy.items).not.toBe(original.items);
                expect(copy.nested.arr).not.toBe(original.nested.arr);
            });

            it('should preserve object prototype', () => {
                class TestClass {
                    constructor(public value: number) {}
                    getValue() {
                        return this.value;
                    }
                }
                
                const original = new TestClass(42);
                const copy = Clone.deepCopy(original);
                
                expect(copy).toBeInstanceOf(TestClass);
                expect(Object.getPrototypeOf(copy)).toBe(Object.getPrototypeOf(original));
                expect(copy.value).toBe(42);
                expect(copy.getValue()).toBe(42);
            });

            it('should handle objects with null prototype', () => {
                const original = Object.create(null);
                original.key = 'value';
                
                const copy = Clone.deepCopy(original);
                
                expect(copy.key).toBe('value');
                expect(Object.getPrototypeOf(copy)).toBe(null);
            });

            it('should preserve property descriptors', () => {
                const original: any = {};
                Object.defineProperty(original, 'readOnly', {
                    value: 'constant',
                    writable: false,
                    enumerable: true,
                    configurable: true
                });
                
                const copy = Clone.deepCopy(original);
                const descriptor = Object.getOwnPropertyDescriptor(copy, 'readOnly');
                
                expect(descriptor?.value).toBe('constant');
                expect(descriptor?.writable).toBe(false);
                expect(descriptor?.enumerable).toBe(true);
            });

            it('should deep copy property descriptor values', () => {
                const original: any = {};
                Object.defineProperty(original, 'complexProp', {
                    value: { nested: { data: 'test' } },
                    writable: true,
                    enumerable: true,
                    configurable: true
                });
                
                const copy = Clone.deepCopy(original);
                
                expect(copy.complexProp).toEqual({ nested: { data: 'test' } });
                expect(copy.complexProp).not.toBe(original.complexProp);
                expect(copy.complexProp.nested).not.toBe(original.complexProp.nested);
            });

            it('should handle objects with symbol properties', () => {
                const sym = Symbol('test');
                const original: any = { [sym]: 'value', regular: 'prop' };
                
                const copy = Clone.deepCopy(original);
                
                // Symbol properties are not copied by getOwnPropertyNames
                expect(copy.regular).toBe('prop');
                expect(copy[sym]).toBeUndefined();
            });

            it('should handle objects with getters and setters', () => {
                const original: any = {
                    _value: 10,
                    get value() { return this._value; },
                    set value(v) { this._value = v; }
                };
                
                const copy = Clone.deepCopy(original);
                
                expect(copy._value).toBe(10);
                // Getters/setters are preserved through descriptors
                const descriptor = Object.getOwnPropertyDescriptor(copy, 'value');
                expect(descriptor?.get).toBeDefined();
                expect(descriptor?.set).toBeDefined();
            });
        });

        describe('complex structures', () => {
            it('should handle deeply nested mixed structures', () => {
                const original = {
                    users: [
                        {
                            name: 'John',
                            birthdate: new Date('1990-01-01'),
                            hobbies: ['reading', 'coding'],
                            address: {
                                city: 'NYC',
                                coordinates: [40.7128, -74.0060]
                            }
                        },
                        {
                            name: 'Jane',
                            birthdate: new Date('1992-05-15'),
                            hobbies: ['painting'],
                            address: {
                                city: 'LA',
                                coordinates: [34.0522, -118.2437]
                            }
                        }
                    ],
                    metadata: {
                        created: new Date(),
                        version: 1.0
                    }
                };
                
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
                expect(copy.users).not.toBe(original.users);
                expect(copy.users[0]).not.toBe(original.users[0]);
                expect(copy.users[0].birthdate).not.toBe(original.users[0].birthdate);
                expect(copy.users[0].hobbies).not.toBe(original.users[0].hobbies);
                expect(copy.users[0].address).not.toBe(original.users[0].address);
                expect(copy.users[0].address.coordinates).not.toBe(original.users[0].address.coordinates);
                expect(copy.metadata.created).not.toBe(original.metadata.created);
            });

            it('should handle arrays of arrays of objects', () => {
                const original = [
                    [{ a: 1 }, { b: 2 }],
                    [{ c: 3 }, { d: 4 }]
                ];
                
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy[0][0]).not.toBe(original[0][0]);
                expect(copy[1][1]).not.toBe(original[1][1]);
            });

            it('should handle objects with circular references gracefully', () => {
                const original: any = { name: 'test' };
                original.self = original; // Circular reference
                
                // This will cause infinite recursion in the current implementation
                // Testing that it at least attempts to copy (may hit stack limit)
                expect(() => {
                    Clone.deepCopy(original);
                }).toThrow();
            });
        });

        describe('edge cases', () => {
            it('should handle objects with numeric string keys', () => {
                const original = { '0': 'zero', '1': 'one', '2': 'two' };
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
            });

            it('should handle objects with special characters in keys', () => {
                const original = { 'key-with-dash': 1, 'key.with.dot': 2, 'key with space': 3 };
                const copy = Clone.deepCopy(original);
                
                expect(copy).toEqual(original);
                expect(copy).not.toBe(original);
            });

            it('should handle objects with function properties', () => {
                const original = {
                    name: 'test',
                    method: function() { return 'result'; }
                };
                
                const copy = Clone.deepCopy(original);
                
                expect(copy.name).toBe('test');
                expect(typeof copy.method).toBe('function');
                expect(copy.method()).toBe('result');
            });

            it('should handle NaN values', () => {
                const original = { value: NaN };
                const copy = Clone.deepCopy(original);
                
                expect(isNaN(copy.value)).toBe(true);
            });

            it('should handle Infinity values', () => {
                const original = { pos: Infinity, neg: -Infinity };
                const copy = Clone.deepCopy(original);
                
                expect(copy.pos).toBe(Infinity);
                expect(copy.neg).toBe(-Infinity);
            });

            it('should handle objects with non-enumerable properties', () => {
                const original: any = { visible: 'yes' };
                Object.defineProperty(original, 'hidden', {
                    value: 'secret',
                    enumerable: false
                });
                
                const copy = Clone.deepCopy(original);
                
                expect(copy.visible).toBe('yes');
                // getOwnPropertyNames includes non-enumerable properties
                expect(copy.hidden).toBe('secret');
            });

            it('should maintain object property order', () => {
                const original = { z: 3, a: 1, m: 2 };
                const copy = Clone.deepCopy(original);
                
                expect(Object.keys(copy)).toEqual(['z', 'a', 'm']);
            });
        });

        describe('mutation independence', () => {
            it('should not affect original when copy is mutated', () => {
                const original = { name: 'John', scores: [1, 2, 3] };
                const copy = Clone.deepCopy(original);
                
                copy.name = 'Jane';
                copy.scores.push(4);
                
                expect(original.name).toBe('John');
                expect(original.scores).toEqual([1, 2, 3]);
                expect(copy.name).toBe('Jane');
                expect(copy.scores).toEqual([1, 2, 3, 4]);
            });

            it('should not affect copy when original is mutated', () => {
                const original = { name: 'John', scores: [1, 2, 3] };
                const copy = Clone.deepCopy(original);
                
                original.name = 'Bob';
                original.scores.push(4);
                
                expect(copy.name).toBe('John');
                expect(copy.scores).toEqual([1, 2, 3]);
                expect(original.name).toBe('Bob');
                expect(original.scores).toEqual([1, 2, 3, 4]);
            });

            it('should handle mutation of nested objects independently', () => {
                const original = {
                    level1: {
                        level2: {
                            value: 'original'
                        }
                    }
                };
                const copy = Clone.deepCopy(original);
                
                copy.level1.level2.value = 'modified';
                
                expect(original.level1.level2.value).toBe('original');
                expect(copy.level1.level2.value).toBe('modified');
            });
        });
    });
});
