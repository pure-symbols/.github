
Trans `*` to `\` :

~~~ r
list (1,2,3+1-4*8,list (3*5)) |> quote() |> 

codes.call.trans.element (\ (a) 
	if (identical(a, `*` |> quote ())) 
	`/` |> quote () else a) ;
# list(1, 2, 3 + 1 - 4/8, list(3/5))
~~~

Trans all `*` expression's first argument to `7` :

~~~ r
list (1,2,3+1-4*8,list (3*5)) |> quote() |> 

codes.call.trans.ast (\ (ast) 
	if (ast[[1]] |> identical(`*` |> quote ())) 
	`[[<-` (ast, 2, value = 7) else ast) ;
# list(1, 2, 3 + 1 - 7 * 8, list(7 * 5))
~~~
