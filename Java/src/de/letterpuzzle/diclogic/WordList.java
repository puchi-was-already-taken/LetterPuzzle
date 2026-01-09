package de.letterpuzzle.diclogic;

import de.letterpuzzle.rules.Rule;
import de.letterpuzzle.rules.RuleSet;
import de.letterpuzzle.rules.Rules;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class WordList {
    private final ArrayList<String> list;

    public ArrayList<String> getList() {
        return list;
    }

    private static Boolean strIsDigit(String str)
    {
        if (str.isEmpty()) {
            return false;
        }

        for (char c : str.toCharArray()) {
            if (!Character.isDigit(c)) {
                return false;
            }
        }

        return true;
    }

    public WordList(List<String> rawWordList, Rules affixRules, String charFilter, ArrayList<Integer> charCounts, ArrayList<String> blackList)
    {
        list = new ArrayList<>();

        for (String line : rawWordList)
        {
            if (!line.trim().isEmpty() && line.charAt(0) != '#' && !strIsDigit(line))
            {
                String[] elements = line.split("/");
                String baseWord = elements[0].toLowerCase();

                if (!blackList.contains(baseWord) && pushToList(charFilter, charCounts, baseWord) && elements.length > 1)
                {

                    for (char flag : elements[1].toCharArray())
                    {
                        Rule rule = affixRules.findRule(flag);

                        if (rule != null)
                        {
                            for (RuleSet ruleSet : rule.getRuleSets())
                            {
                                if (!ruleSet.substitution().isEmpty())
                                {
                                    Matcher matcher = Pattern.compile(ruleSet.condition(), Pattern.CASE_INSENSITIVE).matcher(baseWord);
                                    if (matcher.find())
                                    {
                                        Matcher replacer = Pattern.compile(ruleSet.strippingChars(), Pattern.CASE_INSENSITIVE).matcher(baseWord);
                                        String wordForm = replacer.replaceFirst(ruleSet.substitution());

                                        if (!list.contains(wordForm))
                                        {
                                            pushToList(charFilter, charCounts, wordForm);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        cleanDoubles();
    }

    public Boolean pushToList(String charFilter, ArrayList<Integer> charCounts, String item)
    {
        if (!item.isEmpty() && Filter.fitsFilterCharCounts(item, charFilter, charCounts))
        {
            list.add(item);
            return true;
        }

        return false;
    }

    public void cleanDoubles()
    {
        list.sort(String::compareTo);

        for (int i = list.size() - 2; i >= 0; i--)
        {
            if (list.get(i).equals(list.get(i + 1)))
            {
                list.remove(i + 1);
            }
        }
    }

    public void prepareWordList(int minWordLength)
    {
        list.sort(Comparator.comparingInt(String::length));

        while (list.get(0).length() < minWordLength){
            list.remove(0);
        }
    }
}
