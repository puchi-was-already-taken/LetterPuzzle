#include "utils.hpp"

#include <fstream>
#include <algorithm>

void readFile(std::vector<std::string> &list, const std::string &fileName)
{
    std::fstream file;
    file.open(fileName, std::ios::in);

    if (file.is_open())
    {
        std::string line;
        while (getline(file, line))
        {
            list.push_back(line);
        }

        file.close();
    }
}

void writeFile(std::vector<std::string> &list, const std::string &fileName)
{
    std::fstream file;
    file.open(fileName, std::ios::out);

    if (file.is_open())
    {
        for (std::string &line : list)
        {
            file << line << std::endl;
        }

        file.close();
    }
}

bool dontTrim(const unsigned char &character)
{
    return character > ' ';
}

std::string trim(std::string string)
{
    string.erase(string.begin(), std::find_if(string.begin(), string.end(), dontTrim));
    string.erase(std::find_if(string.rbegin(), string.rend(), dontTrim).base(), string.end());
    return string;
}

std::vector<std::string> split(const std::string &string, const std::string &delimiters)
{
    std::vector<std::string> elements;

    size_t previous = 0;
    size_t current;
    while ((current = string.find_first_of(delimiters, previous)) != std::string::npos)
    {
        if (current > previous)
        {
            std::string element = trim(string.substr(previous, current - previous));
            if (!element.empty())
            {
                elements.push_back(element);
            }
        }

        previous = current + 1;
    }

    if (previous < string.length())
    {
        std::string element = trim(string.substr(previous));
        if (!element.empty())
        {
            elements.push_back(element);
        }
    }

    return elements;
}

std::string lowerCase(std::string string)
{
    std::transform(string.cbegin(), string.cend(), string.begin(), tolower);
    return string;
}

bool strIsDigit(std::string string)
{
    return !string.empty() && std::find_if_not(string.begin(), string.end(), isdigit) == string.end();
}

bool stringVectorContains(std::vector<std::string> &vector, std::string &string)
{
    return std::find(vector.begin(), vector.end(), string) != vector.end();
}