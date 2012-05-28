-module(mt_runner).

-export([mutate/3]).


mutate({modules, Modules}, Mutations, Fun) ->
    [mutate_module(Module, Mutations, Fun) || Module <- Modules].

mutate_module(Module, Mutations, Fun) ->
    {Module, Binary, _} = code:get_object_code(Module),
    {ok,{Module,[{abstract_code,{raw_abstract_v1,Forms}}]}} = beam_lib:chunks(Binary,[abstract_code]),
    Fun({Module,original}, Forms),
    [begin 
	 List = Mutation:mutate(Forms),
	 notify(Fun, Module, Mutation, List)
     end|| Mutation <- Mutations].

notify(Fun, Module, Mutation, List) ->
    notify(Fun, Module, Mutation, List, 1).

notify(_,_,_,[],_) ->
    ok;
notify(Fun, Module, Mutation, [H|T], Index) ->
    Fun(key(Module, Mutation, Index), H),
    notify(Fun, Module, Mutation, T, Index +1).

key(Module, Mutation, Index) ->
    {Module, Mutation, Index}.
