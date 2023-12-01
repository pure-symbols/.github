
# to see does a list have a sub list
codes.ast.nested <- 
\ (ast) 
is.list (ast) && 
ast |> 
lapply (\ (a) is.list (a)) |> 
unlist () |> 
any () ;

# check names did have a name
codes.names.have <- 
\ (names, namez) 
names |> 
lapply (\ (n) identical (namez,n)) |> 
unlist () |> 
any () ;






# trans quoted "call"s to ast "list"
codes.call.to.ast.prerec = 
\ (func.rec) \ (callings) 
callings |> 
as.list () |> 
lapply (\ (x) 
	if (! is.call (x)) x 
	else func.rec (x) 
) ;

codes.call.to.ast = 
codes.call.to.ast.prerec (codes.call.to.ast) ;


# trans ast "list" to quoted "call"s
codes.ast.to.call.prerec = 
\ (func.rec) \ (ast) 
ast |> 
lapply (\ (xs) 
	if (codes.ast.nested (xs)) func.rec (xs) else 
	if (is.list (xs)) as.call (xs) else xs) |> 
as.call () ;

codes.ast.to.call = 
codes.ast.to.call.prerec (codes.ast.to.call) ;







# trans elements in ast "list" by f
codes.ast.maps.element.prerec = 
\ (func.rec) \ (ast, f) if (is.list(ast)) 
ast |> 
lapply (\ (x) 
	if (is.list (x)) 
	func.rec (x, f) else 
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
\ (func.rec) \ (ast, f
	, f.ast.trees = f
	, f.ast.leaves = f
	, f.element.all = \ (x) x) 
if (is.list(ast)) 
ast |> 
lapply (\ (xs) 
	if (codes.ast.nested (xs)) 
	xs |> 
	func.rec (f
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
\ (src) 
( src |> 
	parse (text = _) |> 
	as.call () |> 
	as.list ()
) [[1]] ;

# trans "call"s to "expression"
codes.call.to.expression = 
\ (callings, f = \ (a) a) 
callings |> 
as.expression () |> 
f () ;

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



# list all variable names in a codes
codes.ast.ls.variables = 
\ (ast, f = unique) 
ast |> 
codes.ast.maps.ast (\ (a) c (list (list ()), a |> tail (-1))) |> 
codes.ast.maps.element (\ (a) if (is.name (a)) a else list ()) |> 
unlist () |> 
f () ;


# maps all variable names in a codes
codes.ast.maps.variables = 
\ (ast, f) 
ast |> 
codes.ast.maps.ast (\ (a) 
	c (list (a[[1]])
	, a |> tail (-1) |> 
		lapply (\ (n) if (is.name (n)) f (n) else n))
) ;





