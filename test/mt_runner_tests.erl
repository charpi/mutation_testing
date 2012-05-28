-module(mt_runner_tests).

-include_lib("eunit/include/eunit.hrl").

%% module_with_store_test() ->
%%     Self = self(),
%%     StoreFun = fun(Module, Mutations) -> Self ! {store, Module, Mutations} end,
    
%%     {_Forms, Mutations} = test_utils:test_data_with_load(export),

%%     ok = mt_runner:mutate({modules,[export]}, [remove_export], StoreFun),
%%     receive
%% 	    {store, remove_export, Mutations} -> ok
%%     after 1000 ->
%% 	    exit(store_fun_not_called)
%%     end.
