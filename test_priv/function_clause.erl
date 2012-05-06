-module(function_clause).

-export([foo/0]).
-export([bar/1]).

foo() ->
    foo.

bar(first) ->
    first;
bar(second) ->
    second.
    
