// worker_init.js

// Check if Trusted Types are supported and create a Trusted Type Policy
if (window.trustedTypes) {
    window.policy = trustedTypes.createPolicy('default', {
        createScriptURL: (url) => url
    });
}

const workerUrl = 'worker/worker.js';
const trustedWorkerUrl = window.policy ? window.policy.createScriptURL(workerUrl) : workerUrl;

// Create the Web Worker with the trusted URL
const worker = new Worker(trustedWorkerUrl);

worker.onmessage = function (event) {
    // When Web Worker got a return value, send the result to Flutter
    window.workerResult = event.data;
};

// Expose postMessage function in Web Worker to Flutter
window.postMessageToWorker = function (data, a, b) {
    worker.postMessage({ data: data, a: a, b: b });
};
