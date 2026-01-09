package de.letterpuzzle.diclogic;

import java.util.ArrayList;

public class Filter {
    private static Boolean fitsFilter(String item, String charFilter)
    {
        for (char itemChar : item.toCharArray())
        {
            boolean found = false;

            for (char filterChar : charFilter.toCharArray())
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

    public static Boolean fitsFilterCharCounts(String item, String charFilter, ArrayList<Integer> charCounts)
    {
        if (!fitsFilter(item, charFilter))
        {
            return false;
        }

        for (int i = 0; i < charFilter.length(); i++)
        {

            int filterCharCount = 0;

            for (char itemChar : item.toCharArray())
            {
                if (itemChar == charFilter.charAt(i))
                {
                    filterCharCount++;
                }
            }

            if (filterCharCount > charCounts.get(i))
            {
                return false;
            }
        }

        return true;
    }
}
