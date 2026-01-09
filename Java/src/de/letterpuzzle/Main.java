package de.letterpuzzle;

import de.letterpuzzle.diclogic.Filter;
import de.letterpuzzle.diclogic.WordList;
import de.letterpuzzle.rules.Rules;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class Main {
    public static long start;

    public static void main(String[] args)
    {
        List<String> aff, dic;

        try {
            aff = Files.readAllLines(Path.of("../hunspell/de_DE_frami_mod.aff"));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        try {
            dic = Files.readAllLines(Path.of("../hunspell/de_DE_frami.dic"));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        System.out.println("aff-count: " + aff.size());
        System.out.println("dic-count: " + dic.size());

        Rules rules = new Rules(aff);
        System.out.println("rule-count: " + rules.getList().size());

        LetterBudget letterBudget = new LetterBudget(new String[]{"aa", "e", "hh", "ll", "o", "i", "r", "d", "nn", "t", "u"}); // "hallo ihr da unten"
//        LetterBudget letterBudget = new LetterBudget(new String[]{"a", "h", "ll", "o"});

        ArrayList<String> blacklist = new ArrayList<>();
        blacklist.add("utrecht");

        WordList wordList = new WordList(dic, rules, letterBudget.getChars(), letterBudget.getCharCounts(), blacklist);
        wordList.prepareWordList(2);

        ArrayList<String> result = new ArrayList<>();

        start = System.nanoTime();
        DepthFirstSearch(true, wordList.getList(), 0, letterBudget, "", result);
        long duration = System.nanoTime() - start;

        if (!result.isEmpty())
        {
            if (duration == 0)
            {
                System.out.printf("Duration: %dsec Count: %d: %s\n",
                        0, result.size(), result.get(result.size() - 1));
            }
            else
            {
                System.out.printf("Duration: %fsec Count: %d (%f / sec): %s\n",
                        duration / 1000.0 / 1000.0 / 1000.0, result.size(), result.size() / (duration / 1000.0 / 1000.0 / 1000.0), result.get(result.size() - 1));
            }
        }

        try (FileWriter writer = new FileWriter("results")) {
            for(String line : result) {
                writer.write(line + System.lineSeparator());
            }
        } catch (IOException e) {
            System.err.println("Error writing results: " + e.getMessage());
        }
    }

    static void DepthFirstSearch(Boolean wordOnlyOnce, ArrayList<String> words, int startIndex, LetterBudget budget, String path, ArrayList<String> result)
    {
        if (budget.getCount() == 0)
        {
            result.add(path);

            if (result.size() % 1000 == 0)
            {
                long duration = System.nanoTime() - start;
                if (duration == 0)
                {
                    System.out.printf("Count: %d : %s\n",
                            result.size(), path);
                }
                else
                {
                    System.out.printf("Count: %d (%f / sec): %s\n",
                            result.size(), result.size() / (duration / 1000.0 / 1000.0 / 1000.0), path);
                }
            }
        }
        else
        {
            for (int i = startIndex; i < words.size(); i++)
            {
                if (words.get(i).length() > budget.getCount())
                {
                    // words array is expected to be sorted by length.
                    return;
                }

                if (Filter.fitsFilterCharCounts(words.get(i), budget.getChars(), budget.getCharCounts()))
                {
                    LetterBudget letterBudget = new LetterBudget(words.get(i), budget);
                    if (wordOnlyOnce)
                    {
                        DepthFirstSearch(true, words, i + 1, letterBudget, path + ',' + words.get(i), result);
                    }
                    else
                    {
                        DepthFirstSearch(false, words, i, letterBudget, path + ',' + words.get(i), result);
                    }
                }
            }
        }
    }
}