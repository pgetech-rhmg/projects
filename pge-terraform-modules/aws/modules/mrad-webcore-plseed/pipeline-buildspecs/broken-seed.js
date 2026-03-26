/**
 * This script will download the ids in ids.json in chunks. If a download
 * fails it will split that set of ids into smaller chunks and retry.
 *
 * If you are testing this locally you will need to replace
 * `sync_gateway_admin` with `sync_gateway` and add a session token cookie
 * to the `download` function call.
 *
 */
const { exec } = require('child_process');
const fs = require('fs');
const https = require('https');
const makePromiseQueue = require('./makePromiseQueue');
const download = require('./download');

// The ids list will be split into sets of MAX_DOCS_PER_REQUEST before
// requests begin. If a request fails that subset will be split into
// DOCS_SUBDIVISIONS and retried. This script will exit with an error if
// subset size becomes smaller than MIN_DOCS_PER_REQUEST.

const MAX_DOCS_PER_REQUEST = 10000;
const MIN_DOCS_PER_REQUEST = 20;
const DOCS_SUBDIVISIONS = 3;

const syncGatewayEndpoint = {
  dev: 'admin-sgw-dev.dc.pge.com',
  qa: 'admin-sgw-qa.dc.pge.com',
  prod: 'admin-sgw-prod.dc.pge.com',
}[process.env.ENVIRONMENT];

const enqueue = makePromiseQueue(4);

process.on(
  'unhandledRejection',
  error => console.error(error) || process.exit(1)
);

const chunk = (array, size) => {
  if (size < 1) {
    return [];
  }
  const result = [];
  for (let i = 0; i < array.length; i += size) {
    result.push(array.slice(i, i + size));
  }
  return result;
};

const downloadSeedsByIds = (ids, channel, swapEnv, firstRun) =>
  new Promise((resolve, reject) =>
    enqueue(() => {
      const filePath = `./seeds/${channel}-${ids[0]}-${ids.length}.json.gz`;

      const handleError = err => {
        console.log(
          `Download of ${filePath} failed with reason: ${err.message}`
        );
        const subsetSize = Math.ceil(ids.length / DOCS_SUBDIVISIONS);
        if (subsetSize < MIN_DOCS_PER_REQUEST) {
          console.log(
            'Splitting request would result in fewer docs than config permits. Not retrying'
          );
          reject(err);
        } else {
          console.log(`Retrying request with ${subsetSize} docs`);
          Promise.all(
            chunk(ids, subsetSize).map(subset =>
              downloadSeedsByIds(subset, channel, swapEnv)
            )
          )
            .then(resolve)
            .catch(reject);
        }
      };

      console.log(`Initiating download of ${filePath}`);
      console.log(`Using the following endpoint for ${syncGatewayEndpoint}`);
      console.log(
        'fetching',
        `https://${syncGatewayEndpoint}/asset360/_changes?filter=sync_gateway/bychannel&channels=${channel}&include_docs=true&active_only=true&since=${
          firstRun ? 0 : ids[0]
        }&limit=${ids.length}`
      );
      return download(
        `https://${syncGatewayEndpoint}/asset360/_changes?filter=sync_gateway/bychannel&channels=${channel}&include_docs=true&active_only=true&since=${
          firstRun ? 0 : ids[0]
        }&limit=${ids.length}`,
        {
          agent: new https.Agent({ rejectUnauthorized: false }),
          headers: {
            Accept: '*/*',
            'Accept-Encoding': 'gzip,deflate',
            // Cookie: '',
          },
        },
        filePath
      )
        .then(() => {
          console.log(`Download finished. Validating ${filePath}`);
          exec(`gunzip -t ${filePath}`, err => {
            if (err) {
              fs.unlink(filePath, () => {});
              handleError(err);
            } else {
              console.log(`Validation of ${filePath} successful`);
              resolve();
            }
          });
        })
        .catch(handleError);
    })
  );

(() => {
  try {
    console.log('Starting broken-seed');
    console.log('Reading ids file');
    // The execution context is the root of this repo
    const ids = require('../../../ids.json')[0]
      .results.filter(result => result.changes.length)
      .map(id => id.seq);

    console.log(`Chunking ${ids.length} ids`);
    const chunks = chunk(ids, MAX_DOCS_PER_REQUEST);

    console.log(`Starting download of ${chunks.length} chunks`);
    Promise.all(
      chunks.map((subset, index) =>
        downloadSeedsByIds(
          subset,
          process.env.CHANNEL,
          process.env.SWAP_ENV,
          index === 0
        )
      )
    )
      .then(() => console.log('done!'))
      .catch(() => {
        console.error(
          `Failed to download complete set of seeds for ${process.env.CHANNEL}`
        );
        process.exit(1);
      });
  } catch (err) {
    console.error(`Exception in broken-seed ${err.message}`);
    process.exit(1);
  }
})();
