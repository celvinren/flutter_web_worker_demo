// JavaScript: Define an EventTarget for streaming results
window.resultEmitter = new EventTarget();

window.postMessageToFindMistakesWorker = async function (locale, text, dictionary) {
    try {
        if (Array.isArray(dictionary) && dictionary.length > 0) {
            window.dictionaryList = dictionary;
            console.log('Dictionary updated:', window.dictionaryList);
        } else if (window.dictionaryList.length === 0) {
            console.warn('Dictionary is empty. Please provide a valid dictionary.');
        }

        // Simulate asynchronous calculation
        const result = await new Promise(resolve => {
            setTimeout(() => resolve(`Processed: ${text} with dictionary ${dictionary}`), 5000);
        });

        // Dispatch an event with the new result
        const event = new CustomEvent('newResult', { detail: result });
        window.resultEmitter.dispatchEvent(event);
        console.log('Event dispatched with result:', result);

    } catch (error) {
        console.error('Error in processing:', error);
    }
};
