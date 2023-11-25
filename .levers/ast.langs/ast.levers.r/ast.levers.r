# trans quoted "call"s to ast "list"
codes.call.ast.prerec = 
\ (rec.func.name) \ (callings) callings |> 
as.list () |> lapply (\ (x) 
	if (is.call(x)) rec.func.name (x) else x) ;

codes.call.ast = 
codes.call.ast.prerec (codes.call.ast) ;


# trans ast "list" to quoted "call"s
codes.ast.call.prerec = 
\ (rec.func.name) \ (ast) ast |> 
lapply (\ (xs) 
	if (list.have.nest (xs)) rec.func.name (xs) else 
	if (is.list (xs)) as.call (xs) else xs) |> 
as.call() ;

codes.ast.call = 
codes.ast.call.prerec (codes.ast.call) ;




# to see does a list have a sub list
list.have.nest <- 
\ (lst) is.list(lst) && lst |> 
lapply (\ (x) is.list(x)) |> 
unlist () |> any () ;




# trans elements in ast "list" by f
codes.ast.deeplapply.element.prerec = 
\ (rec.func.name) \ (ast, f) if (is.list(ast)) 
ast |> 
lapply (\ (x) 
	if (is.list (x)) 
		rec.func.name (x, f) else 
	f (x)) else 
ast ;

codes.ast.deeplapply.element = 
codes.ast.deeplapply.element.prerec (codes.ast.deeplapply.element) ;


# trans elements in quoted "call"s by f
codes.call.trans.element = 
\ (callings, f = \ (x) x) 
callings |> 
codes.call.ast () |> 
codes.ast.deeplapply.element (f) |> 
codes.ast.call () ;




# trans asts in ast "list" by f
codes.ast.deeplapply.ast.prerec = 
\ (rec.func.name) \ (ast, f
	, f.ast.trees = f
	, f.ast.leaves = f
	, f.element.all = \ (x) x) 
if (is.list(ast)) 
ast |> 
lapply (\ (xs) 
	if (list.have.nest (xs)) 
	xs |> 
	rec.func.name (f
		, f.ast.trees
		, f.ast.leaves
		, f.element.all) |> 
	f.ast.trees () else 
	if (is.list (xs)) 
	xs |> f.ast.leaves () else 
	xs |> f.element.all ()) |> 
f.ast.trees () else 
ast ;

codes.ast.deeplapply.ast = 
codes.ast.deeplapply.ast.prerec (codes.ast.deeplapply.ast) ;

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





# check names did have a name
codes.names.have = 
\ (names, namez) 
names |> 
lapply (\(n) identical(namez,n)) |> 
unlist () |> any () ;

