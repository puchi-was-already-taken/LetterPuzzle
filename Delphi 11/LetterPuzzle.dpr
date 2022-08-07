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
  lettersBudget: TLetterBudget;
  aff, dic, words, blackList, result: TStringList;
  rules: TObjectList<TRule>;
  duration: UInt64;
begin
  try
//    lettersBudget := TLetterBudget.Create(['eeeeeee', 'tt', 'l', 'iiiii', 'f', 'nnnn', 'ü', 'rr', 'u', 'h', 'c', 'ss', 'g', 'a', 'b', 'm']);
    lettersBudget := TLetterBudget.Create(['aa', 'e', 'hh', 'll', 'o', 'i', 'r', 'd', 'nn', 't', 'u']);
//    lettersBudget := TLetterBudget.Create(['a', 'd', 'e', 'hh', 'ii', 'll', 'o', 'rr']);
//    lettersBudget := TLetterBudget.Create(['aa','hh','ll','o','i','r','d']);
//    lettersBudget := TLetterBudget.Create(['a', 'h', 'll', 'o']);

    aff := TStringList.Create;
    dic := TStringList.Create;
    blackList := TStringList.Create;
    result := TStringList.Create;
    try
      aff.LoadFromFile('..\..\..\hunspell\de_DE_frami_mod.aff', TEncoding.UTF8);
      rules := generateRuleList(aff);
      try
        blackList.Add('utrecht');
        dic.LoadFromFile('..\..\..\hunspell\de_DE_frami.dic', TEncoding.UTF8);

        words := generateWordList(dic, rules, lettersBudget.chars, lettersBudget.charCounts,
          blackList);
        try
          prepareWordList(words, 2);

          words.SaveToFile('words.txt');
          start := GetTickCount64;
          depthFirstSearch(true, words, words.Count - 1, lettersBudget, '', result);
          duration := GetTickCount64 - start;
          if duration = 0 then
          begin
            Writeln(Format('Duration: %dsec Count: %d: %s', [0,
                result.Count,
                result[result.Count - 1]]));
          end
          else
          begin
            Writeln(Format('Duration: %fsec Count: %d (%f / sec): %s', [duration / 1000,
                result.Count,
                result.Count / (duration / 1000), result[result.Count - 1]]));
          end;

          result.SaveToFile('combinations.txt');

        finally
          words.Free;
        end;
      finally
        rules.Free;
      end;
    finally
      result.Free;
      blackList.Free;
      dic.Free;
      aff.Free;
    end;

    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.



