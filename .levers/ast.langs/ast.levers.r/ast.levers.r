# trans quoted "call"s to ast "list"
codes.call.become.ast.prerec = 
\ (rec.func.name) \ (callings) callings |> 
as.list () |> lapply (\ (x) 
	if (is.call(x)) rec.func.name (x) else x) ;

codes.call.become.ast = 
codes.call.become.ast.prerec (codes.call.become.ast) ;


# trans ast "list" to quoted "call"s
codes.ast.become.call.prerec = 
\ (rec.func.name) \ (ast) ast |> 
lapply (\ (xs) 
	if (list.have.nest (xs)) rec.func.name (xs) else 
	if (is.list (xs)) as.call (xs) else xs) |> 
as.call() ;

codes.ast.become.call = 
codes.ast.become.call.prerec (codes.ast.become.call) ;




# to see does a list have a sub list
list.have.nest <- 
\ (lst) is.list(lst) && lst |> 
lapply (\ (x) is.list(x)) |> 
unlist () |> any () ;




# trans elements in ast "list" by f
codes.ast.deepmap.element.prerec = 
\ (rec.func.name) \ (ast, f) if (is.list(ast)) 
ast |> 
lapply (\ (x) 
	if (is.list (x)) 
		rec.func.name (x, f) else 
	f (x)) else 
f (ast) ;

codes.ast.deepmap.element = 
codes.ast.deepmap.element.prerec (codes.ast.deepmap.element) ;


# trans elements in quoted "call"s by f
codes.call.trans.element = 
\ (callings, f = \ (x) x) 
callings |> 
codes.call.become.ast () |> 
codes.ast.deepmap.element (f) |> 
codes.ast.become.call () ;




# trans asts in ast "list" by f
codes.ast.deepmap.ast.prerec = 
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
ast |> f.element.all () ;

codes.ast.deepmap.ast = 
codes.ast.deepmap.ast.prerec (codes.ast.deepmap.ast) ;

# trans asts in quoted "call"s by f
codes.call.trans.ast = 
\ (callings, f = \ (a) a) callings |> 
codes.call.become.ast () |> 
codes.ast.deepmap.ast (f) |> 
codes.ast.become.call () ;



# parse and quote code string to "call"s
codes.src.become.call = 
\ (src) (src |> 
	parse (text = _) |> 
	as.call () |> 
	as.list ()) [[1]] ;

# trans "call"s to "expression"
codes.call.become.expression = 
\ (callings, f) callings |> as.expression () ;





# check names did have a name
codes.names.have = 
\ (names, namez) 
names |> 
lapply (\(n) identical(namez,n)) |> 
unlist () |> any () ;

