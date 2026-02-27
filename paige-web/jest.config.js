module.exports = {
  preset: 'jest-preset-angular',

  setupFilesAfterEnv: ['<rootDir>/setup-jest.ts'],

  testPathIgnorePatterns: ['/node_modules/', '/dist/'],

  collectCoverage: true,
  coverageDirectory: './reports/coverage',
  coverageReporters: ['lcov', 'text-summary'],

  testResultsProcessor: 'jest-sonar-reporter',

  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/main.ts',
    '!src/polyfills.ts',
    '!src/**/*.spec.ts',
    '!src/test.ts',
    '!src/environments/**'
  ],

  moduleNameMapper: {
    '^~\\/(.*)$': '<rootDir>/src/app/$1'
  },

  transform: {
    '^.+\\.(ts|js|html)$': [
      'jest-preset-angular',
      {
        tsconfig: '<rootDir>/tsconfig.spec.json',
        stringifyContentPathRegex: '\\.(html|svg)$',
      },
    ],
  },
};

