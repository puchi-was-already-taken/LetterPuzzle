#ifndef LETTERPUZZLE_HPP
#define LETTERPUZZLE_HPP

#include <string>
#include <vector>
#include <chrono>

class LetterBudget
{
private:
    std::string chars;
    std::vector<size_t> charCounts;
    size_t count = 0;

public:
    LetterBudget(const std::string &word, LetterBudget &letterBudget);
    LetterBudget(const std::vector<std::string> &letters);

    std::string *getChars() { return &chars; };
    std::vector<size_t> *getCharCounts() { return &charCounts; };
    size_t *getCount() { return &count; };
};

void depthFirstSearch(const bool &wordOnlyOnce, const std::vector<std::string> &words, const size_t &startIndex, LetterBudget &budget, const std::string &path, std::vector<std::string> &result);

#endif