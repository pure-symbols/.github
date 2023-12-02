
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

List variables as str from src(s) : 

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

List variables as str from srcs with message : 

~~~ r
c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
Vectorize (codes.src.ls.variables) ( ) ;
## $`a + 1 - "k" * b`
## [1] "a" "b"
## 
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))`
## [1] "/" "F" "f"
## 
## $`z %in% list (c, list (d, list (e, foo (f) |> g (h))))`
## [1] "z" "c" "d" "e" "f" "h"
## 
## $`y || a || c (`/`, z, z)`
## [1] "y" "a" "/" "z"
## 



c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
Vectorize (codes.src.ls.variables) ( ) |> unlist () ;
##                                       a + 1 - "k" * b1 
##                                                    "a" 
##                                       a + 1 - "k" * b2 
##                                                    "b" 
##       quote (quote (`/`), quote (`!`(F)), quote (!f))1 
##                                                    "/" 
##       quote (quote (`/`), quote (`!`(F)), quote (!f))2 
##                                                    "F" 
##       quote (quote (`/`), quote (`!`(F)), quote (!f))3 
##                                                    "f" 
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
##                               y || a || c (`/`, z, z)1 
##                                                    "y" 
##                               y || a || c (`/`, z, z)2 
##                                                    "a" 
##                               y || a || c (`/`, z, z)3 
##                                                    "/" 
##                               y || a || c (`/`, z, z)4 
##                                                    "z" 



c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
Vectorize (codes.src.ls.variables) ( ) |> unlist () |> unique () ;
# [1] "a" "b" "/" "F" "f" "z" "c" "d" "e" "h" "y"
~~~

List variable as names from srcs with message : 

~~~ r
c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
Vectorize (codes.src.ls.variables) (list (\ (a) a)) -> x ;

### or 

c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
codes.srcs.ls.variables (\ (a) a) -> y ;

### same out: 

identical (x, y) ; # [1] TRUE

x ;
## $`a + 1 - "k" * b`
## $`a + 1 - "k" * b`[[1]]
## a
## 
## $`a + 1 - "k" * b`[[2]]
## b
## 
## 
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))`
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))`[[1]]
## `/`
## 
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))`[[2]]
## F
## 
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))`[[3]]
## f
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
## $`y || a || c (`/`, z, z)`
## $`y || a || c (`/`, z, z)`[[1]]
## y
## 
## $`y || a || c (`/`, z, z)`[[2]]
## a
## 
## $`y || a || c (`/`, z, z)`[[3]]
## `/`
## 
## $`y || a || c (`/`, z, z)`[[4]]
## z
## 
## 



### unlist and unique is similar 
### but just names only can inner lists. 

c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
Vectorize (codes.src.ls.variables) (list (\ (a) a)) |> unlist () ;
## $`a + 1 - "k" * b1`
## a
## 
## $`a + 1 - "k" * b2`
## b
## 
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))1`
## `/`
## 
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))2`
## F
## 
## $`quote (quote (`/`), quote (`!`(F)), quote (!f))3`
## f
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
## $`y || a || c (`/`, z, z)1`
## y
## 
## $`y || a || c (`/`, z, z)2`
## a
## 
## $`y || a || c (`/`, z, z)3`
## `/`
## 
## $`y || a || c (`/`, z, z)4`
## z
## 



c ('a + 1 - "k" * b'
, 'quote (quote (`/`), quote (`!`(F)), quote (!f))'
, 'z %in% list (c, list (d, list (e, foo (f) |> g (h))))'
, 'y || a || c (`/`, z, z)') |> 
Vectorize (codes.src.ls.variables) (list (\ (a) a)) |> unlist () |> unique () |> 

identical (list ("a","b","/","F","f","z","c","d","e","h","y") |> lapply (as.symbol)) ;
# [1] TRUE
~~~

