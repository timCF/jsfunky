"use strict"
maybe_raise = (funky, obj, path, functionname) ->
	if (path.length == 0) then throw(new Error(functionname+" func failed - empty path "+path))
	if not(funky.is_map(obj)) then throw(new Error(functionname+" func failed first arg is not object "+obj))
reduce_list = (lst, acc, func) ->
	lst.reduce(((acc, el) -> func(el, acc)), acc)
reduce_map = (obj, acc, func) ->
	Object.keys(obj).reduce(((acc, k) -> obj[k] = func(k, obj[k], acc)), acc)
module.exports =
	clone: (some) ->
		funky = @
		switch Object.prototype.toString.call(some)
			when "[object Undefined]" then undefined
			when "[object Boolean]" then some
			when "[object Number]" then some
			when "[object String]" then some
			when "[object Function]" then (new () -> some)
			when "[object Null]" then null
			when "[object Array]" then some.map((el) -> funky.clone(el))
			when "[object Object]" then Object.keys(some).reduce(((acc, k) -> acc[funky.clone(k)] = funky.clone(some[k]); acc), {})
			else throw(new Error("clone func failed - unsupported data type " + Object.prototype.toString.call(some) + " for object "+some))
	equal: (a, b) ->
		funky = @
		if a == b
			true
		else
			[type_a, type_b] = [Object.prototype.toString.call(a), Object.prototype.toString.call(b)]
			if type_a == type_b
				switch type_a
					when "[object Undefined]" then true
					when "[object Boolean]" then a == b
					when "[object Number]" then a == b
					when "[object String]" then a == b
					when "[object Function]" then false
					when "[object Null]" then true
					when "[object Array]"
						len_a = a.reduce(((acc, _) -> acc+1), 0)
						len_b = b.reduce(((acc, _) -> acc+1), 0)
						if (len_a == len_b) then [0..len_a].every (n) -> funky.equal(a[n], b[n]) else false
					when "[object Object]"
						[keys_a, keys_b] = [a,b].map((obj) -> lst = []; lst.push(k) for k, _ of obj; lst.sort() )
						if funky.equal(keys_a, keys_b) then keys_a.every (k) -> funky.equal(a[k], b[k]) else false
					else throw(new Error("equal func failed - unsupported data type " + type_a + " for object "+a))
			else
				false
	is_undefined: (some) -> Object.prototype.toString.call(some) == "[object Undefined]"
	is_boolean: (some) -> Object.prototype.toString.call(some) == "[object Boolean]"
	is_number: (some) -> Object.prototype.toString.call(some) == "[object Number]"
	is_string: (some) -> Object.prototype.toString.call(some) == "[object String]"
	is_function: (some) -> Object.prototype.toString.call(some) == "[object Function]"
	is_null: (some) -> Object.prototype.toString.call(some) == "[object Null]"
	is_list: (some) -> Object.prototype.toString.call(some) == "[object Array]"
	is_map: (some) -> Object.prototype.toString.call(some) == "[object Object]"
	flatten: (some) ->
		funky = @
		if funky.is_list(some)
			some.reduce(((acc, el) ->
				if funky.is_list(el)
					acc.concat(funky.flatten(el))
				else
					acc.push(el)
					acc),[])
		else
			throw(new Error("get not list input "+some+" in funky flatten func"))
	put_in: (obj, path, value) ->
		funky = @
		maybe_raise(funky, obj, path, "put_in")
		[head, tail...] = path
		if (tail.length == 0)
			obj[head] = value
			obj
		else
			obj[head] = funky.put_in(obj[head], tail, value)
			obj
	get_in: (obj, path) ->
		funky = @
		maybe_raise(funky, obj, path, "get_in")
		[head, tail...] = path
		data = obj[head]
		if (tail.length == 0) or (not data)
			data
		else
			funky.get_in(data, tail)
	update_in: (obj, path, func) ->
		funky = @
		maybe_raise(funky, obj, path, "update_in")
		[head, tail...] = path
		data = obj[head]
		if (tail.length == 0)
			if funky.is_function(func) and (func.length == 1)
				obj[head] = func(target)
				obj
			else
				throw(new Error("got not function/1 handler in update_in func"))
		else
			obj[head] = funky.update_in(data, tail, func)
			obj
	reduce: (some, acc, func) ->
		funky = @
		if funky.is_list(some)
			if (not(funky.is_function(func)) or (func.length != 2))
				throw(new Error("reduce func failed - on lists lambda should be function arity 2"))
			reduce_list(some, acc, func)
		else if funky.is_map(some)
			if (not(funky.is_function(func)) or (func.length != 3))
				throw(new Error("reduce func failed - on maps lambda should be function arity 3"))
			reduce_map(some, acc, func)
		else
			throw(new Error("reduce func failed - unsupported data first arg "+some))
