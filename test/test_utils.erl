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

-module(test_utils).

-export([test_description/2]).
-export([test_data/1]).

-export([assert_mutations/2]).

-include_lib("eunit/include/eunit.hrl").

test_description(Kind, MutationModule) ->
    [{"Generate mutations", fun () ->
				    {Forms, Mutations} = test_utils:test_data(Kind),
				    R = MutationModule:mutate(Forms),
				    test_utils:assert_mutations(Mutations,R)
			    end},
     {"Compile mutations", fun () ->
				   {Forms, _} = test_utils:test_data(Kind),
				   R = MutationModule:mutate(Forms),
				   [{ok,_,_} = compile:forms(Mutation,[binary,
								       report_errors]) ||
				       Mutation <- R]
			   end}].


test_data(Module) ->
    ModuleString = atom_to_list(Module),
    [BaseDir|_] = code:get_path(),
    Source = filename:join([BaseDir,
			    "..",
			    "priv",
			    ModuleString]),
    case compile:file(Source,[debug_info,binary,report_errors]) of
	{ok,Module,Binary} ->
	    {ok, Mutations} = file:consult(filename:join([BaseDir,
							  "..",
							  "priv",
							  ModuleString ++ "_mutations.data"])),
	    {ok,{Module,[{abstract_code,AST}]}} = beam_lib:chunks(Binary,[abstract_code]),
	    {raw_abstract_v1, Forms} =  AST,
	    {Forms, Mutations};
	Errors ->
	    exit({error_during_compilation,filename:absname(BaseDir),Errors})
    end.

assert_mutations([],[]) ->
    ok;
assert_mutations([],[_|_]=X) ->
    io:format("Extra: ~p~~n",[X]),
    exit({too_much_mutations,X});
assert_mutations([_|_]=X,[]) ->
    exit({too_few_mutations,X});
assert_mutations([[_|P]|T],[[_|A]|T2]) ->
    io:format("~p~n~p~n",[P,A]),
    ?assertMatch(P,A),
    assert_mutations(T,T2).
