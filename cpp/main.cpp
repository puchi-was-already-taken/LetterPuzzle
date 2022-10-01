#include "utils.hpp"
#include "rules.hpp"
#include "dicLogic.hpp"
#include "letterPuzzle.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <chrono>

extern std::chrono::steady_clock::time_point start;

int main()
{
    std::vector<std::string> aff, dic, result;
    readFile(aff, "../../hunspell/de_DE_frami_mod.aff");
    readFile(dic, "../../hunspell/de_DE_frami.dic");

    Rules rules = Rules(aff);

    LetterBudget letterBudget = LetterBudget({"aa", "e", "hh", "ll", "o", "i", "r", "d", "nn", "t", "u"}); // "hallo ihr da unten"

    std::vector<std::string> blacklist = {"utrecht"};
    WordList wordList = WordList(dic, rules, *letterBudget.getChars(), *letterBudget.getCharCounts(), blacklist);

    wordList.prepareWordList(2);

    start = std::chrono::steady_clock::now();

    depthFirstSearch(true, *wordList.getWordList(), 0, letterBudget, "", result);

    int64_t duration = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - start).count();

    if (duration == 0)
    {
        std::cout << "Duration: " << 0 << "sec Count: " << result.size() << " : " << result.at(result.size() - 1);
    }
    else
    {
        std::cout << "Duration: " << (duration / 1000000.0) << "sec Count: " << result.size() << " (" << result.size() / (duration / 1000000.0) << " / sec): " << result.at(result.size() - 1);
    }

    writeFile(result, "results");
}