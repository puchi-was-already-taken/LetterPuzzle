#ifndef RULES_HPP
#define RULES_HPP

#include <string>
#include <vector>

class RuleSet
{
public:
    RuleSet(const std::string &strippingChars, const std::string &substitution, const std::string &condition) : strippingChars(strippingChars),
                                                                                                                substitution(substitution),
                                                                                                                condition(condition){};

    std::string strippingChars;
    std::string substitution;
    std::string condition;
};

class Rule
{
private:
    std::vector<RuleSet *> ruleSets;

public:
    Rule(const char &flag, const std::string &affix) : flag(flag),
                                                       affix(affix){};
    ~Rule();

    bool containsRuleSet(const std::string &strippingChars, const std::string &substitution, const std::string &condition);

    char flag;
    std::string affix;
    std::vector<RuleSet *> *getRuleSets() { return &ruleSets; };
};

class Rules
{
private:
    std::vector<Rule *> rules;

public:
    Rules(const std::vector<std::string> &rawRules);
    ~Rules();

    Rule *findRule(const char &flag, const std::string &affix = "");
    std::vector<Rule *> *getRules() { return &rules; };
};

#endif