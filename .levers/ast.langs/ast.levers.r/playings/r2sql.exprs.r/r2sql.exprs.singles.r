
{ \ (rec.f) \ (x, infixname = x[[1]]) 
	paste (rec.f(x[[2]])
		, as.character(infixname)
		, rec.f(x[[3]]) ) 
} -> paster.ast.infix.two ;

{ \ (rec.f) \ (x, infixname = x[[1]])
	paste (as.character(infixname)
		, rec.f(x[[2]])) 
} -> paster.ast.infix.one ;

{ \ (rec.f) \ (x, joins = "")
	x |> tail(-1) |> 
	lapply(rec.f) |> 
	Reduce (\(a,b) paste (a,joins,b), x=_) 
} -> paster.ast.prefix.params ;






codes.ast.r2sql.rec = 
\ (ast) 
ast |> 
codes.ast.maps.ast (\ (a) 
	
	# infix func 1
	if ( identical(a[[1]], quote(`!`)) ) 
	paster.ast.infix.one (codes.ast.r2sql.rec) (a) else 
	
	
	# infix func 1 or 2
	if ( identical (a[[1]], quote(`+`)) 
		|| identical (a[[1]], quote(`-`)) 
		) 
	(
		if (length(a) == 3) paster.ast.infix.two (codes.ast.r2sql.rec) (a) else 
		if (length(a) == 2) paster.ast.infix.one (codes.ast.r2sql.rec) (a) else 
		as.character(a) 
	) else 
	
	# infix func 2
	if ( identical (a[[1]], quote(`*`)) 
		|| identical (a[[1]], quote(`/`)) 
		|| identical (a[[1]], quote(`==`)) 
		|| identical (a[[1]], quote(`!=`)) 
		|| identical (a[[1]], quote(`>`)) 
		|| identical (a[[1]], quote(`<`)) 
		|| identical (a[[1]], quote(`>=`)) 
		|| identical (a[[1]], quote(`<=`)) 
		) 
	paster.ast.infix.two (codes.ast.r2sql.rec) (a) else 
	
	
	# special prefix/infix func
	if (identical (a[[1]], quote(pmax))) 
	a |> paster.ast.prefix.params (codes.ast.r2sql.rec) (",") |> paste("GREATEST","(",... = _,")") else 
	if (identical (a[[1]], quote(pmin))) 
	a |> paster.ast.prefix.params (codes.ast.r2sql.rec) (",") |> paste("LEAST","(",... = _,")") else 
	if (identical (a[[1]], quote(fifelse)) || identical (a[[1]], quote(ifelse))) 
	a |> paster.ast.prefix.params (codes.ast.r2sql.rec) (",") |> paste("IF","(",... = _,")") else 
	
	if (identical (a[[1]], quote(`&`)) || identical (a[[1]], quote(`&&`))) 
	a |> paster.ast.infix.two (codes.ast.r2sql.rec) (quote(`and`)) else 
	if (identical (a[[1]], quote(`|`)) || identical (a[[1]], quote(`||`))) 
	a |> paster.ast.infix.two (codes.ast.r2sql.rec) (quote(`or`)) else 
	
	if (identical (a[[1]], quote(`%%`))) 
	a |> paster.ast.infix.two (codes.ast.r2sql.rec) (quote(`%`))  else 
	if (identical (a[[1]], quote(`%/%`))) 
	a |> paster.ast.infix.two (codes.ast.r2sql.rec) (quote(`div`))  else 
	
	
	if (identical (a[[1]], quote(`%in%`))) 
	list (a[[1]], a[[2]], list (quote(c), a[[3]])) |> 
	paster.ast.infix.two (codes.ast.r2sql.rec) (quote(`in`))  else 
	if (identical (a[[1]], quote(c)) || identical(a[[1]], quote(`(`))) 
	a |> paster.ast.prefix.params (codes.ast.r2sql.rec) (",") |> paste("(",... = _,")") else 
	
	if (identical (a[[1]], quote(case_when)))
	a |> paster.ast.prefix.params (codes.ast.r2sql.rec) ("")|> paste("CASE",... = _,"END") else
	if (identical (a[[1]], quote(`~`)))
	a |> paster.ast.infix.two (codes.ast.r2sql.rec) (quote(`THEN`)) |> paste ("WHEN",... = _) else 
	
	
	
	# prefix func *
	if ( is.name (a[[1]]) 
		&& is.symbol (a[[1]]) 
		)
	a |> 
	paster.ast.prefix.params (codes.ast.r2sql.rec) (",") |> 
	paste (as.character (a[[1]]), "(", ... = _ , ")") else 
	
	# to str
	as.character(a) ) ;



codes.ast.r2sql = 
\ (ast) ast |> 
codes.ast.maps.element (\ (x) if (is.character(x)) paste0 ("'",x,"'") else x) |>
codes.ast.r2sql.rec () ;


codes.src.r2sql.exprs = 
(\ (rsrc) rsrc |> 
	codes.src.to.call () |> 
	codes.call.to.ast () |> 
	codes.ast.r2sql () 
) |> Vectorize () ;


# # Test
# 
# "a+b*c*(d-e+f)*ifelse(x %in% c('xx','yy'), a, list(a,b%in%case_when (a%%2!=0~1,a%/%2>=9~b,a-3==1~3)))" |> 
# codes.src.r2sql.exprs () ;
# #                                                                        a+b*c*(d-e+f)*ifelse(x %in% c('xx','yy'), a, list(a,b%in%case_when (a%%2!=0~1,a%/%2>=9~b,a-3==1~3))) 
# # "a + b * c * ( d - e + f ) * IF ( x in ( ( 'xx' , 'yy' ) ) , a , list ( a , b in ( CASE WHEN a % 2 != 0 THEN 1  WHEN a div 2 >= 9 THEN b  WHEN a - 3 == 1 THEN 3 END ) ) )" 
