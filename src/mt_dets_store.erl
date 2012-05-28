-module(mt_dets_store).

-export([init/1]).
-export([stop/1]).
-export([store_fun/1]).

init(Name) ->
    {ok, Table} = dets:open_file(Name,[]),
    Table.

stop(Name) ->
    dets:close(Name).

store_fun(Name) ->
    fun(Key, Value) ->
	    dets:insert(Name,{Key,Value})
    end.
