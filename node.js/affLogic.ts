interface RuleSet {
    strippingChars: RegExp;
    substitution: string;
    condition: RegExp;
};

interface Rule {
    flag: string;
    affix: string;
    ruleSets: RuleSet[];
};

function findRule(rules: Rule[], flag: string, affix?: string): Rule {
    for (const rule of rules) {
        if (flag === rule.flag && (!affix || affix === rule.affix)) {
            return rule;
        };
    };

    return null;
};

function containsRuleSet(ruleSets: RuleSet[], strippingChars: RegExp, substitution: string, condition: RegExp): Boolean {
    for (const ruleSet of ruleSets) {
        if (strippingChars.source === ruleSet.strippingChars.source && substitution === ruleSet.substitution && condition.source === ruleSet.condition.source) {
            return true;
        };
    };

    return false;
};

function generateRuleList(rawRules: string[]): Rule[] {
    let rules: Rule[] = [];

    for (const element of rawRules) {
        if (element[0] !== '#') {
            const elements = element.split(/\s+/);
            if (elements.length === 5) {
                let rule = findRule(rules, elements[1].trim(), elements[0].trim());

                if (!rule) {
                    rule = {
                        flag: elements[1].trim(),
                        affix: elements[0].trim(),
                        ruleSets: []
                    };
                    rules.push(rule);
                };

                let substitution = elements[3].trim().toLowerCase();
                if (substitution === '0') {
                    substitution = '';
                };

                let strippingChars: RegExp;
                let condition: RegExp;

                if (rule.affix === 'PFX') {
                    if (elements[2].trim() === '0') {
                        strippingChars = new RegExp(/^/);
                    } else {
                        strippingChars = new RegExp('\\b' + elements[2].trim().toLowerCase(), 'i');
                    };

                    condition = new RegExp('\\b' + elements[4].trim().toLowerCase(), 'i');
                } else {
                    if (elements[2].trim() === '0') {
                        strippingChars = new RegExp(/$/);
                    } else {
                        strippingChars = new RegExp(elements[2].trim().toLowerCase() + '\\b', 'i');
                    };

                    condition = new RegExp(elements[4].trim().toLowerCase() + '\\b', 'i');
                };

                if (!containsRuleSet(rule.ruleSets, strippingChars, substitution, condition)) {
                    rule.ruleSets.push({
                        strippingChars: strippingChars,
                        substitution: substitution,
                        condition: condition
                    });
                };
            };
        };
    };

    return rules;
};

export { RuleSet, Rule, findRule, generateRuleList };