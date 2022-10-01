#ifndef UTILS_HPP
#define UTILS_HPP

#include <string>
#include <vector>

void readFile(std::vector<std::string> &list, const std::string &fileName);
void writeFile(std::vector<std::string> &list, const std::string &fileName);
std::vector<std::string> split(const std::string &string, const std::string &delimiters);
std::string trim(std::string string);
std::string lowerCase(std::string string);
bool strIsDigit(std::string string);
bool stringVectorContains(std::vector<std::string> &vector, std::string &string);

#endif