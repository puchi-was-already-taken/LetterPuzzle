package de.letterpuzzle.rules;

import java.util.ArrayList;

public class Rule {
    private final char flag;
    private final String affix;
    private final ArrayList<RuleSet> ruleSets = new ArrayList<>();

    public char getFlag() {
        return flag;
    }

    public String getAffix() {
        return affix;
    }

    public ArrayList<RuleSet> getRuleSets() {
        return ruleSets;
    }
    
    public Rule(char flag, String affix)
    {
        this.flag = flag;
        this.affix = affix;
    }

    public Boolean containsRuleSet(String strippingChars, String substitution, String condition)
    {
        for (RuleSet ruleSet : ruleSets)
        {
            if (strippingChars.equals(ruleSet.strippingChars())
                    && substitution.equals(ruleSet.substitution())
                    && condition.equals(ruleSet.condition()))
            {
                return true;
            }
        }

        return false;
    }
}
