const url = require('url');

module.exports = {
  resolveUrlParamsToBuffer: resolveUrlParamsToBuffer
};

function resolveUrlParamsToBuffer(parameters) {
  return new Promise((resolve, reject) => {
    let promises = [];
    Object.keys(parameters).forEach((key) => {
      if (parameters[key] && parameters[key] instanceof url.Url) {
        promises.push(resolveSingleUrlParamToBuffer(parameters[key].href, key));
      }
    });
    Promise.all(promises)
      .then(convertedParams => {
        convertedParams.forEach((result) => {
          parameters[result.key] = result.value;
        });
        resolve(parameters);
      })
      .catch(reject);
  });
}

function resolveSingleUrlParamToBuffer(urlString, key) {
  return new Promise((resolve, reject) => {
    getContent(urlString)
      .then(buffer => {
        resolve({key: key, value: buffer});
      })
      .catch(reject);
  });
}

function getContent(urlString) {
  // return new pending promise
  return new Promise((resolve, reject) => {
    // select http or https module, depending on requested url
    let lib = urlString.startsWith('https') ? require('https') : require('http');
    let request = lib.get(urlString, (response) => {
      // handle http errors
      if (response.statusCode < 200 || response.statusCode > 299) {
        reject(new Error('Failed to load page, status code: ' + response.statusCode));
      }
      // temporary data holder
      let data = [];
      // on every content chunk, push it to the data array
      response.on('data', (chunk) => data.push(chunk));
      // we are done, resolve promise with those joined chunks in a buffer
      response.on('end', () => resolve(Buffer.concat(data)));
    });
    // handle connection errors of the request
    request.on('error', (err) => reject(err))
  })
}