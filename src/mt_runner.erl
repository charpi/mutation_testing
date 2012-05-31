%%%
%%% Copyright (c) 2012, Nicolas Charpentier, Diana Corbacho
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in the
%%%       documentation and/or other materials provided with the distribution.
%%%     * Neither the name of the <organization> nor the
%%%       names of its contributors may be used to endorse or promote products
%%%       derived from this software without specific prior written permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%%% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT
%%% HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%%% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
%%% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
%%% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%%% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%%% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%

-module(mt_runner).

-export([mutate/3]).


mutate({modules, Modules}, Mutations, Fun) ->
    [mutate_module(Module, Mutations, Fun) || Module <- Modules].

mutate_module(Module, Mutations, Fun) ->
    {Module, Binary, _} = code:get_object_code(Module),
    {ok,{Module, Abstract}} = beam_lib:chunks(Binary,[abstract_code]),
    [{abstract_code,{raw_abstract_v1,Forms}}] = Abstract,
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


