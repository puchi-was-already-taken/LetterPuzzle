#include "letterPuzzle.hpp"
#include "dicLogic.hpp"
#include <algorithm>
#include <map>
#include <iostream>

LetterBudget::LetterBudget(const std::string &word, LetterBudget &letterBudget)
{

    charCounts.reserve(letterBudget.chars.length());

    for (size_t i = 0; i < letterBudget.chars.length(); i++)
    {
        size_t filterCharCount = 0;

        for (const char &wordChar : word)
        {
            if (wordChar == letterBudget.chars.at(i))
            {
                filterCharCount += 1;
            }
        }

        if (letterBudget.charCounts.at(i) != filterCharCount)
        {
            chars += letterBudget.chars.at(i);
            charCounts.push_back(letterBudget.charCounts.at(i) - filterCharCount);
        }

        count += letterBudget.charCounts.at(i) - filterCharCount;
    }
}

LetterBudget::LetterBudget(const std::vector<std::string> &letters)
{
    for (const std::string &letter : letters)
    {
        count += letter.length();

        // Respect unicode.
        std::map<const char, size_t> chars;
        for (const char &chr : letter)
        {
            chars[chr] += 1;
        }

        for (const std::pair<const char, size_t> &charCount : chars)
        {
            this->chars += charCount.first;
            charCounts.push_back(charCount.second);
        }
    }
}

std::chrono::steady_clock::time_point start;

void depthFirstSearch(const bool &wordOnlyOnce, const std::vector<std::string> &words, const size_t &startIndex, LetterBudget &budget, const std::string &path, std::vector<std::string> &result)
{
    if (*budget.getCount() == 0)
    {
        result.push_back(path);

        if (result.size() % 1000 == 0)
        {
            int64_t duration = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - start).count();
            std::cout << "Count: " << result.size() << " (" << result.size() / (duration / 1000000.0) << " / sec): " << result.at(result.size() - 1) << std::endl;
        }
    }
    else
    {
        for (size_t i = startIndex; i < words.size(); i++)
        {
            if (words.at(i).length() > *budget.getCount())
            {
                // words array is expected to be sorted by length.
                return;
            }

            if (fitsFilterCharCounts(words.at(i), *budget.getChars(), *budget.getCharCounts()))
            {
                LetterBudget letterBudget = LetterBudget(words.at(i), budget);
                if (wordOnlyOnce)
                {
                    depthFirstSearch(wordOnlyOnce, words, i + 1, letterBudget, path + ',' + words.at(i), result);
                }
                else
                {
                    depthFirstSearch(wordOnlyOnce, words, i, letterBudget, path + ',' + words.at(i), result);
                }
            }
        }
    }
}