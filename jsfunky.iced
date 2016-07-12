"use strict"
maybe_raise = (jf, obj, path, functionname) ->
	if (path.length == 0) then throw(new Error(functionname+" func failed - empty path "+path))
	if not(jf.is_map(obj)) then throw(new Error(functionname+" func failed first arg is not object "+obj))
reduce_list = (lst, acc, func) ->
	lst.reduce(((acc, el) -> func(el, acc)), acc)
reduce_map = (obj, acc, func) ->
	Object.keys(obj).reduce(((acc, k) -> func(k, obj[k], acc)), acc)
module.exports =
	clone: (some) ->
		jf = @
		switch Object.prototype.toString.call(some)
			when "[object Undefined]" then undefined
			when "[object Boolean]" then some
			when "[object Number]" then some
			when "[object String]" then some
			when "[object Function]" then (new () -> some)
			when "[object Null]" then null
			when "[object Array]" then some.map((el) -> jf.clone(el))
			when "[object Object]" then Object.keys(some).reduce(((acc, k) -> acc[jf.clone(k)] = jf.clone(some[k]); acc), {})
			else throw(new Error("clone func failed - unsupported data type " + Object.prototype.toString.call(some) + " for object "+some))
	equal: (a, b) ->
		jf = @
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
						if (len_a == len_b) then [0..len_a].every (n) -> jf.equal(a[n], b[n]) else false
					when "[object Object]"
						[keys_a, keys_b] = [a,b].map((obj) -> lst = []; lst.push(k) for k, _ of obj; lst.sort() )
						if jf.equal(keys_a, keys_b) then keys_a.every (k) -> jf.equal(a[k], b[k]) else false
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
		jf = @
		if jf.is_list(some)
			some.reduce(((acc, el) ->
				if jf.is_list(el)
					acc.concat(jf.flatten(el))
				else
					acc.push(el)
					acc),[])
		else
			throw(new Error("get not list input "+some+" in jf flatten func"))
	put_in: (obj, path, value) ->
		jf = @
		maybe_raise(jf, obj, path, "put_in")
		[head, tail...] = path
		if (tail.length == 0)
			obj[head] = value
			obj
		else
			obj[head] = jf.put_in(obj[head], tail, value)
			obj
	get_in: (obj, path) ->
		jf = @
		maybe_raise(jf, obj, path, "get_in")
		[head, tail...] = path
		data = obj[head]
		if (tail.length == 0) or (not data)
			data
		else
			jf.get_in(data, tail)
	update_in: (obj, path, func) ->
		jf = @
		maybe_raise(jf, obj, path, "update_in")
		[head, tail...] = path
		data = obj[head]
		if (tail.length == 0)
			if jf.is_function(func) and (func.length == 1)
				obj[head] = func(data)
				obj
			else
				throw(new Error("got not function/1 handler in update_in func"))
		else
			obj[head] = jf.update_in(data, tail, func)
			obj
	reduce: (some, acc, func) ->
		jf = @
		if jf.is_list(some)
			if (not(jf.is_function(func)) or (func.length != 2))
				throw(new Error("reduce func failed - on lists lambda should be function arity 2"))
			reduce_list(some, acc, func)
		else if jf.is_map(some)
			if (not(jf.is_function(func)) or (func.length != 3))
				throw(new Error("reduce func failed - on maps lambda should be function arity 3"))
			reduce_map(some, acc, func)
		else
			throw(new Error("reduce func failed - unsupported data first arg "+some))
