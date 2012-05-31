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

-module(mt_runner_tests).

-include_lib("eunit/include/eunit.hrl").


module_with_store_test_() ->
    {setup,
     fun() -> ok end,
     fun(_) ->
	     Files = filelib:wildcard(filename:join([test_utils:priv_directory(),
						     "*.beam"])),
	     [file:delete(File)|| File <- Files]
     end,
     [fun() ->
	      Self = self(),
	      StoreFun = fun(Module, Mutations) -> Self ! {store, Module,
							   Mutations} end,

	      {Forms, Mutations} = test_utils:test_data_with_load(export),
	      [[ok]] = mt_runner:mutate({modules,[export]}, [remove_export],
					StoreFun),

	      receive
		  {store, {export, original}, Forms} -> ok
	      after 1000 ->
		      exit(original_not_stored)
	      end,
	      [receive
		   {store, {export, remove_export,_}, [_|Mutation]} -> ok;
		   X ->
		       exit(X)
	       after 1000 ->
		       exit(store_fun_not_called)
	       end || [_|Mutation] <- Mutations]
      end]}.
