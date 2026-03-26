const fs = require('fs');
const https = require('https');

const download = (url, options, path) =>
  new Promise((resolve, reject) => {
    const file = fs.createWriteStream(path);

    if (!file) {
      reject(Error('Could not create file write stream'));
      return;
    }

    file.on('error', err => {
      file.end(() => fs.unlink(path, () => {}));
      reject(Error(`File Error: ${err.message}`));
    });

    file.on('finish', resolve);

    const request = https.get(url, options, response => {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        response.pipe(file);
      } else {
        file.end(() => fs.unlink(path, () => {}));
        reject(
          Error(`HTTP Error: ${response.statusCode} ${response.statusText}`)
        );
      }
    });

    if (!request) {
      file.end(() => fs.unlink(path, () => {}));
      reject(Error('Could not create HTTP request'));
      return;
    }

    request.on('error', err => {
      file.end(() => fs.unlink(path, () => {}));
      reject(Error(`Request Error: ${err.message}`));
    });

    request.on('abort', () => {
      file.end(() => fs.unlink(path, () => {}));
      reject(Error(`Request Aborted`));
    });

    request.on('timeout', () => {
      file.end(() => fs.unlink(path, () => {}));
      request.destroy();
      reject(Error(`Request Timeout`));
    });
  });

module.exports = download;
