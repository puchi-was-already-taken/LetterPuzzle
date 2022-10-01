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
  Start: UInt64;

procedure DepthFirstSearch(const WordOnlyOnce: Boolean; const Words: TStringList; const
  StartIndex: Integer; const Budget: TLetterBudget; const Path: string; const Result: TStringList);
procedure prepareWordList(Words: TStringList; const minWordLength: Integer);

implementation

uses
  System.SysUtils, Windows, uDicLogic;

procedure DepthFirstSearch(const WordOnlyOnce: Boolean; const Words: TStringList; const
  StartIndex: Integer; const Budget: TLetterBudget; const Path: string; const Result: TStringList);
var
  Duration: UInt64;
  I: Integer;
  Word: string;
begin
  try
    if (Budget.Count = 0) then
    begin
      Result.Add(Path);

      if Result.Count mod 1000 = 0 then
      begin
        Duration := GetTickCount64 - Start;

        if Duration = 0 then
        begin
          Writeln(Format('Count: %d: %s', [Result.Count, Result[Result.Count - 1]]));
        end
        else
        begin
          Writeln(Format('Count: %d (%f / sec): %s', [Result.Count, Result.Count / (Duration / 1000), Result[Result.Count - 1]]));
        end;
      end;
    end
    else
    begin
      for I := StartIndex downto 0 do
      begin
        Word := Words[I];

        if Word.Length > Budget.Count then
        begin
          // Words array is expected to be sorted by length.
          Exit;
        end;

        if FitsFilterCharCounts(Word, Budget.Chars, Budget.CharCounts) then
        begin
          if WordOnlyOnce then
          begin
            DepthFirstSearch(WordOnlyOnce, Words, I - 1, TLetterBudget.Create(Word, Budget), Path + ',' + Word, Result);
          end
          else
          begin
            DepthFirstSearch(WordOnlyOnce, Words, I, TLetterBudget.Create(Word, Budget), Path + ',' + Word, Result);
          end;
        end;
      end;
    end;

  finally
    Budget.Free;
  end;
end;

function SortByLength(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := List[Index2].Length - List[Index1].Length;
end;

procedure prepareWordList(Words: TStringList; const minWordLength: Integer);
var
  I: Integer;
begin
  Words.CustomSort(SortByLength);

  I := Words.Count - 1;
  while (I >= 0) and (Words[I].length < minWordLength) do
  begin
    Words.Delete(I);
    Dec(I);
  end;
end;

{ TLetterBudget }

constructor TLetterBudget.Create(const Word: string; const LetterBudget: TLetterBudget);
var
  I, FilterCharCount, J: Integer;
  FilterChar, WordChar: PChar;
begin
  Create;
  FCharCounts.Capacity := LetterBudget.Chars.Length;

  WordChar := PChar(Word);
  FilterChar := PChar(LetterBudget.Chars);

  for I := 0 to LetterBudget.Chars.Length - 1 do
  begin
    FilterCharCount := 0;

    for J := 0 to Word.Length - 1 do
    begin
      if (WordChar + J)^ = (FilterChar + I)^ then
      begin
        Inc(FilterCharCount);
      end;
    end;

    if LetterBudget.CharCounts[I] <> FilterCharCount then
    begin
      FChars := FChars + (FilterChar + I)^;
      FCharCounts.Add(LetterBudget.CharCounts[I] - FilterCharCount);
    end;

    FCount := FCount + LetterBudget.CharCounts[I] - FilterCharCount;
  end;
end;

constructor TLetterBudget.Create(const Letters: array of string);
var
  I: Integer;
begin
  Create;

  for I := Low(Letters) to High(Letters) do
  begin
    FChars := FChars + Letters[I][1];
    FCount := FCount + Letters[I].Length;
    FCharCounts.Add(Letters[I].Length);
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

