-module(operator).

-export(['+'/0]).
-export(['-'/0]).
-export(['*'/0]).
-export(['/'/0]).
-export([mix/0]).

'+'() ->
    1 + 1.

'-'() ->
    1 - 1.

'*'() ->
    1 * 1.

'/'() ->
    4 / 2.

mix() ->
    4 + 2 - 3.


