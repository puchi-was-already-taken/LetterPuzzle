unit uDicLogic;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, uAffLogic;

function fitsFilterCharCounts(const item, charFilter: string; const charCounts: TList<Integer>):
  Boolean;
function generateWordList(const rawWordList: TStringList; const affixRules: TObjectList<TRule>; const
  charFilter: string; const charCounts: TList<Integer>; const blackList: TStringList): TStringList;

implementation

uses
  JclStrings, RegularExpressionsCore;

function fitsFilter(const item, charFilter: string): Boolean;
var
  i, j: Integer;
  itemChar, filterChar: PChar;
  found: Boolean;
begin
  itemChar := PChar(item);
  filterChar := PChar(charFilter);

  for i := 0 to item.Length - 1 do
  begin
    found := False;

    for j := 0 to charFilter.Length - 1 do
    begin
      if (itemChar + i)^ = (filterChar + j)^ then
      begin
        found := True;
        Break;
      end;
    end;

    if not found then
    begin
      Exit(False);
    end;
  end;

  Result := True;
end;

function fitsFilterCharCounts(const item, charFilter: string; const charCounts: TList<Integer>):
  Boolean;
var
  i, j, filterCharCount: Integer;
  itemChar, filterChar: PChar;
begin
  if not fitsFilter(item, charFilter) then
  begin
    Result := False;
    Exit;
  end;

  itemChar := PChar(item);
  filterChar := PChar(charFilter);

  for i := 0 to charFilter.Length - 1 do
  begin
    filterCharCount := 0;

    for j := 0 to item.Length - 1 do
    begin
      if (itemChar + j)^ = (filterChar + i)^ then
      begin
        Inc(filterCharCount);
      end;
    end;

    if filterCharCount > charCounts[i] then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

function pushToList(const list: TStringList; const charFilter: string; const charCounts: TList<Integer>; const item: string): Boolean;
begin
  if (item.length > 0) and fitsFilterCharCounts(item, charFilter, charCounts) then
  begin
    list.Add(item);
    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure cleanDoubles(list: TStringList);
var
  i: Integer;
begin
  list.Sort;

  for i := list.Count - 2 downto 0 do
  begin
    if list[i] = list[i + 1] then
    begin
      list.Delete(i + 1);
    end;
  end;
end;

function generateWordList(const rawWordList: TStringList; const affixRules: TObjectList<TRule>; const
  charFilter: string; const charCounts: TList<Integer>; const blackList: TStringList): TStringList;
var
  line, baseWord, wordForm: string;
  elements: TArray<string>;
  baseList: TStringList;
  flag: char;
  rule: TRule;
  ruleSet: TRuleSet;
  RegEx: TPerlRegEx;
  i: Integer;
begin
  Result := TStringList.Create;
  baseList := TStringList.Create;
  RegEx := TPerlRegEx.Create;
  try
    RegEx.State := RegEx.State - [preNotEmpty];
    RegEx.Options := RegEx.Options + [preCaseLess];

    for line in rawWordList do
    begin
      if (line.Trim.Length > 0) and (line[1] <> '#') and not StrIsDigit(line) then
      begin
        elements := line.Split(['/'], TStringSplitOptions.ExcludeEmpty);

        baseWord := elements[0].ToLower;
        if (blackList.IndexOf(baseWord) = -1) and pushToList(Result, charFilter, charCounts, baseWord)
          and (Length(elements) > 1) then
        begin
          baseList.Clear;

          for i := 1 to elements[1].Length do
          begin
            flag := elements[1][i];
            rule := findRule(affixRules, flag);

            if Assigned(rule) then
            begin
              for ruleSet in rule.ruleSets do
              begin
                if ruleSet.substitution.Length > 0 then
                begin
                  RegEx.RegEx := ruleSet.condition;
                  RegEx.Subject := baseWord;

                  if RegEx.Match then
                  begin
                    RegEx.RegEx := ruleSet.strippingChars;
                    RegEx.Replacement := ruleSet.substitution;

                    if RegEx.Match then
                    begin
                      RegEx.Replace;
                      wordForm := RegEx.Subject;

                      if baseList.indexOf(wordForm) = -1 then
                      begin
                        baseList.Add(wordForm);
                        pushToList(Result, charFilter, charCounts, wordForm);
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

    cleanDoubles(Result);
  finally
    baseList.Free;
  end;
end;

end.



