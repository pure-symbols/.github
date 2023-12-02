
Tested on [*webr.r-wasm*](https://webr.r-wasm.org/latest).

## Trans

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

## Names

Check have : 

~~~ r
c("aaa","bbb","ccc") |> 
Vectorize( as.symbol ) () |> 

codes.names.have (quote(aaa)) ;

# [1] TRUE


c("aaa","bbb","ccc") |> 
Vectorize( as.symbol ) () |> 

codes.names.have (quote(bbb)) ;

# [1] TRUE


c("aaa","bbb","ccc") |> 
Vectorize( as.symbol ) () |> 

codes.names.have (quote(aax)) ;

# [1] FALSE
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
'a + 1 - "k" * b %in% list (c, list (d, list (e, foo (f) |> g (h)))) && y || a || c (z, z)' |> 
codes.src.ls.variables () ; # [1] "a" "b" "c" "d" "e" "f" "h" "y" "z"

c ('a + 1 - "k" * b'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (z, z)') |> 
codes.srcs.ls.variables () ;
# [1] "a" "b" "z" "c" "d" "e" "f" "h" "y"
~~~

List variables from src(s) - more : 

~~~ r
c ('a + 1 - "k" * b'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (z, z)') |> 
Vectorize (codes.src.ls.variables) ( ) ;
## $`a + 1 - "k" * b`
## [1] "a" "b"
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`
## [1] "z" "c" "d" "e" "f" "h"
## 
## $`y || a || c (z, z)`
## [1] "y" "a" "z"
## 



c ('a + 1 - "k" * b'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (z, z)') |> 
Vectorize (codes.src.ls.variables) ( ) |> unlist () ;
##                                       a + 1 - "k" * b1 
##                                                    "a" 
##                                       a + 1 - "k" * b2 
##                                                    "b" 
## z %in% list (c, list (d, list (e, foo (f) |> g (h))))1 
##                                                    "z" 
## z %in% list (c, list (d, list (e, foo (f) |> g (h))))2 
##                                                    "c" 
## z %in% list (c, list (d, list (e, foo (f) |> g (h))))3 
##                                                    "d" 
## z %in% list (c, list (d, list (e, foo (f) |> g (h))))4 
##                                                    "e" 
## z %in% list (c, list (d, list (e, foo (f) |> g (h))))5 
##                                                    "f" 
## z %in% list (c, list (d, list (e, foo (f) |> g (h))))6 
##                                                    "h" 
##                                    y || a || c (z, z)1 
##                                                    "y" 
##                                    y || a || c (z, z)2 
##                                                    "a" 
##                                    y || a || c (z, z)3 
##                                                    "z" 



c ('a + 1 - "k" * b'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (z, z)') |> 
Vectorize (codes.src.ls.variables) ( ) |> unlist () |> unique () ;
# [1] "a" "b" "z" "c" "d" "e" "f" "h" "y"



c ('a + 1 - "k" * b'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (z, z)') |> 
Vectorize (codes.src.ls.variables) (list (\ (a) a)) ;
## $`a + 1 - "k" * b`
## $`a + 1 - "k" * b`[[1]]
## a
## 
## $`a + 1 - "k" * b`[[2]]
## b
## 
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`[[1]]
## z
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`[[2]]
## c
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`[[3]]
## d
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`[[4]]
## e
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`[[5]]
## f
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`[[6]]
## h
## 
## 
## $`y || a || c (z, z)`
## $`y || a || c (z, z)`[[1]]
## y
## 
## $`y || a || c (z, z)`[[2]]
## a
## 
## $`y || a || c (z, z)`[[3]]
## z
## 
## 



c ('a + 1 - "k" * b'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (z, z)') |> 
Vectorize (codes.src.ls.variables) (list (\ (a) a)) |> unlist () ;
## $`a + 1 - "k" * b1`
## a
## 
## $`a + 1 - "k" * b2`
## b
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))1`
## z
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))2`
## c
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))3`
## d
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))4`
## e
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))5`
## f
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))6`
## h
## 
## $`y || a || c (z, z)1`
## y
## 
## $`y || a || c (z, z)2`
## a
## 
## $`y || a || c (z, z)3`
## z
## 



c ('a + 1 - "k" * b'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (z, z)') |> 
Vectorize (codes.src.ls.variables) (list (\ (a) a)) |> unlist () |> unique () |> 

identical (list ("a","b","z","c","d","e","f","h","y") |> lapply (as.symbol)) ;
# [1] TRUE
~~~

