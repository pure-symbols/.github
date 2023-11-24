


{ \ (rec.f) \ (x, infixname = x[[1]]) 
	paste (rec.f(x[[2]])
		, as.character(infixname)
		, rec.f(x[[3]]) ) 
} -> codes.ast.paster.r2sql.infix2 ;

{ \ (rec.f) \ (x, infixname = x[[1]])
	paste (as.character(infixname)
		, rec.f(x[[2]])) 
} -> codes.ast.paster.r2sql.infix1 ;

{ \ (rec.f) \ (x, sp = "")
	x |> tail(-1) |> 
	lapply(rec.f) |> 
	Reduce (\(a,b) paste (a,sp,b), x=_) 
} -> codes.ast.paster.r2sql.params.join ;




codes.ast.r2sql.rec = 
\ (ast) 
ast |> 
codes.ast.deeplapply.ast (\ (a) 
	
	# infix func 1
	if ( identical(a[[1]], quote(`!`)) ) 
	codes.ast.paster.r2sql.infix1 (codes.ast.r2sql.rec) (a) else 
	
	
	# infix func 1 or 2
	if ( identical(a[[1]], quote(`+`)) 
		|| identical(a[[1]], quote(`-`)) 
		) 
	(
		if (length(a) == 3) codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (a) else 
		if (length(a) == 2) codes.ast.paster.r2sql.infix1 (codes.ast.r2sql.rec) (a) else 
		as.character(a) 
	) else 
	
	# infix func 2
	if ( identical(a[[1]], quote(`*`)) 
		|| identical(a[[1]], quote(`/`)) 
		|| identical(a[[1]], quote(`==`)) 
		|| identical(a[[1]], quote(`!=`)) 
		|| identical(a[[1]], quote(`>`)) 
		|| identical(a[[1]], quote(`<`)) 
		|| identical(a[[1]], quote(`>=`)) 
		|| identical(a[[1]], quote(`<=`)) 
		) 
	codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (a) else 
	
	
	# special prefix/infix func
	if (identical(a[[1]], quote(pmax))) 
	a |> codes.ast.paster.r2sql.params.join (codes.ast.r2sql.rec) (",") |> paste("GREATEST","(",... = _,")") else 
	if (identical(a[[1]], quote(pmin))) 
	a |> codes.ast.paster.r2sql.params.join (codes.ast.r2sql.rec) (",") |> paste("LEAST","(",... = _,")") else 
	if (identical(a[[1]], quote(fifelse)) || identical(a[[1]], quote(ifelse))) 
	a |> codes.ast.paster.r2sql.params.join (codes.ast.r2sql.rec) (",") |> paste("IF","(",... = _,")") else 
	    
	if (identical(a[[1]], quote(`&`)) || identical(a[[1]], quote(`&&`))) 
	a |> codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (quote(`and`)) else 
	if (identical(a[[1]], quote(`|`)) || identical(a[[1]], quote(`||`))) 
	a |> codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (quote(`or`)) else 
	
	if (identical(a[[1]], quote(`%%`)) ) 
	a |> codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (quote(`%`))  else 
	if (identical(a[[1]], quote(`%/%`)) ) 
	a |> codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (quote(`div`))  else 
	
	
	if (identical(a[[1]], quote(`%in%`))) 
	a |> codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (quote(`in`))  else 
	if (identical(a[[1]], quote(c)) || identical(a[[1]], quote(`(`))) 
	a |> codes.ast.paster.r2sql.params.join (codes.ast.r2sql.rec) (",") |> paste("(",... = _,")") else 
	
	if (identical(a[[1]], quote(case_when)))
	a |> codes.ast.paster.r2sql.params.join (codes.ast.r2sql.rec) ("")|> paste("CASE",... = _,"END") else
	if (identical(a[[1]], quote(`~`)))
	a |> codes.ast.paster.r2sql.infix2 (codes.ast.r2sql.rec) (quote(`THEN`)) |> paste ("WHEN",... = _) else 
	
	
	
	# prefix func *
	if ( is.name(a[[1]]) 
		&& is.symbol(a[[1]]) 
		)
	a |> 
	codes.ast.paster.r2sql.params.join (codes.ast.r2sql.rec) (",") |> 
	paste (as.character(a[[1]]),"(", ... = _ ,")") else 
	
	# to str
	as.character(a) ) ;



codes.ast.r2sql = 
\ (ast) ast |> 
codes.ast.deeplapply.elem (\ (x) if (is.character(x)) paste0 ("'",x,"'") else x) |>
codes.ast.r2sql.rec () ;


codes.src.r2sql.exprs = 
(\ (rsrc) rsrc |> 
	codes.str2call() |> 
	codes.call2ast () |> 
	codes.ast.r2sql () 
) |> Vectorize() ;
