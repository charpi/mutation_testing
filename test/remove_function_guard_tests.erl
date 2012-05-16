-module(remove_function_guard_tests).

-include_lib("eunit/include/eunit.hrl").

all_mutations_test_() ->
    test_utils:test_description(function_guard, remove_function_guard).
