# trans quoted "call"s to ast "list"
codes.call.ast = 
\ (callings) callings |> 
as.list () |> lapply (\ (x) 
	if (is.call(x)) codes.call.ast (x) else x) ;

# trans ast "list" to quoted "call"s
codes.ast.call = 
\ (ast) ast |> 
lapply (\ (xs) 
	if (list.have.nest (xs)) codes.ast.call (xs) else 
	if (is.list (xs)) as.call (xs) else xs) |> 
as.call() ;





# to see does a list have a sub list
list.have.nest <- 
\ (lst) lst |> 
lapply (\ (x) is.list(x)) |> 
unlist () |> any () ;




# trans elements in ast "list" by f
codes.ast.deeplapply.element = 
\ (ast, f) ast |> 
lapply (\ (x) 
	if (is.list (x)) 
	codes.ast.deeplapply.element (x, f) else 
	f (x)) ;

# trans elements in quoted "call"s by f
codes.call.trans.element = 
\ (callings, f = \ (x) x) 
callings |> 
codes.call.ast () |> 
codes.ast.deeplapply.element (f) |> 
codes.ast.call () ;




# trans asts in ast "list" by f
codes.ast.deeplapply.ast = 
\ (ast, f
	, f.ast.trees = f
	, f.ast.leaves = f
	, f.element.all = \ (x) x) 
ast |> 
lapply (\ (xs) 
	if (list.have.nest (xs)) 
	xs |> 
	codes.ast.deeplapply.ast (f
		, f.ast.trees
		, f.ast.leaves
		, f.element.all) |> 
	f.ast.trees () else 
	if (is.list (xs)) 
	xs |> f.ast.leaves () else 
	xs |> f.element.all ()) |> 
f.ast.trees () ;

# trans asts in quoted "call"s by f
codes.call.trans.ast = 
\ (callings, f = \ (a) a) callings |> 
codes.call.ast () |> 
codes.ast.deeplapply.ast (f) |> 
codes.ast.call () ;



# parse and quote code string to "call"s
codes.src.call = 
\ (src) (src |> 
	parse (text = _) |> 
	as.call () |> 
	as.list ()) [[1]] ;

# trans "call"s to "expression"
codes.call.expression = 
\ (callings, f) callings |> as.expression () ;


