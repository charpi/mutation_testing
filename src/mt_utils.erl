%%%
%%% Copyright (c) 2012, Nicolas Charpentier
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
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%%% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%%% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
%%% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%%% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%%% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%%% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%%% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%

-module(mt_utils).

-export([fold/3]).

-record(state,{prev = [],
	       next = [],
	       mutations = []}).

fold(Fun, UserState, Forms) ->
    fold_forms(Fun, UserState, Forms, #state{}).

fold_forms(_, UserState, [], State) ->
    {State#state.mutations, UserState};
fold_forms(Fun, UserState, [H|Forms], State) ->
    Prev = State#state.prev,
    
    {Action, NewState, NewUS} = call_element(H, Fun, Forms, UserState, State),
    {Z,X} = case {Action, H} of
    		{nothing,{function,A,B,C,Clauses}} ->
    		    {Ms, NUS2} = fold(Fun,NewUS,Clauses),
		    MFunctions = [{function,A,B,C,M} || M <- Ms],
		    Ns = lists:foldl(fun(Elt, S) ->
					     add_mutation(Elt,Forms,S)
				     end,
				     NewState, MFunctions),
  		    {Ns,NUS2};
   		{nothing,{clause,A,B,C,Ops}} ->
    		    {Ms, NUS2} = fold(Fun,NewUS,Ops),
		    MFunctions = [{clause,A,B,C,M} || M <- Ms],
		    Ns = lists:foldl(fun(Elt, S) ->
					     add_mutation(Elt,Forms,S)
				     end,
				     NewState, MFunctions),
  		    {Ns,NUS2};
 		{nothing,_} ->
 		    {NewState,NewUS};
		_ ->
		    {NewState,NewUS}
	    end,
    Z2= Z#state{prev = [H|Prev]},
    fold_forms(Fun,X,Forms,Z2).


add_mutation(New, Forms, State) when is_list(New) ->
    Prev = State#state.prev,
    Next = State#state.next,
    Mutations = State#state.mutations,
    
    Mutation = lists:reverse(Prev) ++
	New ++
	Forms ++
	Next,
    NMutations = [Mutation|Mutations],
    State#state{mutations =NMutations};
add_mutation(New, Forms, State) ->
    add_mutation([New], Forms, State).

call_element(H, Fun, Forms, UserState, State) ->
    case catch Fun(H, UserState) of
	{'EXIT',_} ->
	    {nothing, State, UserState};
	{delete, NUS} ->
	    Ns = add_mutation([], Forms, State),
	    {delete, Ns, NUS};
	{replace, New, NUS} when is_list(New)->
	    Ns = lists:foldl(fun(Elt, S) ->
				     add_mutation(Elt, Forms, S)
			     end,
			     State, New),
	    {replace, Ns, NUS};
	{replace, New, NUS} ->
	    NState = add_mutation(New, Forms, State),
	    {replace, NState, NUS};
	{nothing, NUS} ->
	    {nothing, State, NUS}
    end.
