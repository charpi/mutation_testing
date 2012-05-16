-module(remove_function_guard).

-export([mutate/1]).

mutate(Forms) ->
    {R,[]} = mt_utils:fold(fun mutate_fun/2, [], Forms),
    R.

mutate_fun({clause, _, _, [], _}, State) ->
    {nothing, State};
mutate_fun({clause, Line, Pattern, Guards, Body}, State) ->
    Gs = [ Guards -- [G] || G <- Guards],
    Replace = [{clause, Line, Pattern, G, Body} || G <- Gs],
    {replace, Replace, State}.
