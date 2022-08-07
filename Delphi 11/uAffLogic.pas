unit uAffLogic;

interface

uses
  System.Generics.Collections, System.Classes, System.SysUtils;

type
  TRuleSet = class(TObject)
  private
    Fcondition: string;
    FstrippingChars: string;
    Fsubstitution: string;
  public
    constructor Create(strippingChars, substitution, condition: string);

    property strippingChars: string read FstrippingChars write FstrippingChars;
    property substitution: string read Fsubstitution write Fsubstitution;
    property condition: string read Fcondition write Fcondition;
  end;

  TRule = class(TObject)
  private
    FruleSets: TObjectList<TRuleSet>;
    Fflag: string;
    Faffix: string;
  public
    constructor Create(const Flag, Affix: string);
    destructor Destroy; override;

    function containsRuleSet(StrippingChars, Substitution, Condition: string): Boolean;

    property flag: string read Fflag write Fflag;
    property affix: string read Faffix write Faffix;
    property ruleSets: TObjectList<TRuleSet>read FruleSets;
  end;

function findRule(const rules: TObjectList<TRule>; flag: string; const affix: string = ''): TRule;
function generateRuleList(const rawRules: TStringList): TObjectList<TRule>;

implementation

function findRule(const rules: TObjectList<TRule>; flag: string; const affix: string = ''): TRule;
var
  rule: TRule;
begin
  for rule in rules do
  begin
    if (flag = rule.flag) and ((affix = '') or (affix = rule.affix)) then
    begin
      Result := rule;
      Exit;
    end;
  end;

  Result := nil;
end;

function generateRuleList(const rawRules: TStringList): TObjectList<TRule>;
var
  element, substitution, strippingChars, condition: string;
  elements: TArray<string>;
  rule: TRule;
begin
  Result := TObjectList<TRule>.Create(True);

  for element in rawRules do
  begin
    if (Length(element) > 0) and (element[1] <> '#') then
    begin
      elements := element.Split([' ', #9], TStringSplitOptions.ExcludeEmpty);
      if Length(elements) = 5 then
      begin
        rule := findRule(Result, elements[1].Trim, elements[0].Trim);

        if not Assigned(rule) then
        begin
          rule := TRule.Create(elements[1].Trim, elements[0].Trim);
          Result.Add(rule);
        end;

        substitution := elements[3].Trim.ToLower;
        if substitution = '0' then
        begin
          substitution := '';
        end;

        if rule.affix = 'PFX' then
        begin
          if elements[2].Trim = '0' then
          begin
            strippingChars := '^';
          end
          else
          begin
            strippingChars := '\b' + elements[2].Trim.ToLower;
          end;

          condition := '\b' + elements[4].Trim.ToLower;
        end
        else
        begin
          if elements[2].Trim = '0' then
          begin
            strippingChars := '$';
          end
          else
          begin
            strippingChars := elements[2].Trim.ToLower + '\b';
          end;

          condition := elements[4].Trim.ToLower + '\b';
        end;

        if not rule.containsRuleSet(strippingChars, substitution, condition) then
        begin
          rule.ruleSets.Add(TRuleSet.Create(strippingChars, substitution, condition));
        end;
      end;
    end;
  end;
end;

{ TRuleSet }

constructor TRuleSet.Create(strippingChars, substitution, condition: string);
begin
  FstrippingChars := strippingChars;
  Fsubstitution := substitution;
  Fcondition := condition;
end;

{ TRule }

function TRule.containsRuleSet(StrippingChars, Substitution, Condition: string): Boolean;
var
  ruleSet: TRuleSet;
begin
  for ruleSet in ruleSets do
  begin
    if (StrippingChars = ruleSet.strippingChars) and (Substitution = ruleSet.substitution) and
      (Condition = ruleSet.condition) then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

constructor TRule.Create(const Flag, Affix: string);
begin
  Fflag := Flag;
  Faffix := Affix;
  FruleSets := TObjectList<TRuleSet>.Create(True);
end;

destructor TRule.Destroy;
begin
  FruleSets.Free;
  inherited;
end;

end.



