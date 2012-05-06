-module(atom).

-export([foo/0]).
-export([foobar/0]).

foo() ->
    foo.

foobar() ->    
    foobar,
    foo(),
    foobar.

