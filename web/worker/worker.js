window.dictionaryList = [];

window.postMessageToFindMistakesWorker = async function (locale, text, dictionary) {
    try {
        // 如果传入了新的字典，则更新全局的 dictionaryList
        if (Array.isArray(dictionary) && dictionary.length > 0) {
            window.dictionaryList = dictionary;
            console.log('Dictionary updated:', window.dictionaryList);
        } else if (window.dictionaryList.length === 0) {
            console.warn('Dictionary is empty. Please provide a valid dictionary.');
        }

        // 模拟处理延迟
        await new Promise(resolve => setTimeout(resolve, 5000));

        // 输出 locale 和 text，并使用已存储的字典
        console.log('postMessageToFindMistakesWorker', locale, text);
        console.log('Using dictionary:', window.dictionaryList);
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