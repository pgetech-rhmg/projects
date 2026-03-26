const ava = require('ava');
const makePromiseQueue = require('./makePromiseQueue');

ava(
  'queued second promise will not run until active first promise resolves',
  test =>
    new Promise(resolveTest => {
      const enqueue = makePromiseQueue(1);
      const results = [];
      enqueue(
        () =>
          new Promise(resolve =>
            setTimeout(() => {
              results.push('first');
              resolve();
            }, 20)
          )
      );
      enqueue(
        () =>
          new Promise(resolve => {
            results.push('second');
            test.deepEqual(results, ['first', 'second']);
            resolve();
            resolveTest();
          })
      );
    })
);

ava(
  'queued promise will run if active promise rejects',
  test =>
    new Promise(resolveTest => {
      const enqueue = makePromiseQueue(1);
      const results = [];
      enqueue(() =>
        new Promise((_, reject) => {
          results.push('first');
          reject(Error('expected-error'));
        }).catch(err => {
          test.is(err.message, 'expected-error');
        })
      );
      enqueue(
        () =>
          new Promise(resolve => {
            results.push('second');
            test.deepEqual(results, ['first', 'second']);
            resolve();
            resolveTest();
          })
      );
    })
);
