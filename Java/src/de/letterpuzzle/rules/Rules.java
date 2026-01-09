package de.letterpuzzle.rules;

import java.util.ArrayList;
import java.util.List;

public class Rules {
    private final ArrayList<Rule> list = new ArrayList<>();

    public ArrayList<Rule> getList() {
        return list;
    }

    public Rules(List<String> rawRules)
    {
        for (String element : rawRules)
        {
            if (!element.isEmpty() && element.charAt(0) != '#')
            {
                String[] elements = element.split("([ \t])+"); // Split at spaces and tabs.
                if (elements.length == 5 && !elements[1].isEmpty())
                {
                    Rule rule = findRule(elements[1].charAt(0), elements[0]);

                    if (rule == null)
                    {
                        rule = new Rule(elements[1].charAt(0), elements[0]);
                        list.add(rule);
                    }

                    String substitution = elements[3].toLowerCase();
                    if (substitution.equals("0"))
                    {
                        substitution = "";
                    }

                    String strippingChars, condition;

                    if (rule.getAffix().equals("PFX"))
                    {
                        if (elements[2].equals("0"))
                        {
                            strippingChars = "^";
                        }
                        else
                        {
                            strippingChars = "\\b" + elements[2].toLowerCase();
                        }

                        condition = "\\b" + elements[4].toLowerCase();
                    }
                    else
                    {
                        if (elements[2].equals("0"))
                        {
                            strippingChars = "$";
                        }
                        else
                        {
                            strippingChars = elements[2].toLowerCase() + "\\b";
                        }

                        condition = elements[4].toLowerCase() + "\\b";
                    }

                    if (!rule.containsRuleSet(strippingChars, substitution, condition))
                    {
                        rule.getRuleSets().add(new RuleSet(strippingChars, substitution, condition));
                    }
                }
            }
        }
    }

    public Rule findRule(char flag)
    {
        return findRule(flag, "");
    }

    public Rule findRule(char flag, String affix)
    {
        for (Rule rule : list)
        {
            if (flag == rule.getFlag() && (affix.isEmpty() || affix.equals(rule.getAffix())))
            {
                return rule;
            }
        }

        return null;
    }
}
