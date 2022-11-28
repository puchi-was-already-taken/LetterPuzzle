unit uLetterPuzzle;

interface

uses
  System.Classes, System.Generics.Collections, uDicLogic;

type
  TLetterBudget = class(TObject)
  private
    FChars: string;
    FCount: Integer;
    FCharCounts: TList<Integer>;
    FCharsRef: TStringRef;
    constructor Create; overload;
  public
    constructor Create(const Word: TStringRef; const LetterBudget: TLetterBudget); overload;
    constructor Create(const Letters: array of string); overload;
    destructor Destroy; override;

    property Chars: string read FChars;
    property CharsRef: TStringRef read FCharsRef;
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
  System.SysUtils, Windows;

procedure DepthFirstSearch(const WordOnlyOnce: Boolean; const Words: TStringList; const
  StartIndex: Integer; const Budget: TLetterBudget; const Path: string; const Result: TStringList);
var
  Duration: UInt64;
  I: Integer;
  WordRef: TStringRef;
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
          Writeln(Format('Count: %d: %s', [Result.Count, Path]));
        end
        else
        begin
          Writeln(Format('Count: %d (%f / sec): %s', [Result.Count, Result.Count / (Duration / 1000), Path]));
        end;
      end;
    end
    else
    begin
      for I := StartIndex downto 0 do
      begin
        WordRef := TStringRef(Words.Objects[I]);

        if WordRef.Length > Budget.Count then
        begin
          // Words array is expected to be sorted by length.
          Exit;
        end;

        if FitsFilterCharCounts(WordRef, Budget.CharsRef, Budget.CharCounts) then
        begin
          if WordOnlyOnce then
          begin
            DepthFirstSearch(WordOnlyOnce, Words, I - 1, TLetterBudget.Create(WordRef, Budget), Path + ',' + Words[I], Result);
          end
          else
          begin
            DepthFirstSearch(WordOnlyOnce, Words, I, TLetterBudget.Create(WordRef, Budget), Path + ',' + Words[I], Result);
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

constructor TLetterBudget.Create(const Word: TStringRef; const LetterBudget: TLetterBudget);
var
  WordLength, FilterCharLength, I, FilterCharCount, J: Integer;
  FilterChar, WordChar: PChar;
begin
  Create;

  WordChar := Word.Ref;
  WordLength := Word.Length;
  FilterChar := LetterBudget.CharsRef.Ref;
  FilterCharLength := LetterBudget.CharsRef.Length;

  FCharCounts.Capacity := FilterCharLength;

  for I := 0 to FilterCharLength - 1 do
  begin
    FilterCharCount := 0;

    for J := 0 to WordLength - 1 do
    begin
      if WordChar[J] = FilterChar[I] then
      begin
        Inc(FilterCharCount);
      end;
    end;

    FilterCharCount := LetterBudget.CharCounts[I] - FilterCharCount;

    if FilterCharCount > 0 then
    begin
      FChars := FChars + FilterChar[I];
      FCharCounts.Add(FilterCharCount);
      Inc(FCount, FilterCharCount);
    end;
  end;

  FCharsRef := TStringRef.Create(FChars);
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

  FCharsRef := TStringRef.Create(FChars);
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

