# trans quoted "call"s to ast "list"
codes.call.to.ast.prerec = 
\ (rec.func.name) \ (callings) callings |> 
as.list () |> lapply (\ (x) 
	if (is.call(x)) rec.func.name (x) else x) ;

codes.call.to.ast = 
codes.call.to.ast.prerec (codes.call.to.ast) ;


# trans ast "list" to quoted "call"s
codes.ast.to.call.prerec = 
\ (rec.func.name) \ (ast) ast |> 
lapply (\ (xs) 
	if (list.have.nest (xs)) rec.func.name (xs) else 
	if (is.list (xs)) as.call (xs) else xs) |> 
as.call() ;

codes.ast.to.call = 
codes.ast.to.call.prerec (codes.ast.to.call) ;




# to see does a list have a sub list
list.have.nest <- 
\ (lst) is.list(lst) && lst |> 
lapply (\ (x) is.list(x)) |> 
unlist () |> any () ;




# trans elements in ast "list" by f
codes.ast.maps.element.prerec = 
\ (rec.func.name) \ (ast, f) if (is.list(ast)) 
ast |> 
lapply (\ (x) 
	if (is.list (x)) 
		rec.func.name (x, f) else 
	f (x)) else 
f (ast) ;

codes.ast.maps.element = 
codes.ast.maps.element.prerec (codes.ast.maps.element) ;


# trans elements in quoted "call"s by f
codes.call.trans.element = 
\ (callings, f = \ (x) x) 
callings |> 
codes.call.to.ast () |> 
codes.ast.maps.element (f) |> 
codes.ast.to.call () ;




# trans asts in ast "list" by f
codes.ast.maps.ast.prerec = 
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

codes.ast.maps.ast = 
codes.ast.maps.ast.prerec (codes.ast.maps.ast) ;

# trans asts in quoted "call"s by f
codes.call.trans.ast = 
\ (callings, f = \ (a) a
	, f.ast.trees = f
	, f.ast.leaves = f
	, f.element.all = \ (x) x) 
callings |> 
codes.call.to.ast () |> 
codes.ast.maps.ast (f
	, f.ast.trees
	, f.ast.leaves
	, f.element.all) |> 
codes.ast.to.call () ;



# parse and quote code string to "call"s
codes.src.to.call = 
\ (src) (src |> 
	parse (text = _) |> 
	as.call () |> 
	as.list ()) [[1]] ;

# trans "call"s to "expression"
codes.call.to.expression = 
\ (callings, f = \ (a) a) callings |> as.expression () |> f () ;

# trans "call"s to "charactor" src
codes.call.to.src = 
\ (callings, f) 
callings |> 
codes.call.to.expression (as.character) ;

# trans asts in src by f
codes.src.trans.ast = 
\ (src, f
	, f.ast.trees = f
	, f.ast.leaves = f
	, f.element.all = \ (x) x) 
src |> 
codes.src.to.call () |> 
codes.call.trans.ast (f
	, f.ast.trees
	, f.ast.leaves
	, f.element.all) |> 
codes.call.to.src () ;



# check names did have a name
codes.names.have = 
\ (names, namez) 
names |> 
lapply (\(n) identical(namez,n)) |> 
unlist () |> any () ;

