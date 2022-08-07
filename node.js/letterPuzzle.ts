import * as fs from 'fs';
import { Rule, RuleSet, generateRuleList } from './affLogic';
import { fitsFilterCharCounts, generateWordList } from './dicLogic';

interface LetterBudget {
    chars: string;
    charCounts: number[];
    count: number;
};

function initLetterBudget(letters: string[], letterBudget: LetterBudget): void {
    letterBudget.chars = '';
    letterBudget.count = 0;

    for (const letter of letters) {
        letterBudget.chars += letter[0];
        letterBudget.count += letter.length;
        letterBudget.charCounts[letter[0]] = letter.length;
    };
};

function reduceBugdetByWord(word: string, budget: LetterBudget): LetterBudget {
    const result: LetterBudget = {
        chars: '',
        charCounts: [],
        count: 0
    };

    for (let i = 0; i < budget.chars.length; i++) {
        const filterChar = budget.chars[i];

        let filterCharCount = 0;
        for (let j = 0; j < word.length; j++) {
            if (word[j] === filterChar) {
                filterCharCount++;
            };
        };

        if (budget.charCounts[filterChar] > filterCharCount) {
            result.chars += filterChar;
            result.charCounts[filterChar] = budget.charCounts[filterChar] - filterCharCount;
        };

        result.count += budget.charCounts[filterChar] - filterCharCount;
    };

    return result;
};

function depthFirstSearch(wordOnlyOnce: Boolean, words: string[], startIndex: number, budget: LetterBudget, path: string, result: string[]): void {
    if (budget.count === 0) {
        result.push(path);

        if (result.length % 1000 === 0) {
            let duration = new Date().getTime() - start;
            console.log(`Count: ${result.length} (${(result.length / (duration / 1000))} / sec): ${result[result.length - 1]}`);
        };
    } else {
        for (let i = startIndex; i >= 0; i--) {
            const word = words[i];

            if (word.length > budget.count) {
                // words array is expected to be sorted by length.
                return;
            };

            if (fitsFilterCharCounts(word, budget.chars, budget.charCounts)) {
                if (wordOnlyOnce) {
                    depthFirstSearch(wordOnlyOnce, words, i - 1, reduceBugdetByWord(word, budget), path + ',' + word, result);
                } else {
                    depthFirstSearch(wordOnlyOnce, words, i, reduceBugdetByWord(word, budget), path + ',' + word, result);
                };
            };
        };
    };
};

function prepareWordList(words: string[], minWordLength: number): void {
    words.sort(function (a, b) {
        return b.length - a.length;
    });

    let i = words.length - 1;
    while (i >= 0 && words[i].length < minWordLength) {
        i--;
    };

    if (i < words.length - 1) {
        words.splice(i + 1);
    };
};

const lettersBudget: LetterBudget = {
    chars: '',
    charCounts: [],
    count: 0
};

//initLetterBudget(['eeeeeee', 'tt', 'l', 'iiiii', 'f', 'nnnn', 'ü', 'rr', 'u', 'h', 'c', 'ss', 'g', 'a', 'b', 'm'], lettersBudget);
initLetterBudget(['aa', 'e','hh','ll','o','i','r','d', 'nn', 't', 'u'], lettersBudget);
//initLetterBudget(['a', 'd', 'e', 'hh', 'ii', 'll', 'o', 'rr'], lettersBudget);
//initLetterBudget(['aa','hh','ll','o','i','r','d'], lettersBudget);
//initLetterBudget(['a', 'h', 'll', 'o'], lettersBudget);

const aff = fs.readFileSync('../hunspell/de_DE_frami_mod.aff');
const rules = generateRuleList(aff.toString().split('\r\n'));

const blackList = ['utrecht'];
const dic = fs.readFileSync('../hunspell/de_DE_frami.dic');
const words = generateWordList(dic.toString().split('\r\n'), rules, lettersBudget.chars, lettersBudget.charCounts, blackList);

prepareWordList(words, 2);

fs.writeFileSync('words.txt', words.join('\r\n'));

var start = new Date().getTime();

const result: string[] = [];
depthFirstSearch(true, words, words.length - 1, lettersBudget, '', result);

let duration = new Date().getTime() - start;
console.log(`Duration: ${duration /1000}sec Count: ${result.length} (${(result.length / (duration / 1000))} / sec): ${result[result.length - 1]}`);

fs.writeFileSync('combinations.txt', result.join('\r\n'));
