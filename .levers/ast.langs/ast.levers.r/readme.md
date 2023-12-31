All tested on [*webr.r-wasm*](https://webr.r-wasm.org/latest).



## Simple


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


Trans src's ast by f : 

~~~ r
'list (1,2,3+1-4*8*6,list (list(7*1), 3*5))' |> 

codes.src.trans.ast (\ (ast) 
	if (ast[[1]] |> identical (`*` |> quote ())) 
	`[[<-` (ast, 2, value = 0) else ast) ;
# [1] "list(1, 2, 3 + 1 - 0 * 6, list(list(0 * 1), 0 * 5))"
~~~


## Variables

List & Map variables from calls : 

~~~ r
quote (a + 1 - "k" * b %in% list (c, list (d, list (e, foo (f) |> g (h)))) && y || a || c (z, z)) |> 
codes.call.to.ast () -> xyz ;

list ("a","b","c","d","e","f","h","y","z") |> Vectorize( as.symbol ) () |> 
identical ( xyz |> codes.ast.ls.variables () ) ; # [1] TRUE

list ("a","b","c","d","e","f","h","y","a","z","z") |> Vectorize( as.symbol ) () |> 
identical ( xyz |> codes.ast.ls.variables (\ (a) a) ) ; # [1] TRUE

xyz |> 
codes.ast.maps.variables (as.character) |> 
codes.ast.to.call () ;
# "a" + 1 - "k" * "b" %in% list("c", list("d", list("e", g(foo("f"), "h")))) && "y" || "a" || c("z", "z")
~~~

List variables from src(s) : 

~~~ r
'a + 1 - "k" * b %in% 
list (quote (`/`), quote (`!`(F)), quote (!f)
, c, list (d, list (e, foo (f) |> g (h)))) && 
y || a || c (`/`, z, z)' |> 
codes.src.ls.variables () ;
# [1] "a" "b" "/" "F" "f" "c" "d" "e" "h" "y" "z"

c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
codes.srcs.ls.variables () ;
# [1] "a" "b" "/" "F" "f" "z" "c" "d" "e" "h" "y"
~~~

