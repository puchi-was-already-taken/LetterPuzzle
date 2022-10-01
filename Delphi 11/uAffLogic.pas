unit uAffLogic;

interface

uses
  System.Generics.Collections, System.Classes, System.SysUtils;

type
  TRuleSet = class(TObject)
  private
    FCondition: string;
    FStrippingChars: string;
    FSubstitution: string;
  public
    constructor Create(StrippingChars, Substitution, Condition: string);

    property StrippingChars: string read FStrippingChars write FStrippingChars;
    property Substitution: string read FSubstitution write FSubstitution;
    property Condition: string read FCondition write FCondition;
  end;

  TRule = class(TObject)
  private
    FRuleSets: TObjectList<TRuleSet>;
    FFlag: string;
    FAffix: string;
  public
    constructor Create(const Flag, Affix: string);
    destructor Destroy; override;

    function ContainsRuleSet(StrippingChars, Substitution, Condition: string): Boolean;

    property Flag: string read FFlag write FFlag;
    property Affix: string read FAffix write FAffix;
    property RuleSets: TObjectList<TRuleSet>read FRuleSets;
  end;

function FindRule(const Rules: TObjectList<TRule>; Flag: string; const Affix: string = ''): TRule;
function GenerateRuleList(const RawRules: TStringList): TObjectList<TRule>;

implementation

function FindRule(const Rules: TObjectList<TRule>; Flag: string; const Affix: string = ''): TRule;
var
  Rule: TRule;
begin
  for Rule in Rules do
  begin
    if (Flag = Rule.Flag) and ((Affix = '') or (Affix = Rule.Affix)) then
    begin
      Result := Rule;
      Exit;
    end;
  end;

  Result := nil;
end;

function GenerateRuleList(const RawRules: TStringList): TObjectList<TRule>;
var
  Element, Substitution, StrippingChars, Condition: string;
  Elements: TArray<string>;
  Rule: TRule;
begin
  Result := TObjectList<TRule>.Create(True);

  for Element in RawRules do
  begin
    if (Length(Element) > 0) and (Element[1] <> '#') then
    begin
      Elements := Element.Split([' ', #9], TStringSplitOptions.ExcludeEmpty);
      if Length(Elements) = 5 then
      begin
        Rule := FindRule(Result, Elements[1].Trim, Elements[0].Trim);

        if not Assigned(Rule) then
        begin
          Rule := TRule.Create(Elements[1].Trim, Elements[0].Trim);
          Result.Add(Rule);
        end;

        Substitution := Elements[3].Trim.ToLower;
        if Substitution = '0' then
        begin
          Substitution := '';
        end;

        if Rule.Affix = 'PFX' then
        begin
          if Elements[2].Trim = '0' then
          begin
            StrippingChars := '^';
          end
          else
          begin
            StrippingChars := '\b' + Elements[2].Trim.ToLower;
          end;

          Condition := '\b' + Elements[4].Trim.ToLower;
        end
        else
        begin
          if Elements[2].Trim = '0' then
          begin
            StrippingChars := '$';
          end
          else
          begin
            StrippingChars := Elements[2].Trim.ToLower + '\b';
          end;

          Condition := Elements[4].Trim.ToLower + '\b';
        end;

        if not Rule.ContainsRuleSet(StrippingChars, Substitution, Condition) then
        begin
          Rule.RuleSets.Add(TRuleSet.Create(StrippingChars, Substitution, Condition));
        end;
      end;
    end;
  end;
end;

{ TRuleSet }

constructor TRuleSet.Create(StrippingChars, Substitution, Condition: string);
begin
  FStrippingChars := StrippingChars;
  FSubstitution := Substitution;
  FCondition := Condition;
end;

{ TRule }

function TRule.ContainsRuleSet(StrippingChars, Substitution, Condition: string): Boolean;
var
  RuleSet: TRuleSet;
begin
  for RuleSet in RuleSets do
  begin
    if (StrippingChars = RuleSet.StrippingChars) and (Substitution = RuleSet.Substitution) and
      (Condition = RuleSet.Condition) then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

constructor TRule.Create(const Flag, Affix: string);
begin
  FFlag := Flag;
  FAffix := Affix;
  FRuleSets := TObjectList<TRuleSet>.Create(True);
end;

destructor TRule.Destroy;
begin
  FRuleSets.Free;
  inherited;
end;

end.