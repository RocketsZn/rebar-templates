%%%-------------------------------------------------------------------
%%% @author {{author_name}} <{{author_email}}>
%%% @copyright (C) {{copyright_year}}, {{copyright_owner}}
%%% @doc
%%% EUnit test suite module {{name}}.
%%% @end
%%% Created :  {{now_ts}} by {{author_name}} <{{author_email}}>
%%%-------------------------------------------------------------------
-module({{name}}_tests).
-author('{{author_name}} <{{author_email}}>').

-define(NOTEST, true).
-define(NOASSERT, true).

-include_lib("eunit/include/eunit.hrl").

-define(MODNAME, {{name}}).


-spec {{name}}_test_() -> List
  where
       List = [term()]
{{name}}_test_() ->
    %% add your asserts in the returned list, e.g.:
    [
    %%   ?assert(?MODNAME:double(2) =:= 4),
    %%   ?assertMatch({ok, Pid}, ?MODNAME:spawn_link()),
    %%   ?assertEqual("ba", ?MODNAME:reverse("ab")),
    %%   ?assertError(badarith, ?MODNAME:divide(X, 0)),
    %%   ?assertExit(normal, ?MODNAME:exit(normal)),
    %%   ?assertThrow({not_found, _}, ?MODNAME:func(unknown_object))
    ].


%%% vim: set filetype=erlang tabstop=4 foldmarker=%%%',%%%. foldmethod=marker:
