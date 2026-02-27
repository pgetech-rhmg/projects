export class Clone {
    public static deepCopy<T>(source: T): T {
        if (Array.isArray(source)) {
            return this.copyArray(source) as unknown as T;
        }

        if (source instanceof Date) {
            return this.copyDate(source) as unknown as T;
        }

        if (source && typeof source === 'object') {
            return this.copyObject(source);
        }

        return source;
    }

    private static copyArray<T>(source: T[]): T[] {
        return source.map(item => this.deepCopy(item));
    }

    private static copyDate(source: Date): Date {
        return new Date(source);
    }

    private static copyObject<T>(source: T): T {
        const copy = Object.create(Object.getPrototypeOf(source));
        Object.getOwnPropertyNames(source).forEach(prop => {
            const descriptor = Object.getOwnPropertyDescriptor(source, prop);
            if (descriptor) {
                // Check if it's an accessor property (getter/setter)
                if (descriptor.get || descriptor.set) {
                    // Copy accessor descriptors as-is (don't clone the functions)
                    Object.defineProperty(copy, prop, descriptor);
                } else {
                    // For data properties, clone the value
                    const clonedValue = this.deepCopy((source as { [key: string]: any })[prop]);
                    Object.defineProperty(copy, prop, {
                        ...descriptor,
                        value: clonedValue
                    });
                }
            }
        });
        return copy as T;
    }
}
