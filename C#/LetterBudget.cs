using System.Collections.Generic;

namespace LetterPuzzle
{
  class LetterBudget
  {
    public LetterBudget(string word, LetterBudget letterBudget)
    {
      CharCounts.Capacity = letterBudget.Chars.Length;

      for (int i = 0; i < letterBudget.Chars.Length; i++)
      {
        int filterCharCount = 0;

        foreach (char wordChar in word)
        {
          if (wordChar == letterBudget.Chars[i])
          {
            filterCharCount++;
          }
        }

        if (letterBudget.CharCounts[i] != filterCharCount)
        {
          Chars += letterBudget.Chars[i];
          CharCounts.Add(letterBudget.CharCounts[i] - filterCharCount);
        }

        Count += letterBudget.CharCounts[i] - filterCharCount;
      }
    }

    public LetterBudget(string[] letters)
    {
      foreach (string letter in letters)
      {
        Chars += letter[0];
        Count += letter.Length;
        CharCounts.Add(letter.Length);
      }
    }


    public string Chars { get; private set; } = "";
    public List<int> CharCounts { get; private set; } = new List<int>();
    public int Count { get; private set; }
  }
}