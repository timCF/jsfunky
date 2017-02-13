jf = require('../jsfunky')
assert = require('chai').assert

describe 'jsfunky', () ->
	it 'clone equal', () ->
		obj = {a: 1, b: {}, c: [{d: 2, e: [3,4,5]}, 6, 7], f: null, g: undefined, h: ((foo) -> foo + 1)}
		clone = jf.clone(obj)
		assert obj != clone
		assert jf.equal(obj, clone)
	it 'flatten', () ->
		assert jf.equal( jf.flatten([1, 2, [3, 4, [], 5, [6,7,8,[9]]]]), [1..9] )
		assert.throws (() -> jf.flatten({a: 1})), Error
	it 'put_in', () ->
		obj = {a: 1, b: {c: 2, d: {e: 3}}}
		# NOTE : put_in is not immutable function, so use jf.clone here
		assert jf.equal( jf.put_in(jf.clone(obj), ["b","d","f"], 4), {a: 1, b: {c: 2, d: {e: 3, f: 4}}} )
		assert jf.equal( jf.put_in(jf.clone(obj), ["b","f"], 4), {a: 1, b: {c: 2, d: {e: 3}, f: 4}} )
		assert jf.equal( jf.put_in(jf.clone(obj), ["f"], 4), {a: 1, b: {c: 2, d: {e: 3}}, f: 4} )
		assert.throws (() -> jf.put_in(jf.clone(obj), ["f","z"], 4)), Error
		assert.throws (() -> jf.put_in([], ["f"], 4)), Error
		assert.throws (() -> jf.put_in(1, ["f"], 4)), Error
	it 'get_in', () ->
		obj = {a: 1, b: {c: 2, d: {e: 3}}}
		assert jf.equal( jf.get_in(obj, ["b","d","e"]), 3 )
		assert jf.equal( jf.get_in(obj, ["b","d"]), {e: 3} )
		assert jf.equal( jf.get_in(obj, ["b"]), {c: 2, d: {e: 3}} )
		assert jf.get_in(obj, ["z"]) == undefined
		assert jf.get_in(obj, ["x","y","z"]) == undefined
		assert.throws (() -> jf.get_in(obj, ["b","d","e","z"])), Error
	it 'update_in', () ->
		obj = {a: 1, b: {c: 2, d: {e: 3}}}
		# NOTE : update_in is not immutable function, so use jf.clone here
		assert jf.equal( jf.update_in(jf.clone(obj), ["b","d","e"], (n) -> n + 1), {a: 1, b: {c: 2, d: {e: 4}}} )
		assert jf.equal( jf.update_in(jf.clone(obj), ["b","c"], (n) -> n + 1), {a: 1, b: {c: 3, d: {e: 3}}} )
		assert jf.equal( jf.update_in(jf.clone(obj), ["b","d","e"], (_) -> "hello"), {a: 1, b: {c: 2, d: {e: "hello"}}} )
		assert jf.equal( jf.update_in(jf.clone(obj), ["b","d","f"], (_) -> "hello"), {a: 1, b: {c: 2, d: {e: 3, f: "hello"}}} )
	it 'reduce', () ->
		assert jf.reduce([1,2,3], 0, (n, acc) -> n + acc) == 6
		assert jf.reduce({a: 1, b: 2, c: 3}, 0, (k, v, acc) -> if (k == "b") then acc else (acc + v)) == 4
	it 'typed arrays', () ->
		iarr = [230, 202, 150, 232, 248, 147, 92, 203, 35, 36, 168, 173, 115, 185, 81, 127]
		farr = [230, 202, 150, 232, 248, 147, 92, 203, 35, 36, 168, 173, 115, 185, 81, 127].map((some) -> some + 0.1)
		array_types = [
			"[object Array]",
			"[object Int8Array]",
			"[object Uint8Array]",
			"[object Uint8ClampedArray]",
			"[object Int16Array]",
			"[object Uint16Array]",
			"[object Int32Array]",
			"[object Uint32Array]",
			"[object Float32Array]",
			"[object Float64Array]"
		]
		int8_t = new Int8Array(iarr)
		uint8_t = new Uint8Array(iarr)
		uint8_tc = new Uint8ClampedArray(iarr)
		int16_t = new Int16Array(iarr)
		uint16_t = new Uint16Array(iarr)
		int32_t = new Int32Array(iarr)
		uint32_t = new Uint32Array(iarr)
		float = new Float32Array(farr)
		double = new Float64Array(farr)
		arrays = [iarr, int8_t, uint8_t, uint8_tc, int16_t, uint16_t, int32_t, uint32_t, float, double]
		assert arrays.every((arr, index) -> (Object.prototype.toString.call(arr) == array_types[index]))
		assert arrays.every((arr, index) -> (Object.prototype.toString.call( jf.clone(arr) ) == array_types[index]))
		assert arrays.every((arr, index) -> ( jf.clone(arr) != arr ))
		assert arrays.every((arr, index) -> jf.equal( jf.clone(arr) , arr ))
		assert arrays.every((arr, index) ->
			clone = jf.clone(arr)
			clone.every((n, i) -> n == arr[i]) and arr.every((n, i) -> n == clone[i]))
