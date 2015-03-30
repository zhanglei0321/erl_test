-module(t1).

-export([test/1,tree/1,dict/1,list/1,map/1]).

test(CaseNum)->
	random:seed(now()),
	Cases = make_case(CaseNum,[],CaseNum),
	{T1,V1} = timer:tc(?MODULE,tree,[Cases]),
	{T2,V2} = timer:tc(?MODULE,dict,[Cases]),
	{T3,V3} = timer:tc(?MODULE,list,[Cases]),
	{T4,V4} = timer:tc(?MODULE,map,[Cases]),
	io:format("time \ntree ~p \ndict ~p\nlist ~p\nmap ~p\n",[T1,T2,T3,T4]),
	%%check result
	lists:foreach(fun({K,V})-> 
				{value,FV1} = gb_trees:lookup(K,V1),
				{ok,FV2} = dict:find(K,V2)	,
				{ok,FV4} = maps:find(K,V4),
				SV = lists:sort(V),
				SV1 = lists:sort(FV1),
				SV2 = lists:sort(FV2),
				SV4 = lists:sort(FV4),
				if 
					SV =/= SV1->
						throw(e1);
					SV =/= SV2->
						throw(e2);
					SV =/= SV4->
						throw(e4);
					true->
						nothing 
				end
			end,V3).


make_case(0,L,_CaseNum)->
	L;
make_case(Num,L,CaseNum)->
	K = random:uniform(CaseNum),
	V = random:uniform(CaseNum),
	make_case(Num-1,[{K,V}|L],CaseNum).

tree(L)->
	lists:foldl(fun({K,V},T)-> 
			case gb_trees:lookup(K,T) of
				{_,OldV}->
					gb_trees:update(K,[V|OldV],T);
				none->
					gb_trees:insert(K,[V],T)
			end
		end, gb_trees:empty(),L).


dict(L)->
	lists:foldl(fun({K,V},T)-> 
			case dict:is_key(K,T) of 
				true->
					dict:append(K,V,T);
				_->
					dict:store(K,[V],T)
			end
		end, dict:new(),L).

list(L)->
	lists:foldl(fun({K,V},T)-> 
			case lists:keyfind(K,1,T) of
				{K,VLIST}->
					lists:keyreplace(K,1,T,{K,[V|VLIST]});
				_->
					[{K,[V]}|T]
			end
		end, [],L).

map(L)->
	lists:foldl(fun({K,V},T)-> 
			case maps:find(K,T) of
				{ok,VLIST}->
					maps:update(K,[V|VLIST],T);
				_->
					maps:put(K,[V],T)
			end
		end, maps:new(),L).



