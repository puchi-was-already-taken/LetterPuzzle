using System;
using System.Collections.Generic;
using System.Linq;
using System.Diagnostics;

namespace LetterPuzzle
{
  class Program
  {
    private static readonly Stopwatch stopWatch = new();

    static void Main()
    {
      string[] aff, dic;

      aff = System.IO.File.ReadAllLines("../../../hunspell/de_DE_frami_mod.aff");
      dic = System.IO.File.ReadAllLines("../../../hunspell/de_DE_frami.dic");
      Console.WriteLine("aff-count: {0}", aff.Length);
      Console.WriteLine("dic-count: {0}", dic.Length);

      Rules rules = new(aff);
      Console.WriteLine("rule-count: {0}", rules.List.Count);

      LetterBudget letterBudget = new(new[] { "aa", "e", "hh", "ll", "o", "i", "r", "d", "nn", "t", "u" }); // "hallo ihr da unten"

      List<string> blacklist = new()
      {
        "utrecht"
      };

      WordList wordList = new(dic, rules, letterBudget.Chars, letterBudget.CharCounts, blacklist);
      wordList.PrepareWordList(2);

      List<string> result = new();

      stopWatch.Start();
      DepthFirstSearch(true, wordList.List, 0, letterBudget, "", result);
      stopWatch.Stop();

      long duration = stopWatch.ElapsedMilliseconds;

      if (duration == 0)
      {
        Console.WriteLine("Duration: {0}sec Count: {1}: {2}", 0, result.Count, result.Last());
      }
      else
      {
        Console.WriteLine("Duration: {0}sec Count: {1} ({2} / sec): {3}", duration / 1000.0, result.Count, result.Count / (duration / 1000.0), result.Last());
      }

      System.IO.File.WriteAllLines("results", result);
    }

    static void DepthFirstSearch(Boolean wordOnlyOnce, List<string> words, int startIndex, LetterBudget budget, string path, List<string> result)
    {
      if (budget.Count == 0)
      {
        result.Add(path);

        if (result.Count % 1000 == 0)
        {
          long duration = stopWatch.ElapsedMilliseconds;
          if (duration == 0)
          {
            Console.WriteLine("Count: {0} : {1}", result.Count, path);
          }
          else
          {
            Console.WriteLine("Count: {0} ({1} / sec): {2}", result.Count, result.Count / (duration / 1000.0), path);
          }
        }
      }
      else
      {
        for (int i = startIndex; i < words.Count; i++)
        {
          if (words[i].Length > budget.Count)
          {
            // words array is expected to be sorted by length.
            return;
          }

          if (Filter.FitsFilterCharCounts(words[i], budget.Chars, budget.CharCounts))
          {
            LetterBudget letterBudget = new(words[i], budget);
            if (wordOnlyOnce)
            {
              DepthFirstSearch(wordOnlyOnce, words, i + 1, letterBudget, path + ',' + words[i], result);
            }
            else
            {
              DepthFirstSearch(wordOnlyOnce, words, i, letterBudget, path + ',' + words[i], result);
            }
          }
        }
      }
    }
  }
}
