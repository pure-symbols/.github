
codes.src.r2sql.exprs = 
(\ (rsrc) 
{
	codes.ast.r2sql.rec <- 
	\ (ast) ast |> 
	codes.ast.deeplapply.ast (\ (a) 
	{
		{ \ (x, infixname = x[[1]]) 
			paste (codes.ast.r2sql.rec(x[[2]])
				, as.character(infixname)
				, codes.ast.r2sql.rec(x[[3]]) ) 
		} -> paster.infix2 ;
		
		{ \ (x, infixname = x[[1]]) 
			paste (as.character(infixname)
				, codes.ast.r2sql.rec(x[[2]])) 
		} -> paster.infix1 ;
		
		{ \ (x, sp = "") 
			x |> tail(-1) |> 
			lapply(codes.ast.r2sql.rec) |> 
			Reduce (\(a,b) paste (a,sp,b), x=_) 
		} -> paster.params.join ;
		
		return (
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
			paster.infix2 (a) else 
			
			
			# infix func 1 or 2
			if ( identical(a[[1]], quote(`+`)) 
				|| identical(a[[1]], quote(`-`)) 
				)
			(
				if (length(a) == 3) paster.infix2 (a) else 
				if (length(a) == 2) paster.infix1 (a) else 
				as.character(a) 
			) else 
			
			# infix func 1
			if ( identical(a[[1]], quote(`!`)) )
			paster.infix1 (a) else 
			
			# special prefix/infix func
			if (identical(a[[1]], quote(pmax))) 
			a |> paster.params.join (",") |> paste("GREATEST","(",... = _,")") else 
			if (identical(a[[1]], quote(pmin))) 
			a |> paster.params.join (",") |> paste("LEAST","(",... = _,")") else 
			if (identical(a[[1]], quote(fifelse)) || identical(a[[1]], quote(ifelse))) 
			a |> paster.params.join (",") |> paste("IF","(",... = _,")") else 
			
			if (identical(a[[1]], quote(`&`)) || identical(a[[1]], quote(`&&`))) 
			a |> paster.infix2 (quote(`and`)) else 
			if (identical(a[[1]], quote(`|`)) || identical(a[[1]], quote(`||`))) 
			a |> paster.infix2 (quote(`or`)) else 
			
			if (identical(a[[1]], quote(`%%`)) ) 
			a |> paster.infix2 (quote(`%`)) else 
			if (identical(a[[1]], quote(`%/%`)) ) 
			a |> paster.infix2 (quote(`div`)) else 
			
			if (identical(a[[1]], quote(`%in%`))) 
			a |> paster.infix2 (quote(`in`)) else 
			if (identical(a[[1]], quote(c)) || identical(a[[1]], quote(`(`))) 
			a |> paster.params.join (",") |> paste("(",... = _,")") else 
			
			if (identical(a[[1]], quote(case_when)))
			a |> paster.params.join ("") |> paste("CASE",... = _,"END") else
			if (identical(a[[1]], quote(`~`)))
			a |> paster.infix2 ("THEN") |> paste ("WHEN", ... = _) else 
			
			
			# prefix func *
			if ( is.name(a[[1]]) 
				&& is.symbol(a[[1]]) 
				)
			a |> paster.params.join (",") |> 
			paste (as.character(a[[1]]),"(", ... = _ ,")") else 
			
			
			# to str
			as.character(a) ) ;
	}) ;
	
	{ \ (a) 
		a |> 
		codes.ast.deeplapply.elem (\ (x) I
			if (is.character(x)) paste0 ("'",x,"'") else x) |> 
		codes.ast.r2sql.rec () 
	} -> codes.ast.r2sql ;
	
	return (
		rsrc |> 
		codes.src.call() |> 
		codes.call.ast () |> 
		codes.ast.r2sql () ) ;
	
}) |> Vectorize() ;
