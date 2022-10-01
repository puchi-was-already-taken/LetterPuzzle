program LetterPuzzle;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  Windows,
  uLetterPuzzle in 'uLetterPuzzle.pas',
  uAffLogic in 'uAffLogic.pas',
  uDicLogic in 'uDicLogic.pas';

var
  LettersBudget: TLetterBudget;
  Aff, Dic, Words, BlackList, Result: TStringList;
  Rules: TObjectList<TRule>;
  Duration: UInt64;
begin
  try
    LettersBudget := TLetterBudget.Create(['aa', 'e', 'hh', 'll', 'o', 'i', 'r', 'd', 'nn', 't', 'u']); // "hallo ihr da unten"

    Aff := TStringList.Create;
    Dic := TStringList.Create;
    BlackList := TStringList.Create;
    Result := TStringList.Create;
    try
      Aff.LoadFromFile('..\..\..\hunspell\de_DE_frami_mod.Aff', TEncoding.UTF8);
      Rules := GenerateRuleList(Aff);
      try
        BlackList.Add('utrecht');
        Dic.LoadFromFile('..\..\..\hunspell\de_DE_frami.Dic', TEncoding.UTF8);

        Words := GenerateWordList(Dic, Rules, LettersBudget.Chars, LettersBudget.CharCounts, BlackList);
        try
          PrepareWordList(Words, 2);

          Start := GetTickCount64;

          DepthFirstSearch(True, Words, Words.Count - 1, LettersBudget, '', Result);

          Duration := GetTickCount64 - Start;

          if Duration = 0 then
          begin
            Writeln(Format('Duration: %dsec Count: %d: %s', [0, Result.Count, Result[Result.Count - 1]]));
          end
          else
          begin
            Writeln(Format('Duration: %fsec Count: %d (%f / sec): %s', [Duration / 1000,
              Result.Count, Result.Count / (Duration / 1000), Result[Result.Count - 1]]));
          end;

          Result.SaveToFile('results');

        finally
          Words.Free;
        end;
      finally
        Rules.Free;
      end;
    finally
      Result.Free;
      BlackList.Free;
      Dic.Free;
      Aff.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

