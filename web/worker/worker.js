self.onmessage = async function(event) {
    const { data, a, b } = event.data;
    console.log('data', data);
    console.log('a', a);
    console.log('b', b);
    const result = await calculate(data, a, b);
    self.postMessage(result);
  }
  
async function calculate(data, a, b) {
    // This async function will be run in the worker thread.
    return new Promise(resolve => {
        setTimeout(() => {
        resolve((data * a) + b);
        }, 3000);
    });
}