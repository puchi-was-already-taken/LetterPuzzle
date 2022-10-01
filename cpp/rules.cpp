#include "rules.hpp"
#include "utils.hpp"

bool Rule::containsRuleSet(const std::string &strippingChars, const std::string &substitution, const std::string &condition)
{
    for (const RuleSet *ruleSet : ruleSets)
    {
        if (strippingChars == ruleSet->strippingChars && substitution == ruleSet->substitution && condition == ruleSet->condition)
        {
            return true;
        }
    }

    return false;
}

Rule::~Rule()
{
    for (const RuleSet *ruleSet : ruleSets)
    {
        delete ruleSet;
    }
}

Rules::Rules(const std::vector<std::string> &rawRules)
{
    for (const std::string &element : rawRules)
    {
        if (!element.empty() && element.at(0) != '#')
        {
            std::vector<std::string> elements = split(element, " \t");
            if (elements.size() == 5 && !elements.at(1).empty())
            {
                Rule *rule = findRule(elements.at(1).at(0), elements.at(0));

                if (!rule)
                {
                    rule = new Rule(elements.at(1).at(0), elements.at(0));
                    rules.push_back(rule);
                }

                std::string substitution = lowerCase(elements.at(3));
                if (substitution == "0")
                {
                    substitution = "";
                }

                std::string strippingChars, condition;

                if (rule->affix == "PFX")
                {
                    if (elements.at(2) == "0")
                    {
                        strippingChars = "^";
                    }
                    else
                    {
                        strippingChars = "\\b" + lowerCase(elements.at(2));
                    }

                    condition = "\\b" + lowerCase(elements.at(4));
                }
                else
                {
                    if (elements.at(2) == "0")
                    {
                        strippingChars = "$";
                    }
                    else
                    {
                        strippingChars = lowerCase(elements.at(2)) + "\\b";
                    }

                    condition = lowerCase(elements.at(4)) + "\\b";
                }

                if (!rule->containsRuleSet(strippingChars, substitution, condition))
                {
                    rule->getRuleSets()->push_back(new RuleSet(strippingChars, substitution, condition));
                }
            }
        }
    }
}

Rules::~Rules()
{
    for (const Rule *rule : rules)
    {
        delete rule;
    }
}

Rule *Rules::findRule(const char &flag, const std::string &affix)
{
    for (Rule *rule : rules)
    {
        if (flag == rule->flag && (affix == "" || affix == rule->affix))
        {
            return rule;
        }
    }

    return NULL;
}