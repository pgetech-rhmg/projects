// Karma configuration for EPIC.
//
// Mirrors the `@angular/build:karma` builder's built-in config (frameworks,
// plugins, ChromeHeadlessNoSandbox launcher) with ONE change for CI: the coverage
// reporter also emits `lcov` to `reports/coverage/lcov.info`, which the EPIC
// SonarQube scan ingests via `sonar.javascript.lcov.reportPaths`. The builder
// still injects its own Angular polyfills/reporter and auto-enables coverage when
// run with `--code-coverage`.
const path = require('node:path');

module.exports = function karmaConfig(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],
    plugins: [
      'karma-jasmine',
      'karma-chrome-launcher',
      'karma-jasmine-html-reporter',
      'karma-coverage',
    ].map((p) => require(p)),
    jasmineHtmlReporter: {
      suppressAll: true, // removes the duplicated traces
    },
    coverageReporter: {
      dir: path.join(__dirname, 'reports/coverage'),
      subdir: '.',
      reporters: [
        { type: 'html' },
        { type: 'lcovonly', file: 'lcov.info' }, // consumed by the EPIC SonarQube scan
        { type: 'text-summary' },
      ],
    },
    reporters: ['progress', 'kjhtml'],
    browsers: ['Chrome'],
    customLaunchers: {
      // Chrome configured for CI build agents (run as root in a container).
      ChromeHeadlessNoSandbox: {
        base: 'ChromeHeadless',
        flags: ['--no-sandbox', '--headless', '--disable-gpu', '--disable-dev-shm-usage'],
      },
    },
    restartOnFileChange: true,
  });
};
