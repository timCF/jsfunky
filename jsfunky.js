// Generated by IcedCoffeeScript 108.0.11
(function() {
  "use strict";
  var array_types, maybe_raise, reduce_list, reduce_map,
    __slice = [].slice;

  maybe_raise = function(jf, obj, path, functionname) {
    if (path.length === 0) {
      throw new Error(functionname + " func failed - empty path " + path);
    }
    if (!(jf.is_map(obj))) {
      throw new Error(functionname + " func failed first arg is not object " + obj);
    }
  };

  reduce_list = function(lst, acc, func) {
    return lst.reduce((function(acc, el) {
      return func(el, acc);
    }), acc);
  };

  reduce_map = function(obj, acc, func) {
    return Object.keys(obj).reduce((function(acc, k) {
      return func(k, obj[k], acc);
    }), acc);
  };

  array_types = ["[object Array]", "[object Int8Array]", "[object Uint8Array]", "[object Uint8ClampedArray]", "[object Int16Array]", "[object Uint16Array]", "[object Int32Array]", "[object Uint32Array]", "[object Float32Array]", "[object Float64Array]"];

  module.exports = {
    clone: function(some) {
      var jf, this_type;
      jf = this;
      this_type = Object.prototype.toString.call(some);
      switch (this_type) {
        case "[object Undefined]":
          return void 0;
        case "[object Boolean]":
          return some;
        case "[object Number]":
          return some;
        case "[object String]":
          return some;
        case "[object Function]":
          return new function() {
            return some;
          };
        case "[object Null]":
          return null;
        case "[object Object]":
          return Object.keys(some).reduce((function(acc, k) {
            acc[jf.clone(k)] = jf.clone(some[k]);
            return acc;
          }), {});
        default:
          if (array_types.indexOf(this_type) !== -1) {
            return some.map(function(el) {
              return jf.clone(el);
            });
          } else {
            throw new Error("clone func failed - unsupported data type " + Object.prototype.toString.call(some) + " for object " + some);
          }
      }
    },
    equal: function(a, b) {
      var jf, keys_a, keys_b, len_a, len_b, type_a, type_b, _i, _ref, _ref1, _results;
      jf = this;
      if (a === b) {
        return true;
      } else {
        _ref = [Object.prototype.toString.call(a), Object.prototype.toString.call(b)], type_a = _ref[0], type_b = _ref[1];
        if (type_a === type_b) {
          switch (type_a) {
            case "[object Undefined]":
              return true;
            case "[object Boolean]":
              return a === b;
            case "[object Number]":
              return a === b;
            case "[object String]":
              return a === b;
            case "[object Function]":
              return false;
            case "[object Null]":
              return true;
            case "[object Object]":
              _ref1 = [a, b].map(function(obj) {
                var k, lst, _;
                lst = [];
                for (k in obj) {
                  _ = obj[k];
                  lst.push(k);
                }
                return lst.sort();
              }), keys_a = _ref1[0], keys_b = _ref1[1];
              if (jf.equal(keys_a, keys_b)) {
                return keys_a.every(function(k) {
                  return jf.equal(a[k], b[k]);
                });
              } else {
                return false;
              }
              break;
            default:
              if (array_types.indexOf(type_a) !== -1) {
                len_a = a.reduce((function(acc, _) {
                  return acc + 1;
                }), 0);
                len_b = b.reduce((function(acc, _) {
                  return acc + 1;
                }), 0);
                if (len_a === len_b) {
                  return (function() {
                    _results = [];
                    for (var _i = 0; 0 <= len_a ? _i <= len_a : _i >= len_a; 0 <= len_a ? _i++ : _i--){ _results.push(_i); }
                    return _results;
                  }).apply(this).every(function(n) {
                    return jf.equal(a[n], b[n]);
                  });
                } else {
                  return false;
                }
              } else {
                throw new Error("equal func failed - unsupported data type " + type_a + " for object " + a);
              }
          }
        } else {
          return false;
        }
      }
    },
    is_undefined: function(some) {
      return Object.prototype.toString.call(some) === "[object Undefined]";
    },
    is_boolean: function(some) {
      return Object.prototype.toString.call(some) === "[object Boolean]";
    },
    is_number: function(some) {
      return Object.prototype.toString.call(some) === "[object Number]";
    },
    is_string: function(some) {
      return Object.prototype.toString.call(some) === "[object String]";
    },
    is_function: function(some) {
      return Object.prototype.toString.call(some) === "[object Function]";
    },
    is_null: function(some) {
      return Object.prototype.toString.call(some) === "[object Null]";
    },
    is_list: function(some) {
      return Object.prototype.toString.call(some) === "[object Array]";
    },
    is_map: function(some) {
      return Object.prototype.toString.call(some) === "[object Object]";
    },
    flatten: function(some) {
      var jf;
      jf = this;
      if (jf.is_list(some)) {
        return some.reduce((function(acc, el) {
          if (jf.is_list(el)) {
            return acc.concat(jf.flatten(el));
          } else {
            acc.push(el);
            return acc;
          }
        }), []);
      } else {
        throw new Error("get not list input " + some + " in jf flatten func");
      }
    },
    put_in: function(obj, path, value) {
      var head, jf, tail;
      jf = this;
      maybe_raise(jf, obj, path, "put_in");
      head = path[0], tail = 2 <= path.length ? __slice.call(path, 1) : [];
      if (tail.length === 0) {
        obj[head] = value;
        return obj;
      } else {
        obj[head] = jf.put_in(obj[head], tail, value);
        return obj;
      }
    },
    get_in: function(obj, path) {
      var data, head, jf, tail;
      jf = this;
      maybe_raise(jf, obj, path, "get_in");
      head = path[0], tail = 2 <= path.length ? __slice.call(path, 1) : [];
      data = obj[head];
      if ((tail.length === 0) || (!data)) {
        return data;
      } else {
        return jf.get_in(data, tail);
      }
    },
    update_in: function(obj, path, func) {
      var data, head, jf, tail;
      jf = this;
      maybe_raise(jf, obj, path, "update_in");
      head = path[0], tail = 2 <= path.length ? __slice.call(path, 1) : [];
      data = obj[head];
      if (tail.length === 0) {
        if (jf.is_function(func) && (func.length === 1)) {
          obj[head] = func(data);
          return obj;
        } else {
          throw new Error("got not function/1 handler in update_in func");
        }
      } else {
        obj[head] = jf.update_in(data, tail, func);
        return obj;
      }
    },
    reduce: function(some, acc, func) {
      var jf;
      jf = this;
      if (jf.is_list(some)) {
        if (!(jf.is_function(func)) || (func.length !== 2)) {
          throw new Error("reduce func failed - on lists lambda should be function arity 2");
        }
        return reduce_list(some, acc, func);
      } else if (jf.is_map(some)) {
        if (!(jf.is_function(func)) || (func.length !== 3)) {
          throw new Error("reduce func failed - on maps lambda should be function arity 3");
        }
        return reduce_map(some, acc, func);
      } else {
        throw new Error("reduce func failed - unsupported data first arg " + some);
      }
    },
    merge: function(target, obj) {
      var jf;
      jf = this;
      return jf.reduce(obj, target, function(k, v, acc) {
        acc[k] = v;
        return acc;
      });
    }
  };

}).call(this);
