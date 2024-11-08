window.postMessageToFindMistakesWorker = async function (locale, text) {
    try {
        await new Promise(resolve => setTimeout(resolve, 5000));
        console.log('postMessageToFindMistakesWorker', locale, text);
        window.foundMistakesResult = text;
    } catch (error) {
        throw error;
    }
};

function getResult() {
    return window.foundMistakesResult;
}

function deleteResult() {
    window.foundMistakesResult = null;
}