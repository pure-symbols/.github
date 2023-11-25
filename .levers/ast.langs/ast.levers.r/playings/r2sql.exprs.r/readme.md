A Demo which trans r expressions to sql expressions.

### Tests

#### *1*

run: 

~~~ r
"a+b*c*(d-e+f)*ifelse(x %in% c('xx','yy'), a, list(a,b,case_when (a%%2!=0~1,a%/%2>=9~b,a-3==1~3)))" |>
    codes.src.r2sql.exprs ()
~~~

out: 

~~~ r
                                                                 a+b*c*(d-e+f)*ifelse(x %in% c('xx','yy'), a, list(a,b,case_when (a%%2!=0~1,a%/%2>=9~b,a-3==1~3))) 
"a + b * c * ( d - e + f ) * IF ( x in ( 'xx' , 'yy' ) , a , list ( a , b , CASE WHEN a % 2 != 0 THEN 1  WHEN a div 2 >= 9 THEN b  WHEN a - 3 == 1 THEN 3 END ) )" 
~~~

#### *2*

run: 

~~~ r
"a+ifelse(x %in% c('xx','yy'), a, list(a,b,case_when (a%%2!=0~case_when (a-3==1~3),a%/%2>=9~b,a%in%case_when (a%%2!=0~1)~3)))" |>
  codes.src.r2sql.exprs ()
~~~

out: 

~~~ r
                                                                              a+ifelse(x %in% c('xx','yy'), a, list(a,b,case_when (a%%2!=0~case_when (a-3==1~3),a%/%2>=9~b,a%in%case_when (a%%2!=0~1)~3))) 
"a + IF ( x in ( ( 'xx' , 'yy' ) ) , a , list ( a , b , CASE WHEN a % 2 != 0 THEN CASE WHEN a - 3 == 1 THEN 3 END  WHEN a div 2 >= 9 THEN b  WHEN a in ( CASE WHEN a % 2 != 0 THEN 1 END ) THEN 3 END ) )"
~~~

