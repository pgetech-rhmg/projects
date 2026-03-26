/**
 * This script will download specified channels individually with limited
 * concurrent connections so the server doesn't get overwhelmed.
 *
 * ```
 * node ./download-channels.js swapqa YOUR_SESSION_TOKEN doctype-workorder,doctype-assignment
 * ```
 *
 * Will produce:
 *  * doctype-workorder.json.gz
 *  * doctype-assignment.json.gz
 */
const { exec } = require('child_process');
const fs = require('fs');
const https = require('https');
const makePromiseQueue = require('./makePromiseQueue');
const download = require('./download');

const enqueue = makePromiseQueue(2);

const downloadChannel = (swapEnv, sessionToken, channel) =>
  new Promise((resolve, reject) =>
    enqueue(() => {
      const filePath = `./${channel}.json.gz`;
      console.log(`Downloading ${filePath}`);
      return download(
        `https://${swapEnv}.comp.pge.com/sync_gateway/asset360/_changes?filter=sync_gateway/bychannel&channels=${channel}&include_docs=true&active_only=true`,
        {
          agent: new https.Agent({ rejectUnauthorized: false }),
          headers: {
            Accept: '*/*',
            'Accept-Encoding': 'gzip,deflate',
            Cookie: `SyncGatewaySession=${sessionToken}`,
          },
        },
        filePath
      )
        .then(() => {
          exec(`gunzip -t ${filePath}`, err => {
            if (err) {
              fs.unlink(filePath, () => {});
              reject(err);
            } else {
              resolve();
            }
          });
        })
        .catch(reject);
    })
  );

(argv => {
  if (argv.length < 5) {
    console.log(
      `${argv[0]} ${argv[1]} SWAP_ENV SESSION_TOKEN COMMA,DELIMITED,CHANNELS`
    );
    return;
  }

  const swapEnv = String(argv[2]);
  const sessionToken = String(argv[3]);
  const channels = String(argv[4])
    .split(',')
    .map(s => s.trim());

  channels.forEach(channel =>
    downloadChannel(swapEnv, sessionToken, channel).catch(err =>
      console.error(`Channel ${channel} failed to download`, err)
    )
  );
})(process.argv);
