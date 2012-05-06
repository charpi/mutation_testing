-module(export).

-export([foo/0]).
-export([bar/0, baz/0]).

foo() ->
    foo.

bar() ->
    bar.

baz() ->
    baz.
    
