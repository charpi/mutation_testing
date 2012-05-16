-module(function_guard).

-export([foo/1, bar/1]).

foo(X) when is_integer(X); X > 0 ->
    X + 1;
foo(L) when is_list(L) ->
    L.

bar(X) ->
    case X of
        Int when is_integer(Int) ->
            Int + 1;
        L ->
            L
    end.
