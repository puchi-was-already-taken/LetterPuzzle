import { Rule, RuleSet, findRule } from './affLogic';

function fitsFilter(item: string, charFilter: string): Boolean {
    for (let i = 0; i < item.length; i++) {
        if (charFilter.indexOf(item[i]) === -1) {
            return false;
        };
    };

    return true;
};

function fitsFilterCharCounts(item: string, charFilter: string, charCounts: number[]): Boolean {
    if (!fitsFilter(item, charFilter)) {
        return false;
    };

    for (let i = 0; i < charFilter.length; i++) {
        const filterChar = charFilter[i];

        let filterCharCount = 0;
        for (let j = 0; j < item.length; j++) {
            if (item[j] === filterChar) {
                filterCharCount++;
            };
        };

        if (charCounts[filterChar] && filterCharCount > charCounts[filterChar]) {
            return false;
        };
    };

    return true;
};

function pushToList(list: string[], charFilter: string, charCounts: number[], item: string): Boolean {
    if (item.length > 0 && fitsFilterCharCounts(item, charFilter, charCounts)) {
        list.push(item);
        return true;
    };

    return false;
};

function cleanDoubles(list: string[]) {
    list.sort();

    for (let i = list.length - 2; i >= 0; i--) {
        if (list[i] === list[i + 1]) {
            list.splice(i + 1, 1);
        };
    };
};

function generateWordList(rawWordList: string[], affixRules: Rule[], charFilter: string, charCounts: number[], blackList: string[]): string[] {
    let list: string[] = [];

    for (const line of rawWordList) {
        if (line[0] !== '#' && line.trim().length > 0 && !line.match(/\d+/)) {
            const elements = line.split('/');

            let baseWord = elements[0].toLowerCase();
            if (blackList.indexOf(baseWord) === -1 && pushToList(list, charFilter, charCounts, baseWord) && elements[1]) {

                let baseList: string[] = [];

                for (let i = 0; i < elements[1].length; i++) {
                    const flag = elements[1][i];
                    const rule = findRule(affixRules, flag);

                    if (rule) {
                        for (const ruleSet of rule.ruleSets) {
                            if (ruleSet.substitution.length > 0) {
                                if (ruleSet.condition.test(baseWord)) {
                                    const wordForm = baseWord.replace(ruleSet.strippingChars, ruleSet.substitution);

                                    if (baseList.indexOf(wordForm) === -1) {
                                        baseList.push(wordForm);
                                        pushToList(list, charFilter, charCounts, wordForm);
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };

    cleanDoubles(list);
    return list;
};

export { fitsFilterCharCounts, generateWordList };