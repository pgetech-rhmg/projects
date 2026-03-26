/**
 * Creates a queue of promise creators that will wait to execute until
 * previous promises complete. This can be used to prevent lots of
 * connections to a server at the same time.
 *
 * In the following example `one.json` and `two.json` start immediately and
 * `three.json` waits until one or two finishes.
 *
 * <pre>
 *   const enqueue = makePromiseQueue(2);
 *   enqueue(() => fetch('https://pge.com/one.json').then(res => res.json());
 *   enqueue(() => fetch('https://pge.com/two.json').then(res => res.json());
 *   enqueue(() => fetch('https://pge.com/three.json').then(res => res.json());
 * </pre>
 *
 * @param {number} maxConcurrentPromises
 * @returns {function(function(): Promise): void}
 */
const makePromiseQueue = maxConcurrentPromises => {
  const queue = [];
  let numActive = 0;
  const update = () => {
    if (numActive < maxConcurrentPromises && queue.length) {
      numActive += 1;
      queue
        .shift()()
        .then(value => {
          numActive -= 1;
          update();
          return value;
        })
        .catch(err => {
          numActive -= 1;
          update();
          throw err;
        });
    }
  };
  return makePromise => {
    queue.push(makePromise);
    update();
  };
};

module.exports = makePromiseQueue;
