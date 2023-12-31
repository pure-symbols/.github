
Trans `*` to `\` by use `codes.call.trans.element` :

~~~ r
list (1,2,3+1-4*8*6,list (3*5)) |> quote() |> 

codes.call.trans.element (\ (a) 
	if (a |> identical (`*` |> quote ())) 
	`/` |> quote () else a) ;
# list(1, 2, 3 + 1 - 4/8/6, list(3/5))
~~~

Trans all `*` expression's first argument to `7` by use `codes.call.trans.ast` :

~~~ r
list (1,2,3+1-4*8*6,list (3*5)) |> quote() |> 

codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical (`*` |> quote ())) 
	`[[<-` (ast, 2, value = 7) else ast) ;
# list(1, 2, 3 + 1 - 7 * 6, list(7 * 5))

list (1,2,3+1-4*8*6,list (list(7),3*5)) |> quote() |> 

codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical (list |> quote ())) 
	`[[<-` (ast, 3, value = 0) else ast) ;
# list(1, 0, 3 + 1 - 4 * 8 * 6, list(list(7, 0), 0))
~~~

Trans string src to "call"s by use `codes.src.to.call` then do something :

~~~ r
'list (1,2,3+1-4*8*6,list (3*5))' |>

codes.src.to.call () |> 

codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical (`*` |> quote ())) 
	`[[<-` (ast, 2, value = 0) else ast) ;
# list(1, 2, 3 + 1 - 0 * 6, list(0 * 5))
~~~

Trans "call"s to "expression" by use `codes.call.to.expression` then do something :

~~~ r
'list (1,2,3+1-4*8*6,list (list(7*1), 3*5))' |> codes.src.to.call () |> 
codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical (`*` |> quote ())) 
	`[[<-` (ast, 2, value = 0) else ast) |> 

codes.call.to.expression () -> xyz ;
	
xyz |> eval () |> identical (list(1, 2, 4, list(list(0), 0))) ; # [1] TRUE
xyz |> as.character () ; # [1] "list(1, 2, 3 + 1 - 0 * 6, list(list(0 * 1), 0 * 5))"
~~~

Trans src's ast by f : 

~~~ r
'list (1,2,3+1-4*8*6,list (list(7*1), 3*5))' |> 

codes.src.trans.ast (\ (ast) 
	if (ast[[1]] |> identical (`*` |> quote ())) 
	`[[<-` (ast, 2, value = 0) else ast) ;
# [1] "list(1, 2, 3 + 1 - 0 * 6, list(list(0 * 1), 0 * 5))"
~~~
