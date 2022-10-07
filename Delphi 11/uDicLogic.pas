unit uDicLogic;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, uAffLogic;

type
  TStringRef = class(TObject)
  private
    FRef: PChar;
    FLength: Integer;
  public
    constructor Create(Str: string);
    property Ref: PChar read FRef;
    property Length: Integer read FLength;
  end;

function FitsFilterCharCounts(const Item, CharFilter: TStringRef; const CharCounts: TList<Integer>):
  Boolean; overload;
function FitsFilterCharCounts(const Item, CharFilter: string; const CharCounts: TList<Integer>):
  Boolean; overload;
function generateWordList(const RawWordList: TStringList; const AffixRules: TObjectList<TRule>; const
  CharFilter: string; const CharCounts: TList<Integer>; const BlackList: TStringList): TStringList;

implementation

uses
  JclStrings, RegularExpressionsCore;

{ TStringRef }

constructor TStringRef.Create(Str: string);
begin
  FRef := PChar(Str);
  FLength := Str.Length;
end;

function FitsFilter(const Item, CharFilter: TStringRef): Boolean;
var
  I, J, ItemLength, FilterCharLength: Integer;
  ItemChar, FilterChar: PChar;
  Found: Boolean;
begin
  ItemChar := Item.Ref;
  ItemLength := Item.Length;
  FilterChar := CharFilter.Ref;
  FilterCharLength := CharFilter.Length;

  for I := 0 to ItemLength - 1 do
  begin
    Found := False;

    for J := 0 to FilterCharLength - 1 do
    begin
      if (ItemChar + I)^ = (FilterChar + J)^ then
      begin
        Found := True;
        Break;
      end;
    end;

    if not Found then
    begin
      Exit(False);
    end;
  end;

  Result := True;
end;

function FitsFilterCharCounts(const Item, CharFilter: string; const CharCounts: TList<Integer>):
  Boolean;
var
  tmpItemRef, tmpCharFilterRef: TStringRef;
begin
  tmpItemRef := TStringRef.Create(Item);
  tmpCharFilterRef := TStringRef.Create(CharFilter);
  try
    Result := FitsFilterCharCounts(tmpItemRef, tmpCharFilterRef, CharCounts);
  finally
    tmpCharFilterRef.Free;
    tmpItemRef.Free;
  end;
end;

function FitsFilterCharCounts(const Item, CharFilter: TStringRef; const CharCounts: TList<Integer>):
  Boolean; overload;
var
  I, J, ItemLength, FilterCharLength, FilterCharCount: Integer;
  ItemChar, FilterChar: PChar;
begin
  if not FitsFilter(Item, CharFilter) then
  begin
    Result := False;
    Exit;
  end;

  ItemChar := Item.Ref;
  ItemLength := Item.Length;
  FilterChar := CharFilter.Ref;
  FilterCharLength := CharFilter.Length;

  for I := 0 to FilterCharLength - 1 do
  begin
    FilterCharCount := 0;

    for J := 0 to ItemLength - 1 do
    begin
      if (ItemChar + J)^ = (FilterChar + I)^ then
      begin
        Inc(FilterCharCount);
      end;
    end;

    if FilterCharCount > CharCounts[I] then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

function PushToList(const List: TStringList; const CharFilter: string; const CharCounts:
  TList<Integer>; const Item: string): Boolean;
begin
  if (Item.Length > 0) and FitsFilterCharCounts(Item, CharFilter, CharCounts) then
  begin
    List.AddObject(Item, TStringRef.Create(Item));
    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure CleanDoubles(List: TStringList);
var
  I: Integer;
begin
  List.Sort;

  for I := List.Count - 2 downto 0 do
  begin
    if List[I] = List[I + 1] then
    begin
      List.Delete(I + 1);
    end;
  end;
end;

function generateWordList(const RawWordList: TStringList; const AffixRules: TObjectList<TRule>; const
  CharFilter: string; const CharCounts: TList<Integer>; const BlackList: TStringList): TStringList;
var
  Line, BaseWord, WordForm: string;
  Elements: TArray<string>;
  BaseList: TStringList;
  Flag: Char;
  Rule: TRule;
  RuleSet: TRuleSet;
  RegEx: TPerlRegEx;
  I: Integer;
begin
  Result := TStringList.Create;
  BaseList := TStringList.Create;
  RegEx := TPerlRegEx.Create;
  try
    RegEx.State := RegEx.State - [preNotEmpty];
    RegEx.Options := RegEx.Options + [preCaseLess];

    for Line in RawWordList do
    begin
      if (Line.Trim.Length > 0) and (Line[1] <> '#') and not StrIsDigit(Line) then
      begin
        Elements := Line.Split(['/'], TStringSplitOptions.ExcludeEmpty);

        BaseWord := Elements[0].ToLower;
        if (BlackList.IndexOf(BaseWord) = -1) and PushToList(Result, CharFilter, CharCounts,
          BaseWord) and (Length(Elements) > 1) then
        begin
          BaseList.Clear;

          for I := 1 to Elements[1].Length do
          begin
            Flag := Elements[1][I];
            Rule := FindRule(AffixRules, Flag);

            if Assigned(Rule) then
            begin
              for RuleSet in Rule.RuleSets do
              begin
                if RuleSet.Substitution.Length > 0 then
                begin
                  RegEx.RegEx := RuleSet.Condition;
                  RegEx.Subject := BaseWord;

                  if RegEx.Match then
                  begin
                    RegEx.RegEx := RuleSet.StrippingChars;
                    RegEx.Replacement := RuleSet.Substitution;

                    if RegEx.Match then
                    begin
                      RegEx.Replace;
                      WordForm := RegEx.Subject;

                      if BaseList.IndexOf(WordForm) = -1 then
                      begin
                        BaseList.Add(WordForm);
                        PushToList(Result, CharFilter, CharCounts, WordForm);
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    CleanDoubles(Result);
  finally
    BaseList.Free;
  end;
end;

end.

