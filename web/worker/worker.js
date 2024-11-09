// JavaScript: Define an EventTarget for streaming results
window.resultEmitter = new EventTarget();

window.postMessageToFindMistakesWorker = async function (text, dictionary, checkedWords) {
    try {
        // Update dictionaryList if a new dictionary is provided
        if (Array.isArray(dictionary) && dictionary.length > 0) {
            window.dictionaryList = dictionary;
            console.log('Dictionary updated:', window.dictionaryList);
        } else if (window.dictionaryList.length === 0) {
            console.warn('Dictionary is empty. Please provide a valid dictionary.');
        }

        // Simulate asynchronous calculation
        const processedText = await new Promise(resolve => {
            setTimeout(() => resolve(`Processed: ${text} with dictionary ${dictionary}`), 5000);
        });

        // Create a result map that includes the original input values and the processed text
        const result = {
            text: text,
            dictionary: dictionary,
            checkedWords: checkedWords,
            processedText: processedText
        };

        // Dispatch an event with the result map
        const event = new CustomEvent('newResult', { detail: result });
        window.resultEmitter.dispatchEvent(event);
        console.log('Event dispatched with result:', result);

    } catch (error) {
        console.error('Error in processing:', error);
    }
};
