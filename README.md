# LetterPuzzle
I wanted to get a rough understanding about the difference of performance between Delphi code and TypeScript in string intensive tasks.<br>
Therefore I implemented a simple program which makes heavy use of string comparison and concatenation.<br>
The program is searching for a chain of Words fitting a given budget of letters.<br>

By default TypeScript, executed via node.js, easily wins out against the Delphi binary.<br>
Only with the help of some quite heavy code optimizations is the Delphi binary able to "score" a tie.<br>
Beyond that, it is only marginally possible to get the Delphi code to run faster. (We are talking at max. ~1 second.)<br>
Aside from that, of the implementations I wrote by now, C++ (with compiler optimization level 2) is the fastest.

All performance tests where run on an AMD Ryzen 3700X CPU.

Delphi 11 (64bit standard string access and comparison):<br>
Duration: **ø51,61**sec Count: 585446 (11343,65 / sec)

Delphi 11 (64bit optimized string comparison):<br>
Duration: **ø36,69**sec Count: 585446 (15957,42 / sec)

Delphi 11 (64bit optimized string comparison and access):<br>
Duration: **ø25,41**sec Count: 585446 (23043,61 / sec)

TypeScript (node.js):<br>
Duration: **ø25.726s**ec Count: 585446 (22756.977376972714 / sec)

C# .NET 4.8:<br>
Duration: **ø19,939sec** Count: 585446 (29361,8536536436 / sec)

C# .NET 7.0:<br>
Duration: **ø16,537sec** Count: 585446 (35402,18903065853 / sec)

C++:<br>
Duration: **ø13.715**sec Count: 585446 (42686.5 / sec)
