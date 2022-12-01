#ifndef DICLOGIC_HPP
#define DICLOGIC_HPP

#include "rules.hpp"
#include <string>
#include <vector>

bool fitsFilterCharCounts(const std::string &item, const std::string &charFilter, const std::vector<size_t> &charCounts);

class WordList
{
private:
    std::vector<std::string> wordList;

public:
    WordList(std::vector<std::string> &rawWordList, Rules &affixRules, const std::string &charFilter, const std::vector<size_t> &charCounts, std::vector<std::string> &blackList);

    bool pushToList(const std::string &charFilter, const std::vector<size_t> &charCounts, const std::string &item);
    void cleanDoubles();
    void prepareWordList(const size_t &minWordLength);
    std::vector<std::string> *getWordList() { return &wordList; };
};

#endif