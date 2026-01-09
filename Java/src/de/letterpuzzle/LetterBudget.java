package de.letterpuzzle;

import java.util.ArrayList;

public class LetterBudget {
    private String chars = "";
    private final ArrayList<Integer> charCounts;
    private int count = 0;

    public String getChars() {
        return chars;
    }

    public ArrayList<Integer> getCharCounts() {
        return charCounts;
    }

    public int getCount() {
        return count;
    }

    public LetterBudget(String word, LetterBudget letterBudget)
    {
        charCounts = new ArrayList<>(letterBudget.chars.length());

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < letterBudget.chars.length(); i++)
        {
            int filterCharCount = 0;

            for (char wordChar : word.toCharArray())
            {
                if (wordChar == letterBudget.getChars().charAt(i))
                {
                    filterCharCount++;
                }
            }

            if (letterBudget.getCharCounts().get(i) != filterCharCount)
            {
                sb.append(letterBudget.getChars().charAt(i));
                charCounts.add(letterBudget.getCharCounts().get(i) - filterCharCount);
            }

            count += letterBudget.getCharCounts().get(i) - filterCharCount;
        }

        chars =  sb.toString();
    }

    public LetterBudget(String[] letters)
    {
        charCounts = new ArrayList<>();

        StringBuilder sb = new StringBuilder();
        for (String letter : letters)
        {
            sb.append(letter.charAt(0));
            count += letter.length();
            charCounts.add(letter.length());
        }
        chars =  sb.toString();
    }
}
