#include "dicLogic.hpp"
#include "utils.hpp"
#include <algorithm>
#include <regex>

bool fitsFilter(const std::string &item, const std::string &charFilter)
{
    return item.find_first_not_of(charFilter) == std::string::npos;
}

bool fitsFilterCharCounts(const std::string &item, const std::string &charFilter, const std::vector<size_t> &charCounts)
{
    if (!fitsFilter(item, charFilter))
    {
        return false;
    }

    for (size_t i = 0; i < charFilter.length(); i++)
    {
        ptrdiff_t filterCharCount = std::count(item.begin(), item.end(), charFilter.at(i));
        if (filterCharCount > 0 && (size_t)filterCharCount > charCounts.at(i))
        {
            return false;
        }
    }

    return true;
}

WordList::WordList(std::vector<std::string> &rawWordList, Rules &affixRules, const std::string &charFilter, const std::vector<size_t> &charCounts, std::vector<std::string> &blackList)
{
    for (const std::string &line : rawWordList)
    {
        if (trim(line).length() > 0 && line.at(1) != '#' && !strIsDigit(line))
        {
            std::vector<std::string> elements = split(line, "/");
            std::string baseWord = lowerCase(elements.at(0));

            std::vector<std::string> baseList;
            if (!stringVectorContains(blackList, baseWord) && pushToList(charFilter, charCounts, baseWord) && elements.size() > 1)
            {
                baseList.clear();

                for (const char &flag : elements.at(1))
                {
                    Rule *rule = affixRules.findRule(flag);

                    if (rule)
                    {
                        for (const RuleSet *ruleSet : *rule->getRuleSets())
                        {
                            if (!ruleSet->substitution.empty())
                            {
                                std::regex regEx = std::regex(ruleSet->condition, std::regex_constants::icase);

                                if (std::regex_search(baseWord, regEx, std::regex_constants::match_not_null))
                                {
                                    regEx = std::regex(ruleSet->strippingChars, std::regex_constants::icase);
                                    std::string wordForm = std::regex_replace(baseWord, regEx, ruleSet->substitution);

                                    if (!stringVectorContains(baseList, wordForm))
                                    {
                                        baseList.push_back(wordForm);
                                        pushToList(charFilter, charCounts, wordForm);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    cleanDoubles();
}

bool WordList::pushToList(const std::string &charFilter, const std::vector<size_t> &charCounts, const std::string &item)
{
    if (!item.empty() && fitsFilterCharCounts(item, charFilter, charCounts))
    {
        wordList.push_back(item);
        return true;
    }

    return false;
}

void WordList::cleanDoubles()
{
    std::sort(wordList.begin(), wordList.end());

    for (size_t i = wordList.size() - 1; i > 0; i--)
    {
        if (wordList.at(i) == wordList.at(i - 1))
        {
            wordList.erase(wordList.begin() + i);
        }
    }
}

bool compareByLengthAsc(const std::string &string1, const std::string &string2)
{
    return string1.length() < string2.length();
}

void WordList::prepareWordList(const size_t &minWordLength)
{
    std::sort(wordList.begin(), wordList.end(), compareByLengthAsc);

    auto isMinWordLength = [&](std::string string)
    {
        return string.length() >= minWordLength;
    };

    wordList.erase(wordList.begin(), std::find_if(wordList.begin(), wordList.end(), isMinWordLength));
}