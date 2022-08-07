unit uLetterPuzzle;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TLetterBudget = class(TObject)
  private
    FChars: string;
    FCount: Integer;
    FCharCounts: TList<Integer>;
    constructor Create; overload;
  public
    constructor Create(const Word: string; const LetterBudget: TLetterBudget); overload;
    constructor Create(const Letters: array of string); overload;
    destructor Destroy; override;

    property Chars: string read FChars;
    property CharCounts: TList<Integer>read FCharCounts;
    property Count: Integer read FCount;
  end;

var
  start: UInt64;

procedure depthFirstSearch(const wordOnlyOnce: Boolean; const words: TStringList; const
  startIndex: Integer; const budget: TLetterBudget; const path: string; const result: TStringList);
procedure prepareWordList(words: TStringList; const minWordLength: Integer);

implementation

uses
  System.SysUtils, Windows, uDicLogic;

procedure depthFirstSearch(const wordOnlyOnce: Boolean; const words: TStringList; const
  startIndex: Integer; const budget: TLetterBudget; const path: string; const result: TStringList);
var
  duration: UInt64;
  i: Integer;
  word: string;
begin
  try
    if (budget.count = 0) then
    begin
      result.Add(path);

      if result.Count mod 1000 = 0 then
      begin
        duration := GetTickCount64 - start;
        Writeln(Format('Count: %d (%f / sec): %s', [result.Count, result.Count / (duration / 1000),
            result[result.Count - 1]]));
      end;
    end
    else
    begin
      for i := startIndex downto 0 do
      begin
        word := words[i];

        if word.length > budget.count then
        begin
          // words array is expected to be sorted by length.
          Exit;
        end;

        if fitsFilterCharCounts(word, budget.chars, budget.charCounts) then
        begin
          if wordOnlyOnce then
          begin
            depthFirstSearch(wordOnlyOnce, words, i - 1, TLetterBudget.Create(word, budget),
              path + ',' + word, result);
          end
          else
          begin
            depthFirstSearch(wordOnlyOnce, words, i, TLetterBudget.Create(word, budget),
              path + ',' + word, result);
          end;
        end;
      end;
    end;

  finally
    budget.Free;
  end;
end;

function SortByLength(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := List[Index2].Length - List[Index1].Length;
end;

procedure prepareWordList(words: TStringList; const minWordLength: Integer);
var
  i: Integer;
begin
  words.CustomSort(SortByLength);

  i := words.Count - 1;
  while (i >= 0) and (words[i].length < minWordLength) do
  begin
    words.Delete(i);
    Dec(i);
  end;
end;

{ TLetterBudget }

constructor TLetterBudget.Create(const Word: string; const LetterBudget: TLetterBudget);
var
  i, filterCharCount, j: Integer;
  filterChar, wordChar: PChar;
begin
  Create;
  FCharCounts.Capacity := LetterBudget.Chars.Length;

  wordChar := PChar(Word);
  filterChar := PChar(LetterBudget.Chars);

  for i := 0 to LetterBudget.Chars.Length - 1 do
  begin
    filterCharCount := 0;

    for j := 0 to word.Length - 1 do
    begin
      if (wordChar + j)^ = (filterChar + i)^ then
      begin
        Inc(filterCharCount);
      end;
    end;

    if LetterBudget.CharCounts[i] <> filterCharCount then
    begin
      FChars := FChars + (filterChar + i)^;
      FCharCounts.Add(LetterBudget.charCounts[i] - filterCharCount);
    end;

    FCount := FCount + LetterBudget.CharCounts[i] - filterCharCount;
  end;
end;

constructor TLetterBudget.Create(const Letters: array of string);
var
  i: Integer;
begin
  Create;

  for i := Low(Letters) to High(Letters) do
  begin
    FChars := FChars + Letters[i][1];
    FCount := FCount + Letters[i].Length;
    FCharCounts.Add(Letters[i].Length);
  end;
end;

constructor TLetterBudget.Create;
begin
  FChars := '';
  FCount := 0;
  FCharCounts := TList<Integer>.Create;
end;

destructor TLetterBudget.Destroy;
begin
  FCharCounts.Free;
  inherited;
end;

end.


