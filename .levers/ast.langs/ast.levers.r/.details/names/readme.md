
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
