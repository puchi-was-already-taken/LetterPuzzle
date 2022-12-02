using System;
using System.Collections.Generic;

namespace LetterPuzzle
{
  class RuleSet
  {
    public RuleSet(string strippingChars, string substitution, string condition)
    {
      this.StrippingChars = strippingChars;
      this.Substitution = substitution;
      this.Condition = condition;
    }

    public string StrippingChars { get; }
    public string Substitution { get; }
    public string Condition { get; }
  };

  class Rule
  {
    public Rule(char flag, string affix)
    {
      RuleSets = new();
      this.Flag = flag;
      this.Affix = affix;
    }

    public Boolean ContainsRuleSet(string strippingChars, string substitution, string condition)
    {
      foreach (RuleSet ruleSet in RuleSets)
      {
        if (strippingChars == ruleSet.StrippingChars && substitution == ruleSet.Substitution && condition == ruleSet.Condition)
        {
          return true;
        }
      }

      return false;
    }

    public char Flag { get; }
    public string Affix { get; }
    public List<RuleSet> RuleSets { get; private set; }
  };

  class Rules
  {
    private static readonly char[] separators = { ' ', '\t' };

    public Rules(string[] rawRules)
    {
      List = new();

      foreach (string element in rawRules)
      {
        if (!string.IsNullOrEmpty(element) && element[0] != '#')
        {
          string[] elements = element.Split(separators, StringSplitOptions.RemoveEmptyEntries);
          if (elements.Length == 5 && !string.IsNullOrEmpty(elements[1]))
          {
            Rule? rule = FindRule(elements[1][0], elements[0]);

            if (rule == null)
            {
              rule = new(elements[1][0], elements[0]);
              List.Add(rule);
            }

            string substitution = elements[3].ToLower();
            if (substitution == "0")
            {
              substitution = "";
            }

            string strippingChars, condition;

            if (rule.Affix == "PFX")
            {
              if (elements[2] == "0")
              {
                strippingChars = "^";
              }
              else
              {
                strippingChars = "\\b" + elements[2].ToLower();
              }

              condition = "\\b" + elements[4].ToLower();
            }
            else
            {
              if (elements[2] == "0")
              {
                strippingChars = "$";
              }
              else
              {
                strippingChars = elements[2].ToLower() + "\\b";
              }

              condition = elements[4].ToLower() + "\\b";
            }

            if (!rule.ContainsRuleSet(strippingChars, substitution, condition))
            {
              rule.RuleSets.Add(new(strippingChars, substitution, condition));
            }
          }
        }
      }
    }

    public Rule? FindRule(char flag, string affix = "")
    {
      foreach (Rule rule in List)
      {
        if (flag == rule.Flag && (affix == "" || affix == rule.Affix))
        {
          return rule;
        }
      }

      return null;
    }

    public List<Rule> List { get; private set; }
  };
}
