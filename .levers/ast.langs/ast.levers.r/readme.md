
Trans `*` to `\` by use `codes.call.trans.element` :

~~~ r
list (1,2,3+1-4*8,list (3*5)) |> quote() |> 

codes.call.trans.element (\ (a) 
	if (a |> identical (`*` |> quote ())) 
	`/` |> quote () else a) ;
# list(1, 2, 3 + 1 - 4/8, list(3/5))
~~~

Trans all `*` expression's first argument to `7` by use `codes.call.trans.ast` :

~~~ r
list (1,2,3+1-4*8,list (3*5)) |> quote() |> 

codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical (`*` |> quote ())) 
	`[[<-` (ast, 2, value = 7) else ast) ;
# list(1, 2, 3 + 1 - 7 * 8, list(7 * 5))
~~~

Trans string src to "call"s by use `codes.src.call` then do something :

~~~ r
'list (1,2,3+1-4*8,list (3*5))' |> codes.src.call () |> 

codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical(`*` |> quote ())) 
	`[[<-` (ast, 2, value = 0) else ast) ;
# list(1, 2, 3 + 1 - 0 * 8, list(0 * 5))
~~~

Evaluate a "call"s by use `codes.call.evals` :

~~~ r
'list (1,2,3+1-4*8,list (3*5))' |> codes.src.call () |> 

codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical(`*` |> quote ())) 
	`[[<-` (ast, 2, value = 0) else ast) |> 
	codes.call.evals () |> 
	
	identical (list(1, 2, 4, list(0))) ;
# [1] TRUE
~~~




