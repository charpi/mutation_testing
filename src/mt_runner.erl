-module(mt_runner).

-export([mutate/3]).


mutate({modules, Modules}, Mutations, Fun) ->
    [mutate_module(Module, Mutations, Fun) || Module <- Modules].

mutate_module(Module, Mutations, Fun) ->
    {Module, Binary, _} = code:get_object_code(Module),
    {ok,{Module,[{abstract_code,Forms}]}} = beam_lib:chunks(Binary,[abstract_code]),
    [begin 
	 List = Mutation:mutate(Forms),
	 Fun(Module, List)
     end|| Mutation <- Mutations].
    
