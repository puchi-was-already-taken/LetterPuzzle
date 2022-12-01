# LetterPuzzle
I wanted to get a rough understanding about the difference of performance between Delphi code and TypeScript in string intensive tasks.
Therefore I implemented a simple program which makes heavy use of string comparison and concatenation.
The program is searching for a chain of Words fitting a given budget of letters.

By default TypeScript, executed via node.js, easily wins out against the Delphi binary.
Only with the help of quite heavy optimizations is the Delphi code able to "score" a tie.
Beyond that, it is only marginally possible to get the Delphi code to run faster. (We are talking at max. ~1 second.)
Aside from that, of the implementations i wrote by now, C++ with optimization level 2 is the undisputed performace king.

All performance tests where run on an AMD Ryzen 3700X CPU.

Delphi 11 (64bit standard string access and comparison):<br>
Duration: **51,61**sec Count: 585446 (11343,65 / sec)

Delphi 11 (64bit optimized string comparison):<br>
Duration: **36,69**sec Count: 585446 (15957,42 / sec)

Delphi 11 (64bit optimized string comparison and access):<br>
Duration: **25,41**sec Count: 585446 (23043,61 / sec)

TypeScript (node.js):<br>
Duration: **25.726s**ec Count: 585446 (22756.977376972714 / sec)

C++:<br>
Duration: **13.715**sec Count: 585446 (42686.5 / sec)
