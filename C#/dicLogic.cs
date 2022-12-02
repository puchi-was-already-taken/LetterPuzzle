using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace LetterPuzzle
{
  public static class Filter
  {
    private static Boolean FitsFilter(string item, string charFilter)
    {
      foreach (char itemChar in item)
      {
        Boolean found = false;

        foreach (char filterChar in charFilter)
        {
          if (itemChar == filterChar)
          {
            found = true;
            break;
          }
        }

        if (!found)
        {
          return false;
        }
      }

      return true;
    }

    public static Boolean FitsFilterCharCounts(string item, string charFilter, List<int> charCounts)
    {
      if (!FitsFilter(item, charFilter))
      {
        return false;
      }

      for (int i = 0; i < charFilter.Length; i++)
      {

        int filterCharCount = 0;

        foreach (char itemChar in item)
        {
          if (itemChar == charFilter[i])
          {
            filterCharCount++;
          }
        }

        if (filterCharCount > charCounts[i])
        {
          return false;
        }
      }

      return true;
    }
  };

  class WordList
  {
    private Boolean StrIsDigit(string str)
    {
      return !string.IsNullOrEmpty(str) && str.All(char.IsDigit);
    }

    public WordList(string[] rawWordList, Rules affixRules, string charFilter, List<int> charCounts, List<string> blackList)
    {
      List = new List<string>();

      foreach (string line in rawWordList)
      {
        if (line.Trim().Length > 0 && line[0] != '#' && !StrIsDigit(line))
        {
          string[] elements = line.Split('/');
          string baseWord = elements[0].ToLower();

          List<string> baseList = new List<string>();
          if (!blackList.Contains(baseWord) && PushToList(charFilter, charCounts, baseWord) && elements.Length > 1)
          {
            baseList.Clear();

            foreach (char flag in elements[1])
            {
              Rule rule = affixRules.FindRule(flag);

              if (rule != null)
              {
                foreach (RuleSet ruleSet in rule.RuleSets)
                {
                  if (!string.IsNullOrEmpty(ruleSet.Substitution))
                  {
                    Regex regExp = new Regex(ruleSet.Condition, RegexOptions.IgnoreCase);

                    if (regExp.IsMatch(baseWord))
                    {
                      regExp = new Regex(ruleSet.StrippingChars, RegexOptions.IgnoreCase);
                      string wordForm = regExp.Replace(baseWord, ruleSet.Substitution);

                      if (!List.Contains(wordForm))
                      {
                        baseList.Add(wordForm);
                        PushToList(charFilter, charCounts, wordForm);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      CleanDoubles();
    }

    public Boolean PushToList(string charFilter, List<int> charCounts, string item)
    {
      if (!string.IsNullOrEmpty(item) && Filter.FitsFilterCharCounts(item, charFilter, charCounts))
      {
        List.Add(item);
        return true;
      }

      return false;
    }

    public void CleanDoubles()
    {
      List.Sort();

      for (int i = List.Count() - 2; i >= 0; i--)
      {
        if (List[i] == List[i + 1])
        {
          List.RemoveAt(i + 1);
        }
      }
    }

    private static int CompareByLengthAsc(string string1, string string2)
    {
      return string1.Length - string2.Length;
    }

    public void PrepareWordList(int minWordLength)
    {
      List.Sort(CompareByLengthAsc);

      int i = 0;
      while (i < List.Count && List[i].Length < minWordLength)
      {
        i++;
      }

      List.RemoveRange(0, i);
    }
    public List<string> List { get; private set; }

  };
}
