(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (typeof x.$ === 'undefined')
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File === 'function' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[94m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return word
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	result = init(result.a);
	var model = result.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		result = A2(update, msg, model);
		stepper(model = result.a, viewMetadata);
		_Platform_dispatchEffects(managers, result.b, subscriptions(model));
	}

	_Platform_dispatchEffects(managers, result.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				p: bag.n,
				q: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.q)
		{
			x = temp.p(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		r: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		r: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**_UNUSED/
	var node = args['node'];
	//*/
	/**/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		message: func(record.message),
		stopPropagation: record.stopPropagation,
		preventDefault: record.preventDefault
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.message;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var view = impl.view;
			/**_UNUSED/
			var domNode = args['node'];
			//*/
			/**/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.setup && impl.setup(sendToApp)
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.onUrlChange;
	var onUrlRequest = impl.onUrlRequest;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		setup: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		init: function(flags)
		{
			return A3(impl.init, flags, _Browser_getUrl(), key);
		},
		view: impl.view,
		update: impl.update,
		subscriptions: impl.subscriptions
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { hidden: 'hidden', change: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { hidden: 'mozHidden', change: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { hidden: 'msHidden', change: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { hidden: 'webkitHidden', change: 'webkitvisibilitychange' }
		: { hidden: 'hidden', change: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		scene: _Browser_getScene(),
		viewport: {
			x: _Browser_window.pageXOffset,
			y: _Browser_window.pageYOffset,
			width: _Browser_doc.documentElement.clientWidth,
			height: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		width: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		height: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			scene: {
				width: node.scrollWidth,
				height: node.scrollHeight
			},
			viewport: {
				x: node.scrollLeft,
				y: node.scrollTop,
				width: node.clientWidth,
				height: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			scene: _Browser_getScene(),
			viewport: {
				x: x,
				y: y,
				width: _Browser_doc.documentElement.clientWidth,
				height: _Browser_doc.documentElement.clientHeight
			},
			element: {
				x: x + rect.left,
				y: y + rect.top,
				width: rect.width,
				height: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}




// STRINGS


var _Parser_isSubString = F5(function(smallString, offset, row, col, bigString)
{
	var smallLength = smallString.length;
	var isGood = offset + smallLength <= bigString.length;

	for (var i = 0; isGood && i < smallLength; )
	{
		var code = bigString.charCodeAt(offset);
		isGood =
			smallString[i++] === bigString[offset++]
			&& (
				code === 0x000A /* \n */
					? ( row++, col=1 )
					: ( col++, (code & 0xF800) === 0xD800 ? smallString[i++] === bigString[offset++] : 1 )
			)
	}

	return _Utils_Tuple3(isGood ? offset : -1, row, col);
});



// CHARS


var _Parser_isSubChar = F3(function(predicate, offset, string)
{
	return (
		string.length <= offset
			? -1
			:
		(string.charCodeAt(offset) & 0xF800) === 0xD800
			? (predicate(_Utils_chr(string.substr(offset, 2))) ? offset + 2 : -1)
			:
		(predicate(_Utils_chr(string[offset]))
			? ((string[offset] === '\n') ? -2 : (offset + 1))
			: -1
		)
	);
});


var _Parser_isAsciiCode = F3(function(code, offset, string)
{
	return string.charCodeAt(offset) === code;
});



// NUMBERS


var _Parser_chompBase10 = F2(function(offset, string)
{
	for (; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (code < 0x30 || 0x39 < code)
		{
			return offset;
		}
	}
	return offset;
});


var _Parser_consumeBase = F3(function(base, offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var digit = string.charCodeAt(offset) - 0x30;
		if (digit < 0 || base <= digit) break;
		total = base * total + digit;
	}
	return _Utils_Tuple2(offset, total);
});


var _Parser_consumeBase16 = F2(function(offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (0x30 <= code && code <= 0x39)
		{
			total = 16 * total + code - 0x30;
		}
		else if (0x41 <= code && code <= 0x46)
		{
			total = 16 * total + code - 55;
		}
		else if (0x61 <= code && code <= 0x66)
		{
			total = 16 * total + code - 87;
		}
		else
		{
			break;
		}
	}
	return _Utils_Tuple2(offset, total);
});



// FIND STRING


var _Parser_findSubString = F5(function(smallString, offset, row, col, bigString)
{
	var newOffset = bigString.indexOf(smallString, offset);
	var target = newOffset < 0 ? bigString.length : newOffset + smallString.length;

	while (offset < target)
	{
		var code = bigString.charCodeAt(offset++);
		code === 0x000A /* \n */
			? ( col=1, row++ )
			: ( col++, (code & 0xF800) === 0xD800 && offset++ )
	}

	return _Utils_Tuple3(newOffset, row, col);
});



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.expect.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done($elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done($elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.expect.b, xhr)); });
		$elm$core$Maybe$isJust(request.tracker) && _Http_track(router, xhr, request.tracker.a);

		try {
			xhr.open(request.method, request.url, true);
		} catch (e) {
			return done($elm$http$Http$BadUrl_(request.url));
		}

		_Http_configureRequest(xhr, request);

		request.body.a && xhr.setRequestHeader('Content-Type', request.body.a);
		xhr.send(request.body.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.headers; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.timeout.a || 0;
	xhr.responseType = request.expect.d;
	xhr.withCredentials = request.allowCookiesFromOtherDomains;
}


// RESPONSES

function _Http_toResponse(toBody, xhr)
{
	return A2(
		200 <= xhr.status && xhr.status < 300 ? $elm$http$Http$GoodStatus_ : $elm$http$Http$BadStatus_,
		_Http_toMetadata(xhr),
		toBody(xhr.response)
	);
}


// METADATA

function _Http_toMetadata(xhr)
{
	return {
		url: xhr.responseURL,
		statusCode: xhr.status,
		statusText: xhr.statusText,
		headers: _Http_parseHeaders(xhr.getAllResponseHeaders())
	};
}


// HEADERS

function _Http_parseHeaders(rawHeaders)
{
	if (!rawHeaders)
	{
		return $elm$core$Dict$empty;
	}

	var headers = $elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3($elm$core$Dict$update, key, function(oldValue) {
				return $elm$core$Maybe$Just($elm$core$Maybe$isJust(oldValue)
					? value + ', ' + oldValue.a
					: value
				);
			}, headers);
		}
	}
	return headers;
}


// EXPECT

var _Http_expect = F3(function(type, toBody, toValue)
{
	return {
		$: 0,
		d: type,
		b: toBody,
		a: toValue
	};
});

var _Http_mapExpect = F2(function(func, expect)
{
	return {
		$: 0,
		d: expect.d,
		b: expect.b,
		a: function(x) { return func(expect.a(x)); }
	};
});

function _Http_toDataView(arrayBuffer)
{
	return new DataView(arrayBuffer);
}


// BODY and PARTS

var _Http_emptyBody = { $: 0 };
var _Http_pair = F2(function(a, b) { return { $: 0, a: a, b: b }; });

function _Http_toFormData(parts)
{
	for (var formData = new FormData(); parts.b; parts = parts.b) // WHILE_CONS
	{
		var part = parts.a;
		formData.append(part.a, part.b);
	}
	return formData;
}

var _Http_bytesToBlob = F2(function(mime, bytes)
{
	return new Blob([bytes], { type: mime });
});


// PROGRESS

function _Http_track(router, xhr, tracker)
{
	// TODO check out lengthComputable on loadstart event

	xhr.upload.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Sending({
			sent: event.loaded,
			size: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Receiving({
			received: event.loaded,
			size: event.lengthComputable ? $elm$core$Maybe$Just(event.total) : $elm$core$Maybe$Nothing
		}))));
	});
}


function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2($elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = $elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = $elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}


function _Url_percentEncode(string)
{
	return encodeURIComponent(string);
}

function _Url_percentDecode(string)
{
	try
	{
		return $elm$core$Maybe$Just(decodeURIComponent(string));
	}
	catch (e)
	{
		return $elm$core$Maybe$Nothing;
	}
}


// DECODER

var _File_decoder = _Json_decodePrim(function(value) {
	// NOTE: checks if `File` exists in case this is run on node
	return (typeof File !== 'undefined' && value instanceof File)
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FILE', value);
});


// METADATA

function _File_name(file) { return file.name; }
function _File_mime(file) { return file.type; }
function _File_size(file) { return file.size; }

function _File_lastModified(file)
{
	return $elm$time$Time$millisToPosix(file.lastModified);
}


// DOWNLOAD

var _File_downloadNode;

function _File_getDownloadNode()
{
	return _File_downloadNode || (_File_downloadNode = document.createElement('a'));
}

var _File_download = F3(function(name, mime, content)
{
	return _Scheduler_binding(function(callback)
	{
		var blob = new Blob([content], {type: mime});

		// for IE10+
		if (navigator.msSaveOrOpenBlob)
		{
			navigator.msSaveOrOpenBlob(blob, name);
			return;
		}

		// for HTML5
		var node = _File_getDownloadNode();
		var objectUrl = URL.createObjectURL(blob);
		node.href = objectUrl;
		node.download = name;
		_File_click(node);
		URL.revokeObjectURL(objectUrl);
	});
});

function _File_downloadUrl(href)
{
	return _Scheduler_binding(function(callback)
	{
		var node = _File_getDownloadNode();
		node.href = href;
		node.download = '';
		node.origin === location.origin || (node.target = '_blank');
		_File_click(node);
	});
}


// IE COMPATIBILITY

function _File_makeBytesSafeForInternetExplorer(bytes)
{
	// only needed by IE10 and IE11 to fix https://github.com/elm/file/issues/10
	// all other browsers can just run `new Blob([bytes])` directly with no problem
	//
	return new Uint8Array(bytes.buffer, bytes.byteOffset, bytes.byteLength);
}

function _File_click(node)
{
	// only needed by IE10 and IE11 to fix https://github.com/elm/file/issues/11
	// all other browsers have MouseEvent and do not need this conditional stuff
	//
	if (typeof MouseEvent === 'function')
	{
		node.dispatchEvent(new MouseEvent('click'));
	}
	else
	{
		var event = document.createEvent('MouseEvents');
		event.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
		document.body.appendChild(node);
		node.dispatchEvent(event);
		document.body.removeChild(node);
	}
}


// UPLOAD

var _File_node;

function _File_uploadOne(mimes)
{
	return _Scheduler_binding(function(callback)
	{
		_File_node = document.createElement('input');
		_File_node.type = 'file';
		_File_node.accept = A2($elm$core$String$join, ',', mimes);
		_File_node.addEventListener('change', function(event)
		{
			callback(_Scheduler_succeed(event.target.files[0]));
		});
		_File_click(_File_node);
	});
}

function _File_uploadOneOrMore(mimes)
{
	return _Scheduler_binding(function(callback)
	{
		_File_node = document.createElement('input');
		_File_node.type = 'file';
		_File_node.multiple = true;
		_File_node.accept = A2($elm$core$String$join, ',', mimes);
		_File_node.addEventListener('change', function(event)
		{
			var elmFiles = _List_fromArray(event.target.files);
			callback(_Scheduler_succeed(_Utils_Tuple2(elmFiles.a, elmFiles.b)));
		});
		_File_click(_File_node);
	});
}


// CONTENT

function _File_toString(blob)
{
	return _Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
			callback(_Scheduler_succeed(reader.result));
		});
		reader.readAsText(blob);
		return function() { reader.abort(); };
	});
}

function _File_toBytes(blob)
{
	return _Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
			callback(_Scheduler_succeed(new DataView(reader.result)));
		});
		reader.readAsArrayBuffer(blob);
		return function() { reader.abort(); };
	});
}

function _File_toUrl(blob)
{
	return _Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
			callback(_Scheduler_succeed(reader.result));
		});
		reader.readAsDataURL(blob);
		return function() { reader.abort(); };
	});
}




var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});


// BYTES

function _Bytes_width(bytes)
{
	return bytes.byteLength;
}

var _Bytes_getHostEndianness = F2(function(le, be)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(new Uint8Array(new Uint32Array([1]))[0] === 1 ? le : be));
	});
});


// ENCODERS

function _Bytes_encode(encoder)
{
	var mutableBytes = new DataView(new ArrayBuffer($elm$bytes$Bytes$Encode$getWidth(encoder)));
	$elm$bytes$Bytes$Encode$write(encoder)(mutableBytes)(0);
	return mutableBytes;
}


// SIGNED INTEGERS

var _Bytes_write_i8  = F3(function(mb, i, n) { mb.setInt8(i, n); return i + 1; });
var _Bytes_write_i16 = F4(function(mb, i, n, isLE) { mb.setInt16(i, n, isLE); return i + 2; });
var _Bytes_write_i32 = F4(function(mb, i, n, isLE) { mb.setInt32(i, n, isLE); return i + 4; });


// UNSIGNED INTEGERS

var _Bytes_write_u8  = F3(function(mb, i, n) { mb.setUint8(i, n); return i + 1 ;});
var _Bytes_write_u16 = F4(function(mb, i, n, isLE) { mb.setUint16(i, n, isLE); return i + 2; });
var _Bytes_write_u32 = F4(function(mb, i, n, isLE) { mb.setUint32(i, n, isLE); return i + 4; });


// FLOATS

var _Bytes_write_f32 = F4(function(mb, i, n, isLE) { mb.setFloat32(i, n, isLE); return i + 4; });
var _Bytes_write_f64 = F4(function(mb, i, n, isLE) { mb.setFloat64(i, n, isLE); return i + 8; });


// BYTES

var _Bytes_write_bytes = F3(function(mb, offset, bytes)
{
	for (var i = 0, len = bytes.byteLength, limit = len - 4; i <= limit; i += 4)
	{
		mb.setUint32(offset + i, bytes.getUint32(i));
	}
	for (; i < len; i++)
	{
		mb.setUint8(offset + i, bytes.getUint8(i));
	}
	return offset + len;
});


// STRINGS

function _Bytes_getStringWidth(string)
{
	for (var width = 0, i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		width +=
			(code < 0x80) ? 1 :
			(code < 0x800) ? 2 :
			(code < 0xD800 || 0xDBFF < code) ? 3 : (i++, 4);
	}
	return width;
}

var _Bytes_write_string = F3(function(mb, offset, string)
{
	for (var i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		offset +=
			(code < 0x80)
				? (mb.setUint8(offset, code)
				, 1
				)
				:
			(code < 0x800)
				? (mb.setUint16(offset, 0xC080 /* 0b1100000010000000 */
					| (code >>> 6 & 0x1F /* 0b00011111 */) << 8
					| code & 0x3F /* 0b00111111 */)
				, 2
				)
				:
			(code < 0xD800 || 0xDBFF < code)
				? (mb.setUint16(offset, 0xE080 /* 0b1110000010000000 */
					| (code >>> 12 & 0xF /* 0b00001111 */) << 8
					| code >>> 6 & 0x3F /* 0b00111111 */)
				, mb.setUint8(offset + 2, 0x80 /* 0b10000000 */
					| code & 0x3F /* 0b00111111 */)
				, 3
				)
				:
			(code = (code - 0xD800) * 0x400 + string.charCodeAt(++i) - 0xDC00 + 0x10000
			, mb.setUint32(offset, 0xF0808080 /* 0b11110000100000001000000010000000 */
				| (code >>> 18 & 0x7 /* 0b00000111 */) << 24
				| (code >>> 12 & 0x3F /* 0b00111111 */) << 16
				| (code >>> 6 & 0x3F /* 0b00111111 */) << 8
				| code & 0x3F /* 0b00111111 */)
			, 4
			);
	}
	return offset;
});


// DECODER

var _Bytes_decode = F2(function(decoder, bytes)
{
	try {
		return $elm$core$Maybe$Just(A2(decoder, bytes, 0).b);
	} catch(e) {
		return $elm$core$Maybe$Nothing;
	}
});

var _Bytes_read_i8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getInt8(offset)); });
var _Bytes_read_i16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getInt16(offset, isLE)); });
var _Bytes_read_i32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getInt32(offset, isLE)); });
var _Bytes_read_u8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getUint8(offset)); });
var _Bytes_read_u16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getUint16(offset, isLE)); });
var _Bytes_read_u32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getUint32(offset, isLE)); });
var _Bytes_read_f32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getFloat32(offset, isLE)); });
var _Bytes_read_f64 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 8, bytes.getFloat64(offset, isLE)); });

var _Bytes_read_bytes = F3(function(len, bytes, offset)
{
	return _Utils_Tuple2(offset + len, new DataView(bytes.buffer, bytes.byteOffset + offset, len));
});

var _Bytes_read_string = F3(function(len, bytes, offset)
{
	var string = '';
	var end = offset + len;
	for (; offset < end;)
	{
		var byte = bytes.getUint8(offset++);
		string +=
			(byte < 128)
				? String.fromCharCode(byte)
				:
			((byte & 0xE0 /* 0b11100000 */) === 0xC0 /* 0b11000000 */)
				? String.fromCharCode((byte & 0x1F /* 0b00011111 */) << 6 | bytes.getUint8(offset++) & 0x3F /* 0b00111111 */)
				:
			((byte & 0xF0 /* 0b11110000 */) === 0xE0 /* 0b11100000 */)
				? String.fromCharCode(
					(byte & 0xF /* 0b00001111 */) << 12
					| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
					| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
				)
				:
				(byte =
					((byte & 0x7 /* 0b00000111 */) << 18
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 12
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
						| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
					) - 0x10000
				, String.fromCharCode(Math.floor(byte / 0x400) + 0xD800, byte % 0x400 + 0xDC00)
				);
	}
	return _Utils_Tuple2(offset, string);
});

var _Bytes_decodeFailure = F2(function() { throw 0; });




// VIRTUAL-DOM WIDGETS


var _Markdown_toHtml = F3(function(options, factList, rawMarkdown)
{
	return _VirtualDom_custom(
		factList,
		{
			a: options,
			b: rawMarkdown
		},
		_Markdown_render,
		_Markdown_diff
	);
});



// WIDGET IMPLEMENTATION


function _Markdown_render(model)
{
	return A2(_Markdown_replace, model, _VirtualDom_doc.createElement('div'));
}


function _Markdown_diff(x, y)
{
	return x.b === y.b && x.a === y.a
		? false
		: _Markdown_replace(y);
}


var _Markdown_replace = F2(function(model, div)
{
	div.innerHTML = _Markdown_marked(model.b, _Markdown_formatOptions(model.a));
	return div;
});



// ACTUAL MARKDOWN PARSER


var _Markdown_marked = function() {
	// catch the `marked` object regardless of the outer environment.
	// (ex. a CommonJS module compatible environment.)
	// note that this depends on marked's implementation of environment detection.
	var module = {};
	var exports = module.exports = {};

	/**
	 * marked - a markdown parser
	 * Copyright (c) 2011-2014, Christopher Jeffrey. (MIT Licensed)
	 * https://github.com/chjj/marked
	 * commit cd2f6f5b7091154c5526e79b5f3bfb4d15995a51
	 */
	(function(){var block={newline:/^\n+/,code:/^( {4}[^\n]+\n*)+/,fences:noop,hr:/^( *[-*_]){3,} *(?:\n+|$)/,heading:/^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)/,nptable:noop,lheading:/^([^\n]+)\n *(=|-){2,} *(?:\n+|$)/,blockquote:/^( *>[^\n]+(\n(?!def)[^\n]+)*\n*)+/,list:/^( *)(bull) [\s\S]+?(?:hr|def|\n{2,}(?! )(?!\1bull )\n*|\s*$)/,html:/^ *(?:comment *(?:\n|\s*$)|closed *(?:\n{2,}|\s*$)|closing *(?:\n{2,}|\s*$))/,def:/^ *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$)/,table:noop,paragraph:/^((?:[^\n]+\n?(?!hr|heading|lheading|blockquote|tag|def))+)\n*/,text:/^[^\n]+/};block.bullet=/(?:[*+-]|\d+\.)/;block.item=/^( *)(bull) [^\n]*(?:\n(?!\1bull )[^\n]*)*/;block.item=replace(block.item,"gm")(/bull/g,block.bullet)();block.list=replace(block.list)(/bull/g,block.bullet)("hr","\\n+(?=\\1?(?:[-*_] *){3,}(?:\\n+|$))")("def","\\n+(?="+block.def.source+")")();block.blockquote=replace(block.blockquote)("def",block.def)();block._tag="(?!(?:"+"a|em|strong|small|s|cite|q|dfn|abbr|data|time|code"+"|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo"+"|span|br|wbr|ins|del|img)\\b)\\w+(?!:/|[^\\w\\s@]*@)\\b";block.html=replace(block.html)("comment",/<!--[\s\S]*?-->/)("closed",/<(tag)[\s\S]+?<\/\1>/)("closing",/<tag(?:"[^"]*"|'[^']*'|[^'">])*?>/)(/tag/g,block._tag)();block.paragraph=replace(block.paragraph)("hr",block.hr)("heading",block.heading)("lheading",block.lheading)("blockquote",block.blockquote)("tag","<"+block._tag)("def",block.def)();block.normal=merge({},block);block.gfm=merge({},block.normal,{fences:/^ *(`{3,}|~{3,})[ \.]*(\S+)? *\n([\s\S]*?)\s*\1 *(?:\n+|$)/,paragraph:/^/,heading:/^ *(#{1,6}) +([^\n]+?) *#* *(?:\n+|$)/});block.gfm.paragraph=replace(block.paragraph)("(?!","(?!"+block.gfm.fences.source.replace("\\1","\\2")+"|"+block.list.source.replace("\\1","\\3")+"|")();block.tables=merge({},block.gfm,{nptable:/^ *(\S.*\|.*)\n *([-:]+ *\|[-| :]*)\n((?:.*\|.*(?:\n|$))*)\n*/,table:/^ *\|(.+)\n *\|( *[-:]+[-| :]*)\n((?: *\|.*(?:\n|$))*)\n*/});function Lexer(options){this.tokens=[];this.tokens.links={};this.options=options||marked.defaults;this.rules=block.normal;if(this.options.gfm){if(this.options.tables){this.rules=block.tables}else{this.rules=block.gfm}}}Lexer.rules=block;Lexer.lex=function(src,options){var lexer=new Lexer(options);return lexer.lex(src)};Lexer.prototype.lex=function(src){src=src.replace(/\r\n|\r/g,"\n").replace(/\t/g,"    ").replace(/\u00a0/g," ").replace(/\u2424/g,"\n");return this.token(src,true)};Lexer.prototype.token=function(src,top,bq){var src=src.replace(/^ +$/gm,""),next,loose,cap,bull,b,item,space,i,l;while(src){if(cap=this.rules.newline.exec(src)){src=src.substring(cap[0].length);if(cap[0].length>1){this.tokens.push({type:"space"})}}if(cap=this.rules.code.exec(src)){src=src.substring(cap[0].length);cap=cap[0].replace(/^ {4}/gm,"");this.tokens.push({type:"code",text:!this.options.pedantic?cap.replace(/\n+$/,""):cap});continue}if(cap=this.rules.fences.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"code",lang:cap[2],text:cap[3]||""});continue}if(cap=this.rules.heading.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"heading",depth:cap[1].length,text:cap[2]});continue}if(top&&(cap=this.rules.nptable.exec(src))){src=src.substring(cap[0].length);item={type:"table",header:cap[1].replace(/^ *| *\| *$/g,"").split(/ *\| */),align:cap[2].replace(/^ *|\| *$/g,"").split(/ *\| */),cells:cap[3].replace(/\n$/,"").split("\n")};for(i=0;i<item.align.length;i++){if(/^ *-+: *$/.test(item.align[i])){item.align[i]="right"}else if(/^ *:-+: *$/.test(item.align[i])){item.align[i]="center"}else if(/^ *:-+ *$/.test(item.align[i])){item.align[i]="left"}else{item.align[i]=null}}for(i=0;i<item.cells.length;i++){item.cells[i]=item.cells[i].split(/ *\| */)}this.tokens.push(item);continue}if(cap=this.rules.lheading.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"heading",depth:cap[2]==="="?1:2,text:cap[1]});continue}if(cap=this.rules.hr.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"hr"});continue}if(cap=this.rules.blockquote.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"blockquote_start"});cap=cap[0].replace(/^ *> ?/gm,"");this.token(cap,top,true);this.tokens.push({type:"blockquote_end"});continue}if(cap=this.rules.list.exec(src)){src=src.substring(cap[0].length);bull=cap[2];this.tokens.push({type:"list_start",ordered:bull.length>1});cap=cap[0].match(this.rules.item);next=false;l=cap.length;i=0;for(;i<l;i++){item=cap[i];space=item.length;item=item.replace(/^ *([*+-]|\d+\.) +/,"");if(~item.indexOf("\n ")){space-=item.length;item=!this.options.pedantic?item.replace(new RegExp("^ {1,"+space+"}","gm"),""):item.replace(/^ {1,4}/gm,"")}if(this.options.smartLists&&i!==l-1){b=block.bullet.exec(cap[i+1])[0];if(bull!==b&&!(bull.length>1&&b.length>1)){src=cap.slice(i+1).join("\n")+src;i=l-1}}loose=next||/\n\n(?!\s*$)/.test(item);if(i!==l-1){next=item.charAt(item.length-1)==="\n";if(!loose)loose=next}this.tokens.push({type:loose?"loose_item_start":"list_item_start"});this.token(item,false,bq);this.tokens.push({type:"list_item_end"})}this.tokens.push({type:"list_end"});continue}if(cap=this.rules.html.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:this.options.sanitize?"paragraph":"html",pre:!this.options.sanitizer&&(cap[1]==="pre"||cap[1]==="script"||cap[1]==="style"),text:cap[0]});continue}if(!bq&&top&&(cap=this.rules.def.exec(src))){src=src.substring(cap[0].length);this.tokens.links[cap[1].toLowerCase()]={href:cap[2],title:cap[3]};continue}if(top&&(cap=this.rules.table.exec(src))){src=src.substring(cap[0].length);item={type:"table",header:cap[1].replace(/^ *| *\| *$/g,"").split(/ *\| */),align:cap[2].replace(/^ *|\| *$/g,"").split(/ *\| */),cells:cap[3].replace(/(?: *\| *)?\n$/,"").split("\n")};for(i=0;i<item.align.length;i++){if(/^ *-+: *$/.test(item.align[i])){item.align[i]="right"}else if(/^ *:-+: *$/.test(item.align[i])){item.align[i]="center"}else if(/^ *:-+ *$/.test(item.align[i])){item.align[i]="left"}else{item.align[i]=null}}for(i=0;i<item.cells.length;i++){item.cells[i]=item.cells[i].replace(/^ *\| *| *\| *$/g,"").split(/ *\| */)}this.tokens.push(item);continue}if(top&&(cap=this.rules.paragraph.exec(src))){src=src.substring(cap[0].length);this.tokens.push({type:"paragraph",text:cap[1].charAt(cap[1].length-1)==="\n"?cap[1].slice(0,-1):cap[1]});continue}if(cap=this.rules.text.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"text",text:cap[0]});continue}if(src){throw new Error("Infinite loop on byte: "+src.charCodeAt(0))}}return this.tokens};var inline={escape:/^\\([\\`*{}\[\]()#+\-.!_>])/,autolink:/^<([^ >]+(@|:\/)[^ >]+)>/,url:noop,tag:/^<!--[\s\S]*?-->|^<\/?\w+(?:"[^"]*"|'[^']*'|[^'">])*?>/,link:/^!?\[(inside)\]\(href\)/,reflink:/^!?\[(inside)\]\s*\[([^\]]*)\]/,nolink:/^!?\[((?:\[[^\]]*\]|[^\[\]])*)\]/,strong:/^_\_([\s\S]+?)_\_(?!_)|^\*\*([\s\S]+?)\*\*(?!\*)/,em:/^\b_((?:[^_]|_\_)+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,code:/^(`+)\s*([\s\S]*?[^`])\s*\1(?!`)/,br:/^ {2,}\n(?!\s*$)/,del:noop,text:/^[\s\S]+?(?=[\\<!\[_*`]| {2,}\n|$)/};inline._inside=/(?:\[[^\]]*\]|[^\[\]]|\](?=[^\[]*\]))*/;inline._href=/\s*<?([\s\S]*?)>?(?:\s+['"]([\s\S]*?)['"])?\s*/;inline.link=replace(inline.link)("inside",inline._inside)("href",inline._href)();inline.reflink=replace(inline.reflink)("inside",inline._inside)();inline.normal=merge({},inline);inline.pedantic=merge({},inline.normal,{strong:/^_\_(?=\S)([\s\S]*?\S)_\_(?!_)|^\*\*(?=\S)([\s\S]*?\S)\*\*(?!\*)/,em:/^_(?=\S)([\s\S]*?\S)_(?!_)|^\*(?=\S)([\s\S]*?\S)\*(?!\*)/});inline.gfm=merge({},inline.normal,{escape:replace(inline.escape)("])","~|])")(),url:/^(https?:\/\/[^\s<]+[^<.,:;"')\]\s])/,del:/^~~(?=\S)([\s\S]*?\S)~~/,text:replace(inline.text)("]|","~]|")("|","|https?://|")()});inline.breaks=merge({},inline.gfm,{br:replace(inline.br)("{2,}","*")(),text:replace(inline.gfm.text)("{2,}","*")()});function InlineLexer(links,options){this.options=options||marked.defaults;this.links=links;this.rules=inline.normal;this.renderer=this.options.renderer||new Renderer;this.renderer.options=this.options;if(!this.links){throw new Error("Tokens array requires a `links` property.")}if(this.options.gfm){if(this.options.breaks){this.rules=inline.breaks}else{this.rules=inline.gfm}}else if(this.options.pedantic){this.rules=inline.pedantic}}InlineLexer.rules=inline;InlineLexer.output=function(src,links,options){var inline=new InlineLexer(links,options);return inline.output(src)};InlineLexer.prototype.output=function(src){var out="",link,text,href,cap;while(src){if(cap=this.rules.escape.exec(src)){src=src.substring(cap[0].length);out+=cap[1];continue}if(cap=this.rules.autolink.exec(src)){src=src.substring(cap[0].length);if(cap[2]==="@"){text=cap[1].charAt(6)===":"?this.mangle(cap[1].substring(7)):this.mangle(cap[1]);href=this.mangle("mailto:")+text}else{text=escape(cap[1]);href=text}out+=this.renderer.link(href,null,text);continue}if(!this.inLink&&(cap=this.rules.url.exec(src))){src=src.substring(cap[0].length);text=escape(cap[1]);href=text;out+=this.renderer.link(href,null,text);continue}if(cap=this.rules.tag.exec(src)){if(!this.inLink&&/^<a /i.test(cap[0])){this.inLink=true}else if(this.inLink&&/^<\/a>/i.test(cap[0])){this.inLink=false}src=src.substring(cap[0].length);out+=this.options.sanitize?this.options.sanitizer?this.options.sanitizer(cap[0]):escape(cap[0]):cap[0];continue}if(cap=this.rules.link.exec(src)){src=src.substring(cap[0].length);this.inLink=true;out+=this.outputLink(cap,{href:cap[2],title:cap[3]});this.inLink=false;continue}if((cap=this.rules.reflink.exec(src))||(cap=this.rules.nolink.exec(src))){src=src.substring(cap[0].length);link=(cap[2]||cap[1]).replace(/\s+/g," ");link=this.links[link.toLowerCase()];if(!link||!link.href){out+=cap[0].charAt(0);src=cap[0].substring(1)+src;continue}this.inLink=true;out+=this.outputLink(cap,link);this.inLink=false;continue}if(cap=this.rules.strong.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.strong(this.output(cap[2]||cap[1]));continue}if(cap=this.rules.em.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.em(this.output(cap[2]||cap[1]));continue}if(cap=this.rules.code.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.codespan(escape(cap[2],true));continue}if(cap=this.rules.br.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.br();continue}if(cap=this.rules.del.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.del(this.output(cap[1]));continue}if(cap=this.rules.text.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.text(escape(this.smartypants(cap[0])));continue}if(src){throw new Error("Infinite loop on byte: "+src.charCodeAt(0))}}return out};InlineLexer.prototype.outputLink=function(cap,link){var href=escape(link.href),title=link.title?escape(link.title):null;return cap[0].charAt(0)!=="!"?this.renderer.link(href,title,this.output(cap[1])):this.renderer.image(href,title,escape(cap[1]))};InlineLexer.prototype.smartypants=function(text){if(!this.options.smartypants)return text;return text.replace(/---/g,"—").replace(/--/g,"–").replace(/(^|[-\u2014\/(\[{"\s])'/g,"$1‘").replace(/'/g,"’").replace(/(^|[-\u2014\/(\[{\u2018\s])"/g,"$1“").replace(/"/g,"”").replace(/\.{3}/g,"…")};InlineLexer.prototype.mangle=function(text){if(!this.options.mangle)return text;var out="",l=text.length,i=0,ch;for(;i<l;i++){ch=text.charCodeAt(i);if(Math.random()>.5){ch="x"+ch.toString(16)}out+="&#"+ch+";"}return out};function Renderer(options){this.options=options||{}}Renderer.prototype.code=function(code,lang,escaped){if(this.options.highlight){var out=this.options.highlight(code,lang);if(out!=null&&out!==code){escaped=true;code=out}}if(!lang){return"<pre><code>"+(escaped?code:escape(code,true))+"\n</code></pre>"}return'<pre><code class="'+this.options.langPrefix+escape(lang,true)+'">'+(escaped?code:escape(code,true))+"\n</code></pre>\n"};Renderer.prototype.blockquote=function(quote){return"<blockquote>\n"+quote+"</blockquote>\n"};Renderer.prototype.html=function(html){return html};Renderer.prototype.heading=function(text,level,raw){return"<h"+level+' id="'+this.options.headerPrefix+raw.toLowerCase().replace(/[^\w]+/g,"-")+'">'+text+"</h"+level+">\n"};Renderer.prototype.hr=function(){return this.options.xhtml?"<hr/>\n":"<hr>\n"};Renderer.prototype.list=function(body,ordered){var type=ordered?"ol":"ul";return"<"+type+">\n"+body+"</"+type+">\n"};Renderer.prototype.listitem=function(text){return"<li>"+text+"</li>\n"};Renderer.prototype.paragraph=function(text){return"<p>"+text+"</p>\n"};Renderer.prototype.table=function(header,body){return"<table>\n"+"<thead>\n"+header+"</thead>\n"+"<tbody>\n"+body+"</tbody>\n"+"</table>\n"};Renderer.prototype.tablerow=function(content){return"<tr>\n"+content+"</tr>\n"};Renderer.prototype.tablecell=function(content,flags){var type=flags.header?"th":"td";var tag=flags.align?"<"+type+' style="text-align:'+flags.align+'">':"<"+type+">";return tag+content+"</"+type+">\n"};Renderer.prototype.strong=function(text){return"<strong>"+text+"</strong>"};Renderer.prototype.em=function(text){return"<em>"+text+"</em>"};Renderer.prototype.codespan=function(text){return"<code>"+text+"</code>"};Renderer.prototype.br=function(){return this.options.xhtml?"<br/>":"<br>"};Renderer.prototype.del=function(text){return"<del>"+text+"</del>"};Renderer.prototype.link=function(href,title,text){if(this.options.sanitize){try{var prot=decodeURIComponent(unescape(href)).replace(/[^\w:]/g,"").toLowerCase()}catch(e){return""}if(prot.indexOf("javascript:")===0||prot.indexOf("vbscript:")===0||prot.indexOf("data:")===0){return""}}var out='<a href="'+href+'"';if(title){out+=' title="'+title+'"'}out+=">"+text+"</a>";return out};Renderer.prototype.image=function(href,title,text){var out='<img src="'+href+'" alt="'+text+'"';if(title){out+=' title="'+title+'"'}out+=this.options.xhtml?"/>":">";return out};Renderer.prototype.text=function(text){return text};function Parser(options){this.tokens=[];this.token=null;this.options=options||marked.defaults;this.options.renderer=this.options.renderer||new Renderer;this.renderer=this.options.renderer;this.renderer.options=this.options}Parser.parse=function(src,options,renderer){var parser=new Parser(options,renderer);return parser.parse(src)};Parser.prototype.parse=function(src){this.inline=new InlineLexer(src.links,this.options,this.renderer);this.tokens=src.reverse();var out="";while(this.next()){out+=this.tok()}return out};Parser.prototype.next=function(){return this.token=this.tokens.pop()};Parser.prototype.peek=function(){return this.tokens[this.tokens.length-1]||0};Parser.prototype.parseText=function(){var body=this.token.text;while(this.peek().type==="text"){body+="\n"+this.next().text}return this.inline.output(body)};Parser.prototype.tok=function(){switch(this.token.type){case"space":{return""}case"hr":{return this.renderer.hr()}case"heading":{return this.renderer.heading(this.inline.output(this.token.text),this.token.depth,this.token.text)}case"code":{return this.renderer.code(this.token.text,this.token.lang,this.token.escaped)}case"table":{var header="",body="",i,row,cell,flags,j;cell="";for(i=0;i<this.token.header.length;i++){flags={header:true,align:this.token.align[i]};cell+=this.renderer.tablecell(this.inline.output(this.token.header[i]),{header:true,align:this.token.align[i]})}header+=this.renderer.tablerow(cell);for(i=0;i<this.token.cells.length;i++){row=this.token.cells[i];cell="";for(j=0;j<row.length;j++){cell+=this.renderer.tablecell(this.inline.output(row[j]),{header:false,align:this.token.align[j]})}body+=this.renderer.tablerow(cell)}return this.renderer.table(header,body)}case"blockquote_start":{var body="";while(this.next().type!=="blockquote_end"){body+=this.tok()}return this.renderer.blockquote(body)}case"list_start":{var body="",ordered=this.token.ordered;while(this.next().type!=="list_end"){body+=this.tok()}return this.renderer.list(body,ordered)}case"list_item_start":{var body="";while(this.next().type!=="list_item_end"){body+=this.token.type==="text"?this.parseText():this.tok()}return this.renderer.listitem(body)}case"loose_item_start":{var body="";while(this.next().type!=="list_item_end"){body+=this.tok()}return this.renderer.listitem(body)}case"html":{var html=!this.token.pre&&!this.options.pedantic?this.inline.output(this.token.text):this.token.text;return this.renderer.html(html)}case"paragraph":{return this.renderer.paragraph(this.inline.output(this.token.text))}case"text":{return this.renderer.paragraph(this.parseText())}}};function escape(html,encode){return html.replace(!encode?/&(?!#?\w+;)/g:/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;")}function unescape(html){return html.replace(/&(#(?:\d+)|(?:#x[0-9A-Fa-f]+)|(?:\w+));?/g,function(_,n){n=n.toLowerCase();if(n==="colon")return":";if(n.charAt(0)==="#"){return n.charAt(1)==="x"?String.fromCharCode(parseInt(n.substring(2),16)):String.fromCharCode(+n.substring(1))}return""})}function replace(regex,opt){regex=regex.source;opt=opt||"";return function self(name,val){if(!name)return new RegExp(regex,opt);val=val.source||val;val=val.replace(/(^|[^\[])\^/g,"$1");regex=regex.replace(name,val);return self}}function noop(){}noop.exec=noop;function merge(obj){var i=1,target,key;for(;i<arguments.length;i++){target=arguments[i];for(key in target){if(Object.prototype.hasOwnProperty.call(target,key)){obj[key]=target[key]}}}return obj}function marked(src,opt,callback){if(callback||typeof opt==="function"){if(!callback){callback=opt;opt=null}opt=merge({},marked.defaults,opt||{});var highlight=opt.highlight,tokens,pending,i=0;try{tokens=Lexer.lex(src,opt)}catch(e){return callback(e)}pending=tokens.length;var done=function(err){if(err){opt.highlight=highlight;return callback(err)}var out;try{out=Parser.parse(tokens,opt)}catch(e){err=e}opt.highlight=highlight;return err?callback(err):callback(null,out)};if(!highlight||highlight.length<3){return done()}delete opt.highlight;if(!pending)return done();for(;i<tokens.length;i++){(function(token){if(token.type!=="code"){return--pending||done()}return highlight(token.text,token.lang,function(err,code){if(err)return done(err);if(code==null||code===token.text){return--pending||done()}token.text=code;token.escaped=true;--pending||done()})})(tokens[i])}return}try{if(opt)opt=merge({},marked.defaults,opt);return Parser.parse(Lexer.lex(src,opt),opt)}catch(e){e.message+="\nPlease report this to https://github.com/chjj/marked.";if((opt||marked.defaults).silent){return"<p>An error occured:</p><pre>"+escape(e.message+"",true)+"</pre>"}throw e}}marked.options=marked.setOptions=function(opt){merge(marked.defaults,opt);return marked};marked.defaults={gfm:true,tables:true,breaks:false,pedantic:false,sanitize:false,sanitizer:null,mangle:true,smartLists:false,silent:false,highlight:null,langPrefix:"lang-",smartypants:false,headerPrefix:"",renderer:new Renderer,xhtml:false};marked.Parser=Parser;marked.parser=Parser.parse;marked.Renderer=Renderer;marked.Lexer=Lexer;marked.lexer=Lexer.lex;marked.InlineLexer=InlineLexer;marked.inlineLexer=InlineLexer.output;marked.parse=marked;if(typeof module!=="undefined"&&typeof exports==="object"){module.exports=marked}else if(typeof define==="function"&&define.amd){define(function(){return marked})}else{this.marked=marked}}).call(function(){return this||(typeof window!=="undefined"?window:global)}());

	return module.exports;
}();


// FORMAT OPTIONS FOR MARKED IMPLEMENTATION

function _Markdown_formatOptions(options)
{
	function toHighlight(code, lang)
	{
		if (!lang && $elm$core$Maybe$isJust(options.defaultHighlighting))
		{
			lang = options.defaultHighlighting.a;
		}

		if (typeof hljs !== 'undefined' && lang && hljs.listLanguages().indexOf(lang) >= 0)
		{
			return hljs.highlight(lang, code, true).value;
		}

		return code;
	}

	var gfm = options.githubFlavored.a;

	return {
		highlight: toHighlight,
		gfm: gfm,
		tables: gfm && gfm.tables,
		breaks: gfm && gfm.breaks,
		sanitize: options.sanitize,
		smartypants: options.smartypants
	};
}
var $author$project$Main$ChangedUrl = function (a) {
	return {$: 'ChangedUrl', a: a};
};
var $author$project$Main$ClickedLink = function (a) {
	return {$: 'ClickedLink', a: a};
};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$core$Result$andThen = F2(
	function (callback, result) {
		if (result.$ === 'Ok') {
			var value = result.a;
			return callback(value);
		} else {
			var msg = result.a;
			return $elm$core$Result$Err(msg);
		}
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $elm$core$List$cons = _List_cons;
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$Basics$False = {$: 'False'};
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 'Normal':
			return 0;
		case 'MayStopPropagation':
			return 1;
		case 'MayPreventDefault':
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $elm$url$Url$Http = {$: 'Http'};
var $elm$url$Url$Https = {$: 'Https'};
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 'Nothing') {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Http,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Https,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0.a;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(_Utils_Tuple0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0.a;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return _Utils_Tuple0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0.a;
		return $elm$core$Task$Perform(
			A2($elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2($elm$core$Task$map, toMessage, task)));
	});
var $elm$browser$Browser$application = _Browser_application;
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $author$project$Api$Cred = F2(
	function (a, b) {
		return {$: 'Cred', a: a, b: b};
	});
var $author$project$Username$Username = function (a) {
	return {$: 'Username', a: a};
};
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Username$decoder = A2($elm$json$Json$Decode$map, $author$project$Username$Username, $elm$json$Json$Decode$string);
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom = $elm$json$Json$Decode$map2($elm$core$Basics$apR);
var $elm$json$Json$Decode$field = _Json_decodeField;
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required = F3(
	function (key, valDecoder, decoder) {
		return A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A2($elm$json$Json$Decode$field, key, valDecoder),
			decoder);
	});
var $author$project$Api$credDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'token',
	$elm$json$Json$Decode$string,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'username',
		$author$project$Username$decoder,
		$elm$json$Json$Decode$succeed($author$project$Api$Cred)));
var $author$project$Api$decoderFromCred = function (decoder) {
	return A3(
		$elm$json$Json$Decode$map2,
		F2(
			function (fromCred, cred) {
				return fromCred(cred);
			}),
		decoder,
		$author$project$Api$credDecoder);
};
var $author$project$Api$storageDecoder = function (viewerDecoder) {
	return A2(
		$elm$json$Json$Decode$field,
		'user',
		$author$project$Api$decoderFromCred(viewerDecoder));
};
var $elm$core$Result$toMaybe = function (result) {
	if (result.$ === 'Ok') {
		var v = result.a;
		return $elm$core$Maybe$Just(v);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Api$application = F2(
	function (viewerDecoder, config) {
		var init = F3(
			function (flags, url, navKey) {
				var maybeViewer = $elm$core$Result$toMaybe(
					A2(
						$elm$core$Result$andThen,
						$elm$json$Json$Decode$decodeString(
							$author$project$Api$storageDecoder(viewerDecoder)),
						A2($elm$json$Json$Decode$decodeValue, $elm$json$Json$Decode$string, flags)));
				return A3(config.init, maybeViewer, url, navKey);
			});
		return $elm$browser$Browser$application(
			{init: init, onUrlChange: config.onUrlChange, onUrlRequest: config.onUrlRequest, subscriptions: config.subscriptions, update: config.update, view: config.view});
	});
var $author$project$Viewer$Viewer = F2(
	function (a, b) {
		return {$: 'Viewer', a: a, b: b};
	});
var $author$project$Avatar$Avatar = function (a) {
	return {$: 'Avatar', a: a};
};
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$nullable = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				$elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder)
			]));
};
var $author$project$Avatar$decoder = A2(
	$elm$json$Json$Decode$map,
	$author$project$Avatar$Avatar,
	$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string));
var $author$project$Viewer$decoder = A2(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
	A2($elm$json$Json$Decode$field, 'image', $author$project$Avatar$decoder),
	$elm$json$Json$Decode$succeed($author$project$Viewer$Viewer));
var $author$project$Main$Redirect = function (a) {
	return {$: 'Redirect', a: a};
};
var $author$project$Main$Article = function (a) {
	return {$: 'Article', a: a};
};
var $author$project$Main$Editor = F2(
	function (a, b) {
		return {$: 'Editor', a: a, b: b};
	});
var $author$project$Main$GotArticleMsg = function (a) {
	return {$: 'GotArticleMsg', a: a};
};
var $author$project$Main$GotEditorMsg = function (a) {
	return {$: 'GotEditorMsg', a: a};
};
var $author$project$Main$GotHomeMsg = function (a) {
	return {$: 'GotHomeMsg', a: a};
};
var $author$project$Main$GotLoginMsg = function (a) {
	return {$: 'GotLoginMsg', a: a};
};
var $author$project$Main$GotPricesMsg = function (a) {
	return {$: 'GotPricesMsg', a: a};
};
var $author$project$Main$GotProfileMsg = function (a) {
	return {$: 'GotProfileMsg', a: a};
};
var $author$project$Main$GotRegisterMsg = function (a) {
	return {$: 'GotRegisterMsg', a: a};
};
var $author$project$Main$GotSettingsMsg = function (a) {
	return {$: 'GotSettingsMsg', a: a};
};
var $author$project$Main$Home = function (a) {
	return {$: 'Home', a: a};
};
var $author$project$Route$Home = {$: 'Home'};
var $author$project$Main$Login = function (a) {
	return {$: 'Login', a: a};
};
var $author$project$Main$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $author$project$Main$Prices = function (a) {
	return {$: 'Prices', a: a};
};
var $author$project$Main$Profile = F2(
	function (a, b) {
		return {$: 'Profile', a: a, b: b};
	});
var $author$project$Main$Register = function (a) {
	return {$: 'Register', a: a};
};
var $author$project$Main$Settings = function (a) {
	return {$: 'Settings', a: a};
};
var $author$project$Page$Article$CompletedLoadArticle = function (a) {
	return {$: 'CompletedLoadArticle', a: a};
};
var $author$project$Page$Article$CompletedLoadComments = function (a) {
	return {$: 'CompletedLoadComments', a: a};
};
var $author$project$Page$Article$GotTimeZone = function (a) {
	return {$: 'GotTimeZone', a: a};
};
var $author$project$Page$Article$Loading = {$: 'Loading'};
var $author$project$Page$Article$PassedSlowLoadThreshold = {$: 'PassedSlowLoadThreshold'};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $author$project$Viewer$cred = function (_v0) {
	var val = _v0.b;
	return val;
};
var $author$project$Session$cred = function (session) {
	if (session.$ === 'LoggedIn') {
		var val = session.b;
		return $elm$core$Maybe$Just(
			$author$project$Viewer$cred(val));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Article$Slug$toString = function (_v0) {
	var str = _v0.a;
	return str;
};
var $author$project$Api$Endpoint$Endpoint = function (a) {
	return {$: 'Endpoint', a: a};
};
var $elm$url$Url$Builder$toQueryPair = function (_v0) {
	var key = _v0.a;
	var value = _v0.b;
	return key + ('=' + value);
};
var $elm$url$Url$Builder$toQuery = function (parameters) {
	if (!parameters.b) {
		return '';
	} else {
		return '?' + A2(
			$elm$core$String$join,
			'&',
			A2($elm$core$List$map, $elm$url$Url$Builder$toQueryPair, parameters));
	}
};
var $elm$url$Url$Builder$crossOrigin = F3(
	function (prePath, pathSegments, parameters) {
		return prePath + ('/' + (A2($elm$core$String$join, '/', pathSegments) + $elm$url$Url$Builder$toQuery(parameters)));
	});
var $author$project$Api$Endpoint$url = F2(
	function (paths, queryParams) {
		return $author$project$Api$Endpoint$Endpoint(
			A3(
				$elm$url$Url$Builder$crossOrigin,
				'https://conduit.productionready.io',
				A2($elm$core$List$cons, 'api', paths),
				queryParams));
	});
var $author$project$Api$Endpoint$article = function (slug) {
	return A2(
		$author$project$Api$Endpoint$url,
		_List_fromArray(
			[
				'articles',
				$author$project$Article$Slug$toString(slug)
			]),
		_List_Nil);
};
var $author$project$Article$Article = F2(
	function (a, b) {
		return {$: 'Article', a: a, b: b};
	});
var $author$project$Article$Full = function (a) {
	return {$: 'Full', a: a};
};
var $author$project$Article$Body$Body = function (a) {
	return {$: 'Body', a: a};
};
var $author$project$Article$Body$decoder = A2($elm$json$Json$Decode$map, $author$project$Article$Body$Body, $elm$json$Json$Decode$string);
var $author$project$Article$Internals = F3(
	function (slug, author, metadata) {
		return {author: author, metadata: metadata, slug: slug};
	});
var $author$project$Article$Slug$Slug = function (a) {
	return {$: 'Slug', a: a};
};
var $author$project$Article$Slug$decoder = A2($elm$json$Json$Decode$map, $author$project$Article$Slug$Slug, $elm$json$Json$Decode$string);
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $author$project$Author$IsNotFollowing = function (a) {
	return {$: 'IsNotFollowing', a: a};
};
var $author$project$Author$IsViewer = F2(
	function (a, b) {
		return {$: 'IsViewer', a: a, b: b};
	});
var $author$project$Author$UnfollowedAuthor = F2(
	function (a, b) {
		return {$: 'UnfollowedAuthor', a: a, b: b};
	});
var $author$project$Author$FollowedAuthor = F2(
	function (a, b) {
		return {$: 'FollowedAuthor', a: a, b: b};
	});
var $author$project$Author$IsFollowing = function (a) {
	return {$: 'IsFollowing', a: a};
};
var $author$project$Author$authorFromFollowing = F3(
	function (prof, uname, isFollowing) {
		return isFollowing ? $author$project$Author$IsFollowing(
			A2($author$project$Author$FollowedAuthor, uname, prof)) : $author$project$Author$IsNotFollowing(
			A2($author$project$Author$UnfollowedAuthor, uname, prof));
	});
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $elm$json$Json$Decode$fail = _Json_fail;
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optionalDecoder = F3(
	function (pathDecoder, valDecoder, fallback) {
		var nullOr = function (decoder) {
			return $elm$json$Json$Decode$oneOf(
				_List_fromArray(
					[
						decoder,
						$elm$json$Json$Decode$null(fallback)
					]));
		};
		var handleResult = function (input) {
			var _v0 = A2($elm$json$Json$Decode$decodeValue, pathDecoder, input);
			if (_v0.$ === 'Ok') {
				var rawValue = _v0.a;
				var _v1 = A2(
					$elm$json$Json$Decode$decodeValue,
					nullOr(valDecoder),
					rawValue);
				if (_v1.$ === 'Ok') {
					var finalResult = _v1.a;
					return $elm$json$Json$Decode$succeed(finalResult);
				} else {
					var finalErr = _v1.a;
					return $elm$json$Json$Decode$fail(
						$elm$json$Json$Decode$errorToString(finalErr));
				}
			} else {
				return $elm$json$Json$Decode$succeed(fallback);
			}
		};
		return A2($elm$json$Json$Decode$andThen, handleResult, $elm$json$Json$Decode$value);
	});
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional = F4(
	function (key, valDecoder, fallback, decoder) {
		return A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optionalDecoder,
				A2($elm$json$Json$Decode$field, key, $elm$json$Json$Decode$value),
				valDecoder,
				fallback),
			decoder);
	});
var $author$project$Author$nonViewerDecoder = F2(
	function (prof, uname) {
		return A4(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'following',
			$elm$json$Json$Decode$bool,
			false,
			$elm$json$Json$Decode$succeed(
				A2($author$project$Author$authorFromFollowing, prof, uname)));
	});
var $author$project$Api$username = function (_v0) {
	var val = _v0.a;
	return val;
};
var $author$project$Author$decodeFromPair = F2(
	function (maybeCred, _v0) {
		var prof = _v0.a;
		var uname = _v0.b;
		if (maybeCred.$ === 'Nothing') {
			return $elm$json$Json$Decode$succeed(
				$author$project$Author$IsNotFollowing(
					A2($author$project$Author$UnfollowedAuthor, uname, prof)));
		} else {
			var cred = maybeCred.a;
			return _Utils_eq(
				uname,
				$author$project$Api$username(cred)) ? $elm$json$Json$Decode$succeed(
				A2($author$project$Author$IsViewer, cred, prof)) : A2($author$project$Author$nonViewerDecoder, prof, uname);
		}
	});
var $author$project$Profile$Internals = F2(
	function (bio, avatar) {
		return {avatar: avatar, bio: bio};
	});
var $author$project$Profile$Profile = function (a) {
	return {$: 'Profile', a: a};
};
var $author$project$Profile$decoder = A2(
	$elm$json$Json$Decode$map,
	$author$project$Profile$Profile,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'image',
		$author$project$Avatar$decoder,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'bio',
			$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
			$elm$json$Json$Decode$succeed($author$project$Profile$Internals))));
var $elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var $author$project$Author$decoder = function (maybeCred) {
	return A2(
		$elm$json$Json$Decode$andThen,
		$author$project$Author$decodeFromPair(maybeCred),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'username',
			$author$project$Username$decoder,
			A2(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
				$author$project$Profile$decoder,
				$elm$json$Json$Decode$succeed($elm$core$Tuple$pair))));
};
var $author$project$Article$Metadata = F6(
	function (description, title, tags, createdAt, favorited, favoritesCount) {
		return {createdAt: createdAt, description: description, favorited: favorited, favoritesCount: favoritesCount, tags: tags, title: title};
	});
var $elm$parser$Parser$deadEndsToString = function (deadEnds) {
	return 'TODO deadEndsToString';
};
var $elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 'Bad', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 'Good', a: a, b: b, c: c};
	});
var $elm$parser$Parser$Advanced$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var $elm$parser$Parser$Advanced$andThen = F2(
	function (callback, _v0) {
		var parseA = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parseA(s0);
				if (_v1.$ === 'Bad') {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					var _v2 = callback(a);
					var parseB = _v2.a;
					var _v3 = parseB(s1);
					if (_v3.$ === 'Bad') {
						var p2 = _v3.a;
						var x = _v3.b;
						return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _v3.a;
						var b = _v3.b;
						var s2 = _v3.c;
						return A3($elm$parser$Parser$Advanced$Good, p1 || p2, b, s2);
					}
				}
			});
	});
var $elm$parser$Parser$andThen = $elm$parser$Parser$Advanced$andThen;
var $elm$parser$Parser$ExpectingEnd = {$: 'ExpectingEnd'};
var $elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 'AddRight', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {col: col, contextStack: contextStack, problem: problem, row: row};
	});
var $elm$parser$Parser$Advanced$Empty = {$: 'Empty'};
var $elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			$elm$parser$Parser$Advanced$AddRight,
			$elm$parser$Parser$Advanced$Empty,
			A4($elm$parser$Parser$Advanced$DeadEnd, s.row, s.col, x, s.context));
	});
var $elm$parser$Parser$Advanced$end = function (x) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return _Utils_eq(
				$elm$core$String$length(s.src),
				s.offset) ? A3($elm$parser$Parser$Advanced$Good, false, _Utils_Tuple0, s) : A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var $elm$parser$Parser$end = $elm$parser$Parser$Advanced$end($elm$parser$Parser$ExpectingEnd);
var $elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$parser$Parser$Advanced$chompWhileHelp = F5(
	function (isGood, offset, row, col, s0) {
		chompWhileHelp:
		while (true) {
			var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, offset, s0.src);
			if (_Utils_eq(newOffset, -1)) {
				return A3(
					$elm$parser$Parser$Advanced$Good,
					_Utils_cmp(s0.offset, offset) < 0,
					_Utils_Tuple0,
					{col: col, context: s0.context, indent: s0.indent, offset: offset, row: row, src: s0.src});
			} else {
				if (_Utils_eq(newOffset, -2)) {
					var $temp$isGood = isGood,
						$temp$offset = offset + 1,
						$temp$row = row + 1,
						$temp$col = 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				} else {
					var $temp$isGood = isGood,
						$temp$offset = newOffset,
						$temp$row = row,
						$temp$col = col + 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$chompWhile = function (isGood) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A5($elm$parser$Parser$Advanced$chompWhileHelp, isGood, s.offset, s.row, s.col, s);
		});
};
var $elm$parser$Parser$chompWhile = $elm$parser$Parser$Advanced$chompWhile;
var $elm$core$Basics$always = F2(
	function (a, _v0) {
		return a;
	});
var $elm$parser$Parser$Advanced$mapChompedString = F2(
	function (func, _v0) {
		var parse = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parse(s0);
				if (_v1.$ === 'Bad') {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p,
						A2(
							func,
							A3($elm$core$String$slice, s0.offset, s1.offset, s0.src),
							a),
						s1);
				}
			});
	});
var $elm$parser$Parser$Advanced$getChompedString = function (parser) {
	return A2($elm$parser$Parser$Advanced$mapChompedString, $elm$core$Basics$always, parser);
};
var $elm$parser$Parser$getChompedString = $elm$parser$Parser$Advanced$getChompedString;
var $elm$parser$Parser$Problem = function (a) {
	return {$: 'Problem', a: a};
};
var $elm$parser$Parser$Advanced$problem = function (x) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var $elm$parser$Parser$problem = function (msg) {
	return $elm$parser$Parser$Advanced$problem(
		$elm$parser$Parser$Problem(msg));
};
var $elm$core$Basics$round = _Basics_round;
var $elm$parser$Parser$Advanced$succeed = function (a) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3($elm$parser$Parser$Advanced$Good, false, a, s);
		});
};
var $elm$parser$Parser$succeed = $elm$parser$Parser$Advanced$succeed;
var $elm$core$String$toFloat = _String_toFloat;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$fractionsOfASecondInMs = A2(
	$elm$parser$Parser$andThen,
	function (str) {
		if ($elm$core$String$length(str) <= 9) {
			var _v0 = $elm$core$String$toFloat('0.' + str);
			if (_v0.$ === 'Just') {
				var floatVal = _v0.a;
				return $elm$parser$Parser$succeed(
					$elm$core$Basics$round(floatVal * 1000));
			} else {
				return $elm$parser$Parser$problem('Invalid float: \"' + (str + '\"'));
			}
		} else {
			return $elm$parser$Parser$problem(
				'Expected at most 9 digits, but got ' + $elm$core$String$fromInt(
					$elm$core$String$length(str)));
		}
	},
	$elm$parser$Parser$getChompedString(
		$elm$parser$Parser$chompWhile($elm$core$Char$isDigit)));
var $elm$time$Time$Posix = function (a) {
	return {$: 'Posix', a: a};
};
var $elm$time$Time$millisToPosix = $elm$time$Time$Posix;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts = F6(
	function (monthYearDayMs, hour, minute, second, ms, utcOffsetMinutes) {
		return $elm$time$Time$millisToPosix((((monthYearDayMs + (((hour * 60) * 60) * 1000)) + (((minute - utcOffsetMinutes) * 60) * 1000)) + (second * 1000)) + ms);
	});
var $elm$parser$Parser$Advanced$map2 = F3(
	function (func, _v0, _v1) {
		var parseA = _v0.a;
		var parseB = _v1.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v2 = parseA(s0);
				if (_v2.$ === 'Bad') {
					var p = _v2.a;
					var x = _v2.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _v2.a;
					var a = _v2.b;
					var s1 = _v2.c;
					var _v3 = parseB(s1);
					if (_v3.$ === 'Bad') {
						var p2 = _v3.a;
						var x = _v3.b;
						return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _v3.a;
						var b = _v3.b;
						var s2 = _v3.c;
						return A3(
							$elm$parser$Parser$Advanced$Good,
							p1 || p2,
							A2(func, a, b),
							s2);
					}
				}
			});
	});
var $elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$always, keepParser, ignoreParser);
	});
var $elm$parser$Parser$ignorer = $elm$parser$Parser$Advanced$ignorer;
var $elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$apL, parseFunc, parseArg);
	});
var $elm$parser$Parser$keeper = $elm$parser$Parser$Advanced$keeper;
var $elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 'Append', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2($elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a.a;
				var remainingParsers = parsers.b;
				var _v1 = parse(s0);
				if (_v1.$ === 'Good') {
					var step = _v1;
					return step;
				} else {
					var step = _v1;
					var p = step.a;
					var x = step.b;
					if (p) {
						return step;
					} else {
						var $temp$s0 = s0,
							$temp$bag = A2($elm$parser$Parser$Advanced$Append, bag, x),
							$temp$parsers = remainingParsers;
						s0 = $temp$s0;
						bag = $temp$bag;
						parsers = $temp$parsers;
						continue oneOfHelp;
					}
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$oneOf = function (parsers) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3($elm$parser$Parser$Advanced$oneOfHelp, s, $elm$parser$Parser$Advanced$Empty, parsers);
		});
};
var $elm$parser$Parser$oneOf = $elm$parser$Parser$Advanced$oneOf;
var $elm$parser$Parser$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$parser$Parser$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $elm$core$String$append = _String_append;
var $elm$parser$Parser$UnexpectedChar = {$: 'UnexpectedChar'};
var $elm$parser$Parser$Advanced$chompIf = F2(
	function (isGood, expecting) {
		return $elm$parser$Parser$Advanced$Parser(
			function (s) {
				var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, s.offset, s.src);
				return _Utils_eq(newOffset, -1) ? A2(
					$elm$parser$Parser$Advanced$Bad,
					false,
					A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : (_Utils_eq(newOffset, -2) ? A3(
					$elm$parser$Parser$Advanced$Good,
					true,
					_Utils_Tuple0,
					{col: 1, context: s.context, indent: s.indent, offset: s.offset + 1, row: s.row + 1, src: s.src}) : A3(
					$elm$parser$Parser$Advanced$Good,
					true,
					_Utils_Tuple0,
					{col: s.col + 1, context: s.context, indent: s.indent, offset: newOffset, row: s.row, src: s.src}));
			});
	});
var $elm$parser$Parser$chompIf = function (isGood) {
	return A2($elm$parser$Parser$Advanced$chompIf, isGood, $elm$parser$Parser$UnexpectedChar);
};
var $elm$parser$Parser$Advanced$loopHelp = F4(
	function (p, state, callback, s0) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var parse = _v0.a;
			var _v1 = parse(s0);
			if (_v1.$ === 'Good') {
				var p1 = _v1.a;
				var step = _v1.b;
				var s1 = _v1.c;
				if (step.$ === 'Loop') {
					var newState = step.a;
					var $temp$p = p || p1,
						$temp$state = newState,
						$temp$callback = callback,
						$temp$s0 = s1;
					p = $temp$p;
					state = $temp$state;
					callback = $temp$callback;
					s0 = $temp$s0;
					continue loopHelp;
				} else {
					var result = step.a;
					return A3($elm$parser$Parser$Advanced$Good, p || p1, result, s1);
				}
			} else {
				var p1 = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p || p1, x);
			}
		}
	});
var $elm$parser$Parser$Advanced$loop = F2(
	function (state, callback) {
		return $elm$parser$Parser$Advanced$Parser(
			function (s) {
				return A4($elm$parser$Parser$Advanced$loopHelp, false, state, callback, s);
			});
	});
var $elm$parser$Parser$Advanced$map = F2(
	function (func, _v0) {
		var parse = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parse(s0);
				if (_v1.$ === 'Good') {
					var p = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p,
						func(a),
						s1);
				} else {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				}
			});
	});
var $elm$parser$Parser$map = $elm$parser$Parser$Advanced$map;
var $elm$parser$Parser$Advanced$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$parser$Parser$Advanced$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $elm$parser$Parser$toAdvancedStep = function (step) {
	if (step.$ === 'Loop') {
		var s = step.a;
		return $elm$parser$Parser$Advanced$Loop(s);
	} else {
		var a = step.a;
		return $elm$parser$Parser$Advanced$Done(a);
	}
};
var $elm$parser$Parser$loop = F2(
	function (state, callback) {
		return A2(
			$elm$parser$Parser$Advanced$loop,
			state,
			function (s) {
				return A2(
					$elm$parser$Parser$map,
					$elm$parser$Parser$toAdvancedStep,
					callback(s));
			});
	});
var $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt = function (quantity) {
	var helper = function (str) {
		if (_Utils_eq(
			$elm$core$String$length(str),
			quantity)) {
			var _v0 = $elm$core$String$toInt(str);
			if (_v0.$ === 'Just') {
				var intVal = _v0.a;
				return A2(
					$elm$parser$Parser$map,
					$elm$parser$Parser$Done,
					$elm$parser$Parser$succeed(intVal));
			} else {
				return $elm$parser$Parser$problem('Invalid integer: \"' + (str + '\"'));
			}
		} else {
			return A2(
				$elm$parser$Parser$map,
				function (nextChar) {
					return $elm$parser$Parser$Loop(
						A2($elm$core$String$append, str, nextChar));
				},
				$elm$parser$Parser$getChompedString(
					$elm$parser$Parser$chompIf($elm$core$Char$isDigit)));
		}
	};
	return A2($elm$parser$Parser$loop, '', helper);
};
var $elm$parser$Parser$ExpectingSymbol = function (a) {
	return {$: 'ExpectingSymbol', a: a};
};
var $elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 'Token', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var $elm$core$Basics$not = _Basics_not;
var $elm$parser$Parser$Advanced$token = function (_v0) {
	var str = _v0.a;
	var expecting = _v0.b;
	var progress = !$elm$core$String$isEmpty(str);
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			var _v1 = A5($elm$parser$Parser$Advanced$isSubString, str, s.offset, s.row, s.col, s.src);
			var newOffset = _v1.a;
			var newRow = _v1.b;
			var newCol = _v1.c;
			return _Utils_eq(newOffset, -1) ? A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
				$elm$parser$Parser$Advanced$Good,
				progress,
				_Utils_Tuple0,
				{col: newCol, context: s.context, indent: s.indent, offset: newOffset, row: newRow, src: s.src});
		});
};
var $elm$parser$Parser$Advanced$symbol = $elm$parser$Parser$Advanced$token;
var $elm$parser$Parser$symbol = function (str) {
	return $elm$parser$Parser$Advanced$symbol(
		A2(
			$elm$parser$Parser$Advanced$Token,
			str,
			$elm$parser$Parser$ExpectingSymbol(str)));
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear = 1970;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay = function (day) {
	return $elm$parser$Parser$problem(
		'Invalid day: ' + $elm$core$String$fromInt(day));
};
var $elm$core$Basics$modBy = _Basics_modBy;
var $elm$core$Basics$neq = _Utils_notEqual;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear = function (year) {
	return (!A2($elm$core$Basics$modBy, 4, year)) && ((!(!A2($elm$core$Basics$modBy, 100, year))) || (!A2($elm$core$Basics$modBy, 400, year)));
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore = function (y1) {
	var y = y1 - 1;
	return (((y / 4) | 0) - ((y / 100) | 0)) + ((y / 400) | 0);
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerDay = 86400000;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerYear = 31536000000;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$yearMonthDay = function (_v0) {
	var year = _v0.a;
	var month = _v0.b;
	var dayInMonth = _v0.c;
	if (dayInMonth < 0) {
		return $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth);
	} else {
		var succeedWith = function (extraMs) {
			var yearMs = $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerYear * (year - $rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear);
			var days = ((month < 3) || (!$rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear(year))) ? (dayInMonth - 1) : dayInMonth;
			var dayMs = $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerDay * (days + ($rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore(year) - $rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore($rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear)));
			return $elm$parser$Parser$succeed((extraMs + yearMs) + dayMs);
		};
		switch (month) {
			case 1:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(0);
			case 2:
				return ((dayInMonth > 29) || ((dayInMonth === 29) && (!$rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear(year)))) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(2678400000);
			case 3:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(5097600000);
			case 4:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(7776000000);
			case 5:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(10368000000);
			case 6:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(13046400000);
			case 7:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(15638400000);
			case 8:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(18316800000);
			case 9:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(20995200000);
			case 10:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(23587200000);
			case 11:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(26265600000);
			case 12:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(28857600000);
			default:
				return $elm$parser$Parser$problem(
					'Invalid month: \"' + ($elm$core$String$fromInt(month) + '\"'));
		}
	}
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$monthYearDayInMs = A2(
	$elm$parser$Parser$andThen,
	$rtfeldman$elm_iso8601_date_strings$Iso8601$yearMonthDay,
	A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			A2(
				$elm$parser$Parser$keeper,
				$elm$parser$Parser$succeed(
					F3(
						function (year, month, day) {
							return _Utils_Tuple3(year, month, day);
						})),
				$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(4)),
			$elm$parser$Parser$oneOf(
				_List_fromArray(
					[
						A2(
						$elm$parser$Parser$keeper,
						A2(
							$elm$parser$Parser$ignorer,
							$elm$parser$Parser$succeed($elm$core$Basics$identity),
							$elm$parser$Parser$symbol('-')),
						$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
						$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
					]))),
		$elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$keeper,
					A2(
						$elm$parser$Parser$ignorer,
						$elm$parser$Parser$succeed($elm$core$Basics$identity),
						$elm$parser$Parser$symbol('-')),
					$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
					$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
				]))));
var $rtfeldman$elm_iso8601_date_strings$Iso8601$utcOffsetInMinutes = function () {
	var utcOffsetMinutesFromParts = F3(
		function (multiplier, hours, minutes) {
			return (multiplier * (hours * 60)) + minutes;
		});
	return A2(
		$elm$parser$Parser$keeper,
		$elm$parser$Parser$succeed($elm$core$Basics$identity),
		$elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$map,
					function (_v0) {
						return 0;
					},
					$elm$parser$Parser$symbol('Z')),
					A2(
					$elm$parser$Parser$keeper,
					A2(
						$elm$parser$Parser$keeper,
						A2(
							$elm$parser$Parser$keeper,
							$elm$parser$Parser$succeed(utcOffsetMinutesFromParts),
							$elm$parser$Parser$oneOf(
								_List_fromArray(
									[
										A2(
										$elm$parser$Parser$map,
										function (_v1) {
											return 1;
										},
										$elm$parser$Parser$symbol('+')),
										A2(
										$elm$parser$Parser$map,
										function (_v2) {
											return -1;
										},
										$elm$parser$Parser$symbol('-'))
									]))),
						$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
					$elm$parser$Parser$oneOf(
						_List_fromArray(
							[
								A2(
								$elm$parser$Parser$keeper,
								A2(
									$elm$parser$Parser$ignorer,
									$elm$parser$Parser$succeed($elm$core$Basics$identity),
									$elm$parser$Parser$symbol(':')),
								$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
								$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2),
								$elm$parser$Parser$succeed(0)
							]))),
					A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed(0),
					$elm$parser$Parser$end)
				])));
}();
var $rtfeldman$elm_iso8601_date_strings$Iso8601$iso8601 = A2(
	$elm$parser$Parser$andThen,
	function (datePart) {
		return $elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$keeper,
					A2(
						$elm$parser$Parser$keeper,
						A2(
							$elm$parser$Parser$keeper,
							A2(
								$elm$parser$Parser$keeper,
								A2(
									$elm$parser$Parser$keeper,
									A2(
										$elm$parser$Parser$ignorer,
										$elm$parser$Parser$succeed(
											$rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts(datePart)),
										$elm$parser$Parser$symbol('T')),
									$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
								$elm$parser$Parser$oneOf(
									_List_fromArray(
										[
											A2(
											$elm$parser$Parser$keeper,
											A2(
												$elm$parser$Parser$ignorer,
												$elm$parser$Parser$succeed($elm$core$Basics$identity),
												$elm$parser$Parser$symbol(':')),
											$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
											$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
										]))),
							$elm$parser$Parser$oneOf(
								_List_fromArray(
									[
										A2(
										$elm$parser$Parser$keeper,
										A2(
											$elm$parser$Parser$ignorer,
											$elm$parser$Parser$succeed($elm$core$Basics$identity),
											$elm$parser$Parser$symbol(':')),
										$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
										$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
									]))),
						$elm$parser$Parser$oneOf(
							_List_fromArray(
								[
									A2(
									$elm$parser$Parser$keeper,
									A2(
										$elm$parser$Parser$ignorer,
										$elm$parser$Parser$succeed($elm$core$Basics$identity),
										$elm$parser$Parser$symbol('.')),
									$rtfeldman$elm_iso8601_date_strings$Iso8601$fractionsOfASecondInMs),
									$elm$parser$Parser$succeed(0)
								]))),
					A2($elm$parser$Parser$ignorer, $rtfeldman$elm_iso8601_date_strings$Iso8601$utcOffsetInMinutes, $elm$parser$Parser$end)),
					A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed(
						A6($rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts, datePart, 0, 0, 0, 0, 0)),
					$elm$parser$Parser$end)
				]));
	},
	$rtfeldman$elm_iso8601_date_strings$Iso8601$monthYearDayInMs);
var $elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {col: col, problem: problem, row: row};
	});
var $elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3($elm$parser$Parser$DeadEnd, p.row, p.col, p.problem);
};
var $elm$parser$Parser$Advanced$bagToList = F2(
	function (bag, list) {
		bagToList:
		while (true) {
			switch (bag.$) {
				case 'Empty':
					return list;
				case 'AddRight':
					var bag1 = bag.a;
					var x = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$core$List$cons, x, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
				default:
					var bag1 = bag.a;
					var bag2 = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$parser$Parser$Advanced$bagToList, bag2, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
			}
		}
	});
var $elm$parser$Parser$Advanced$run = F2(
	function (_v0, src) {
		var parse = _v0.a;
		var _v1 = parse(
			{col: 1, context: _List_Nil, indent: 1, offset: 0, row: 1, src: src});
		if (_v1.$ === 'Good') {
			var value = _v1.b;
			return $elm$core$Result$Ok(value);
		} else {
			var bag = _v1.b;
			return $elm$core$Result$Err(
				A2($elm$parser$Parser$Advanced$bagToList, bag, _List_Nil));
		}
	});
var $elm$parser$Parser$run = F2(
	function (parser, source) {
		var _v0 = A2($elm$parser$Parser$Advanced$run, parser, source);
		if (_v0.$ === 'Ok') {
			var a = _v0.a;
			return $elm$core$Result$Ok(a);
		} else {
			var problems = _v0.a;
			return $elm$core$Result$Err(
				A2($elm$core$List$map, $elm$parser$Parser$problemToDeadEnd, problems));
		}
	});
var $rtfeldman$elm_iso8601_date_strings$Iso8601$toTime = function (str) {
	return A2($elm$parser$Parser$run, $rtfeldman$elm_iso8601_date_strings$Iso8601$iso8601, str);
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$decoder = A2(
	$elm$json$Json$Decode$andThen,
	function (str) {
		var _v0 = $rtfeldman$elm_iso8601_date_strings$Iso8601$toTime(str);
		if (_v0.$ === 'Err') {
			var deadEnds = _v0.a;
			return $elm$json$Json$Decode$fail(
				$elm$parser$Parser$deadEndsToString(deadEnds));
		} else {
			var time = _v0.a;
			return $elm$json$Json$Decode$succeed(time);
		}
	},
	$elm$json$Json$Decode$string);
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Article$metadataDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'favoritesCount',
	$elm$json$Json$Decode$int,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'favorited',
		$elm$json$Json$Decode$bool,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'createdAt',
			$rtfeldman$elm_iso8601_date_strings$Iso8601$decoder,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'tagList',
				$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'title',
					$elm$json$Json$Decode$string,
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'description',
						A2(
							$elm$json$Json$Decode$map,
							$elm$core$Maybe$withDefault(''),
							$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string)),
						$elm$json$Json$Decode$succeed($author$project$Article$Metadata)))))));
var $author$project$Article$internalsDecoder = function (maybeCred) {
	return A2(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
		$author$project$Article$metadataDecoder,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'author',
			$author$project$Author$decoder(maybeCred),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'slug',
				$author$project$Article$Slug$decoder,
				$elm$json$Json$Decode$succeed($author$project$Article$Internals))));
};
var $author$project$Article$fullDecoder = function (maybeCred) {
	return A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'body',
		A2($elm$json$Json$Decode$map, $author$project$Article$Full, $author$project$Article$Body$decoder),
		A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			$author$project$Article$internalsDecoder(maybeCred),
			$elm$json$Json$Decode$succeed($author$project$Article$Article)));
};
var $elm$http$Http$Header = F2(
	function (a, b) {
		return {$: 'Header', a: a, b: b};
	});
var $elm$http$Http$header = $elm$http$Http$Header;
var $author$project$Api$corsHeader = A2($elm$http$Http$header, 'Access-Control-Allow-Origin', 'https://api.kraken.com');
var $elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 'BadStatus_', a: a, b: b};
	});
var $elm$http$Http$BadUrl_ = function (a) {
	return {$: 'BadUrl_', a: a};
};
var $elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 'GoodStatus_', a: a, b: b};
	});
var $elm$http$Http$NetworkError_ = {$: 'NetworkError_'};
var $elm$http$Http$Receiving = function (a) {
	return {$: 'Receiving', a: a};
};
var $elm$http$Http$Sending = function (a) {
	return {$: 'Sending', a: a};
};
var $elm$http$Http$Timeout_ = {$: 'Timeout_'};
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Maybe$isJust = function (maybe) {
	if (maybe.$ === 'Just') {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.e.d.$ === 'RBNode_elm_builtin') && (dict.e.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.d.d.$ === 'RBNode_elm_builtin') && (dict.d.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Black')) {
					if (right.d.$ === 'RBNode_elm_builtin') {
						if (right.d.a.$ === 'Black') {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor.$ === 'Black') {
			if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === 'RBNode_elm_builtin') {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Black')) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === 'RBNode_elm_builtin') {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBNode_elm_builtin') {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === 'RBNode_elm_builtin') {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (_v0.$ === 'Just') {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $elm$http$Http$emptyBody = _Http_emptyBody;
var $NoRedInk$http_upgrade_shim$Http$Legacy$emptyBody = $elm$http$Http$emptyBody;
var $NoRedInk$http_upgrade_shim$Http$Legacy$BadPayload = F2(
	function (a, b) {
		return {$: 'BadPayload', a: a, b: b};
	});
var $NoRedInk$http_upgrade_shim$Http$Legacy$combine = function (result) {
	if (result.$ === 'Ok') {
		var x = result.a;
		return x;
	} else {
		var x = result.a;
		return x;
	}
};
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $elm$http$Http$expectStringResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'',
			$elm$core$Basics$identity,
			A2($elm$core$Basics$composeR, toResult, toMsg));
	});
var $NoRedInk$http_upgrade_shim$Http$Legacy$BadStatus = function (a) {
	return {$: 'BadStatus', a: a};
};
var $NoRedInk$http_upgrade_shim$Http$Legacy$BadUrl = function (a) {
	return {$: 'BadUrl', a: a};
};
var $NoRedInk$http_upgrade_shim$Http$Legacy$NetworkError = {$: 'NetworkError'};
var $NoRedInk$http_upgrade_shim$Http$Legacy$Timeout = {$: 'Timeout'};
var $NoRedInk$http_upgrade_shim$Http$Legacy$metadataAndBodyToResponse = F2(
	function (meta, body) {
		return {
			body: body,
			headers: meta.headers,
			status: {code: meta.statusCode, message: meta.statusText},
			url: meta.url
		};
	});
var $NoRedInk$http_upgrade_shim$Http$Legacy$fromHttpResponse = function (response) {
	switch (response.$) {
		case 'BadUrl_':
			var url = response.a;
			return $elm$core$Result$Err(
				$NoRedInk$http_upgrade_shim$Http$Legacy$BadUrl(url));
		case 'Timeout_':
			return $elm$core$Result$Err($NoRedInk$http_upgrade_shim$Http$Legacy$Timeout);
		case 'NetworkError_':
			return $elm$core$Result$Err($NoRedInk$http_upgrade_shim$Http$Legacy$NetworkError);
		case 'BadStatus_':
			var meta = response.a;
			var body = response.b;
			return $elm$core$Result$Err(
				$NoRedInk$http_upgrade_shim$Http$Legacy$BadStatus(
					A2($NoRedInk$http_upgrade_shim$Http$Legacy$metadataAndBodyToResponse, meta, body)));
		default:
			var meta = response.a;
			var body = response.b;
			return $elm$core$Result$Ok(
				A2($NoRedInk$http_upgrade_shim$Http$Legacy$metadataAndBodyToResponse, meta, body));
	}
};
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (result.$ === 'Ok') {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $NoRedInk$http_upgrade_shim$Http$Legacy$expectJson = function (decoder) {
	return {
		decode: function (response) {
			return A2(
				$elm$core$Result$mapError,
				function (err) {
					return A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$BadPayload,
						$elm$json$Json$Decode$errorToString(err),
						response);
				},
				A2($elm$json$Json$Decode$decodeString, decoder, response.body));
		},
		expect: A2(
			$elm$http$Http$expectStringResponse,
			A2($elm$core$Basics$composeL, $NoRedInk$http_upgrade_shim$Http$Legacy$fromHttpResponse, $NoRedInk$http_upgrade_shim$Http$Legacy$combine),
			$elm$core$Result$Ok)
	};
};
var $NoRedInk$http_upgrade_shim$Http$Legacy$request = $elm$core$Basics$identity;
var $author$project$Api$Endpoint$unwrap = function (_v0) {
	var str = _v0.a;
	return str;
};
var $author$project$Api$Endpoint$request = function (config) {
	return $NoRedInk$http_upgrade_shim$Http$Legacy$request(
		{
			body: config.body,
			expect: config.expect,
			headers: config.headers,
			method: config.method,
			timeout: config.timeout,
			url: $author$project$Api$Endpoint$unwrap(config.url),
			withCredentials: config.withCredentials
		});
};
var $author$project$Api$get = F3(
	function (url, maybeCred, decoder) {
		return $author$project$Api$Endpoint$request(
			{
				body: $NoRedInk$http_upgrade_shim$Http$Legacy$emptyBody,
				expect: $NoRedInk$http_upgrade_shim$Http$Legacy$expectJson(decoder),
				headers: function () {
					if (maybeCred.$ === 'Just') {
						var cred = maybeCred.a;
						return _List_fromArray(
							[$author$project$Api$corsHeader]);
					} else {
						return _List_Nil;
					}
				}(),
				method: 'GET',
				timeout: $elm$core$Maybe$Nothing,
				url: url,
				withCredentials: false
			});
	});
var $author$project$Article$fetch = F2(
	function (maybeCred, articleSlug) {
		return A3(
			$author$project$Api$get,
			$author$project$Api$Endpoint$article(articleSlug),
			maybeCred,
			A2(
				$elm$json$Json$Decode$field,
				'article',
				$author$project$Article$fullDecoder(maybeCred)));
	});
var $elm$time$Time$Name = function (a) {
	return {$: 'Name', a: a};
};
var $elm$time$Time$Offset = function (a) {
	return {$: 'Offset', a: a};
};
var $elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 'Zone', a: a, b: b};
	});
var $elm$time$Time$customZone = $elm$time$Time$Zone;
var $elm$time$Time$here = _Time_here(_Utils_Tuple0);
var $author$project$Api$Endpoint$comments = function (slug) {
	return A2(
		$author$project$Api$Endpoint$url,
		_List_fromArray(
			[
				'articles',
				$author$project$Article$Slug$toString(slug),
				'comments'
			]),
		_List_Nil);
};
var $author$project$Article$Comment$Comment = function (a) {
	return {$: 'Comment', a: a};
};
var $author$project$Article$Comment$Internals = F4(
	function (id, body, createdAt, author) {
		return {author: author, body: body, createdAt: createdAt, id: id};
	});
var $author$project$CommentId$CommentId = function (a) {
	return {$: 'CommentId', a: a};
};
var $author$project$CommentId$decoder = A2($elm$json$Json$Decode$map, $author$project$CommentId$CommentId, $elm$json$Json$Decode$int);
var $author$project$Article$Comment$decoder = function (maybeCred) {
	return A2(
		$elm$json$Json$Decode$map,
		$author$project$Article$Comment$Comment,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'author',
			$author$project$Author$decoder(maybeCred),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'createdAt',
				$rtfeldman$elm_iso8601_date_strings$Iso8601$decoder,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'body',
					$elm$json$Json$Decode$string,
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'id',
						$author$project$CommentId$decoder,
						$elm$json$Json$Decode$succeed($author$project$Article$Comment$Internals))))));
};
var $author$project$Article$Comment$list = F2(
	function (maybeCred, articleSlug) {
		return A3(
			$author$project$Api$get,
			$author$project$Api$Endpoint$comments(articleSlug),
			maybeCred,
			A2(
				$elm$json$Json$Decode$field,
				'comments',
				$elm$json$Json$Decode$list(
					$author$project$Article$Comment$decoder(maybeCred))));
	});
var $elm$core$Platform$Cmd$map = _Platform_map;
var $elm$http$Http$Request = function (a) {
	return {$: 'Request', a: a};
};
var $elm$http$Http$State = F2(
	function (reqs, subs) {
		return {reqs: reqs, subs: subs};
	});
var $elm$http$Http$init = $elm$core$Task$succeed(
	A2($elm$http$Http$State, $elm$core$Dict$empty, _List_Nil));
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$http$Http$updateReqs = F3(
	function (router, cmds, reqs) {
		updateReqs:
		while (true) {
			if (!cmds.b) {
				return $elm$core$Task$succeed(reqs);
			} else {
				var cmd = cmds.a;
				var otherCmds = cmds.b;
				if (cmd.$ === 'Cancel') {
					var tracker = cmd.a;
					var _v2 = A2($elm$core$Dict$get, tracker, reqs);
					if (_v2.$ === 'Nothing') {
						var $temp$router = router,
							$temp$cmds = otherCmds,
							$temp$reqs = reqs;
						router = $temp$router;
						cmds = $temp$cmds;
						reqs = $temp$reqs;
						continue updateReqs;
					} else {
						var pid = _v2.a;
						return A2(
							$elm$core$Task$andThen,
							function (_v3) {
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A2($elm$core$Dict$remove, tracker, reqs));
							},
							$elm$core$Process$kill(pid));
					}
				} else {
					var req = cmd.a;
					return A2(
						$elm$core$Task$andThen,
						function (pid) {
							var _v4 = req.tracker;
							if (_v4.$ === 'Nothing') {
								return A3($elm$http$Http$updateReqs, router, otherCmds, reqs);
							} else {
								var tracker = _v4.a;
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A3($elm$core$Dict$insert, tracker, pid, reqs));
							}
						},
						$elm$core$Process$spawn(
							A3(
								_Http_toTask,
								router,
								$elm$core$Platform$sendToApp(router),
								req)));
				}
			}
		}
	});
var $elm$http$Http$onEffects = F4(
	function (router, cmds, subs, state) {
		return A2(
			$elm$core$Task$andThen,
			function (reqs) {
				return $elm$core$Task$succeed(
					A2($elm$http$Http$State, reqs, subs));
			},
			A3($elm$http$Http$updateReqs, router, cmds, state.reqs));
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$http$Http$maybeSend = F4(
	function (router, desiredTracker, progress, _v0) {
		var actualTracker = _v0.a;
		var toMsg = _v0.b;
		return _Utils_eq(desiredTracker, actualTracker) ? $elm$core$Maybe$Just(
			A2(
				$elm$core$Platform$sendToApp,
				router,
				toMsg(progress))) : $elm$core$Maybe$Nothing;
	});
var $elm$http$Http$onSelfMsg = F3(
	function (router, _v0, state) {
		var tracker = _v0.a;
		var progress = _v0.b;
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$filterMap,
					A3($elm$http$Http$maybeSend, router, tracker, progress),
					state.subs)));
	});
var $elm$http$Http$Cancel = function (a) {
	return {$: 'Cancel', a: a};
};
var $elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (cmd.$ === 'Cancel') {
			var tracker = cmd.a;
			return $elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return $elm$http$Http$Request(
				{
					allowCookiesFromOtherDomains: r.allowCookiesFromOtherDomains,
					body: r.body,
					expect: A2(_Http_mapExpect, func, r.expect),
					headers: r.headers,
					method: r.method,
					timeout: r.timeout,
					tracker: r.tracker,
					url: r.url
				});
		}
	});
var $elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 'MySub', a: a, b: b};
	});
var $elm$http$Http$subMap = F2(
	function (func, _v0) {
		var tracker = _v0.a;
		var toMsg = _v0.b;
		return A2(
			$elm$http$Http$MySub,
			tracker,
			A2($elm$core$Basics$composeR, toMsg, func));
	});
_Platform_effectManagers['Http'] = _Platform_createManager($elm$http$Http$init, $elm$http$Http$onEffects, $elm$http$Http$onSelfMsg, $elm$http$Http$cmdMap, $elm$http$Http$subMap);
var $elm$http$Http$command = _Platform_leaf('Http');
var $elm$http$Http$subscription = _Platform_leaf('Http');
var $elm$http$Http$request = function (r) {
	return $elm$http$Http$command(
		$elm$http$Http$Request(
			{allowCookiesFromOtherDomains: false, body: r.body, expect: r.expect, headers: r.headers, method: r.method, timeout: r.timeout, tracker: r.tracker, url: r.url}));
};
var $elm$http$Http$riskyRequest = function (r) {
	return $elm$http$Http$command(
		$elm$http$Http$Request(
			{allowCookiesFromOtherDomains: true, body: r.body, expect: r.expect, headers: r.headers, method: r.method, timeout: r.timeout, tracker: r.tracker, url: r.url}));
};
var $NoRedInk$http_upgrade_shim$Http$Legacy$send = F2(
	function (callback, _v0) {
		var method = _v0.method;
		var headers = _v0.headers;
		var url = _v0.url;
		var body = _v0.body;
		var expect = _v0.expect;
		var timeout = _v0.timeout;
		var withCredentials = _v0.withCredentials;
		var request_ = {body: body, expect: expect.expect, headers: headers, method: method, timeout: timeout, tracker: $elm$core$Maybe$Nothing, url: url};
		var handleResponse = function (response) {
			return callback(
				A2($elm$core$Result$andThen, expect.decode, response));
		};
		return A2(
			$elm$core$Platform$Cmd$map,
			handleResponse,
			withCredentials ? $elm$http$Http$riskyRequest(request_) : $elm$http$Http$request(request_));
	});
var $elm$core$Process$sleep = _Process_sleep;
var $author$project$Loading$slowThreshold = $elm$core$Process$sleep(500);
var $elm$time$Time$utc = A2($elm$time$Time$Zone, 0, _List_Nil);
var $author$project$Page$Article$init = F2(
	function (session, slug) {
		var maybeCred = $author$project$Session$cred(session);
		return _Utils_Tuple2(
			{article: $author$project$Page$Article$Loading, comments: $author$project$Page$Article$Loading, errors: _List_Nil, session: session, timeZone: $elm$time$Time$utc},
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$send,
						$author$project$Page$Article$CompletedLoadArticle,
						A2($author$project$Article$fetch, maybeCred, slug)),
						A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$send,
						$author$project$Page$Article$CompletedLoadComments,
						A2($author$project$Article$Comment$list, maybeCred, slug)),
						A2($elm$core$Task$perform, $author$project$Page$Article$GotTimeZone, $elm$time$Time$here),
						A2(
						$elm$core$Task$perform,
						function (_v0) {
							return $author$project$Page$Article$PassedSlowLoadThreshold;
						},
						$author$project$Loading$slowThreshold)
					])));
	});
var $author$project$Page$Home$GetMetaInfo = function (a) {
	return {$: 'GetMetaInfo', a: a};
};
var $elm$core$Task$onError = _Scheduler_onError;
var $elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2(
					$elm$core$Task$onError,
					A2(
						$elm$core$Basics$composeL,
						A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
						$elm$core$Result$Err),
					A2(
						$elm$core$Task$andThen,
						A2(
							$elm$core$Basics$composeL,
							A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
							$elm$core$Result$Ok),
						task))));
	});
var $author$project$Api$Data$KrakenMetaResponse = F2(
	function (errors, assetInfo) {
		return {assetInfo: assetInfo, errors: errors};
	});
var $author$project$Api$Data$AssetMetaInfo = F9(
	function (a, b, c, v, p, t, l, h, o) {
		return {a: a, b: b, c: c, h: h, l: l, o: o, p: p, t: t, v: v};
	});
var $author$project$Api$Data$AskArray = F3(
	function (price, wLotVol, lotVol) {
		return {lotVol: lotVol, price: price, wLotVol: wLotVol};
	});
var $elm$json$Json$Decode$index = _Json_decodeIndex;
var $elm$json$Json$Decode$map3 = _Json_map3;
var $author$project$Api$Data$askArrayDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Api$Data$AskArray,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Api$Data$askArrayDecoderInt = A4(
	$elm$json$Json$Decode$map3,
	F3(
		function (a, b, c) {
			return A3(
				$author$project$Api$Data$AskArray,
				a,
				$elm$core$String$fromInt(b),
				c);
		}),
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Api$Data$bidArrayDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Api$Data$AskArray,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Api$Data$BidArray = F3(
	function (price, wLotVol, lotVol) {
		return {lotVol: lotVol, price: price, wLotVol: wLotVol};
	});
var $author$project$Api$Data$bidArrayDecoderInt = A4(
	$elm$json$Json$Decode$map3,
	F3(
		function (a, b, c) {
			return A3(
				$author$project$Api$Data$BidArray,
				a,
				$elm$core$String$fromInt(b),
				c);
		}),
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Api$Data$LastClosedTrade = F2(
	function (price, lotVol) {
		return {lotVol: lotVol, price: price};
	});
var $author$project$Api$Data$lastClosedTradeDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Api$Data$LastClosedTrade,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string));
var $author$project$Api$Data$NumberOfTrades = F2(
	function (today, last24h) {
		return {last24h: last24h, today: today};
	});
var $author$project$Api$Data$numberOfTradesDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Api$Data$NumberOfTrades,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$int));
var $author$project$Api$Data$OpenPrice = F2(
	function (last24h, today) {
		return {last24h: last24h, today: today};
	});
var $author$project$Api$Data$openPriceDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Api$Data$OpenPrice,
	A2(
		$elm$json$Json$Decode$index,
		0,
		$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string));
var $author$project$Api$Data$openPriceDecoderSingl = A2(
	$elm$json$Json$Decode$map,
	$author$project$Api$Data$OpenPrice($elm$core$Maybe$Nothing),
	$elm$json$Json$Decode$string);
var $author$project$Api$Data$decoderAssetMetaInfo = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'o',
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[$author$project$Api$Data$openPriceDecoder, $author$project$Api$Data$openPriceDecoderSingl])),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'h',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'l',
			$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				't',
				$author$project$Api$Data$numberOfTradesDecoder,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'p',
					$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'v',
						$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'c',
							$author$project$Api$Data$lastClosedTradeDecoder,
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'b',
								$elm$json$Json$Decode$oneOf(
									_List_fromArray(
										[$author$project$Api$Data$bidArrayDecoder, $author$project$Api$Data$bidArrayDecoderInt])),
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'a',
									$elm$json$Json$Decode$oneOf(
										_List_fromArray(
											[$author$project$Api$Data$askArrayDecoder, $author$project$Api$Data$askArrayDecoderInt])),
									$elm$json$Json$Decode$succeed($author$project$Api$Data$AssetMetaInfo))))))))));
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
var $elm$json$Json$Decode$dict = function (decoder) {
	return A2(
		$elm$json$Json$Decode$map,
		$elm$core$Dict$fromList,
		$elm$json$Json$Decode$keyValuePairs(decoder));
};
var $author$project$Api$Data$decoderKrakenMeta = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'result',
	$elm$json$Json$Decode$dict($author$project$Api$Data$decoderAssetMetaInfo),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'error',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
		$elm$json$Json$Decode$succeed($author$project$Api$Data$KrakenMetaResponse)));
var $author$project$Api$Endpoint$craken_public_url = F2(
	function (paths, queryParams) {
		return $author$project$Api$Endpoint$Endpoint(
			A3(
				$elm$url$Url$Builder$crossOrigin,
				'https://api.kraken.com',
				A2($elm$core$List$cons, '0', paths),
				queryParams));
	});
var $author$project$Api$Endpoint$kraken_meta_info = function (params) {
	return A2(
		$author$project$Api$Endpoint$craken_public_url,
		_List_fromArray(
			['public', 'Ticker']),
		params);
};
var $elm$url$Url$Builder$QueryParameter = F2(
	function (a, b) {
		return {$: 'QueryParameter', a: a, b: b};
	});
var $elm$url$Url$percentEncode = _Url_percentEncode;
var $elm$url$Url$Builder$string = F2(
	function (key, value) {
		return A2(
			$elm$url$Url$Builder$QueryParameter,
			$elm$url$Url$percentEncode(key),
			$elm$url$Url$percentEncode(value));
	});
var $elm$core$Task$fail = _Scheduler_fail;
var $NoRedInk$http_upgrade_shim$Http$Legacy$handleTaskResponse = F2(
	function (req, response) {
		var _v0 = $NoRedInk$http_upgrade_shim$Http$Legacy$fromHttpResponse(response);
		if (_v0.$ === 'Err') {
			var err = _v0.a;
			return $elm$core$Task$fail(err);
		} else {
			var response_ = _v0.a;
			var _v1 = req.expect.decode(response_);
			if (_v1.$ === 'Ok') {
				var payload = _v1.a;
				return $elm$core$Task$succeed(payload);
			} else {
				var err = _v1.a;
				return $elm$core$Task$fail(err);
			}
		}
	});
var $elm$http$Http$resultToTask = function (result) {
	if (result.$ === 'Ok') {
		var a = result.a;
		return $elm$core$Task$succeed(a);
	} else {
		var x = result.a;
		return $elm$core$Task$fail(x);
	}
};
var $elm$http$Http$riskyTask = function (r) {
	return A3(
		_Http_toTask,
		_Utils_Tuple0,
		$elm$http$Http$resultToTask,
		{allowCookiesFromOtherDomains: true, body: r.body, expect: r.resolver, headers: r.headers, method: r.method, timeout: r.timeout, tracker: $elm$core$Maybe$Nothing, url: r.url});
};
var $elm$http$Http$stringResolver = A2(_Http_expect, '', $elm$core$Basics$identity);
var $elm$http$Http$task = function (r) {
	return A3(
		_Http_toTask,
		_Utils_Tuple0,
		$elm$http$Http$resultToTask,
		{allowCookiesFromOtherDomains: false, body: r.body, expect: r.resolver, headers: r.headers, method: r.method, timeout: r.timeout, tracker: $elm$core$Maybe$Nothing, url: r.url});
};
var $NoRedInk$http_upgrade_shim$Http$Legacy$toTask = function (req) {
	var taskReq = {
		body: req.body,
		headers: req.headers,
		method: req.method,
		resolver: $elm$http$Http$stringResolver($elm$core$Result$Ok),
		timeout: req.timeout,
		url: req.url
	};
	var task = req.withCredentials ? $elm$http$Http$riskyTask(taskReq) : $elm$http$Http$task(taskReq);
	return A2(
		$elm$core$Task$andThen,
		$NoRedInk$http_upgrade_shim$Http$Legacy$handleTaskResponse(req),
		task);
};
var $author$project$Page$Home$fetchMetaInfo = function (assetPair) {
	var request = A3(
		$author$project$Api$get,
		$author$project$Api$Endpoint$kraken_meta_info(
			_List_fromArray(
				[
					A2($elm$url$Url$Builder$string, 'pair', assetPair)
				])),
		$elm$core$Maybe$Nothing,
		$author$project$Api$Data$decoderKrakenMeta);
	return $NoRedInk$http_upgrade_shim$Http$Legacy$toTask(request);
};
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Page$Home$updatePriceIfNeeded = function (model) {
	var _v0 = model.selectedDropdownValueFrom;
	if (_v0.$ === 'Just') {
		var fromCurrency = _v0.a;
		var _v1 = model.selectedDropdownValueTo;
		if (_v1.$ === 'Just') {
			var toCurrency = _v1.a;
			return A2(
				$elm$core$Task$attempt,
				$author$project$Page$Home$GetMetaInfo,
				$author$project$Page$Home$fetchMetaInfo(
					_Utils_ap(fromCurrency, toCurrency)));
		} else {
			return $elm$core$Platform$Cmd$none;
		}
	} else {
		return $elm$core$Platform$Cmd$none;
	}
};
var $author$project$Page$Home$init = function (session) {
	var md = {
		fromNumber: '',
		name: 'Nikos',
		pairName: 'ADAEUR',
		priceInfo: $elm$core$Maybe$Nothing,
		selectedDropdownValueFrom: $elm$core$Maybe$Just('ADA'),
		selectedDropdownValueTo: $elm$core$Maybe$Just('EUR'),
		session: session,
		textIndex: 1,
		toNumber: ''
	};
	return _Utils_Tuple2(
		md,
		$elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					$author$project$Page$Home$updatePriceIfNeeded(md)
				])));
};
var $author$project$Page$Login$Ready = function (a) {
	return {$: 'Ready', a: a};
};
var $author$project$Page$Login$init = function (session) {
	return _Utils_Tuple2(
		{
			form: {email: 'adfasdfafs', password: ''},
			problems: _List_Nil,
			session: session
		},
		A2(
			$elm$core$Task$perform,
			$author$project$Page$Login$Ready,
			$elm$core$Process$sleep(0)));
};
var $author$project$Page$Prices$CompletedFeedLoad = function (a) {
	return {$: 'CompletedFeedLoad', a: a};
};
var $author$project$Page$Prices$CompletedTagsLoad = function (a) {
	return {$: 'CompletedTagsLoad', a: a};
};
var $author$project$Page$Prices$GlobalFeed = {$: 'GlobalFeed'};
var $author$project$Page$Prices$GotTimeZone = function (a) {
	return {$: 'GotTimeZone', a: a};
};
var $author$project$Page$Prices$Loading = {$: 'Loading'};
var $author$project$Page$Prices$PassedSlowLoadThreshold = {$: 'PassedSlowLoadThreshold'};
var $author$project$Page$Prices$YourFeed = function (a) {
	return {$: 'YourFeed', a: a};
};
var $author$project$Api$Endpoint$kraken_local_url = F2(
	function (paths, queryParams) {
		return $author$project$Api$Endpoint$Endpoint(
			A3(
				$elm$url$Url$Builder$crossOrigin,
				'http://localhost/',
				A2($elm$core$List$cons, 'kraken', paths),
				queryParams));
	});
var $author$project$Api$Endpoint$asset_pairs = A2(
	$author$project$Api$Endpoint$kraken_local_url,
	_List_fromArray(
		['assetpairs']),
	_List_Nil);
var $author$project$Page$Prices$KrakenResponse = F2(
	function (errors, assetPairs) {
		return {assetPairs: assetPairs, errors: errors};
	});
var $author$project$Page$Prices$AssetPairInfo = F4(
	function (alternate_name, ws_name, base, quote) {
		return {alternate_name: alternate_name, base: base, quote: quote, ws_name: ws_name};
	});
var $author$project$Page$Prices$decoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'quote',
	$elm$json$Json$Decode$string,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'base',
		$elm$json$Json$Decode$string,
		A4(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'wsname',
			$elm$json$Json$Decode$string,
			'',
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'altname',
				$elm$json$Json$Decode$string,
				$elm$json$Json$Decode$succeed($author$project$Page$Prices$AssetPairInfo)))));
var $author$project$Page$Prices$decoderKraken = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'result',
	$elm$json$Json$Decode$dict($author$project$Page$Prices$decoder),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'error',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
		$elm$json$Json$Decode$succeed($author$project$Page$Prices$KrakenResponse)));
var $author$project$Page$Prices$fetchFeed = F2(
	function (session, page) {
		var request = A3($author$project$Api$get, $author$project$Api$Endpoint$asset_pairs, $elm$core$Maybe$Nothing, $author$project$Page$Prices$decoderKraken);
		var maybeCred = $author$project$Session$cred(session);
		return $NoRedInk$http_upgrade_shim$Http$Legacy$toTask(request);
	});
var $author$project$Article$Tag$Tag = function (a) {
	return {$: 'Tag', a: a};
};
var $author$project$Article$Tag$decoder = A2($elm$json$Json$Decode$map, $author$project$Article$Tag$Tag, $elm$json$Json$Decode$string);
var $author$project$Api$Endpoint$tags = A2(
	$author$project$Api$Endpoint$url,
	_List_fromArray(
		['tags']),
	_List_Nil);
var $author$project$Article$Tag$list = A3(
	$author$project$Api$get,
	$author$project$Api$Endpoint$tags,
	$elm$core$Maybe$Nothing,
	A2(
		$elm$json$Json$Decode$field,
		'tags',
		$elm$json$Json$Decode$list($author$project$Article$Tag$decoder)));
var $author$project$Page$Prices$init = function (session) {
	var loadTags = $NoRedInk$http_upgrade_shim$Http$Legacy$toTask($author$project$Article$Tag$list);
	var feedTab = function () {
		var _v1 = $author$project$Session$cred(session);
		if (_v1.$ === 'Just') {
			var cred = _v1.a;
			return $author$project$Page$Prices$YourFeed(cred);
		} else {
			return $author$project$Page$Prices$GlobalFeed;
		}
	}();
	return _Utils_Tuple2(
		{feed: $author$project$Page$Prices$Loading, feedMeta: $elm$core$Maybe$Nothing, feedPage: 1, feedPair: $elm$core$Maybe$Nothing, feedTab: feedTab, session: session, tags: $author$project$Page$Prices$Loading, timeZone: $elm$time$Time$utc},
		$elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					A2(
					$elm$core$Task$attempt,
					$author$project$Page$Prices$CompletedFeedLoad,
					A2($author$project$Page$Prices$fetchFeed, session, 1)),
					A2($NoRedInk$http_upgrade_shim$Http$Legacy$send, $author$project$Page$Prices$CompletedTagsLoad, $author$project$Article$Tag$list),
					A2($elm$core$Task$perform, $author$project$Page$Prices$GotTimeZone, $elm$time$Time$here),
					A2(
					$elm$core$Task$perform,
					function (_v0) {
						return $author$project$Page$Prices$PassedSlowLoadThreshold;
					},
					$author$project$Loading$slowThreshold)
				])));
};
var $author$project$Page$Profile$GotTimeZone = function (a) {
	return {$: 'GotTimeZone', a: a};
};
var $author$project$Page$Profile$Loading = function (a) {
	return {$: 'Loading', a: a};
};
var $author$project$Page$Profile$PassedSlowLoadThreshold = {$: 'PassedSlowLoadThreshold'};
var $author$project$Page$Profile$init = F2(
	function (session, username) {
		var maybeCred = $author$project$Session$cred(session);
		return _Utils_Tuple2(
			{
				author: $author$project$Page$Profile$Loading(username),
				currentFile: $elm$core$Maybe$Nothing,
				currentFileBytes: $elm$core$Maybe$Nothing,
				currentFileHash: '',
				currentFileUrl: 'http://ssl.gstatic.com/accounts/ui/avatar_2x.png',
				errors: _List_Nil,
				feed: $author$project$Page$Profile$Loading(username),
				session: session,
				timeZone: $elm$time$Time$utc,
				upCreds: $elm$core$Maybe$Nothing
			},
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						A2($elm$core$Task$perform, $author$project$Page$Profile$GotTimeZone, $elm$time$Time$here),
						A2(
						$elm$core$Task$perform,
						function (_v0) {
							return $author$project$Page$Profile$PassedSlowLoadThreshold;
						},
						$author$project$Loading$slowThreshold)
					])));
	});
var $author$project$Page$Register$init = function (session) {
	return _Utils_Tuple2(
		{
			form: {email: '', password: '', username: ''},
			problems: _List_Nil,
			session: session
		},
		$elm$core$Platform$Cmd$none);
};
var $author$project$Page$Settings$CompletedFormLoad = function (a) {
	return {$: 'CompletedFormLoad', a: a};
};
var $author$project$Page$Settings$Loading = {$: 'Loading'};
var $author$project$Page$Settings$PassedSlowLoadThreshold = {$: 'PassedSlowLoadThreshold'};
var $author$project$Page$Settings$Form = F5(
	function (avatar, bio, email, username, password) {
		return {avatar: avatar, bio: bio, email: email, password: password, username: username};
	});
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded = A2($elm$core$Basics$composeR, $elm$json$Json$Decode$succeed, $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom);
var $author$project$Page$Settings$formDecoder = A2(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
	'',
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'username',
		$elm$json$Json$Decode$string,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'email',
			$elm$json$Json$Decode$string,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'bio',
				A2(
					$elm$json$Json$Decode$map,
					$elm$core$Maybe$withDefault(''),
					$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string)),
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'image',
					A2(
						$elm$json$Json$Decode$map,
						$elm$core$Maybe$withDefault(''),
						$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string)),
					$elm$json$Json$Decode$succeed($author$project$Page$Settings$Form))))));
var $author$project$Api$Endpoint$user = A2(
	$author$project$Api$Endpoint$url,
	_List_fromArray(
		['user']),
	_List_Nil);
var $author$project$Page$Settings$init = function (session) {
	return _Utils_Tuple2(
		{problems: _List_Nil, session: session, status: $author$project$Page$Settings$Loading},
		$elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					A2(
					$NoRedInk$http_upgrade_shim$Http$Legacy$send,
					$author$project$Page$Settings$CompletedFormLoad,
					A3(
						$author$project$Api$get,
						$author$project$Api$Endpoint$user,
						$author$project$Session$cred(session),
						A2($elm$json$Json$Decode$field, 'user', $author$project$Page$Settings$formDecoder))),
					A2(
					$elm$core$Task$perform,
					function (_v0) {
						return $author$project$Page$Settings$PassedSlowLoadThreshold;
					},
					$author$project$Loading$slowThreshold)
				])));
};
var $author$project$Page$Article$Editor$CompletedArticleLoad = function (a) {
	return {$: 'CompletedArticleLoad', a: a};
};
var $author$project$Page$Article$Editor$Loading = function (a) {
	return {$: 'Loading', a: a};
};
var $author$project$Page$Article$Editor$PassedSlowLoadThreshold = {$: 'PassedSlowLoadThreshold'};
var $elm$core$Task$mapError = F2(
	function (convert, task) {
		return A2(
			$elm$core$Task$onError,
			A2($elm$core$Basics$composeL, $elm$core$Task$fail, convert),
			task);
	});
var $author$project$Page$Article$Editor$initEdit = F2(
	function (session, slug) {
		return _Utils_Tuple2(
			{
				session: session,
				status: $author$project$Page$Article$Editor$Loading(slug)
			},
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						A2(
						$elm$core$Task$attempt,
						$author$project$Page$Article$Editor$CompletedArticleLoad,
						A2(
							$elm$core$Task$mapError,
							function (httpError) {
								return _Utils_Tuple2(slug, httpError);
							},
							$NoRedInk$http_upgrade_shim$Http$Legacy$toTask(
								A2(
									$author$project$Article$fetch,
									$author$project$Session$cred(session),
									slug)))),
						A2(
						$elm$core$Task$perform,
						function (_v0) {
							return $author$project$Page$Article$Editor$PassedSlowLoadThreshold;
						},
						$author$project$Loading$slowThreshold)
					])));
	});
var $author$project$Page$Article$Editor$EditingNew = F2(
	function (a, b) {
		return {$: 'EditingNew', a: a, b: b};
	});
var $author$project$Page$Article$Editor$initNew = function (session) {
	return _Utils_Tuple2(
		{
			session: session,
			status: A2(
				$author$project$Page$Article$Editor$EditingNew,
				_List_Nil,
				{body: '', description: '', tags: '', title: ''})
		},
		$elm$core$Platform$Cmd$none);
};
var $elm$core$Maybe$destruct = F3(
	function (_default, func, maybe) {
		if (maybe.$ === 'Just') {
			var a = maybe.a;
			return func(a);
		} else {
			return _default;
		}
	});
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $author$project$Api$storeCache = _Platform_outgoingPort(
	'storeCache',
	function ($) {
		return A3($elm$core$Maybe$destruct, $elm$json$Json$Encode$null, $elm$core$Basics$identity, $);
	});
var $author$project$Api$logout = $author$project$Api$storeCache($elm$core$Maybe$Nothing);
var $author$project$Session$navKey = function (session) {
	if (session.$ === 'LoggedIn') {
		var key = session.a;
		return key;
	} else {
		var key = session.a;
		return key;
	}
};
var $elm$browser$Browser$Navigation$replaceUrl = _Browser_replaceUrl;
var $author$project$Username$toString = function (_v0) {
	var username = _v0.a;
	return username;
};
var $author$project$Route$routeToString = function (page) {
	var pieces = function () {
		switch (page.$) {
			case 'Home':
				return _List_Nil;
			case 'Root':
				return _List_Nil;
			case 'Login':
				return _List_fromArray(
					['login']);
			case 'Logout':
				return _List_fromArray(
					['logout']);
			case 'Prices':
				return _List_fromArray(
					['prices']);
			case 'Register':
				return _List_fromArray(
					['register']);
			case 'Settings':
				return _List_fromArray(
					['settings']);
			case 'Article':
				var slug = page.a;
				return _List_fromArray(
					[
						'article',
						$author$project$Article$Slug$toString(slug)
					]);
			case 'Profile':
				var username = page.a;
				return _List_fromArray(
					[
						'profile',
						$author$project$Username$toString(username)
					]);
			case 'NewArticle':
				return _List_fromArray(
					['editor']);
			default:
				var slug = page.a;
				return _List_fromArray(
					[
						'editor',
						$author$project$Article$Slug$toString(slug)
					]);
		}
	}();
	return '#/' + A2($elm$core$String$join, '/', pieces);
};
var $author$project$Route$replaceUrl = F2(
	function (key, route) {
		return A2(
			$elm$browser$Browser$Navigation$replaceUrl,
			key,
			$author$project$Route$routeToString(route));
	});
var $author$project$Page$Article$toSession = function (model) {
	return model.session;
};
var $author$project$Page$Article$Editor$toSession = function (model) {
	return model.session;
};
var $author$project$Page$Home$toSession = function (model) {
	return model.session;
};
var $author$project$Page$Login$toSession = function (model) {
	return model.session;
};
var $author$project$Page$Prices$toSession = function (model) {
	return model.session;
};
var $author$project$Page$Profile$toSession = function (model) {
	return model.session;
};
var $author$project$Page$Register$toSession = function (model) {
	return model.session;
};
var $author$project$Page$Settings$toSession = function (model) {
	return model.session;
};
var $author$project$Main$toSession = function (page) {
	switch (page.$) {
		case 'Redirect':
			var session = page.a;
			return session;
		case 'NotFound':
			var session = page.a;
			return session;
		case 'Home':
			var home = page.a;
			return $author$project$Page$Home$toSession(home);
		case 'Settings':
			var settings = page.a;
			return $author$project$Page$Settings$toSession(settings);
		case 'Prices':
			var prices = page.a;
			return $author$project$Page$Prices$toSession(prices);
		case 'Login':
			var login = page.a;
			return $author$project$Page$Login$toSession(login);
		case 'Register':
			var register = page.a;
			return $author$project$Page$Register$toSession(register);
		case 'Profile':
			var profile = page.b;
			return $author$project$Page$Profile$toSession(profile);
		case 'Article':
			var article = page.a;
			return $author$project$Page$Article$toSession(article);
		default:
			var editor = page.b;
			return $author$project$Page$Article$Editor$toSession(editor);
	}
};
var $author$project$Main$updateWith = F4(
	function (toModel, toMsg, model, _v0) {
		var subModel = _v0.a;
		var subCmd = _v0.b;
		return _Utils_Tuple2(
			toModel(subModel),
			A2($elm$core$Platform$Cmd$map, toMsg, subCmd));
	});
var $author$project$Main$changeRouteTo = F2(
	function (maybeRoute, model) {
		var session = $author$project$Main$toSession(model);
		if (maybeRoute.$ === 'Nothing') {
			return _Utils_Tuple2(
				$author$project$Main$NotFound(session),
				$elm$core$Platform$Cmd$none);
		} else {
			switch (maybeRoute.a.$) {
				case 'Root':
					var _v1 = maybeRoute.a;
					return _Utils_Tuple2(
						model,
						A2(
							$author$project$Route$replaceUrl,
							$author$project$Session$navKey(session),
							$author$project$Route$Home));
				case 'Logout':
					var _v2 = maybeRoute.a;
					return _Utils_Tuple2(model, $author$project$Api$logout);
				case 'NewArticle':
					var _v3 = maybeRoute.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Editor($elm$core$Maybe$Nothing),
						$author$project$Main$GotEditorMsg,
						model,
						$author$project$Page$Article$Editor$initNew(session));
				case 'EditArticle':
					var slug = maybeRoute.a.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Editor(
							$elm$core$Maybe$Just(slug)),
						$author$project$Main$GotEditorMsg,
						model,
						A2($author$project$Page$Article$Editor$initEdit, session, slug));
				case 'Settings':
					var _v4 = maybeRoute.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Settings,
						$author$project$Main$GotSettingsMsg,
						model,
						$author$project$Page$Settings$init(session));
				case 'Home':
					var _v5 = maybeRoute.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Home,
						$author$project$Main$GotHomeMsg,
						model,
						$author$project$Page$Home$init(session));
				case 'Login':
					var _v6 = maybeRoute.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Login,
						$author$project$Main$GotLoginMsg,
						model,
						$author$project$Page$Login$init(session));
				case 'Register':
					var _v7 = maybeRoute.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Register,
						$author$project$Main$GotRegisterMsg,
						model,
						$author$project$Page$Register$init(session));
				case 'Prices':
					var _v8 = maybeRoute.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Prices,
						$author$project$Main$GotPricesMsg,
						model,
						$author$project$Page$Prices$init(session));
				case 'Profile':
					var username = maybeRoute.a.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Profile(username),
						$author$project$Main$GotProfileMsg,
						model,
						A2($author$project$Page$Profile$init, session, username));
				default:
					var slug = maybeRoute.a.a;
					return A4(
						$author$project$Main$updateWith,
						$author$project$Main$Article,
						$author$project$Main$GotArticleMsg,
						model,
						A2($author$project$Page$Article$init, session, slug));
			}
		}
	});
var $elm$url$Url$Parser$State = F5(
	function (visited, unvisited, params, frag, value) {
		return {frag: frag, params: params, unvisited: unvisited, value: value, visited: visited};
	});
var $elm$url$Url$Parser$getFirstMatch = function (states) {
	getFirstMatch:
	while (true) {
		if (!states.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			var state = states.a;
			var rest = states.b;
			var _v1 = state.unvisited;
			if (!_v1.b) {
				return $elm$core$Maybe$Just(state.value);
			} else {
				if ((_v1.a === '') && (!_v1.b.b)) {
					return $elm$core$Maybe$Just(state.value);
				} else {
					var $temp$states = rest;
					states = $temp$states;
					continue getFirstMatch;
				}
			}
		}
	}
};
var $elm$url$Url$Parser$removeFinalEmpty = function (segments) {
	if (!segments.b) {
		return _List_Nil;
	} else {
		if ((segments.a === '') && (!segments.b.b)) {
			return _List_Nil;
		} else {
			var segment = segments.a;
			var rest = segments.b;
			return A2(
				$elm$core$List$cons,
				segment,
				$elm$url$Url$Parser$removeFinalEmpty(rest));
		}
	}
};
var $elm$url$Url$Parser$preparePath = function (path) {
	var _v0 = A2($elm$core$String$split, '/', path);
	if (_v0.b && (_v0.a === '')) {
		var segments = _v0.b;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	} else {
		var segments = _v0;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	}
};
var $elm$url$Url$Parser$addToParametersHelp = F2(
	function (value, maybeList) {
		if (maybeList.$ === 'Nothing') {
			return $elm$core$Maybe$Just(
				_List_fromArray(
					[value]));
		} else {
			var list = maybeList.a;
			return $elm$core$Maybe$Just(
				A2($elm$core$List$cons, value, list));
		}
	});
var $elm$url$Url$percentDecode = _Url_percentDecode;
var $elm$url$Url$Parser$addParam = F2(
	function (segment, dict) {
		var _v0 = A2($elm$core$String$split, '=', segment);
		if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
			var rawKey = _v0.a;
			var _v1 = _v0.b;
			var rawValue = _v1.a;
			var _v2 = $elm$url$Url$percentDecode(rawKey);
			if (_v2.$ === 'Nothing') {
				return dict;
			} else {
				var key = _v2.a;
				var _v3 = $elm$url$Url$percentDecode(rawValue);
				if (_v3.$ === 'Nothing') {
					return dict;
				} else {
					var value = _v3.a;
					return A3(
						$elm$core$Dict$update,
						key,
						$elm$url$Url$Parser$addToParametersHelp(value),
						dict);
				}
			}
		} else {
			return dict;
		}
	});
var $elm$url$Url$Parser$prepareQuery = function (maybeQuery) {
	if (maybeQuery.$ === 'Nothing') {
		return $elm$core$Dict$empty;
	} else {
		var qry = maybeQuery.a;
		return A3(
			$elm$core$List$foldr,
			$elm$url$Url$Parser$addParam,
			$elm$core$Dict$empty,
			A2($elm$core$String$split, '&', qry));
	}
};
var $elm$url$Url$Parser$parse = F2(
	function (_v0, url) {
		var parser = _v0.a;
		return $elm$url$Url$Parser$getFirstMatch(
			parser(
				A5(
					$elm$url$Url$Parser$State,
					_List_Nil,
					$elm$url$Url$Parser$preparePath(url.path),
					$elm$url$Url$Parser$prepareQuery(url.query),
					url.fragment,
					$elm$core$Basics$identity)));
	});
var $author$project$Route$Article = function (a) {
	return {$: 'Article', a: a};
};
var $author$project$Route$EditArticle = function (a) {
	return {$: 'EditArticle', a: a};
};
var $author$project$Route$Login = {$: 'Login'};
var $author$project$Route$Logout = {$: 'Logout'};
var $author$project$Route$NewArticle = {$: 'NewArticle'};
var $author$project$Route$Prices = {$: 'Prices'};
var $author$project$Route$Profile = function (a) {
	return {$: 'Profile', a: a};
};
var $author$project$Route$Register = {$: 'Register'};
var $author$project$Route$Settings = {$: 'Settings'};
var $elm$url$Url$Parser$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var $elm$url$Url$Parser$mapState = F2(
	function (func, _v0) {
		var visited = _v0.visited;
		var unvisited = _v0.unvisited;
		var params = _v0.params;
		var frag = _v0.frag;
		var value = _v0.value;
		return A5(
			$elm$url$Url$Parser$State,
			visited,
			unvisited,
			params,
			frag,
			func(value));
	});
var $elm$url$Url$Parser$map = F2(
	function (subValue, _v0) {
		var parseArg = _v0.a;
		return $elm$url$Url$Parser$Parser(
			function (_v1) {
				var visited = _v1.visited;
				var unvisited = _v1.unvisited;
				var params = _v1.params;
				var frag = _v1.frag;
				var value = _v1.value;
				return A2(
					$elm$core$List$map,
					$elm$url$Url$Parser$mapState(value),
					parseArg(
						A5($elm$url$Url$Parser$State, visited, unvisited, params, frag, subValue)));
			});
	});
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $elm$url$Url$Parser$oneOf = function (parsers) {
	return $elm$url$Url$Parser$Parser(
		function (state) {
			return A2(
				$elm$core$List$concatMap,
				function (_v0) {
					var parser = _v0.a;
					return parser(state);
				},
				parsers);
		});
};
var $elm$url$Url$Parser$s = function (str) {
	return $elm$url$Url$Parser$Parser(
		function (_v0) {
			var visited = _v0.visited;
			var unvisited = _v0.unvisited;
			var params = _v0.params;
			var frag = _v0.frag;
			var value = _v0.value;
			if (!unvisited.b) {
				return _List_Nil;
			} else {
				var next = unvisited.a;
				var rest = unvisited.b;
				return _Utils_eq(next, str) ? _List_fromArray(
					[
						A5(
						$elm$url$Url$Parser$State,
						A2($elm$core$List$cons, next, visited),
						rest,
						params,
						frag,
						value)
					]) : _List_Nil;
			}
		});
};
var $elm$url$Url$Parser$slash = F2(
	function (_v0, _v1) {
		var parseBefore = _v0.a;
		var parseAfter = _v1.a;
		return $elm$url$Url$Parser$Parser(
			function (state) {
				return A2(
					$elm$core$List$concatMap,
					parseAfter,
					parseBefore(state));
			});
	});
var $elm$url$Url$Parser$top = $elm$url$Url$Parser$Parser(
	function (state) {
		return _List_fromArray(
			[state]);
	});
var $elm$url$Url$Parser$custom = F2(
	function (tipe, stringToSomething) {
		return $elm$url$Url$Parser$Parser(
			function (_v0) {
				var visited = _v0.visited;
				var unvisited = _v0.unvisited;
				var params = _v0.params;
				var frag = _v0.frag;
				var value = _v0.value;
				if (!unvisited.b) {
					return _List_Nil;
				} else {
					var next = unvisited.a;
					var rest = unvisited.b;
					var _v2 = stringToSomething(next);
					if (_v2.$ === 'Just') {
						var nextValue = _v2.a;
						return _List_fromArray(
							[
								A5(
								$elm$url$Url$Parser$State,
								A2($elm$core$List$cons, next, visited),
								rest,
								params,
								frag,
								value(nextValue))
							]);
					} else {
						return _List_Nil;
					}
				}
			});
	});
var $author$project$Article$Slug$urlParser = A2(
	$elm$url$Url$Parser$custom,
	'SLUG',
	function (str) {
		return $elm$core$Maybe$Just(
			$author$project$Article$Slug$Slug(str));
	});
var $author$project$Username$urlParser = A2(
	$elm$url$Url$Parser$custom,
	'USERNAME',
	function (str) {
		return $elm$core$Maybe$Just(
			$author$project$Username$Username(str));
	});
var $author$project$Route$parser = $elm$url$Url$Parser$oneOf(
	_List_fromArray(
		[
			A2($elm$url$Url$Parser$map, $author$project$Route$Home, $elm$url$Url$Parser$top),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$Prices,
			$elm$url$Url$Parser$s('prices')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$Login,
			$elm$url$Url$Parser$s('login')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$Logout,
			$elm$url$Url$Parser$s('logout')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$Settings,
			$elm$url$Url$Parser$s('settings')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$Profile,
			A2(
				$elm$url$Url$Parser$slash,
				$elm$url$Url$Parser$s('profile'),
				$author$project$Username$urlParser)),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$Register,
			$elm$url$Url$Parser$s('register')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$Article,
			A2(
				$elm$url$Url$Parser$slash,
				$elm$url$Url$Parser$s('article'),
				$author$project$Article$Slug$urlParser)),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$NewArticle,
			$elm$url$Url$Parser$s('editor')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Route$EditArticle,
			A2(
				$elm$url$Url$Parser$slash,
				$elm$url$Url$Parser$s('editor'),
				$author$project$Article$Slug$urlParser))
		]));
var $author$project$Route$fromUrl = function (url) {
	return A2(
		$elm$url$Url$Parser$parse,
		$author$project$Route$parser,
		_Utils_update(
			url,
			{
				fragment: $elm$core$Maybe$Nothing,
				path: A2($elm$core$Maybe$withDefault, '', url.fragment)
			}));
};
var $author$project$Session$Guest = function (a) {
	return {$: 'Guest', a: a};
};
var $author$project$Session$LoggedIn = F2(
	function (a, b) {
		return {$: 'LoggedIn', a: a, b: b};
	});
var $author$project$Session$fromViewer = F2(
	function (key, maybeViewer) {
		if (maybeViewer.$ === 'Just') {
			var viewerVal = maybeViewer.a;
			return A2($author$project$Session$LoggedIn, key, viewerVal);
		} else {
			return $author$project$Session$Guest(key);
		}
	});
var $author$project$Main$init = F3(
	function (maybeViewer, url, navKey) {
		return A2(
			$author$project$Main$changeRouteTo,
			$author$project$Route$fromUrl(url),
			$author$project$Main$Redirect(
				A2($author$project$Session$fromViewer, navKey, maybeViewer)));
	});
var $author$project$Main$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $elm$core$Debug$log = _Debug_log;
var $elm$core$Debug$toString = _Debug_toString;
var $author$project$Api$decodeFromChange = F2(
	function (viewerDecoder, val) {
		var result = A2(
			$elm$json$Json$Decode$decodeValue,
			$author$project$Api$storageDecoder(viewerDecoder),
			val);
		var result2 = $elm$core$Result$toMaybe(result);
		var _v0 = A2(
			$elm$core$Debug$log,
			'decodeFromChange',
			$elm$core$Debug$toString(result));
		var _v1 = A2(
			$elm$core$Debug$log,
			'decodeFromChange2:',
			$elm$core$Debug$toString(result2));
		return result2;
	});
var $author$project$Api$onStoreChange = _Platform_incomingPort('onStoreChange', $elm$json$Json$Decode$value);
var $author$project$Api$viewerChanges = F2(
	function (toMsg, decoder) {
		return $author$project$Api$onStoreChange(
			function (value) {
				return toMsg(
					A2($author$project$Api$decodeFromChange, decoder, value));
			});
	});
var $author$project$Session$changes = F2(
	function (toMsg, key) {
		return A2(
			$author$project$Api$viewerChanges,
			function (maybeViewer) {
				return toMsg(
					A2($author$project$Session$fromViewer, key, maybeViewer));
			},
			$author$project$Viewer$decoder);
	});
var $elm$core$Platform$Sub$map = _Platform_map;
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $author$project$Page$Article$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $author$project$Page$Article$subscriptions = function (model) {
	return A2(
		$author$project$Session$changes,
		$author$project$Page$Article$GotSession,
		$author$project$Session$navKey(model.session));
};
var $author$project$Page$Article$Editor$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $author$project$Page$Article$Editor$subscriptions = function (model) {
	return A2(
		$author$project$Session$changes,
		$author$project$Page$Article$Editor$GotSession,
		$author$project$Session$navKey(model.session));
};
var $author$project$Page$Home$subscriptions = function (model) {
	return $elm$core$Platform$Sub$none;
};
var $author$project$Page$Login$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $author$project$Page$Login$subscriptions = function (model) {
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				A2(
				$author$project$Session$changes,
				$author$project$Page$Login$GotSession,
				$author$project$Session$navKey(model.session))
			]));
};
var $author$project$Page$Prices$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $author$project$Page$Prices$Receive = function (a) {
	return {$: 'Receive', a: a};
};
var $author$project$Page$Prices$receive = _Platform_incomingPort('receive', $elm$json$Json$Decode$value);
var $author$project$Page$Prices$subscriptions = function (model) {
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				A2(
				$author$project$Session$changes,
				$author$project$Page$Prices$GotSession,
				$author$project$Session$navKey(model.session)),
				$author$project$Page$Prices$receive($author$project$Page$Prices$Receive)
			]));
};
var $author$project$Page$Profile$GotFileSha = function (a) {
	return {$: 'GotFileSha', a: a};
};
var $author$project$Page$Profile$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $author$project$Page$Profile$fileSha = _Platform_incomingPort('fileSha', $elm$json$Json$Decode$string);
var $author$project$Page$Profile$subscriptions = function (model) {
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				A2(
				$author$project$Session$changes,
				$author$project$Page$Profile$GotSession,
				$author$project$Session$navKey(model.session)),
				$author$project$Page$Profile$fileSha($author$project$Page$Profile$GotFileSha)
			]));
};
var $author$project$Page$Register$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $author$project$Page$Register$subscriptions = function (model) {
	return A2(
		$author$project$Session$changes,
		$author$project$Page$Register$GotSession,
		$author$project$Session$navKey(model.session));
};
var $author$project$Page$Settings$GotSession = function (a) {
	return {$: 'GotSession', a: a};
};
var $author$project$Page$Settings$subscriptions = function (model) {
	return A2(
		$author$project$Session$changes,
		$author$project$Page$Settings$GotSession,
		$author$project$Session$navKey(model.session));
};
var $author$project$Main$subscriptions = function (model) {
	switch (model.$) {
		case 'NotFound':
			return $elm$core$Platform$Sub$none;
		case 'Redirect':
			return A2(
				$author$project$Session$changes,
				$author$project$Main$GotSession,
				$author$project$Session$navKey(
					$author$project$Main$toSession(model)));
		case 'Settings':
			var settings = model.a;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotSettingsMsg,
				$author$project$Page$Settings$subscriptions(settings));
		case 'Home':
			var home = model.a;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotHomeMsg,
				$author$project$Page$Home$subscriptions(home));
		case 'Login':
			var login = model.a;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotLoginMsg,
				$author$project$Page$Login$subscriptions(login));
		case 'Register':
			var register = model.a;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotRegisterMsg,
				$author$project$Page$Register$subscriptions(register));
		case 'Profile':
			var profile = model.b;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotProfileMsg,
				$author$project$Page$Profile$subscriptions(profile));
		case 'Prices':
			var prices = model.a;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotPricesMsg,
				$author$project$Page$Prices$subscriptions(prices));
		case 'Article':
			var article = model.a;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotArticleMsg,
				$author$project$Page$Article$subscriptions(article));
		default:
			var editor = model.b;
			return A2(
				$elm$core$Platform$Sub$map,
				$author$project$Main$GotEditorMsg,
				$author$project$Page$Article$Editor$subscriptions(editor));
	}
};
var $elm$browser$Browser$Navigation$load = _Browser_load;
var $elm$browser$Browser$Navigation$pushUrl = _Browser_pushUrl;
var $elm$url$Url$addPort = F2(
	function (maybePort, starter) {
		if (maybePort.$ === 'Nothing') {
			return starter;
		} else {
			var port_ = maybePort.a;
			return starter + (':' + $elm$core$String$fromInt(port_));
		}
	});
var $elm$url$Url$addPrefixed = F3(
	function (prefix, maybeSegment, starter) {
		if (maybeSegment.$ === 'Nothing') {
			return starter;
		} else {
			var segment = maybeSegment.a;
			return _Utils_ap(
				starter,
				_Utils_ap(prefix, segment));
		}
	});
var $elm$url$Url$toString = function (url) {
	var http = function () {
		var _v0 = url.protocol;
		if (_v0.$ === 'Http') {
			return 'http://';
		} else {
			return 'https://';
		}
	}();
	return A3(
		$elm$url$Url$addPrefixed,
		'#',
		url.fragment,
		A3(
			$elm$url$Url$addPrefixed,
			'?',
			url.query,
			_Utils_ap(
				A2(
					$elm$url$Url$addPort,
					url.port_,
					_Utils_ap(http, url.host)),
				url.path)));
};
var $author$project$Page$Article$CompletedDeleteArticle = function (a) {
	return {$: 'CompletedDeleteArticle', a: a};
};
var $author$project$Page$Article$CompletedDeleteComment = F2(
	function (a, b) {
		return {$: 'CompletedDeleteComment', a: a, b: b};
	});
var $author$project$Page$Article$CompletedFollowChange = function (a) {
	return {$: 'CompletedFollowChange', a: a};
};
var $author$project$Page$Article$CompletedPostComment = function (a) {
	return {$: 'CompletedPostComment', a: a};
};
var $author$project$Page$Article$Editing = function (a) {
	return {$: 'Editing', a: a};
};
var $author$project$Page$Article$Failed = {$: 'Failed'};
var $author$project$Page$Article$Loaded = function (a) {
	return {$: 'Loaded', a: a};
};
var $author$project$Page$Article$LoadingSlowly = {$: 'LoadingSlowly'};
var $author$project$Page$Article$Sending = function (a) {
	return {$: 'Sending', a: a};
};
var $author$project$Api$addServerError = function (list) {
	return A2($elm$core$List$cons, 'Server error', list);
};
var $author$project$CommentId$toString = function (_v0) {
	var id = _v0.a;
	return $elm$core$String$fromInt(id);
};
var $author$project$Api$Endpoint$comment = F2(
	function (slug, commentId) {
		return A2(
			$author$project$Api$Endpoint$url,
			_List_fromArray(
				[
					'articles',
					$author$project$Article$Slug$toString(slug),
					'comments',
					$author$project$CommentId$toString(commentId)
				]),
			_List_Nil);
	});
var $author$project$Api$credHeader = function (_v0) {
	var str = _v0.b;
	return A2($elm$http$Http$header, 'authorization', 'Token ' + str);
};
var $author$project$Api$delete = F4(
	function (url, cred, body, decoder) {
		return $author$project$Api$Endpoint$request(
			{
				body: body,
				expect: $NoRedInk$http_upgrade_shim$Http$Legacy$expectJson(decoder),
				headers: _List_fromArray(
					[
						$author$project$Api$credHeader(cred)
					]),
				method: 'DELETE',
				timeout: $elm$core$Maybe$Nothing,
				url: url,
				withCredentials: false
			});
	});
var $author$project$Article$Comment$delete = F3(
	function (articleSlug, commentId, cred) {
		return A4(
			$author$project$Api$delete,
			A2($author$project$Api$Endpoint$comment, articleSlug, commentId),
			cred,
			$elm$http$Http$emptyBody,
			$elm$json$Json$Decode$succeed(_Utils_Tuple0));
	});
var $author$project$Page$Article$delete = F2(
	function (slug, cred) {
		return A4(
			$author$project$Api$delete,
			$author$project$Api$Endpoint$article(slug),
			cred,
			$NoRedInk$http_upgrade_shim$Http$Legacy$emptyBody,
			$elm$json$Json$Decode$succeed(_Utils_Tuple0));
	});
var $author$project$Log$error = $elm$core$Platform$Cmd$none;
var $author$project$Page$Article$CompletedFavoriteChange = function (a) {
	return {$: 'CompletedFavoriteChange', a: a};
};
var $author$project$Article$fromPreview = F2(
	function (newBody, _v0) {
		var info = _v0.a;
		var _v1 = _v0.b;
		return A2(
			$author$project$Article$Article,
			info,
			$author$project$Article$Full(newBody));
	});
var $author$project$Page$Article$fave = F4(
	function (toRequest, cred, slug, body) {
		return A2(
			$elm$core$Task$attempt,
			$author$project$Page$Article$CompletedFavoriteChange,
			A2(
				$elm$core$Task$map,
				$author$project$Article$fromPreview(body),
				$NoRedInk$http_upgrade_shim$Http$Legacy$toTask(
					A2(toRequest, slug, cred))));
	});
var $author$project$Article$Preview = {$: 'Preview'};
var $author$project$Article$previewDecoder = function (maybeCred) {
	return A2(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
		$author$project$Article$Preview,
		A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			$author$project$Article$internalsDecoder(maybeCred),
			$elm$json$Json$Decode$succeed($author$project$Article$Article)));
};
var $author$project$Article$faveDecoder = function (cred) {
	return A2(
		$elm$json$Json$Decode$field,
		'article',
		$author$project$Article$previewDecoder(
			$elm$core$Maybe$Just(cred)));
};
var $author$project$Api$Endpoint$favorite = function (slug) {
	return A2(
		$author$project$Api$Endpoint$url,
		_List_fromArray(
			[
				'articles',
				$author$project$Article$Slug$toString(slug),
				'favorite'
			]),
		_List_Nil);
};
var $author$project$Api$post = F4(
	function (url, maybeCred, body, decoder) {
		return $author$project$Api$Endpoint$request(
			{
				body: body,
				expect: $NoRedInk$http_upgrade_shim$Http$Legacy$expectJson(decoder),
				headers: function () {
					if (maybeCred.$ === 'Just') {
						var cred = maybeCred.a;
						return _List_fromArray(
							[
								$author$project$Api$credHeader(cred)
							]);
					} else {
						return _List_Nil;
					}
				}(),
				method: 'POST',
				timeout: $elm$core$Maybe$Nothing,
				url: url,
				withCredentials: false
			});
	});
var $author$project$Article$favorite = F2(
	function (articleSlug, cred) {
		return A4(
			$author$project$Api$post,
			$author$project$Api$Endpoint$favorite(articleSlug),
			$elm$core$Maybe$Just(cred),
			$elm$http$Http$emptyBody,
			$author$project$Article$faveDecoder(cred));
	});
var $author$project$Article$mapAuthor = F2(
	function (transform, _v0) {
		var info = _v0.a;
		var extras = _v0.b;
		return A2(
			$author$project$Article$Article,
			_Utils_update(
				info,
				{
					author: transform(info.author)
				}),
			extras);
	});
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Article$Comment$encodeCommentBody = function (str) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'comment',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'body',
							$elm$json$Json$Encode$string(str))
						])))
			]));
};
var $elm$http$Http$jsonBody = function (value) {
	return A2(
		_Http_pair,
		'application/json',
		A2($elm$json$Json$Encode$encode, 0, value));
};
var $author$project$Article$Comment$post = F3(
	function (articleSlug, commentBody, cred) {
		var bod = $elm$http$Http$jsonBody(
			$author$project$Article$Comment$encodeCommentBody(commentBody));
		return A4(
			$author$project$Api$post,
			$author$project$Api$Endpoint$comments(articleSlug),
			$elm$core$Maybe$Just(cred),
			bod,
			A2(
				$elm$json$Json$Decode$field,
				'comment',
				$author$project$Article$Comment$decoder(
					$elm$core$Maybe$Just(cred))));
	});
var $author$project$Api$Endpoint$follow = function (uname) {
	return A2(
		$author$project$Api$Endpoint$url,
		_List_fromArray(
			[
				'profiles',
				$author$project$Username$toString(uname),
				'follow'
			]),
		_List_Nil);
};
var $author$project$Author$followDecoder = function (cred) {
	return A2(
		$elm$json$Json$Decode$field,
		'profile',
		$author$project$Author$decoder(
			$elm$core$Maybe$Just(cred)));
};
var $author$project$Author$requestFollow = F2(
	function (_v0, cred) {
		var uname = _v0.a;
		return A4(
			$author$project$Api$post,
			$author$project$Api$Endpoint$follow(uname),
			$elm$core$Maybe$Just(cred),
			$elm$http$Http$emptyBody,
			$author$project$Author$followDecoder(cred));
	});
var $author$project$Author$requestUnfollow = F2(
	function (_v0, cred) {
		var uname = _v0.a;
		return A4(
			$author$project$Api$delete,
			$author$project$Api$Endpoint$follow(uname),
			cred,
			$elm$http$Http$emptyBody,
			$author$project$Author$followDecoder(cred));
	});
var $author$project$Article$unfavorite = F2(
	function (articleSlug, cred) {
		return A4(
			$author$project$Api$delete,
			$author$project$Api$Endpoint$favorite(articleSlug),
			cred,
			$elm$http$Http$emptyBody,
			$author$project$Article$faveDecoder(cred));
	});
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $author$project$Article$Comment$id = function (_v0) {
	var comment = _v0.a;
	return comment.id;
};
var $author$project$Page$Article$withoutComment = F2(
	function (id, list) {
		return A2(
			$elm$core$List$filter,
			function (comment) {
				return !_Utils_eq(
					$author$project$Article$Comment$id(comment),
					id);
			},
			list);
	});
var $author$project$Page$Article$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'ClickedDismissErrors':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{errors: _List_Nil}),
					$elm$core$Platform$Cmd$none);
			case 'ClickedFavorite':
				var cred = msg.a;
				var slug = msg.b;
				var body = msg.c;
				return _Utils_Tuple2(
					model,
					A4($author$project$Page$Article$fave, $author$project$Article$favorite, cred, slug, body));
			case 'ClickedUnfavorite':
				var cred = msg.a;
				var slug = msg.b;
				var body = msg.c;
				return _Utils_Tuple2(
					model,
					A4($author$project$Page$Article$fave, $author$project$Article$unfavorite, cred, slug, body));
			case 'CompletedLoadArticle':
				if (msg.a.$ === 'Ok') {
					var article = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								article: $author$project$Page$Article$Loaded(article)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{article: $author$project$Page$Article$Failed}),
						$author$project$Log$error);
				}
			case 'CompletedLoadComments':
				if (msg.a.$ === 'Ok') {
					var comments = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								comments: $author$project$Page$Article$Loaded(
									_Utils_Tuple2(
										$author$project$Page$Article$Editing(''),
										comments))
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{article: $author$project$Page$Article$Failed}),
						$author$project$Log$error);
				}
			case 'CompletedFavoriteChange':
				if (msg.a.$ === 'Ok') {
					var newArticle = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								article: $author$project$Page$Article$Loaded(newArticle)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								errors: $author$project$Api$addServerError(model.errors)
							}),
						$author$project$Log$error);
				}
			case 'ClickedUnfollow':
				var cred = msg.a;
				var followedAuthor = msg.b;
				return _Utils_Tuple2(
					model,
					A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$send,
						$author$project$Page$Article$CompletedFollowChange,
						A2($author$project$Author$requestUnfollow, followedAuthor, cred)));
			case 'ClickedFollow':
				var cred = msg.a;
				var unfollowedAuthor = msg.b;
				return _Utils_Tuple2(
					model,
					A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$send,
						$author$project$Page$Article$CompletedFollowChange,
						A2($author$project$Author$requestFollow, unfollowedAuthor, cred)));
			case 'CompletedFollowChange':
				if (msg.a.$ === 'Ok') {
					var newAuthor = msg.a.a;
					var _v1 = model.article;
					if (_v1.$ === 'Loaded') {
						var article = _v1.a;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									article: $author$project$Page$Article$Loaded(
										A2(
											$author$project$Article$mapAuthor,
											function (_v2) {
												return newAuthor;
											},
											article))
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						return _Utils_Tuple2(model, $author$project$Log$error);
					}
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								errors: $author$project$Api$addServerError(model.errors)
							}),
						$author$project$Log$error);
				}
			case 'EnteredCommentText':
				var str = msg.a;
				var _v3 = model.comments;
				if ((_v3.$ === 'Loaded') && (_v3.a.a.$ === 'Editing')) {
					var _v4 = _v3.a;
					var comments = _v4.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								comments: $author$project$Page$Article$Loaded(
									_Utils_Tuple2(
										$author$project$Page$Article$Editing(str),
										comments))
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $author$project$Log$error);
				}
			case 'ClickedPostComment':
				var cred = msg.a;
				var slug = msg.b;
				var _v5 = model.comments;
				if ((_v5.$ === 'Loaded') && (_v5.a.a.$ === 'Editing')) {
					if (_v5.a.a.a === '') {
						var _v6 = _v5.a;
						var comments = _v6.b;
						return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
					} else {
						var _v7 = _v5.a;
						var str = _v7.a.a;
						var comments = _v7.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									comments: $author$project$Page$Article$Loaded(
										_Utils_Tuple2(
											$author$project$Page$Article$Sending(str),
											comments))
								}),
							A2(
								$NoRedInk$http_upgrade_shim$Http$Legacy$send,
								$author$project$Page$Article$CompletedPostComment,
								A3($author$project$Article$Comment$post, slug, str, cred)));
					}
				} else {
					return _Utils_Tuple2(model, $author$project$Log$error);
				}
			case 'CompletedPostComment':
				if (msg.a.$ === 'Ok') {
					var comment = msg.a.a;
					var _v8 = model.comments;
					if (_v8.$ === 'Loaded') {
						var _v9 = _v8.a;
						var comments = _v9.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									comments: $author$project$Page$Article$Loaded(
										_Utils_Tuple2(
											$author$project$Page$Article$Editing(''),
											A2($elm$core$List$cons, comment, comments)))
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						return _Utils_Tuple2(model, $author$project$Log$error);
					}
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								errors: $author$project$Api$addServerError(model.errors)
							}),
						$author$project$Log$error);
				}
			case 'ClickedDeleteComment':
				var cred = msg.a;
				var slug = msg.b;
				var id = msg.c;
				return _Utils_Tuple2(
					model,
					A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$send,
						$author$project$Page$Article$CompletedDeleteComment(id),
						A3($author$project$Article$Comment$delete, slug, id, cred)));
			case 'CompletedDeleteComment':
				if (msg.b.$ === 'Ok') {
					var id = msg.a;
					var _v10 = model.comments;
					if (_v10.$ === 'Loaded') {
						var _v11 = _v10.a;
						var commentText = _v11.a;
						var comments = _v11.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									comments: $author$project$Page$Article$Loaded(
										_Utils_Tuple2(
											commentText,
											A2($author$project$Page$Article$withoutComment, id, comments)))
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						return _Utils_Tuple2(model, $author$project$Log$error);
					}
				} else {
					var id = msg.a;
					var error = msg.b.a;
					var _v12 = A2(
						$elm$core$Debug$log,
						'the Error: ',
						$elm$core$Debug$toString(error));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								errors: $author$project$Api$addServerError(model.errors)
							}),
						$author$project$Log$error);
				}
			case 'ClickedDeleteArticle':
				var cred = msg.a;
				var slug = msg.b;
				return _Utils_Tuple2(
					model,
					A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$send,
						$author$project$Page$Article$CompletedDeleteArticle,
						A2($author$project$Page$Article$delete, slug, cred)));
			case 'CompletedDeleteArticle':
				if (msg.a.$ === 'Ok') {
					return _Utils_Tuple2(
						model,
						A2(
							$author$project$Route$replaceUrl,
							$author$project$Session$navKey(model.session),
							$author$project$Route$Home));
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								errors: $author$project$Api$addServerError(model.errors)
							}),
						$author$project$Log$error);
				}
			case 'GotTimeZone':
				var tz = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{timeZone: tz}),
					$elm$core$Platform$Cmd$none);
			case 'GotSession':
				var session = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{session: session}),
					A2(
						$author$project$Route$replaceUrl,
						$author$project$Session$navKey(session),
						$author$project$Route$Home));
			default:
				var comments = function () {
					var _v14 = model.comments;
					if (_v14.$ === 'Loading') {
						return $author$project$Page$Article$LoadingSlowly;
					} else {
						var other = _v14;
						return other;
					}
				}();
				var article = function () {
					var _v13 = model.article;
					if (_v13.$ === 'Loading') {
						return $author$project$Page$Article$LoadingSlowly;
					} else {
						var other = _v13;
						return other;
					}
				}();
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{article: article, comments: comments}),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$Article$Editor$Editing = F3(
	function (a, b, c) {
		return {$: 'Editing', a: a, b: b, c: c};
	});
var $author$project$Page$Article$Editor$LoadingFailed = function (a) {
	return {$: 'LoadingFailed', a: a};
};
var $author$project$Page$Article$Editor$LoadingSlowly = function (a) {
	return {$: 'LoadingSlowly', a: a};
};
var $author$project$Article$body = function (_v0) {
	var extraInfo = _v0.b.a;
	return extraInfo;
};
var $elm$core$Tuple$mapFirst = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var $author$project$Article$metadata = function (_v0) {
	var internals = _v0.a;
	return internals.metadata;
};
var $author$project$Page$Article$Editor$CompletedCreate = function (a) {
	return {$: 'CompletedCreate', a: a};
};
var $author$project$Page$Article$Editor$CompletedEdit = function (a) {
	return {$: 'CompletedEdit', a: a};
};
var $author$project$Page$Article$Editor$Creating = function (a) {
	return {$: 'Creating', a: a};
};
var $author$project$Page$Article$Editor$Saving = F2(
	function (a, b) {
		return {$: 'Saving', a: a, b: b};
	});
var $author$project$Api$Endpoint$articles = function (params) {
	return A2(
		$author$project$Api$Endpoint$url,
		_List_fromArray(
			['articles']),
		params);
};
var $NoRedInk$http_upgrade_shim$Http$Legacy$jsonBody = $elm$http$Http$jsonBody;
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var $elm$core$String$trim = _String_trim;
var $author$project$Page$Article$Editor$tagsFromString = function (str) {
	return A2(
		$elm$core$List$filter,
		A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$String$isEmpty),
		A2(
			$elm$core$List$map,
			$elm$core$String$trim,
			A2($elm$core$String$split, ' ', str)));
};
var $author$project$Page$Article$Editor$create = F2(
	function (_v0, cred) {
		var form = _v0.a;
		var article = $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'title',
					$elm$json$Json$Encode$string(form.title)),
					_Utils_Tuple2(
					'description',
					$elm$json$Json$Encode$string(form.description)),
					_Utils_Tuple2(
					'body',
					$elm$json$Json$Encode$string(form.body)),
					_Utils_Tuple2(
					'tagList',
					A2(
						$elm$json$Json$Encode$list,
						$elm$json$Json$Encode$string,
						$author$project$Page$Article$Editor$tagsFromString(form.tags)))
				]));
		var body = $NoRedInk$http_upgrade_shim$Http$Legacy$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2('article', article)
					])));
		return A4(
			$author$project$Api$post,
			$author$project$Api$Endpoint$articles(_List_Nil),
			$elm$core$Maybe$Just(cred),
			body,
			A2(
				$elm$json$Json$Decode$field,
				'article',
				$author$project$Article$fullDecoder(
					$elm$core$Maybe$Just(cred))));
	});
var $author$project$Api$put = F4(
	function (url, cred, body, decoder) {
		return $author$project$Api$Endpoint$request(
			{
				body: body,
				expect: $NoRedInk$http_upgrade_shim$Http$Legacy$expectJson(decoder),
				headers: _List_fromArray(
					[
						$author$project$Api$credHeader(cred)
					]),
				method: 'PUT',
				timeout: $elm$core$Maybe$Nothing,
				url: url,
				withCredentials: false
			});
	});
var $author$project$Page$Article$Editor$edit = F3(
	function (articleSlug, _v0, cred) {
		var form = _v0.a;
		var article = $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'title',
					$elm$json$Json$Encode$string(form.title)),
					_Utils_Tuple2(
					'description',
					$elm$json$Json$Encode$string(form.description)),
					_Utils_Tuple2(
					'body',
					$elm$json$Json$Encode$string(form.body))
				]));
		var body = $NoRedInk$http_upgrade_shim$Http$Legacy$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2('article', article)
					])));
		return A4(
			$author$project$Api$put,
			$author$project$Api$Endpoint$article(articleSlug),
			cred,
			body,
			A2(
				$elm$json$Json$Decode$field,
				'article',
				$author$project$Article$fullDecoder(
					$elm$core$Maybe$Just(cred))));
	});
var $author$project$Page$Article$Editor$Body = {$: 'Body'};
var $author$project$Page$Article$Editor$Title = {$: 'Title'};
var $author$project$Page$Article$Editor$fieldsToValidate = _List_fromArray(
	[$author$project$Page$Article$Editor$Title, $author$project$Page$Article$Editor$Body]);
var $author$project$Page$Article$Editor$Trimmed = function (a) {
	return {$: 'Trimmed', a: a};
};
var $author$project$Page$Article$Editor$trimFields = function (form) {
	return $author$project$Page$Article$Editor$Trimmed(
		{
			body: $elm$core$String$trim(form.body),
			description: $elm$core$String$trim(form.description),
			tags: $elm$core$String$trim(form.tags),
			title: $elm$core$String$trim(form.title)
		});
};
var $author$project$Page$Article$Editor$InvalidEntry = F2(
	function (a, b) {
		return {$: 'InvalidEntry', a: a, b: b};
	});
var $author$project$Page$Article$Editor$validateField = F2(
	function (_v0, field) {
		var form = _v0.a;
		return A2(
			$elm$core$List$map,
			$author$project$Page$Article$Editor$InvalidEntry(field),
			function () {
				if (field.$ === 'Title') {
					return $elm$core$String$isEmpty(form.title) ? _List_fromArray(
						['title can\'t be blank.']) : _List_Nil;
				} else {
					return $elm$core$String$isEmpty(form.body) ? _List_fromArray(
						['body can\'t be blank.']) : _List_Nil;
				}
			}());
	});
var $author$project$Page$Article$Editor$validate = function (form) {
	var trimmedForm = $author$project$Page$Article$Editor$trimFields(form);
	var _v0 = A2(
		$elm$core$List$concatMap,
		$author$project$Page$Article$Editor$validateField(trimmedForm),
		$author$project$Page$Article$Editor$fieldsToValidate);
	if (!_v0.b) {
		return $elm$core$Result$Ok(trimmedForm);
	} else {
		var problems = _v0;
		return $elm$core$Result$Err(problems);
	}
};
var $author$project$Page$Article$Editor$save = F2(
	function (cred, status) {
		switch (status.$) {
			case 'Editing':
				var slug = status.a;
				var form = status.c;
				var _v1 = $author$project$Page$Article$Editor$validate(form);
				if (_v1.$ === 'Ok') {
					var validForm = _v1.a;
					return _Utils_Tuple2(
						A2($author$project$Page$Article$Editor$Saving, slug, form),
						A2(
							$NoRedInk$http_upgrade_shim$Http$Legacy$send,
							$author$project$Page$Article$Editor$CompletedEdit,
							A3($author$project$Page$Article$Editor$edit, slug, validForm, cred)));
				} else {
					var problems = _v1.a;
					return _Utils_Tuple2(
						A3($author$project$Page$Article$Editor$Editing, slug, problems, form),
						$elm$core$Platform$Cmd$none);
				}
			case 'EditingNew':
				var form = status.b;
				var _v2 = $author$project$Page$Article$Editor$validate(form);
				if (_v2.$ === 'Ok') {
					var validForm = _v2.a;
					return _Utils_Tuple2(
						$author$project$Page$Article$Editor$Creating(form),
						A2(
							$NoRedInk$http_upgrade_shim$Http$Legacy$send,
							$author$project$Page$Article$Editor$CompletedCreate,
							A2($author$project$Page$Article$Editor$create, validForm, cred)));
				} else {
					var problems = _v2.a;
					return _Utils_Tuple2(
						A2($author$project$Page$Article$Editor$EditingNew, problems, form),
						$elm$core$Platform$Cmd$none);
				}
			default:
				return _Utils_Tuple2(status, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$Article$Editor$ServerError = function (a) {
	return {$: 'ServerError', a: a};
};
var $author$project$Page$Article$Editor$savingError = F2(
	function (error, status) {
		var problems = _List_fromArray(
			[
				$author$project$Page$Article$Editor$ServerError('Error saving article')
			]);
		switch (status.$) {
			case 'Saving':
				var slug = status.a;
				var form = status.b;
				return A3($author$project$Page$Article$Editor$Editing, slug, problems, form);
			case 'Creating':
				var form = status.a;
				return A2($author$project$Page$Article$Editor$EditingNew, problems, form);
			default:
				return status;
		}
	});
var $author$project$Article$slug = function (_v0) {
	var internals = _v0.a;
	return internals.slug;
};
var $author$project$Article$Body$toMarkdownString = function (_v0) {
	var markdown = _v0.a;
	return markdown;
};
var $author$project$Page$Article$Editor$updateForm = F2(
	function (transform, model) {
		var newModel = function () {
			var _v0 = model.status;
			switch (_v0.$) {
				case 'Loading':
					return model;
				case 'LoadingSlowly':
					return model;
				case 'LoadingFailed':
					return model;
				case 'Saving':
					var slug = _v0.a;
					var form = _v0.b;
					return _Utils_update(
						model,
						{
							status: A2(
								$author$project$Page$Article$Editor$Saving,
								slug,
								transform(form))
						});
				case 'Editing':
					var slug = _v0.a;
					var errors = _v0.b;
					var form = _v0.c;
					return _Utils_update(
						model,
						{
							status: A3(
								$author$project$Page$Article$Editor$Editing,
								slug,
								errors,
								transform(form))
						});
				case 'EditingNew':
					var errors = _v0.a;
					var form = _v0.b;
					return _Utils_update(
						model,
						{
							status: A2(
								$author$project$Page$Article$Editor$EditingNew,
								errors,
								transform(form))
						});
				default:
					var form = _v0.a;
					return _Utils_update(
						model,
						{
							status: $author$project$Page$Article$Editor$Creating(
								transform(form))
						});
			}
		}();
		return _Utils_Tuple2(newModel, $elm$core$Platform$Cmd$none);
	});
var $author$project$Page$Article$Editor$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'ClickedSave':
				var cred = msg.a;
				return A2(
					$elm$core$Tuple$mapFirst,
					function (status) {
						return _Utils_update(
							model,
							{status: status});
					},
					A2($author$project$Page$Article$Editor$save, cred, model.status));
			case 'EnteredTitle':
				var title = msg.a;
				return A2(
					$author$project$Page$Article$Editor$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{title: title});
					},
					model);
			case 'EnteredDescription':
				var description = msg.a;
				return A2(
					$author$project$Page$Article$Editor$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{description: description});
					},
					model);
			case 'EnteredTags':
				var tags = msg.a;
				return A2(
					$author$project$Page$Article$Editor$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{tags: tags});
					},
					model);
			case 'EnteredBody':
				var body = msg.a;
				return A2(
					$author$project$Page$Article$Editor$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{body: body});
					},
					model);
			case 'CompletedCreate':
				if (msg.a.$ === 'Ok') {
					var article = msg.a.a;
					return _Utils_Tuple2(
						model,
						A2(
							$author$project$Route$replaceUrl,
							$author$project$Session$navKey(model.session),
							$author$project$Route$Article(
								$author$project$Article$slug(article))));
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								status: A2($author$project$Page$Article$Editor$savingError, error, model.status)
							}),
						$elm$core$Platform$Cmd$none);
				}
			case 'CompletedEdit':
				if (msg.a.$ === 'Ok') {
					var article = msg.a.a;
					return _Utils_Tuple2(
						model,
						A2(
							$author$project$Route$replaceUrl,
							$author$project$Session$navKey(model.session),
							$author$project$Route$Article(
								$author$project$Article$slug(article))));
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								status: A2($author$project$Page$Article$Editor$savingError, error, model.status)
							}),
						$elm$core$Platform$Cmd$none);
				}
			case 'CompletedArticleLoad':
				if (msg.a.$ === 'Err') {
					var _v1 = msg.a.a;
					var slug = _v1.a;
					var error = _v1.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								status: $author$project$Page$Article$Editor$LoadingFailed(slug)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var article = msg.a.a;
					var _v2 = $author$project$Article$metadata(article);
					var title = _v2.title;
					var description = _v2.description;
					var tags = _v2.tags;
					var status = A3(
						$author$project$Page$Article$Editor$Editing,
						$author$project$Article$slug(article),
						_List_Nil,
						{
							body: $author$project$Article$Body$toMarkdownString(
								$author$project$Article$body(article)),
							description: description,
							tags: A2($elm$core$String$join, ' ', tags),
							title: title
						});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{status: status}),
						$elm$core$Platform$Cmd$none);
				}
			case 'GotSession':
				var session = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{session: session}),
					A2(
						$author$project$Route$replaceUrl,
						$author$project$Session$navKey(session),
						$author$project$Route$Home));
			default:
				var status = function () {
					var _v3 = model.status;
					if (_v3.$ === 'Loading') {
						var slug = _v3.a;
						return $author$project$Page$Article$Editor$LoadingSlowly(slug);
					} else {
						var other = _v3;
						return other;
					}
				}();
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{status: status}),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$Home$ChangeFromNumb = function (a) {
	return {$: 'ChangeFromNumb', a: a};
};
var $elm$core$String$fromFloat = _String_fromNumber;
var $author$project$Page$Home$update = F2(
	function (msg, model) {
		update:
		while (true) {
			switch (msg.$) {
				case 'First':
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				case 'DropdownChangedFrom':
					var val = msg.a;
					var md = function () {
						if (val.$ === 'Just') {
							var theName = val.a;
							return _Utils_update(
								model,
								{pairName: theName + 'EUR', selectedDropdownValueFrom: val, toNumber: ''});
						} else {
							return model;
						}
					}();
					return _Utils_Tuple2(
						md,
						$author$project$Page$Home$updatePriceIfNeeded(md));
				case 'DropdownChangedTo':
					var val = msg.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{selectedDropdownValueTo: val}),
						$elm$core$Platform$Cmd$none);
				case 'ChangeText':
					var num = msg.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{textIndex: num}),
						$elm$core$Platform$Cmd$none);
				case 'GetMetaInfo':
					if (msg.a.$ === 'Ok') {
						var krakenResponse = msg.a.a;
						var model_new = _Utils_update(
							model,
							{
								priceInfo: A2($elm$core$Dict$get, model.pairName, krakenResponse.assetInfo)
							});
						var _v2 = A2(
							$elm$core$Debug$log,
							'The response',
							$elm$core$Debug$toString(krakenResponse));
						var $temp$msg = $author$project$Page$Home$ChangeFromNumb(model.fromNumber),
							$temp$model = model_new;
						msg = $temp$msg;
						model = $temp$model;
						continue update;
					} else {
						var error = msg.a.a;
						var _v3 = A2(
							$elm$core$Debug$log,
							'error when geting meta',
							$elm$core$Debug$toString(error));
						return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
					}
				case 'ChangeFromNumb':
					var val = msg.a;
					if ($elm$core$String$isEmpty(val)) {
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{fromNumber: val, toNumber: val}),
							$elm$core$Platform$Cmd$none);
					} else {
						var _v4 = $elm$core$String$toFloat(val);
						if (_v4.$ === 'Nothing') {
							var _v5 = A2($elm$core$Debug$log, 'st', 'stat');
							return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
						} else {
							var numb = _v4.a;
							var _v6 = model.priceInfo;
							if (_v6.$ === 'Nothing') {
								var _v7 = A2($elm$core$Debug$log, 'st', 'stat232323222323');
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{fromNumber: val}),
									$elm$core$Platform$Cmd$none);
							} else {
								var price = _v6.a;
								var _v8 = $elm$core$String$toFloat(price.a.price);
								if (_v8.$ === 'Just') {
									var number = _v8.a;
									var payPri = numb * number;
									var _v9 = A2(
										$elm$core$Debug$log,
										'the number',
										$elm$core$String$fromFloat(payPri));
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												fromNumber: val,
												toNumber: $elm$core$String$fromFloat(payPri)
											}),
										$elm$core$Platform$Cmd$none);
								} else {
									var _v10 = A2($elm$core$Debug$log, 'asdfasdf', 'nothing232232');
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{fromNumber: val}),
										$elm$core$Platform$Cmd$none);
								}
							}
						}
					}
				default:
					var val = msg.a;
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			}
		}
	});
var $author$project$Page$Login$CompletedLogin = function (a) {
	return {$: 'CompletedLogin', a: a};
};
var $author$project$Page$Login$ServerError = function (a) {
	return {$: 'ServerError', a: a};
};
var $author$project$Api$fromPair = function (_v0) {
	var field = _v0.a;
	var errors = _v0.b;
	return A2(
		$elm$core$List$map,
		function (error) {
			return field + (' ' + error);
		},
		errors);
};
var $author$project$Api$errorsDecoder = A2(
	$elm$json$Json$Decode$map,
	$elm$core$List$concatMap($author$project$Api$fromPair),
	$elm$json$Json$Decode$keyValuePairs(
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string)));
var $elm$core$Result$withDefault = F2(
	function (def, result) {
		if (result.$ === 'Ok') {
			var a = result.a;
			return a;
		} else {
			return def;
		}
	});
var $author$project$Api$decodeErrors = function (error) {
	if (error.$ === 'BadStatus') {
		var response = error.a;
		return A2(
			$elm$core$Result$withDefault,
			_List_fromArray(
				['Server error']),
			A2(
				$elm$json$Json$Decode$decodeString,
				A2($elm$json$Json$Decode$field, 'errors', $author$project$Api$errorsDecoder),
				response.body));
	} else {
		var err = error;
		return _List_fromArray(
			[
				$elm$core$Debug$toString(err)
			]);
	}
};
var $author$project$Api$Endpoint$url2 = F2(
	function (paths, queryParams) {
		return $author$project$Api$Endpoint$Endpoint(
			A3(
				$elm$url$Url$Builder$crossOrigin,
				'http://localhost/',
				A2($elm$core$List$cons, 'api/v1', paths),
				queryParams));
	});
var $author$project$Api$Endpoint$login = A2(
	$author$project$Api$Endpoint$url2,
	_List_fromArray(
		['users', 'login']),
	_List_Nil);
var $author$project$Api$login = F2(
	function (body, decoder) {
		return A4(
			$author$project$Api$post,
			$author$project$Api$Endpoint$login,
			$elm$core$Maybe$Nothing,
			body,
			A2(
				$elm$json$Json$Decode$field,
				'user',
				$author$project$Api$decoderFromCred(decoder)));
	});
var $author$project$Page$Login$login = function (_v0) {
	var form = _v0.a;
	var user = $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'email',
				$elm$json$Json$Encode$string(form.email)),
				_Utils_Tuple2(
				'password',
				$elm$json$Json$Encode$string(form.password))
			]));
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2('credential', user)
				])));
	return A2($author$project$Api$login, body, $author$project$Viewer$decoder);
};
var $author$project$Page$Login$renderCaptcha = _Platform_outgoingPort('renderCaptcha', $elm$core$Basics$identity);
var $author$project$Avatar$encode = function (_v0) {
	var maybeUrl = _v0.a;
	if (maybeUrl.$ === 'Just') {
		var url = maybeUrl.a;
		return $elm$json$Json$Encode$string(url);
	} else {
		return $elm$json$Json$Encode$null;
	}
};
var $author$project$Username$encode = function (_v0) {
	var username = _v0.a;
	return $elm$json$Json$Encode$string(username);
};
var $author$project$Api$storeCredWith = F2(
	function (_v0, avatar) {
		var uname = _v0.a;
		var token = _v0.b;
		var json = $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'user',
					$elm$json$Json$Encode$object(
						_List_fromArray(
							[
								_Utils_Tuple2(
								'username',
								$author$project$Username$encode(uname)),
								_Utils_Tuple2(
								'token',
								$elm$json$Json$Encode$string(token)),
								_Utils_Tuple2(
								'image',
								$author$project$Avatar$encode(avatar))
							])))
				]));
		return $author$project$Api$storeCache(
			$elm$core$Maybe$Just(json));
	});
var $author$project$Viewer$store = function (_v0) {
	var avatarVal = _v0.a;
	var credVal = _v0.b;
	var _v1 = A2($elm$core$Debug$log, 'storing', 'creds');
	return A2($author$project$Api$storeCredWith, credVal, avatarVal);
};
var $author$project$Page$Login$updateForm = F2(
	function (transform, model) {
		return _Utils_Tuple2(
			_Utils_update(
				model,
				{
					form: transform(model.form)
				}),
			$elm$core$Platform$Cmd$none);
	});
var $author$project$Page$Login$Email = {$: 'Email'};
var $author$project$Page$Login$Password = {$: 'Password'};
var $author$project$Page$Login$fieldsToValidate = _List_fromArray(
	[$author$project$Page$Login$Email, $author$project$Page$Login$Password]);
var $author$project$Page$Login$Trimmed = function (a) {
	return {$: 'Trimmed', a: a};
};
var $author$project$Page$Login$trimFields = function (form) {
	return $author$project$Page$Login$Trimmed(
		{
			email: $elm$core$String$trim(form.email),
			password: $elm$core$String$trim(form.password)
		});
};
var $author$project$Page$Login$InvalidEntry = F2(
	function (a, b) {
		return {$: 'InvalidEntry', a: a, b: b};
	});
var $author$project$Page$Login$validateField = F2(
	function (_v0, field) {
		var form = _v0.a;
		return A2(
			$elm$core$List$map,
			$author$project$Page$Login$InvalidEntry(field),
			function () {
				if (field.$ === 'Email') {
					return $elm$core$String$isEmpty(form.email) ? _List_fromArray(
						['email can\'t be blank.']) : _List_Nil;
				} else {
					return $elm$core$String$isEmpty(form.password) ? _List_fromArray(
						['password can\'t be blank.']) : _List_Nil;
				}
			}());
	});
var $author$project$Page$Login$validate = function (form) {
	var trimmedForm = $author$project$Page$Login$trimFields(form);
	var _v0 = A2(
		$elm$core$List$concatMap,
		$author$project$Page$Login$validateField(trimmedForm),
		$author$project$Page$Login$fieldsToValidate);
	if (!_v0.b) {
		return $elm$core$Result$Ok(trimmedForm);
	} else {
		var problems = _v0;
		return $elm$core$Result$Err(problems);
	}
};
var $author$project$Page$Login$update = F2(
	function (msg, model) {
		var _v0 = $elm$core$Debug$log(
			$elm$core$Debug$toString(msg));
		switch (msg.$) {
			case 'SubmittedForm':
				var _v2 = $author$project$Page$Login$validate(model.form);
				if (_v2.$ === 'Ok') {
					var validForm = _v2.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{problems: _List_Nil}),
						A2(
							$NoRedInk$http_upgrade_shim$Http$Legacy$send,
							$author$project$Page$Login$CompletedLogin,
							$author$project$Page$Login$login(validForm)));
				} else {
					var problems = _v2.a;
					var _v3 = $elm$core$Debug$log(
						$elm$core$Debug$toString(problems));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{problems: problems}),
						$elm$core$Platform$Cmd$none);
				}
			case 'EnteredEmail':
				var email = msg.a;
				return A2(
					$author$project$Page$Login$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{email: email});
					},
					model);
			case 'EnteredPassword':
				var password = msg.a;
				return A2(
					$author$project$Page$Login$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{password: password});
					},
					model);
			case 'CompletedLogin':
				if (msg.a.$ === 'Err') {
					var error = msg.a.a;
					var serverErrors = A2(
						$elm$core$List$map,
						$author$project$Page$Login$ServerError,
						$author$project$Api$decodeErrors(error));
					var _v4 = $elm$core$Debug$log('asfafads');
					var _v5 = $elm$core$Debug$log(
						$elm$core$Debug$toString(error));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								problems: A2($elm$core$List$append, model.problems, serverErrors)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var viewer = msg.a.a;
					var _v6 = A2($elm$core$Debug$log, 'loged in', 'I said');
					return _Utils_Tuple2(
						model,
						$author$project$Viewer$store(viewer));
				}
			case 'Ready':
				return _Utils_Tuple2(
					model,
					$author$project$Page$Login$renderCaptcha(
						$elm$json$Json$Encode$string('recaptcha')));
			case 'Sub':
				var _v7 = A2($elm$core$Debug$log, 'adfaf', 'adsa');
				return _Utils_Tuple2(
					model,
					$author$project$Page$Login$renderCaptcha(
						$elm$json$Json$Encode$string('recaptcha')));
			default:
				var session = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{session: session}),
					A2(
						$author$project$Route$replaceUrl,
						$author$project$Session$navKey(session),
						$author$project$Route$Home));
		}
	});
var $author$project$Page$Prices$Failed = {$: 'Failed'};
var $author$project$Page$Prices$GetMetaInfo = function (a) {
	return {$: 'GetMetaInfo', a: a};
};
var $author$project$Page$Prices$Loaded = function (a) {
	return {$: 'Loaded', a: a};
};
var $author$project$Page$Prices$LoadingSlowly = {$: 'LoadingSlowly'};
var $author$project$Page$Prices$TagFeed = function (a) {
	return {$: 'TagFeed', a: a};
};
var $author$project$Page$Prices$DataUpdate = F4(
	function (numb, metaInf, apiStr, pair) {
		return {apiStr: apiStr, metaInf: metaInf, numb: numb, pair: pair};
	});
var $author$project$Page$Prices$AssetMetaInfoUp = F9(
	function (a, b, c, v, p, t, l, h, o) {
		return {a: a, b: b, c: c, h: h, l: l, o: o, p: p, t: t, v: v};
	});
var $author$project$Page$Prices$AskArray = F3(
	function (price, wLotVol, lotVol) {
		return {lotVol: lotVol, price: price, wLotVol: wLotVol};
	});
var $author$project$Page$Prices$askArrayDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Page$Prices$AskArray,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Page$Prices$askArrayDecoderInt = A4(
	$elm$json$Json$Decode$map3,
	F3(
		function (a, b, c) {
			return A3(
				$author$project$Page$Prices$AskArray,
				a,
				$elm$core$String$fromInt(b),
				c);
		}),
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Page$Prices$bidArrayDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Page$Prices$AskArray,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Page$Prices$BidArray = F3(
	function (price, wLotVol, lotVol) {
		return {lotVol: lotVol, price: price, wLotVol: wLotVol};
	});
var $author$project$Page$Prices$bidArrayDecoderInt = A4(
	$elm$json$Json$Decode$map3,
	F3(
		function (a, b, c) {
			return A3(
				$author$project$Page$Prices$BidArray,
				a,
				$elm$core$String$fromInt(b),
				c);
		}),
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string));
var $author$project$Page$Prices$LastClosedTrade = F2(
	function (price, lotVol) {
		return {lotVol: lotVol, price: price};
	});
var $author$project$Page$Prices$lastClosedTradeDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Page$Prices$LastClosedTrade,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string));
var $author$project$Page$Prices$NumberOfTrades = F2(
	function (today, last24h) {
		return {last24h: last24h, today: today};
	});
var $author$project$Page$Prices$numberOfTradesDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Page$Prices$NumberOfTrades,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$int));
var $author$project$Page$Prices$OpenPrice = F2(
	function (last24h, today) {
		return {last24h: last24h, today: today};
	});
var $author$project$Page$Prices$openPriceDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Page$Prices$OpenPrice,
	A2(
		$elm$json$Json$Decode$index,
		0,
		$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string));
var $author$project$Page$Prices$openPriceDecoderSingl = A2(
	$elm$json$Json$Decode$map,
	$author$project$Page$Prices$OpenPrice($elm$core$Maybe$Nothing),
	$elm$json$Json$Decode$string);
var $author$project$Page$Prices$decoderAssetMetaInfoUp = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'o',
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[$author$project$Page$Prices$openPriceDecoder, $author$project$Page$Prices$openPriceDecoderSingl])),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'h',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'l',
			$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				't',
				$author$project$Page$Prices$numberOfTradesDecoder,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'p',
					$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'v',
						$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'c',
							$author$project$Page$Prices$lastClosedTradeDecoder,
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'b',
								$elm$json$Json$Decode$oneOf(
									_List_fromArray(
										[$author$project$Page$Prices$bidArrayDecoder, $author$project$Page$Prices$bidArrayDecoderInt])),
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'a',
									$elm$json$Json$Decode$oneOf(
										_List_fromArray(
											[$author$project$Page$Prices$askArrayDecoder, $author$project$Page$Prices$askArrayDecoderInt])),
									$elm$json$Json$Decode$succeed($author$project$Page$Prices$AssetMetaInfoUp))))))))));
var $elm$json$Json$Decode$map4 = _Json_map4;
var $author$project$Page$Prices$dataDecoder = A5(
	$elm$json$Json$Decode$map4,
	$author$project$Page$Prices$DataUpdate,
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$index, 1, $author$project$Page$Prices$decoderAssetMetaInfoUp),
	A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$index, 3, $elm$json$Json$Decode$string));
var $author$project$Page$Prices$assetsToNamesCsv = function (assetList) {
	var new_info = {alternate_name: 'ZECUSD'};
	var cnct = F2(
		function (original, pair) {
			var new_info_2 = {alternate_name: original.info.alternate_name + (',' + pair.info.alternate_name)};
			return {info: new_info_2};
		});
	var result = A3(
		$elm$core$List$foldr,
		cnct,
		{info: new_info},
		assetList);
	return result.info.alternate_name;
};
var $author$project$Page$Prices$KrakenMetaResponse = F2(
	function (errors, assetInfo) {
		return {assetInfo: assetInfo, errors: errors};
	});
var $author$project$Page$Prices$AssetMetaInfo = F9(
	function (a, b, c, v, p, t, l, h, o) {
		return {a: a, b: b, c: c, h: h, l: l, o: o, p: p, t: t, v: v};
	});
var $author$project$Page$Prices$decoderAssetMetaInfo = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'o',
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[$author$project$Page$Prices$openPriceDecoder, $author$project$Page$Prices$openPriceDecoderSingl])),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'h',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'l',
			$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				't',
				$author$project$Page$Prices$numberOfTradesDecoder,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'p',
					$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'v',
						$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'c',
							$author$project$Page$Prices$lastClosedTradeDecoder,
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'b',
								$elm$json$Json$Decode$oneOf(
									_List_fromArray(
										[$author$project$Page$Prices$bidArrayDecoder, $author$project$Page$Prices$bidArrayDecoderInt])),
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'a',
									$elm$json$Json$Decode$oneOf(
										_List_fromArray(
											[$author$project$Page$Prices$askArrayDecoder, $author$project$Page$Prices$askArrayDecoderInt])),
									$elm$json$Json$Decode$succeed($author$project$Page$Prices$AssetMetaInfo))))))))));
var $author$project$Page$Prices$decoderKrakenMeta = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'result',
	$elm$json$Json$Decode$dict($author$project$Page$Prices$decoderAssetMetaInfo),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'error',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
		$elm$json$Json$Decode$succeed($author$project$Page$Prices$KrakenMetaResponse)));
var $author$project$Page$Prices$fetchMetaInfo = function (assetPair) {
	var request = A3(
		$author$project$Api$get,
		$author$project$Api$Endpoint$kraken_meta_info(
			_List_fromArray(
				[
					A2(
					$elm$url$Url$Builder$string,
					'pair',
					$author$project$Page$Prices$assetsToNamesCsv(assetPair))
				])),
		$elm$core$Maybe$Nothing,
		$author$project$Page$Prices$decoderKrakenMeta);
	return $NoRedInk$http_upgrade_shim$Http$Legacy$toTask(request);
};
var $jschomay$elm_paginate$Paginate$Custom$Paginated = function (a) {
	return {$: 'Paginated', a: a};
};
var $jschomay$elm_bounded_number$Number$Bounded$Bounded = function (a) {
	return {$: 'Bounded', a: a};
};
var $elm$core$Basics$clamp = F3(
	function (low, high, number) {
		return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
	});
var $jschomay$elm_bounded_number$Number$Bounded$set = F2(
	function (n, _v0) {
		var min = _v0.a.min;
		var max = _v0.a.max;
		return $jschomay$elm_bounded_number$Number$Bounded$Bounded(
			{
				max: max,
				min: min,
				n: A3($elm$core$Basics$clamp, min, max, n)
			});
	});
var $jschomay$elm_paginate$Paginate$Custom$goTo = F2(
	function (i, _v0) {
		var p = _v0.a;
		return $jschomay$elm_paginate$Paginate$Custom$Paginated(
			_Utils_update(
				p,
				{
					currentPage_: A2($jschomay$elm_bounded_number$Number$Bounded$set, i, p.currentPage_)
				}));
	});
var $jschomay$elm_paginate$Paginate$Custom$first = function (paginatedList) {
	return A2($jschomay$elm_paginate$Paginate$Custom$goTo, 1, paginatedList);
};
var $jschomay$elm_paginate$Paginate$first = $jschomay$elm_paginate$Paginate$Custom$first;
var $jschomay$elm_bounded_number$Number$Bounded$between = F2(
	function (a, b) {
		return (_Utils_cmp(a, b) < 0) ? $jschomay$elm_bounded_number$Number$Bounded$Bounded(
			{max: b, min: a, n: a}) : $jschomay$elm_bounded_number$Number$Bounded$Bounded(
			{max: a, min: b, n: b});
	});
var $jschomay$elm_paginate$Paginate$Custom$init = F3(
	function (lengthFn, itemsPerPage_, items) {
		var max = (!lengthFn(items)) ? 1 : $elm$core$Basics$ceiling(
			lengthFn(items) / A2($elm$core$Basics$max, 1, itemsPerPage_));
		return $jschomay$elm_paginate$Paginate$Custom$Paginated(
			{
				currentPage_: A2($jschomay$elm_bounded_number$Number$Bounded$between, 1, max),
				items: items,
				itemsPerPage_: A2($elm$core$Basics$max, 1, itemsPerPage_)
			});
	});
var $jschomay$elm_paginate$Paginate$fromList = F2(
	function (a, b) {
		return A3($jschomay$elm_paginate$Paginate$Custom$init, $elm$core$List$length, a, b);
	});
var $jschomay$elm_paginate$Paginate$goTo = $jschomay$elm_paginate$Paginate$Custom$goTo;
var $jschomay$elm_bounded_number$Number$Bounded$maxBound = function (_v0) {
	var max = _v0.a.max;
	return max;
};
var $jschomay$elm_paginate$Paginate$Custom$totalPages = function (_v0) {
	var currentPage_ = _v0.a.currentPage_;
	return $jschomay$elm_bounded_number$Number$Bounded$maxBound(currentPage_);
};
var $jschomay$elm_paginate$Paginate$Custom$last = function (paginatedList) {
	return A2(
		$jschomay$elm_paginate$Paginate$Custom$goTo,
		$jschomay$elm_paginate$Paginate$Custom$totalPages(paginatedList),
		paginatedList);
};
var $jschomay$elm_paginate$Paginate$last = $jschomay$elm_paginate$Paginate$Custom$last;
var $elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2($elm$core$Dict$map, func, left),
				A2($elm$core$Dict$map, func, right));
		}
	});
var $elm$core$Dict$values = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Page$Prices$mapperOfAssets = function (dict) {
	var dict_trans = A2(
		$elm$core$Dict$map,
		F2(
			function (k, a) {
				return {info: a, name: k};
			}),
		dict);
	return $elm$core$Dict$values(dict_trans);
};
var $jschomay$elm_bounded_number$Number$Bounded$inc = F2(
	function (by, _v0) {
		var min = _v0.a.min;
		var max = _v0.a.max;
		var n = _v0.a.n;
		return $jschomay$elm_bounded_number$Number$Bounded$Bounded(
			{
				max: max,
				min: min,
				n: A3($elm$core$Basics$clamp, min, max, n + by)
			});
	});
var $jschomay$elm_paginate$Paginate$Custom$next = function (_v0) {
	var p = _v0.a;
	return $jschomay$elm_paginate$Paginate$Custom$Paginated(
		_Utils_update(
			p,
			{
				currentPage_: A2($jschomay$elm_bounded_number$Number$Bounded$inc, 1, p.currentPage_)
			}));
};
var $jschomay$elm_paginate$Paginate$next = $jschomay$elm_paginate$Paginate$Custom$next;
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $jschomay$elm_bounded_number$Number$Bounded$value = function (_v0) {
	var n = _v0.a.n;
	return n;
};
var $jschomay$elm_paginate$Paginate$Custom$page = F2(
	function (sliceFn, _v0) {
		var itemsPerPage_ = _v0.a.itemsPerPage_;
		var currentPage_ = _v0.a.currentPage_;
		var items = _v0.a.items;
		var from = ($jschomay$elm_bounded_number$Number$Bounded$value(currentPage_) - 1) * itemsPerPage_;
		var to = from + itemsPerPage_;
		return A3(sliceFn, from, to, items);
	});
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $jschomay$elm_paginate$Paginate$page = $jschomay$elm_paginate$Paginate$Custom$page(
	F2(
		function (from, to) {
			return A2(
				$elm$core$Basics$composeR,
				$elm$core$List$drop(from),
				$elm$core$List$take(to - from));
		}));
var $jschomay$elm_bounded_number$Number$Bounded$dec = F2(
	function (by, _v0) {
		var min = _v0.a.min;
		var max = _v0.a.max;
		var n = _v0.a.n;
		return $jschomay$elm_bounded_number$Number$Bounded$Bounded(
			{
				max: max,
				min: min,
				n: A3($elm$core$Basics$clamp, min, max, n - by)
			});
	});
var $jschomay$elm_paginate$Paginate$Custom$prev = function (_v0) {
	var p = _v0.a;
	return $jschomay$elm_paginate$Paginate$Custom$Paginated(
		_Utils_update(
			p,
			{
				currentPage_: A2($jschomay$elm_bounded_number$Number$Bounded$dec, 1, p.currentPage_)
			}));
};
var $jschomay$elm_paginate$Paginate$prev = $jschomay$elm_paginate$Paginate$Custom$prev;
var $elm$core$String$replace = F3(
	function (before, after, string) {
		return A2(
			$elm$core$String$join,
			after,
			A2($elm$core$String$split, before, string));
	});
var $elm$browser$Browser$Dom$setViewport = _Browser_setViewport;
var $author$project$Page$Prices$scrollToTop = A2(
	$elm$core$Task$onError,
	function (_v0) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	},
	A2($elm$browser$Browser$Dom$setViewport, 0, 0));
var $author$project$Page$Prices$RegisterTopic = F3(
	function (event, pair, subscription) {
		return {event: event, pair: pair, subscription: subscription};
	});
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$json$Json$Encode$dict = F3(
	function (toKey, toValue, dictionary) {
		return _Json_wrap(
			A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, value, obj) {
						return A3(
							_Json_addField,
							toKey(key),
							toValue(value),
							obj);
					}),
				_Json_emptyObject(_Utils_Tuple0),
				dictionary));
	});
var $author$project$Page$Prices$encode = function (reTo) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'event',
				$elm$json$Json$Encode$string(reTo.event)),
				_Utils_Tuple2(
				'pair',
				$elm$json$Json$Encode$list($elm$json$Json$Encode$string)(reTo.pair)),
				_Utils_Tuple2(
				'subscription',
				A3(
					$elm$json$Json$Encode$dict,
					function (top) {
						return top;
					},
					$elm$json$Json$Encode$string,
					reTo.subscription))
			]));
};
var $author$project$Page$Prices$send = _Platform_outgoingPort('send', $elm$core$Basics$identity);
var $author$project$Page$Prices$sendSubscribeMessage = function (assetPairs) {
	var string_pairs = A2(
		$elm$core$List$map,
		function (as_p) {
			return as_p.info.ws_name;
		},
		assetPairs);
	var dictS = $elm$core$Dict$fromList(
		_List_fromArray(
			[
				_Utils_Tuple2('name', 'ticker')
			]));
	var subs = A3($author$project$Page$Prices$RegisterTopic, 'subscribe', string_pairs, dictS);
	var json_subs = $author$project$Page$Prices$encode(subs);
	var command = $author$project$Page$Prices$send(json_subs);
	var _v0 = A2(
		$elm$core$Debug$log,
		'command',
		$elm$core$Debug$toString(command));
	return command;
};
var $elm$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var left = dict.d;
				var right = dict.e;
				var $temp$n = A2($elm$core$Dict$sizeHelp, n + 1, right),
					$temp$dict = left;
				n = $temp$n;
				dict = $temp$dict;
				continue sizeHelp;
			}
		}
	});
var $elm$core$Dict$size = function (dict) {
	return A2($elm$core$Dict$sizeHelp, 0, dict);
};
var $author$project$Page$Prices$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'Receive':
				var value = msg.a;
				var decodedMessage = A2($elm$json$Json$Decode$decodeValue, $author$project$Page$Prices$dataDecoder, value);
				if (decodedMessage.$ === 'Ok') {
					var data = decodedMessage.a;
					var _v2 = model.feedMeta;
					if (_v2.$ === 'Just') {
						var dictMeta = _v2.a;
						var data_alt_name = A3($elm$core$String$replace, '/', '', data.pair);
						var newFeedMeta = A3($elm$core$Dict$insert, data_alt_name, data.metaInf, dictMeta);
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									feedMeta: $elm$core$Maybe$Just(newFeedMeta)
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
					}
				} else {
					var error = decodedMessage.a;
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'ClickedTag':
				var tag = msg.a;
				var feedTab = $author$project$Page$Prices$TagFeed(tag);
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{feedTab: feedTab}),
					A2(
						$elm$core$Task$attempt,
						$author$project$Page$Prices$CompletedFeedLoad,
						A2($author$project$Page$Prices$fetchFeed, model.session, 1)));
			case 'ClickedTab':
				var tab = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{feedTab: tab}),
					A2(
						$elm$core$Task$attempt,
						$author$project$Page$Prices$CompletedFeedLoad,
						A2($author$project$Page$Prices$fetchFeed, model.session, 1)));
			case 'ClickedFeedPage':
				var page = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{feedPage: page}),
					A2(
						$elm$core$Task$attempt,
						$author$project$Page$Prices$CompletedFeedLoad,
						A2(
							$elm$core$Task$andThen,
							function (feed) {
								return A2(
									$elm$core$Task$map,
									function (_v3) {
										return feed;
									},
									$author$project$Page$Prices$scrollToTop);
							},
							A2($author$project$Page$Prices$fetchFeed, model.session, page))));
			case 'GetMetaInfo':
				if (msg.a.$ === 'Ok') {
					var krakenResponse = msg.a.a;
					var _v4 = model.feedPair;
					if (_v4.$ === 'Just') {
						var feedPairs = _v4.a;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									feedMeta: $elm$core$Maybe$Just(krakenResponse.assetInfo)
								}),
							$author$project$Page$Prices$sendSubscribeMessage(
								$jschomay$elm_paginate$Paginate$page(feedPairs.pairs)));
					} else {
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									feedMeta: $elm$core$Maybe$Just(krakenResponse.assetInfo)
								}),
							$elm$core$Platform$Cmd$none);
					}
				} else {
					var error = msg.a.a;
					var _v5 = A2(
						$elm$core$Debug$log,
						'error when geting meta',
						$elm$core$Debug$toString(error));
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'CompletedFeedLoad':
				if (msg.a.$ === 'Ok') {
					var feed = msg.a.a;
					var list = $author$project$Page$Prices$mapperOfAssets(feed.assetPairs);
					var pagination = {
						globalId: $elm$core$Dict$size(feed.assetPairs),
						pairs: A2($jschomay$elm_paginate$Paginate$fromList, 13, list),
						query: '',
						reversed: false
					};
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								feed: $author$project$Page$Prices$Loaded(feed),
								feedPair: $elm$core$Maybe$Just(pagination)
							}),
						$elm$core$Platform$Cmd$batch(
							_List_fromArray(
								[
									A2(
									$elm$core$Task$attempt,
									$author$project$Page$Prices$GetMetaInfo,
									$author$project$Page$Prices$fetchMetaInfo(
										$jschomay$elm_paginate$Paginate$page(pagination.pairs))),
									$author$project$Page$Prices$sendSubscribeMessage(
									$jschomay$elm_paginate$Paginate$page(pagination.pairs))
								])));
				} else {
					var error = msg.a.a;
					var _v6 = A2(
						$elm$core$Debug$log,
						'error in feed',
						$elm$core$Debug$toString(error));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{feed: $author$project$Page$Prices$Failed}),
						$elm$core$Platform$Cmd$none);
				}
			case 'CompletedTagsLoad':
				if (msg.a.$ === 'Ok') {
					var tags = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								tags: $author$project$Page$Prices$Loaded(tags)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var error = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{tags: $author$project$Page$Prices$Failed}),
						$author$project$Log$error);
				}
			case 'GotTimeZone':
				var tz = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{timeZone: tz}),
					$elm$core$Platform$Cmd$none);
			case 'GotSession':
				var session = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{session: session}),
					$elm$core$Platform$Cmd$none);
			case 'GoTo':
				var index = msg.a;
				var _v7 = model.feedPair;
				if (_v7.$ === 'Just') {
					var pgnation = _v7.a;
					var old_pagination = pgnation;
					var new_pagination = _Utils_update(
						old_pagination,
						{
							pairs: A2($jschomay$elm_paginate$Paginate$goTo, index, old_pagination.pairs)
						});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								feedPair: $elm$core$Maybe$Just(new_pagination)
							}),
						A2(
							$elm$core$Task$attempt,
							$author$project$Page$Prices$GetMetaInfo,
							$author$project$Page$Prices$fetchMetaInfo(
								$jschomay$elm_paginate$Paginate$page(new_pagination.pairs))));
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'Next':
				var _v8 = model.feedPair;
				if (_v8.$ === 'Just') {
					var pgnation = _v8.a;
					var old_pagination = pgnation;
					var new_pagination = _Utils_update(
						old_pagination,
						{
							pairs: $jschomay$elm_paginate$Paginate$next(old_pagination.pairs)
						});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								feedPair: $elm$core$Maybe$Just(new_pagination)
							}),
						A2(
							$elm$core$Task$attempt,
							$author$project$Page$Prices$GetMetaInfo,
							$author$project$Page$Prices$fetchMetaInfo(
								$jschomay$elm_paginate$Paginate$page(new_pagination.pairs))));
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'Prev':
				var _v9 = model.feedPair;
				if (_v9.$ === 'Just') {
					var pgnation = _v9.a;
					var old_pagination = pgnation;
					var new_pagination = _Utils_update(
						old_pagination,
						{
							pairs: $jschomay$elm_paginate$Paginate$prev(old_pagination.pairs)
						});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								feedPair: $elm$core$Maybe$Just(new_pagination)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'First':
				var _v10 = model.feedPair;
				if (_v10.$ === 'Just') {
					var pgnation = _v10.a;
					var old_pagination = pgnation;
					var new_pagination = _Utils_update(
						old_pagination,
						{
							pairs: $jschomay$elm_paginate$Paginate$first(old_pagination.pairs)
						});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								feedPair: $elm$core$Maybe$Just(new_pagination)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 'Last':
				var _v11 = model.feedPair;
				if (_v11.$ === 'Just') {
					var pgnation = _v11.a;
					var old_pagination = pgnation;
					var new_pagination = _Utils_update(
						old_pagination,
						{
							pairs: $jschomay$elm_paginate$Paginate$last(old_pagination.pairs)
						});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								feedPair: $elm$core$Maybe$Just(new_pagination)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			default:
				var tags = function () {
					var _v13 = model.tags;
					if (_v13.$ === 'Loading') {
						return $author$project$Page$Prices$LoadingSlowly;
					} else {
						var other = _v13;
						return other;
					}
				}();
				var feed = function () {
					var _v12 = model.feed;
					if (_v12.$ === 'Loading') {
						return $author$project$Page$Prices$LoadingSlowly;
					} else {
						var other = _v12;
						return other;
					}
				}();
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{feed: feed, tags: tags}),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$Profile$GotImageBytes = function (a) {
	return {$: 'GotImageBytes', a: a};
};
var $author$project$Page$Profile$GotUploadCreds = function (a) {
	return {$: 'GotUploadCreds', a: a};
};
var $author$project$Page$Profile$GotViewUrl = function (a) {
	return {$: 'GotViewUrl', a: a};
};
var $author$project$Page$Profile$LoadingSlowly = function (a) {
	return {$: 'LoadingSlowly', a: a};
};
var $author$project$Page$Profile$fileInput = _Platform_outgoingPort(
	'fileInput',
	function ($) {
		return $elm$json$Json$Encode$null;
	});
var $author$project$Page$Profile$UploadCreds = F4(
	function (auth_header, date, hash, path) {
		return {auth_header: auth_header, date: date, hash: hash, path: path};
	});
var $author$project$Page$Profile$decoderUploadCreds = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'path',
	$elm$json$Json$Decode$string,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'hash',
		$elm$json$Json$Decode$string,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'date',
			$elm$json$Json$Decode$string,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'auth_header',
				$elm$json$Json$Decode$string,
				$elm$json$Json$Decode$succeed($author$project$Page$Profile$UploadCreds)))));
var $author$project$Api$Endpoint$uploadImmageUrl = A2(
	$author$project$Api$Endpoint$url2,
	_List_fromArray(
		['users', 'immage']),
	_List_Nil);
var $author$project$Api$uploadImmageUrl = F2(
	function (body, decoder) {
		return A4($author$project$Api$post, $author$project$Api$Endpoint$uploadImmageUrl, $elm$core$Maybe$Nothing, body, decoder);
	});
var $author$project$Page$Profile$getUploadCreds = F2(
	function (path, file_hash) {
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'file_hash',
						$elm$json$Json$Encode$string(file_hash)),
						_Utils_Tuple2(
						'path',
						$elm$json$Json$Encode$string(path))
					])));
		return A2($author$project$Api$uploadImmageUrl, body, $author$project$Page$Profile$decoderUploadCreds);
	});
var $author$project$Page$Profile$ViewUrl = function (url) {
	return {url: url};
};
var $author$project$Page$Profile$decoderViewUrl = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'url',
	$elm$json$Json$Decode$string,
	$elm$json$Json$Decode$succeed($author$project$Page$Profile$ViewUrl));
var $author$project$Api$Endpoint$getViewUrl = A2(
	$author$project$Api$Endpoint$url2,
	_List_fromArray(
		['users', 'immage', 'view']),
	_List_Nil);
var $author$project$Api$getViewUrl = F2(
	function (body, decoder) {
		return A4($author$project$Api$post, $author$project$Api$Endpoint$getViewUrl, $elm$core$Maybe$Nothing, body, decoder);
	});
var $author$project$Page$Profile$getViewUrl = function (path) {
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'path',
					$elm$json$Json$Encode$string(path))
				])));
	return A2($author$project$Api$getViewUrl, body, $author$project$Page$Profile$decoderViewUrl);
};
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$file$File$name = _File_name;
var $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256 = {$: 'SHA256'};
var $ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars = F8(
	function (a, b, c, d, e, f, g, h) {
		return {a: a, b: b, c: c, d: d, e: e, f: f, g: g, h: h};
	});
var $ktonon$elm_word$Word$D = F2(
	function (a, b) {
		return {$: 'D', a: a, b: b};
	});
var $ktonon$elm_word$Word$Mismatch = {$: 'Mismatch'};
var $ktonon$elm_word$Word$W = function (a) {
	return {$: 'W', a: a};
};
var $elm$core$Bitwise$and = _Bitwise_and;
var $ktonon$elm_word$Word$low31mask = 2147483647;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $ktonon$elm_word$Word$carry32 = F2(
	function (x, y) {
		var _v0 = (x >>> 31) + (y >>> 31);
		switch (_v0) {
			case 0:
				return 0;
			case 2:
				return 1;
			default:
				return (1 === ((($ktonon$elm_word$Word$low31mask & x) + ($ktonon$elm_word$Word$low31mask & y)) >>> 31)) ? 1 : 0;
		}
	});
var $elm$core$Basics$pow = _Basics_pow;
var $ktonon$elm_word$Word$mod32 = function (val) {
	return A2(
		$elm$core$Basics$modBy,
		A2($elm$core$Basics$pow, 2, 32),
		val);
};
var $ktonon$elm_word$Word$add = F2(
	function (wx, wy) {
		var _v0 = _Utils_Tuple2(wx, wy);
		_v0$2:
		while (true) {
			switch (_v0.a.$) {
				case 'W':
					if (_v0.b.$ === 'W') {
						var x = _v0.a.a;
						var y = _v0.b.a;
						return $ktonon$elm_word$Word$W(
							$ktonon$elm_word$Word$mod32(x + y));
					} else {
						break _v0$2;
					}
				case 'D':
					if (_v0.b.$ === 'D') {
						var _v1 = _v0.a;
						var xh = _v1.a;
						var xl = _v1.b;
						var _v2 = _v0.b;
						var yh = _v2.a;
						var yl = _v2.b;
						var zl = xl + yl;
						var zh = (xh + yh) + A2($ktonon$elm_word$Word$carry32, xl, yl);
						return A2(
							$ktonon$elm_word$Word$D,
							$ktonon$elm_word$Word$mod32(zh),
							$ktonon$elm_word$Word$mod32(zl));
					} else {
						break _v0$2;
					}
				default:
					break _v0$2;
			}
		}
		return $ktonon$elm_word$Word$Mismatch;
	});
var $ktonon$elm_crypto$Crypto$SHA$Types$addWorkingVars = F2(
	function (x, y) {
		return A8(
			$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
			A2($ktonon$elm_word$Word$add, x.a, y.a),
			A2($ktonon$elm_word$Word$add, x.b, y.b),
			A2($ktonon$elm_word$Word$add, x.c, y.c),
			A2($ktonon$elm_word$Word$add, x.d, y.d),
			A2($ktonon$elm_word$Word$add, x.e, y.e),
			A2($ktonon$elm_word$Word$add, x.f, y.f),
			A2($ktonon$elm_word$Word$add, x.g, y.g),
			A2($ktonon$elm_word$Word$add, x.h, y.h));
	});
var $ktonon$elm_word$Word$and = F2(
	function (wx, wy) {
		var _v0 = _Utils_Tuple2(wx, wy);
		_v0$2:
		while (true) {
			switch (_v0.a.$) {
				case 'W':
					if (_v0.b.$ === 'W') {
						var x = _v0.a.a;
						var y = _v0.b.a;
						return $ktonon$elm_word$Word$W(x & y);
					} else {
						break _v0$2;
					}
				case 'D':
					if (_v0.b.$ === 'D') {
						var _v1 = _v0.a;
						var xh = _v1.a;
						var xl = _v1.b;
						var _v2 = _v0.b;
						var yh = _v2.a;
						var yl = _v2.b;
						return A2($ktonon$elm_word$Word$D, xh & yh, xl & yl);
					} else {
						break _v0$2;
					}
				default:
					break _v0$2;
			}
		}
		return $ktonon$elm_word$Word$Mismatch;
	});
var $elm$core$Bitwise$complement = _Bitwise_complement;
var $ktonon$elm_word$Word$complement = function (word) {
	switch (word.$) {
		case 'W':
			var x = word.a;
			return $ktonon$elm_word$Word$W(~x);
		case 'D':
			var xh = word.a;
			var xl = word.b;
			return A2($ktonon$elm_word$Word$D, ~xh, ~xl);
		default:
			return $ktonon$elm_word$Word$Mismatch;
	}
};
var $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512 = {$: 'SHA512'};
var $ktonon$elm_word$Word$Helpers$lowMask = function (n) {
	switch (n) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 3;
		case 3:
			return 7;
		case 4:
			return 15;
		case 5:
			return 31;
		case 6:
			return 63;
		case 7:
			return 127;
		case 8:
			return 255;
		case 9:
			return 511;
		case 10:
			return 1023;
		case 11:
			return 2047;
		case 12:
			return 4095;
		case 13:
			return 8191;
		case 14:
			return 16383;
		case 15:
			return 32767;
		case 16:
			return 65535;
		case 17:
			return 131071;
		case 18:
			return 262143;
		case 19:
			return 524287;
		case 20:
			return 1048575;
		case 21:
			return 2097151;
		case 22:
			return 4194303;
		case 23:
			return 8388607;
		case 24:
			return 16777215;
		case 25:
			return 33554431;
		case 26:
			return 67108863;
		case 27:
			return 134217727;
		case 28:
			return 268435455;
		case 29:
			return 536870911;
		case 30:
			return 1073741823;
		case 31:
			return 2147483647;
		default:
			return 4294967295;
	}
};
var $elm$core$Basics$ge = _Utils_ge;
var $ktonon$elm_word$Word$Helpers$safeShiftRightZfBy = F2(
	function (n, val) {
		return (n >= 32) ? 0 : (val >>> n);
	});
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $ktonon$elm_word$Word$dShiftRightZfBy = F2(
	function (n, _v0) {
		var xh = _v0.a;
		var xl = _v0.b;
		return (n > 32) ? _Utils_Tuple2(
			0,
			A2($ktonon$elm_word$Word$Helpers$safeShiftRightZfBy, n - 32, xh)) : _Utils_Tuple2(
			A2($ktonon$elm_word$Word$Helpers$safeShiftRightZfBy, n, xh),
			A2($ktonon$elm_word$Word$Helpers$safeShiftRightZfBy, n, xl) + (($ktonon$elm_word$Word$Helpers$lowMask(n) & xh) << (32 - n)));
	});
var $ktonon$elm_word$Word$Helpers$rotatedLowBits = F2(
	function (n, val) {
		return $elm$core$Basics$add(
			($ktonon$elm_word$Word$Helpers$lowMask(n) & val) << (32 - n));
	});
var $ktonon$elm_word$Word$rotateRightBy = F2(
	function (unboundN, word) {
		switch (word.$) {
			case 'W':
				var x = word.a;
				var n = A2($elm$core$Basics$modBy, 32, unboundN);
				return $ktonon$elm_word$Word$W(
					A3(
						$ktonon$elm_word$Word$Helpers$rotatedLowBits,
						n,
						x,
						A2($ktonon$elm_word$Word$Helpers$safeShiftRightZfBy, n, x)));
			case 'D':
				var xh = word.a;
				var xl = word.b;
				var n = A2($elm$core$Basics$modBy, 64, unboundN);
				if (n > 32) {
					var n_ = n - 32;
					var _v1 = A2(
						$ktonon$elm_word$Word$dShiftRightZfBy,
						n_,
						_Utils_Tuple2(xl, xh));
					var zh = _v1.a;
					var zl = _v1.b;
					return A2(
						$ktonon$elm_word$Word$D,
						A3($ktonon$elm_word$Word$Helpers$rotatedLowBits, n_, xh, zh),
						zl);
				} else {
					var _v2 = A2(
						$ktonon$elm_word$Word$dShiftRightZfBy,
						n,
						_Utils_Tuple2(xh, xl));
					var zh = _v2.a;
					var zl = _v2.b;
					return A2(
						$ktonon$elm_word$Word$D,
						A3($ktonon$elm_word$Word$Helpers$rotatedLowBits, n, xl, zh),
						zl);
				}
			default:
				return $ktonon$elm_word$Word$Mismatch;
		}
	});
var $elm$core$Bitwise$xor = _Bitwise_xor;
var $ktonon$elm_word$Word$xor = F2(
	function (wx, wy) {
		var _v0 = _Utils_Tuple2(wx, wy);
		_v0$2:
		while (true) {
			switch (_v0.a.$) {
				case 'W':
					if (_v0.b.$ === 'W') {
						var x = _v0.a.a;
						var y = _v0.b.a;
						return $ktonon$elm_word$Word$W(x ^ y);
					} else {
						break _v0$2;
					}
				case 'D':
					if (_v0.b.$ === 'D') {
						var _v1 = _v0.a;
						var xh = _v1.a;
						var xl = _v1.b;
						var _v2 = _v0.b;
						var yh = _v2.a;
						var yl = _v2.b;
						return A2($ktonon$elm_word$Word$D, xh ^ yh, xl ^ yl);
					} else {
						break _v0$2;
					}
				default:
					break _v0$2;
			}
		}
		return $ktonon$elm_word$Word$Mismatch;
	});
var $ktonon$elm_crypto$Crypto$SHA$Process$sum0 = F2(
	function (alg, word) {
		sum0:
		while (true) {
			switch (alg.$) {
				case 'SHA224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum0;
				case 'SHA384':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum0;
				case 'SHA256':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$rotateRightBy, 22, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 13, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 2, word)));
				case 'SHA512':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$rotateRightBy, 39, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 34, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 28, word)));
				case 'SHA512_224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum0;
				default:
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum0;
			}
		}
	});
var $ktonon$elm_crypto$Crypto$SHA$Process$sum1 = F2(
	function (alg, word) {
		sum1:
		while (true) {
			switch (alg.$) {
				case 'SHA224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum1;
				case 'SHA384':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum1;
				case 'SHA256':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$rotateRightBy, 25, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 11, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 6, word)));
				case 'SHA512':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$rotateRightBy, 41, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 18, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 14, word)));
				case 'SHA512_224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum1;
				default:
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sum1;
			}
		}
	});
var $ktonon$elm_crypto$Crypto$SHA$Process$compress = F3(
	function (alg, _v0, _v1) {
		var k = _v0.a;
		var w = _v0.b;
		var a = _v1.a;
		var b = _v1.b;
		var c = _v1.c;
		var d = _v1.d;
		var e = _v1.e;
		var f = _v1.f;
		var g = _v1.g;
		var h = _v1.h;
		var s1 = A2($ktonon$elm_crypto$Crypto$SHA$Process$sum1, alg, e);
		var s0 = A2($ktonon$elm_crypto$Crypto$SHA$Process$sum0, alg, a);
		var maj = A2(
			$ktonon$elm_word$Word$xor,
			A2($ktonon$elm_word$Word$and, b, c),
			A2(
				$ktonon$elm_word$Word$xor,
				A2($ktonon$elm_word$Word$and, a, c),
				A2($ktonon$elm_word$Word$and, a, b)));
		var temp2 = A2($ktonon$elm_word$Word$add, s0, maj);
		var ch = A2(
			$ktonon$elm_word$Word$xor,
			A2(
				$ktonon$elm_word$Word$and,
				g,
				$ktonon$elm_word$Word$complement(e)),
			A2($ktonon$elm_word$Word$and, e, f));
		var temp1 = A2(
			$ktonon$elm_word$Word$add,
			w,
			A2(
				$ktonon$elm_word$Word$add,
				k,
				A2(
					$ktonon$elm_word$Word$add,
					ch,
					A2($ktonon$elm_word$Word$add, s1, h))));
		return A8(
			$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
			A2($ktonon$elm_word$Word$add, temp1, temp2),
			a,
			b,
			c,
			A2($ktonon$elm_word$Word$add, d, temp1),
			e,
			f,
			g);
	});
var $ktonon$elm_crypto$Crypto$SHA$Constants$roundConstants = function (alg) {
	roundConstants:
	while (true) {
		switch (alg.$) {
			case 'SHA224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256;
				alg = $temp$alg;
				continue roundConstants;
			case 'SHA256':
				return _List_fromArray(
					[
						$ktonon$elm_word$Word$W(1116352408),
						$ktonon$elm_word$Word$W(1899447441),
						$ktonon$elm_word$Word$W(3049323471),
						$ktonon$elm_word$Word$W(3921009573),
						$ktonon$elm_word$Word$W(961987163),
						$ktonon$elm_word$Word$W(1508970993),
						$ktonon$elm_word$Word$W(2453635748),
						$ktonon$elm_word$Word$W(2870763221),
						$ktonon$elm_word$Word$W(3624381080),
						$ktonon$elm_word$Word$W(310598401),
						$ktonon$elm_word$Word$W(607225278),
						$ktonon$elm_word$Word$W(1426881987),
						$ktonon$elm_word$Word$W(1925078388),
						$ktonon$elm_word$Word$W(2162078206),
						$ktonon$elm_word$Word$W(2614888103),
						$ktonon$elm_word$Word$W(3248222580),
						$ktonon$elm_word$Word$W(3835390401),
						$ktonon$elm_word$Word$W(4022224774),
						$ktonon$elm_word$Word$W(264347078),
						$ktonon$elm_word$Word$W(604807628),
						$ktonon$elm_word$Word$W(770255983),
						$ktonon$elm_word$Word$W(1249150122),
						$ktonon$elm_word$Word$W(1555081692),
						$ktonon$elm_word$Word$W(1996064986),
						$ktonon$elm_word$Word$W(2554220882),
						$ktonon$elm_word$Word$W(2821834349),
						$ktonon$elm_word$Word$W(2952996808),
						$ktonon$elm_word$Word$W(3210313671),
						$ktonon$elm_word$Word$W(3336571891),
						$ktonon$elm_word$Word$W(3584528711),
						$ktonon$elm_word$Word$W(113926993),
						$ktonon$elm_word$Word$W(338241895),
						$ktonon$elm_word$Word$W(666307205),
						$ktonon$elm_word$Word$W(773529912),
						$ktonon$elm_word$Word$W(1294757372),
						$ktonon$elm_word$Word$W(1396182291),
						$ktonon$elm_word$Word$W(1695183700),
						$ktonon$elm_word$Word$W(1986661051),
						$ktonon$elm_word$Word$W(2177026350),
						$ktonon$elm_word$Word$W(2456956037),
						$ktonon$elm_word$Word$W(2730485921),
						$ktonon$elm_word$Word$W(2820302411),
						$ktonon$elm_word$Word$W(3259730800),
						$ktonon$elm_word$Word$W(3345764771),
						$ktonon$elm_word$Word$W(3516065817),
						$ktonon$elm_word$Word$W(3600352804),
						$ktonon$elm_word$Word$W(4094571909),
						$ktonon$elm_word$Word$W(275423344),
						$ktonon$elm_word$Word$W(430227734),
						$ktonon$elm_word$Word$W(506948616),
						$ktonon$elm_word$Word$W(659060556),
						$ktonon$elm_word$Word$W(883997877),
						$ktonon$elm_word$Word$W(958139571),
						$ktonon$elm_word$Word$W(1322822218),
						$ktonon$elm_word$Word$W(1537002063),
						$ktonon$elm_word$Word$W(1747873779),
						$ktonon$elm_word$Word$W(1955562222),
						$ktonon$elm_word$Word$W(2024104815),
						$ktonon$elm_word$Word$W(2227730452),
						$ktonon$elm_word$Word$W(2361852424),
						$ktonon$elm_word$Word$W(2428436474),
						$ktonon$elm_word$Word$W(2756734187),
						$ktonon$elm_word$Word$W(3204031479),
						$ktonon$elm_word$Word$W(3329325298)
					]);
			case 'SHA384':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue roundConstants;
			case 'SHA512':
				return _List_fromArray(
					[
						A2($ktonon$elm_word$Word$D, 1116352408, 3609767458),
						A2($ktonon$elm_word$Word$D, 1899447441, 602891725),
						A2($ktonon$elm_word$Word$D, 3049323471, 3964484399),
						A2($ktonon$elm_word$Word$D, 3921009573, 2173295548),
						A2($ktonon$elm_word$Word$D, 961987163, 4081628472),
						A2($ktonon$elm_word$Word$D, 1508970993, 3053834265),
						A2($ktonon$elm_word$Word$D, 2453635748, 2937671579),
						A2($ktonon$elm_word$Word$D, 2870763221, 3664609560),
						A2($ktonon$elm_word$Word$D, 3624381080, 2734883394),
						A2($ktonon$elm_word$Word$D, 310598401, 1164996542),
						A2($ktonon$elm_word$Word$D, 607225278, 1323610764),
						A2($ktonon$elm_word$Word$D, 1426881987, 3590304994),
						A2($ktonon$elm_word$Word$D, 1925078388, 4068182383),
						A2($ktonon$elm_word$Word$D, 2162078206, 991336113),
						A2($ktonon$elm_word$Word$D, 2614888103, 633803317),
						A2($ktonon$elm_word$Word$D, 3248222580, 3479774868),
						A2($ktonon$elm_word$Word$D, 3835390401, 2666613458),
						A2($ktonon$elm_word$Word$D, 4022224774, 944711139),
						A2($ktonon$elm_word$Word$D, 264347078, 2341262773),
						A2($ktonon$elm_word$Word$D, 604807628, 2007800933),
						A2($ktonon$elm_word$Word$D, 770255983, 1495990901),
						A2($ktonon$elm_word$Word$D, 1249150122, 1856431235),
						A2($ktonon$elm_word$Word$D, 1555081692, 3175218132),
						A2($ktonon$elm_word$Word$D, 1996064986, 2198950837),
						A2($ktonon$elm_word$Word$D, 2554220882, 3999719339),
						A2($ktonon$elm_word$Word$D, 2821834349, 766784016),
						A2($ktonon$elm_word$Word$D, 2952996808, 2566594879),
						A2($ktonon$elm_word$Word$D, 3210313671, 3203337956),
						A2($ktonon$elm_word$Word$D, 3336571891, 1034457026),
						A2($ktonon$elm_word$Word$D, 3584528711, 2466948901),
						A2($ktonon$elm_word$Word$D, 113926993, 3758326383),
						A2($ktonon$elm_word$Word$D, 338241895, 168717936),
						A2($ktonon$elm_word$Word$D, 666307205, 1188179964),
						A2($ktonon$elm_word$Word$D, 773529912, 1546045734),
						A2($ktonon$elm_word$Word$D, 1294757372, 1522805485),
						A2($ktonon$elm_word$Word$D, 1396182291, 2643833823),
						A2($ktonon$elm_word$Word$D, 1695183700, 2343527390),
						A2($ktonon$elm_word$Word$D, 1986661051, 1014477480),
						A2($ktonon$elm_word$Word$D, 2177026350, 1206759142),
						A2($ktonon$elm_word$Word$D, 2456956037, 344077627),
						A2($ktonon$elm_word$Word$D, 2730485921, 1290863460),
						A2($ktonon$elm_word$Word$D, 2820302411, 3158454273),
						A2($ktonon$elm_word$Word$D, 3259730800, 3505952657),
						A2($ktonon$elm_word$Word$D, 3345764771, 106217008),
						A2($ktonon$elm_word$Word$D, 3516065817, 3606008344),
						A2($ktonon$elm_word$Word$D, 3600352804, 1432725776),
						A2($ktonon$elm_word$Word$D, 4094571909, 1467031594),
						A2($ktonon$elm_word$Word$D, 275423344, 851169720),
						A2($ktonon$elm_word$Word$D, 430227734, 3100823752),
						A2($ktonon$elm_word$Word$D, 506948616, 1363258195),
						A2($ktonon$elm_word$Word$D, 659060556, 3750685593),
						A2($ktonon$elm_word$Word$D, 883997877, 3785050280),
						A2($ktonon$elm_word$Word$D, 958139571, 3318307427),
						A2($ktonon$elm_word$Word$D, 1322822218, 3812723403),
						A2($ktonon$elm_word$Word$D, 1537002063, 2003034995),
						A2($ktonon$elm_word$Word$D, 1747873779, 3602036899),
						A2($ktonon$elm_word$Word$D, 1955562222, 1575990012),
						A2($ktonon$elm_word$Word$D, 2024104815, 1125592928),
						A2($ktonon$elm_word$Word$D, 2227730452, 2716904306),
						A2($ktonon$elm_word$Word$D, 2361852424, 442776044),
						A2($ktonon$elm_word$Word$D, 2428436474, 593698344),
						A2($ktonon$elm_word$Word$D, 2756734187, 3733110249),
						A2($ktonon$elm_word$Word$D, 3204031479, 2999351573),
						A2($ktonon$elm_word$Word$D, 3329325298, 3815920427),
						A2($ktonon$elm_word$Word$D, 3391569614, 3928383900),
						A2($ktonon$elm_word$Word$D, 3515267271, 566280711),
						A2($ktonon$elm_word$Word$D, 3940187606, 3454069534),
						A2($ktonon$elm_word$Word$D, 4118630271, 4000239992),
						A2($ktonon$elm_word$Word$D, 116418474, 1914138554),
						A2($ktonon$elm_word$Word$D, 174292421, 2731055270),
						A2($ktonon$elm_word$Word$D, 289380356, 3203993006),
						A2($ktonon$elm_word$Word$D, 460393269, 320620315),
						A2($ktonon$elm_word$Word$D, 685471733, 587496836),
						A2($ktonon$elm_word$Word$D, 852142971, 1086792851),
						A2($ktonon$elm_word$Word$D, 1017036298, 365543100),
						A2($ktonon$elm_word$Word$D, 1126000580, 2618297676),
						A2($ktonon$elm_word$Word$D, 1288033470, 3409855158),
						A2($ktonon$elm_word$Word$D, 1501505948, 4234509866),
						A2($ktonon$elm_word$Word$D, 1607167915, 987167468),
						A2($ktonon$elm_word$Word$D, 1816402316, 1246189591)
					]);
			case 'SHA512_224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue roundConstants;
			default:
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue roundConstants;
		}
	}
};
var $ktonon$elm_crypto$Crypto$SHA$Process$compressLoop = F3(
	function (alg, workingVars, messageSchedule) {
		return A3(
			$elm$core$List$foldl,
			$ktonon$elm_crypto$Crypto$SHA$Process$compress(alg),
			workingVars,
			A3(
				$elm$core$List$map2,
				F2(
					function (a, b) {
						return _Utils_Tuple2(a, b);
					}),
				$ktonon$elm_crypto$Crypto$SHA$Constants$roundConstants(alg),
				$elm$core$Array$toList(messageSchedule)));
	});
var $elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, list);
			var jsArray = _v0.a;
			var remainingItems = _v0.b;
			if (_Utils_cmp(
				$elm$core$Elm$JsArray$length(jsArray),
				$elm$core$Array$branchFactor) < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					true,
					{nodeList: nodeList, nodeListSize: nodeListSize, tail: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					$elm$core$List$cons,
					$elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var $elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return $elm$core$Array$empty;
	} else {
		return A3($elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var $elm$core$Elm$JsArray$appendN = _JsArray_appendN;
var $elm$core$Elm$JsArray$slice = _JsArray_slice;
var $elm$core$Array$appendHelpBuilder = F2(
	function (tail, builder) {
		var tailLen = $elm$core$Elm$JsArray$length(tail);
		var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(builder.tail)) - tailLen;
		var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, builder.tail, tail);
		return (notAppended < 0) ? {
			nodeList: A2(
				$elm$core$List$cons,
				$elm$core$Array$Leaf(appended),
				builder.nodeList),
			nodeListSize: builder.nodeListSize + 1,
			tail: A3($elm$core$Elm$JsArray$slice, notAppended, tailLen, tail)
		} : ((!notAppended) ? {
			nodeList: A2(
				$elm$core$List$cons,
				$elm$core$Array$Leaf(appended),
				builder.nodeList),
			nodeListSize: builder.nodeListSize + 1,
			tail: $elm$core$Elm$JsArray$empty
		} : {nodeList: builder.nodeList, nodeListSize: builder.nodeListSize, tail: appended});
	});
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Elm$JsArray$push = _JsArray_push;
var $elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var $elm$core$Array$insertTailInTree = F4(
	function (shift, index, tail, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		if (_Utils_cmp(
			pos,
			$elm$core$Elm$JsArray$length(tree)) > -1) {
			if (shift === 5) {
				return A2(
					$elm$core$Elm$JsArray$push,
					$elm$core$Array$Leaf(tail),
					tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, $elm$core$Elm$JsArray$empty));
				return A2($elm$core$Elm$JsArray$push, newSub, tree);
			}
		} else {
			var value = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (value.$ === 'SubTree') {
				var subTree = value.a;
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, subTree));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4(
						$elm$core$Array$insertTailInTree,
						shift - $elm$core$Array$shiftStep,
						index,
						tail,
						$elm$core$Elm$JsArray$singleton(value)));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			}
		}
	});
var $elm$core$Array$unsafeReplaceTail = F2(
	function (newTail, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var originalTailLen = $elm$core$Elm$JsArray$length(tail);
		var newTailLen = $elm$core$Elm$JsArray$length(newTail);
		var newArrayLen = len + (newTailLen - originalTailLen);
		if (_Utils_eq(newTailLen, $elm$core$Array$branchFactor)) {
			var overflow = _Utils_cmp(newArrayLen >>> $elm$core$Array$shiftStep, 1 << startShift) > 0;
			if (overflow) {
				var newShift = startShift + $elm$core$Array$shiftStep;
				var newTree = A4(
					$elm$core$Array$insertTailInTree,
					newShift,
					len,
					newTail,
					$elm$core$Elm$JsArray$singleton(
						$elm$core$Array$SubTree(tree)));
				return A4($elm$core$Array$Array_elm_builtin, newArrayLen, newShift, newTree, $elm$core$Elm$JsArray$empty);
			} else {
				return A4(
					$elm$core$Array$Array_elm_builtin,
					newArrayLen,
					startShift,
					A4($elm$core$Array$insertTailInTree, startShift, len, newTail, tree),
					$elm$core$Elm$JsArray$empty);
			}
		} else {
			return A4($elm$core$Array$Array_elm_builtin, newArrayLen, startShift, tree, newTail);
		}
	});
var $elm$core$Array$appendHelpTree = F2(
	function (toAppend, array) {
		var len = array.a;
		var tree = array.c;
		var tail = array.d;
		var itemsToAppend = $elm$core$Elm$JsArray$length(toAppend);
		var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(tail)) - itemsToAppend;
		var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, tail, toAppend);
		var newArray = A2($elm$core$Array$unsafeReplaceTail, appended, array);
		if (notAppended < 0) {
			var nextTail = A3($elm$core$Elm$JsArray$slice, notAppended, itemsToAppend, toAppend);
			return A2($elm$core$Array$unsafeReplaceTail, nextTail, newArray);
		} else {
			return newArray;
		}
	});
var $elm$core$Elm$JsArray$foldl = _JsArray_foldl;
var $elm$core$Array$builderFromArray = function (_v0) {
	var len = _v0.a;
	var tree = _v0.c;
	var tail = _v0.d;
	var helper = F2(
		function (node, acc) {
			if (node.$ === 'SubTree') {
				var subTree = node.a;
				return A3($elm$core$Elm$JsArray$foldl, helper, acc, subTree);
			} else {
				return A2($elm$core$List$cons, node, acc);
			}
		});
	return {
		nodeList: A3($elm$core$Elm$JsArray$foldl, helper, _List_Nil, tree),
		nodeListSize: (len / $elm$core$Array$branchFactor) | 0,
		tail: tail
	};
};
var $elm$core$Array$append = F2(
	function (a, _v0) {
		var aTail = a.d;
		var bLen = _v0.a;
		var bTree = _v0.c;
		var bTail = _v0.d;
		if (_Utils_cmp(bLen, $elm$core$Array$branchFactor * 4) < 1) {
			var foldHelper = F2(
				function (node, array) {
					if (node.$ === 'SubTree') {
						var tree = node.a;
						return A3($elm$core$Elm$JsArray$foldl, foldHelper, array, tree);
					} else {
						var leaf = node.a;
						return A2($elm$core$Array$appendHelpTree, leaf, array);
					}
				});
			return A2(
				$elm$core$Array$appendHelpTree,
				bTail,
				A3($elm$core$Elm$JsArray$foldl, foldHelper, a, bTree));
		} else {
			var foldHelper = F2(
				function (node, builder) {
					if (node.$ === 'SubTree') {
						var tree = node.a;
						return A3($elm$core$Elm$JsArray$foldl, foldHelper, builder, tree);
					} else {
						var leaf = node.a;
						return A2($elm$core$Array$appendHelpBuilder, leaf, builder);
					}
				});
			return A2(
				$elm$core$Array$builderToArray,
				true,
				A2(
					$elm$core$Array$appendHelpBuilder,
					bTail,
					A3(
						$elm$core$Elm$JsArray$foldl,
						foldHelper,
						$elm$core$Array$builderFromArray(a),
						bTree)));
		}
	});
var $elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = $elm$core$Array$bitMask & (index >>> shift);
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (_v0.$ === 'SubTree') {
				var subTree = _v0.a;
				var $temp$shift = shift - $elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _v0.a;
				return A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, values);
			}
		}
	});
var $elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var $elm$core$Array$get = F2(
	function (index, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? $elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Maybe$Just(
			A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, tail)) : $elm$core$Maybe$Just(
			A3($elm$core$Array$getHelp, startShift, index, tree)));
	});
var $ktonon$elm_crypto$Crypto$SHA$MessageSchedule$at = function (i) {
	return A2(
		$elm$core$Basics$composeR,
		$elm$core$Array$get(i),
		$elm$core$Maybe$withDefault($ktonon$elm_word$Word$Mismatch));
};
var $ktonon$elm_word$Word$shiftRightZfBy = F2(
	function (n, word) {
		switch (word.$) {
			case 'W':
				var x = word.a;
				return $ktonon$elm_word$Word$W(
					A2($ktonon$elm_word$Word$Helpers$safeShiftRightZfBy, n, x));
			case 'D':
				var xh = word.a;
				var xl = word.b;
				var _v1 = A2(
					$ktonon$elm_word$Word$dShiftRightZfBy,
					n,
					_Utils_Tuple2(xh, xl));
				var zh = _v1.a;
				var zl = _v1.b;
				return A2($ktonon$elm_word$Word$D, zh, zl);
			default:
				return $ktonon$elm_word$Word$Mismatch;
		}
	});
var $ktonon$elm_crypto$Crypto$SHA$MessageSchedule$sigma0 = F2(
	function (alg, word) {
		sigma0:
		while (true) {
			switch (alg.$) {
				case 'SHA224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma0;
				case 'SHA384':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma0;
				case 'SHA256':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$shiftRightZfBy, 3, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 18, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 7, word)));
				case 'SHA512':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$shiftRightZfBy, 7, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 8, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 1, word)));
				case 'SHA512_224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma0;
				default:
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma0;
			}
		}
	});
var $ktonon$elm_crypto$Crypto$SHA$MessageSchedule$sigma1 = F2(
	function (alg, word) {
		sigma1:
		while (true) {
			switch (alg.$) {
				case 'SHA224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma1;
				case 'SHA384':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma1;
				case 'SHA256':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$shiftRightZfBy, 10, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 19, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 17, word)));
				case 'SHA512':
					return A2(
						$ktonon$elm_word$Word$xor,
						A2($ktonon$elm_word$Word$shiftRightZfBy, 6, word),
						A2(
							$ktonon$elm_word$Word$xor,
							A2($ktonon$elm_word$Word$rotateRightBy, 61, word),
							A2($ktonon$elm_word$Word$rotateRightBy, 19, word)));
				case 'SHA512_224':
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma1;
				default:
					var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512,
						$temp$word = word;
					alg = $temp$alg;
					word = $temp$word;
					continue sigma1;
			}
		}
	});
var $ktonon$elm_crypto$Crypto$SHA$MessageSchedule$nextPart = F3(
	function (alg, i, w) {
		var i2 = A2($ktonon$elm_crypto$Crypto$SHA$MessageSchedule$at, i - 2, w);
		var s1 = A2($ktonon$elm_crypto$Crypto$SHA$MessageSchedule$sigma1, alg, i2);
		var i15 = A2($ktonon$elm_crypto$Crypto$SHA$MessageSchedule$at, i - 15, w);
		var s0 = A2($ktonon$elm_crypto$Crypto$SHA$MessageSchedule$sigma0, alg, i15);
		return A2(
			$elm$core$Array$append,
			w,
			$elm$core$Array$fromList(
				_List_fromArray(
					[
						A2(
						$ktonon$elm_word$Word$add,
						s1,
						A2(
							$ktonon$elm_word$Word$add,
							A2($ktonon$elm_crypto$Crypto$SHA$MessageSchedule$at, i - 7, w),
							A2(
								$ktonon$elm_word$Word$add,
								s0,
								A2($ktonon$elm_crypto$Crypto$SHA$MessageSchedule$at, i - 16, w))))
					])));
	});
var $ktonon$elm_crypto$Crypto$SHA$MessageSchedule$fromChunk = F2(
	function (alg, chunk) {
		var n = $elm$core$List$length(
			$ktonon$elm_crypto$Crypto$SHA$Constants$roundConstants(alg));
		return A3(
			$elm$core$List$foldl,
			$ktonon$elm_crypto$Crypto$SHA$MessageSchedule$nextPart(alg),
			$elm$core$Array$fromList(chunk),
			A2($elm$core$List$range, 16, n - 1));
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $ktonon$elm_crypto$Crypto$SHA$Chunk$sizeInBytes = function (alg) {
	sizeInBytes:
	while (true) {
		switch (alg.$) {
			case 'SHA224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256;
				alg = $temp$alg;
				continue sizeInBytes;
			case 'SHA256':
				return 64;
			case 'SHA384':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue sizeInBytes;
			case 'SHA512':
				return 128;
			case 'SHA512_224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue sizeInBytes;
			default:
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue sizeInBytes;
		}
	}
};
var $ktonon$elm_word$Word$sizeInBytes = function (s) {
	if (s.$ === 'Bit32') {
		return 4;
	} else {
		return 8;
	}
};
var $ktonon$elm_word$Word$Bit32 = {$: 'Bit32'};
var $ktonon$elm_word$Word$Bit64 = {$: 'Bit64'};
var $ktonon$elm_crypto$Crypto$SHA$Alg$wordSize = function (alg) {
	wordSize:
	while (true) {
		switch (alg.$) {
			case 'SHA224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256;
				alg = $temp$alg;
				continue wordSize;
			case 'SHA256':
				return $ktonon$elm_word$Word$Bit32;
			case 'SHA384':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue wordSize;
			case 'SHA512':
				return $ktonon$elm_word$Word$Bit64;
			case 'SHA512_224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue wordSize;
			default:
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue wordSize;
		}
	}
};
var $ktonon$elm_crypto$Crypto$SHA$Chunk$sizeInWords = function (alg) {
	return ($ktonon$elm_crypto$Crypto$SHA$Chunk$sizeInBytes(alg) / $ktonon$elm_word$Word$sizeInBytes(
		$ktonon$elm_crypto$Crypto$SHA$Alg$wordSize(alg))) | 0;
};
var $ktonon$elm_crypto$Crypto$SHA$Chunk$next = F2(
	function (alg, words) {
		var n = $ktonon$elm_crypto$Crypto$SHA$Chunk$sizeInWords(alg);
		var chunk = A2($elm$core$List$take, n, words);
		return _Utils_Tuple2(
			$elm$core$List$isEmpty(chunk) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(chunk),
			A2($elm$core$List$drop, n, words));
	});
var $ktonon$elm_crypto$Crypto$SHA$Process$chunks_ = F3(
	function (alg, words, currentHash) {
		chunks_:
		while (true) {
			var _v0 = A2($ktonon$elm_crypto$Crypto$SHA$Chunk$next, alg, words);
			if (_v0.a.$ === 'Nothing') {
				var _v1 = _v0.a;
				return currentHash;
			} else {
				var chunk = _v0.a.a;
				var rest = _v0.b;
				var vars = A2(
					$ktonon$elm_crypto$Crypto$SHA$Types$addWorkingVars,
					currentHash,
					A3(
						$ktonon$elm_crypto$Crypto$SHA$Process$compressLoop,
						alg,
						currentHash,
						A2($ktonon$elm_crypto$Crypto$SHA$MessageSchedule$fromChunk, alg, chunk)));
				var $temp$alg = alg,
					$temp$words = rest,
					$temp$currentHash = vars;
				alg = $temp$alg;
				words = $temp$words;
				currentHash = $temp$currentHash;
				continue chunks_;
			}
		}
	});
var $ktonon$elm_crypto$Crypto$SHA$Constants$initialHashValues = function (alg) {
	switch (alg.$) {
		case 'SHA224':
			return A8(
				$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
				$ktonon$elm_word$Word$W(3238371032),
				$ktonon$elm_word$Word$W(914150663),
				$ktonon$elm_word$Word$W(812702999),
				$ktonon$elm_word$Word$W(4144912697),
				$ktonon$elm_word$Word$W(4290775857),
				$ktonon$elm_word$Word$W(1750603025),
				$ktonon$elm_word$Word$W(1694076839),
				$ktonon$elm_word$Word$W(3204075428));
		case 'SHA256':
			return A8(
				$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
				$ktonon$elm_word$Word$W(1779033703),
				$ktonon$elm_word$Word$W(3144134277),
				$ktonon$elm_word$Word$W(1013904242),
				$ktonon$elm_word$Word$W(2773480762),
				$ktonon$elm_word$Word$W(1359893119),
				$ktonon$elm_word$Word$W(2600822924),
				$ktonon$elm_word$Word$W(528734635),
				$ktonon$elm_word$Word$W(1541459225));
		case 'SHA384':
			return A8(
				$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
				A2($ktonon$elm_word$Word$D, 3418070365, 3238371032),
				A2($ktonon$elm_word$Word$D, 1654270250, 914150663),
				A2($ktonon$elm_word$Word$D, 2438529370, 812702999),
				A2($ktonon$elm_word$Word$D, 355462360, 4144912697),
				A2($ktonon$elm_word$Word$D, 1731405415, 4290775857),
				A2($ktonon$elm_word$Word$D, 2394180231, 1750603025),
				A2($ktonon$elm_word$Word$D, 3675008525, 1694076839),
				A2($ktonon$elm_word$Word$D, 1203062813, 3204075428));
		case 'SHA512':
			return A8(
				$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
				A2($ktonon$elm_word$Word$D, 1779033703, 4089235720),
				A2($ktonon$elm_word$Word$D, 3144134277, 2227873595),
				A2($ktonon$elm_word$Word$D, 1013904242, 4271175723),
				A2($ktonon$elm_word$Word$D, 2773480762, 1595750129),
				A2($ktonon$elm_word$Word$D, 1359893119, 2917565137),
				A2($ktonon$elm_word$Word$D, 2600822924, 725511199),
				A2($ktonon$elm_word$Word$D, 528734635, 4215389547),
				A2($ktonon$elm_word$Word$D, 1541459225, 327033209));
		case 'SHA512_224':
			return A8(
				$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
				A2($ktonon$elm_word$Word$D, 2352822216, 424955298),
				A2($ktonon$elm_word$Word$D, 1944164710, 2312950998),
				A2($ktonon$elm_word$Word$D, 502970286, 855612546),
				A2($ktonon$elm_word$Word$D, 1738396948, 1479516111),
				A2($ktonon$elm_word$Word$D, 258812777, 2077511080),
				A2($ktonon$elm_word$Word$D, 2011393907, 79989058),
				A2($ktonon$elm_word$Word$D, 1067287976, 1780299464),
				A2($ktonon$elm_word$Word$D, 286451373, 2446758561));
		default:
			return A8(
				$ktonon$elm_crypto$Crypto$SHA$Types$WorkingVars,
				A2($ktonon$elm_word$Word$D, 573645204, 4230739756),
				A2($ktonon$elm_word$Word$D, 2673172387, 3360449730),
				A2($ktonon$elm_word$Word$D, 596883563, 1867755857),
				A2($ktonon$elm_word$Word$D, 2520282905, 1497426621),
				A2($ktonon$elm_word$Word$D, 2519219938, 2827943907),
				A2($ktonon$elm_word$Word$D, 3193839141, 1401305490),
				A2($ktonon$elm_word$Word$D, 721525244, 746961066),
				A2($ktonon$elm_word$Word$D, 246885852, 2177182882));
	}
};
var $ktonon$elm_crypto$Crypto$SHA$Types$toSingleWord = function (word) {
	if (word.$ === 'D') {
		var xh = word.a;
		var xl = word.b;
		return _List_fromArray(
			[
				$ktonon$elm_word$Word$W(xh),
				$ktonon$elm_word$Word$W(xl)
			]);
	} else {
		return _List_fromArray(
			[word]);
	}
};
var $ktonon$elm_crypto$Crypto$SHA$Types$workingVarsToWords = F2(
	function (alg, _v0) {
		var a = _v0.a;
		var b = _v0.b;
		var c = _v0.c;
		var d = _v0.d;
		var e = _v0.e;
		var f = _v0.f;
		var g = _v0.g;
		var h = _v0.h;
		switch (alg.$) {
			case 'SHA224':
				return $elm$core$Array$fromList(
					_List_fromArray(
						[a, b, c, d, e, f, g]));
			case 'SHA256':
				return $elm$core$Array$fromList(
					_List_fromArray(
						[a, b, c, d, e, f, g, h]));
			case 'SHA384':
				return $elm$core$Array$fromList(
					_List_fromArray(
						[a, b, c, d, e, f]));
			case 'SHA512':
				return $elm$core$Array$fromList(
					_List_fromArray(
						[a, b, c, d, e, f, g, h]));
			case 'SHA512_224':
				return $elm$core$Array$fromList(
					A2(
						$elm$core$List$take,
						7,
						A2(
							$elm$core$List$concatMap,
							$ktonon$elm_crypto$Crypto$SHA$Types$toSingleWord,
							_List_fromArray(
								[a, b, c, d]))));
			default:
				return $elm$core$Array$fromList(
					_List_fromArray(
						[a, b, c, d]));
		}
	});
var $ktonon$elm_crypto$Crypto$SHA$Process$chunks = F2(
	function (alg, words) {
		return A2(
			$ktonon$elm_crypto$Crypto$SHA$Types$workingVarsToWords,
			alg,
			A3(
				$ktonon$elm_crypto$Crypto$SHA$Process$chunks_,
				alg,
				$elm$core$Array$toList(words),
				$ktonon$elm_crypto$Crypto$SHA$Constants$initialHashValues(alg)));
	});
var $ktonon$elm_word$Word$FourBytes = F4(
	function (a, b, c, d) {
		return {$: 'FourBytes', a: a, b: b, c: c, d: d};
	});
var $ktonon$elm_word$Word$int32FromBytes = function (_v0) {
	var x3 = _v0.a;
	var x2 = _v0.b;
	var x1 = _v0.c;
	var x0 = _v0.d;
	return ((x0 + (x1 * A2($elm$core$Basics$pow, 2, 8))) + (x2 * A2($elm$core$Basics$pow, 2, 16))) + (x3 * A2($elm$core$Basics$pow, 2, 24));
};
var $ktonon$elm_word$Word$pad4 = function (bytes) {
	_v0$4:
	while (true) {
		if (bytes.b) {
			if (bytes.b.b) {
				if (bytes.b.b.b) {
					if (bytes.b.b.b.b) {
						if (!bytes.b.b.b.b.b) {
							var x3 = bytes.a;
							var _v1 = bytes.b;
							var x2 = _v1.a;
							var _v2 = _v1.b;
							var x1 = _v2.a;
							var _v3 = _v2.b;
							var x0 = _v3.a;
							return A4($ktonon$elm_word$Word$FourBytes, x3, x2, x1, x0);
						} else {
							break _v0$4;
						}
					} else {
						var x3 = bytes.a;
						var _v4 = bytes.b;
						var x2 = _v4.a;
						var _v5 = _v4.b;
						var x1 = _v5.a;
						return A4($ktonon$elm_word$Word$FourBytes, x3, x2, x1, 0);
					}
				} else {
					var x3 = bytes.a;
					var _v6 = bytes.b;
					var x2 = _v6.a;
					return A4($ktonon$elm_word$Word$FourBytes, x3, x2, 0, 0);
				}
			} else {
				var x3 = bytes.a;
				return A4($ktonon$elm_word$Word$FourBytes, x3, 0, 0, 0);
			}
		} else {
			break _v0$4;
		}
	}
	return A4($ktonon$elm_word$Word$FourBytes, 0, 0, 0, 0);
};
var $elm$core$Array$push = F2(
	function (a, array) {
		var tail = array.d;
		return A2(
			$elm$core$Array$unsafeReplaceTail,
			A2($elm$core$Elm$JsArray$push, a, tail),
			array);
	});
var $ktonon$elm_word$Word$accWords = F3(
	function (wordSize, bytes, acc) {
		accWords:
		while (true) {
			var _v0 = _Utils_Tuple2(wordSize, bytes);
			_v0$2:
			while (true) {
				if (_v0.a.$ === 'Bit32') {
					if (_v0.b.b) {
						if ((_v0.b.b.b && _v0.b.b.b.b) && _v0.b.b.b.b.b) {
							var _v1 = _v0.a;
							var _v2 = _v0.b;
							var x3 = _v2.a;
							var _v3 = _v2.b;
							var x2 = _v3.a;
							var _v4 = _v3.b;
							var x1 = _v4.a;
							var _v5 = _v4.b;
							var x0 = _v5.a;
							var rest = _v5.b;
							var acc2 = A2(
								$elm$core$Array$push,
								$ktonon$elm_word$Word$W(
									$ktonon$elm_word$Word$int32FromBytes(
										A4($ktonon$elm_word$Word$FourBytes, x3, x2, x1, x0))),
								acc);
							var $temp$wordSize = wordSize,
								$temp$bytes = rest,
								$temp$acc = acc2;
							wordSize = $temp$wordSize;
							bytes = $temp$bytes;
							acc = $temp$acc;
							continue accWords;
						} else {
							var _v15 = _v0.a;
							var rest = _v0.b;
							return A2(
								$elm$core$Array$push,
								$ktonon$elm_word$Word$W(
									$ktonon$elm_word$Word$int32FromBytes(
										$ktonon$elm_word$Word$pad4(rest))),
								acc);
						}
					} else {
						break _v0$2;
					}
				} else {
					if (_v0.b.b) {
						if ((((((_v0.b.b.b && _v0.b.b.b.b) && _v0.b.b.b.b.b) && _v0.b.b.b.b.b.b) && _v0.b.b.b.b.b.b.b) && _v0.b.b.b.b.b.b.b.b) && _v0.b.b.b.b.b.b.b.b.b) {
							var _v6 = _v0.a;
							var _v7 = _v0.b;
							var x7 = _v7.a;
							var _v8 = _v7.b;
							var x6 = _v8.a;
							var _v9 = _v8.b;
							var x5 = _v9.a;
							var _v10 = _v9.b;
							var x4 = _v10.a;
							var _v11 = _v10.b;
							var x3 = _v11.a;
							var _v12 = _v11.b;
							var x2 = _v12.a;
							var _v13 = _v12.b;
							var x1 = _v13.a;
							var _v14 = _v13.b;
							var x0 = _v14.a;
							var rest = _v14.b;
							var acc2 = A2(
								$elm$core$Array$push,
								A2(
									$ktonon$elm_word$Word$D,
									$ktonon$elm_word$Word$int32FromBytes(
										A4($ktonon$elm_word$Word$FourBytes, x7, x6, x5, x4)),
									$ktonon$elm_word$Word$int32FromBytes(
										A4($ktonon$elm_word$Word$FourBytes, x3, x2, x1, x0))),
								acc);
							var $temp$wordSize = wordSize,
								$temp$bytes = rest,
								$temp$acc = acc2;
							wordSize = $temp$wordSize;
							bytes = $temp$bytes;
							acc = $temp$acc;
							continue accWords;
						} else {
							var _v16 = _v0.a;
							var rest = _v0.b;
							return A2(
								$elm$core$Array$push,
								A2(
									$ktonon$elm_word$Word$D,
									$ktonon$elm_word$Word$int32FromBytes(
										$ktonon$elm_word$Word$pad4(
											A2($elm$core$List$take, 4, rest))),
									$ktonon$elm_word$Word$int32FromBytes(
										$ktonon$elm_word$Word$pad4(
											A2($elm$core$List$drop, 4, rest)))),
								acc);
						}
					} else {
						break _v0$2;
					}
				}
			}
			return acc;
		}
	});
var $ktonon$elm_word$Word$fromBytes = F2(
	function (wordSize, bytes) {
		return A3($ktonon$elm_word$Word$accWords, wordSize, bytes, $elm$core$Array$empty);
	});
var $ktonon$elm_crypto$Crypto$SHA$Preprocess$messageSizeBytes = function (alg) {
	messageSizeBytes:
	while (true) {
		switch (alg.$) {
			case 'SHA224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA256;
				alg = $temp$alg;
				continue messageSizeBytes;
			case 'SHA256':
				return 8;
			case 'SHA384':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue messageSizeBytes;
			case 'SHA512':
				return 16;
			case 'SHA512_224':
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue messageSizeBytes;
			default:
				var $temp$alg = $ktonon$elm_crypto$Crypto$SHA$Alg$SHA512;
				alg = $temp$alg;
				continue messageSizeBytes;
		}
	}
};
var $ktonon$elm_crypto$Crypto$SHA$Chunk$sizeInBits = A2(
	$elm$core$Basics$composeR,
	$ktonon$elm_crypto$Crypto$SHA$Chunk$sizeInBytes,
	$elm$core$Basics$mul(8));
var $ktonon$elm_crypto$Crypto$SHA$Preprocess$calculateK = F2(
	function (alg, l) {
		var c = $ktonon$elm_crypto$Crypto$SHA$Chunk$sizeInBits(alg);
		return A2(
			$elm$core$Basics$modBy,
			c,
			((c - 1) - (8 * $ktonon$elm_crypto$Crypto$SHA$Preprocess$messageSizeBytes(alg))) - A2($elm$core$Basics$modBy, c, l));
	});
var $ktonon$elm_word$Word$Bytes$fromInt = F2(
	function (byteCount, value) {
		return (byteCount > 4) ? A2(
			$elm$core$List$append,
			A2(
				$ktonon$elm_word$Word$Bytes$fromInt,
				byteCount - 4,
				(value / A2($elm$core$Basics$pow, 2, 32)) | 0),
			A2($ktonon$elm_word$Word$Bytes$fromInt, 4, 4294967295 & value)) : A2(
			$elm$core$List$map,
			function (i) {
				return 255 & (value >>> ((byteCount - i) * A2($elm$core$Basics$pow, 2, 3)));
			},
			A2($elm$core$List$range, 1, byteCount));
	});
var $elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2($elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var $elm$core$List$repeat = F2(
	function (n, value) {
		return A3($elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var $ktonon$elm_crypto$Crypto$SHA$Preprocess$postfix = F2(
	function (alg, messageSize) {
		return $elm$core$List$concat(
			_List_fromArray(
				[
					_List_fromArray(
					[128]),
					A2(
					$elm$core$List$repeat,
					((A2($ktonon$elm_crypto$Crypto$SHA$Preprocess$calculateK, alg, messageSize) - 7) / 8) | 0,
					0),
					A2(
					$ktonon$elm_word$Word$Bytes$fromInt,
					$ktonon$elm_crypto$Crypto$SHA$Preprocess$messageSizeBytes(alg),
					messageSize)
				]));
	});
var $ktonon$elm_crypto$Crypto$SHA$Preprocess$preprocess = F2(
	function (alg, message) {
		return A2(
			$elm$core$List$append,
			message,
			A2(
				$ktonon$elm_crypto$Crypto$SHA$Preprocess$postfix,
				alg,
				8 * $elm$core$List$length(message)));
	});
var $ktonon$elm_crypto$Crypto$SHA$digest = function (alg) {
	return A2(
		$elm$core$Basics$composeR,
		$ktonon$elm_crypto$Crypto$SHA$Preprocess$preprocess(alg),
		A2(
			$elm$core$Basics$composeR,
			$ktonon$elm_word$Word$fromBytes(
				$ktonon$elm_crypto$Crypto$SHA$Alg$wordSize(alg)),
			$ktonon$elm_crypto$Crypto$SHA$Process$chunks(alg)));
};
var $elm$core$Bitwise$or = _Bitwise_or;
var $ktonon$elm_word$Word$Bytes$splitUtf8 = function (x) {
	return (x < 128) ? _List_fromArray(
		[x]) : ((x < 2048) ? _List_fromArray(
		[192 | ((1984 & x) >>> 6), 128 | (63 & x)]) : _List_fromArray(
		[224 | ((61440 & x) >>> 12), 128 | ((4032 & x) >>> 6), 128 | (63 & x)]));
};
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$toList = function (string) {
	return A3($elm$core$String$foldr, $elm$core$List$cons, _List_Nil, string);
};
var $ktonon$elm_word$Word$Bytes$fromUTF8 = A2(
	$elm$core$Basics$composeR,
	$elm$core$String$toList,
	A2(
		$elm$core$List$foldl,
		F2(
			function (_char, acc) {
				return A2(
					$elm$core$List$append,
					acc,
					$ktonon$elm_word$Word$Bytes$splitUtf8(
						$elm$core$Char$toCode(_char)));
			}),
		_List_Nil));
var $elm$core$Array$foldl = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldl, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldl, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldl,
			func,
			A3($elm$core$Elm$JsArray$foldl, helper, baseCase, tree),
			tail);
	});
var $ktonon$elm_word$Word$Hex$fromArray = function (toHex) {
	return A2(
		$elm$core$Array$foldl,
		F2(
			function (val, acc) {
				return _Utils_ap(
					acc,
					toHex(val));
			}),
		'');
};
var $elm$core$String$cons = _String_cons;
var $elm$core$Char$fromCode = _Char_fromCode;
var $ktonon$elm_word$Word$Hex$fromIntAccumulator = function (x) {
	return $elm$core$String$cons(
		$elm$core$Char$fromCode(
			(x < 10) ? (x + 48) : ((x + 97) - 10)));
};
var $ktonon$elm_word$Word$Hex$fromInt = F2(
	function (charCount, value) {
		return A3(
			$elm$core$List$foldl,
			function (i) {
				return $ktonon$elm_word$Word$Hex$fromIntAccumulator(
					15 & (value >>> (i * A2($elm$core$Basics$pow, 2, 2))));
			},
			'',
			A2($elm$core$List$range, 0, charCount - 1));
	});
var $ktonon$elm_word$Word$Hex$fromWord = function (word) {
	switch (word.$) {
		case 'W':
			var x = word.a;
			return A2($ktonon$elm_word$Word$Hex$fromInt, 8, x);
		case 'D':
			var h = word.a;
			var l = word.b;
			return _Utils_ap(
				A2($ktonon$elm_word$Word$Hex$fromInt, 8, h),
				A2($ktonon$elm_word$Word$Hex$fromInt, 8, l));
		default:
			return 'M';
	}
};
var $ktonon$elm_word$Word$Hex$fromWordArray = $ktonon$elm_word$Word$Hex$fromArray($ktonon$elm_word$Word$Hex$fromWord);
var $ktonon$elm_crypto$Crypto$Hash$sha256 = function (message) {
	return $ktonon$elm_word$Word$Hex$fromWordArray(
		A2(
			$ktonon$elm_crypto$Crypto$SHA$digest,
			$ktonon$elm_crypto$Crypto$SHA$Alg$SHA256,
			$ktonon$elm_word$Word$Bytes$fromUTF8(message)));
};
var $elm$file$File$toBytes = _File_toBytes;
var $elm$bytes$Bytes$Encode$getWidth = function (builder) {
	switch (builder.$) {
		case 'I8':
			return 1;
		case 'I16':
			return 2;
		case 'I32':
			return 4;
		case 'U8':
			return 1;
		case 'U16':
			return 2;
		case 'U32':
			return 4;
		case 'F32':
			return 4;
		case 'F64':
			return 8;
		case 'Seq':
			var w = builder.a;
			return w;
		case 'Utf8':
			var w = builder.a;
			return w;
		default:
			var bs = builder.a;
			return _Bytes_width(bs);
	}
};
var $elm$bytes$Bytes$LE = {$: 'LE'};
var $elm$bytes$Bytes$Encode$write = F3(
	function (builder, mb, offset) {
		switch (builder.$) {
			case 'I8':
				var n = builder.a;
				return A3(_Bytes_write_i8, mb, offset, n);
			case 'I16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'I32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U8':
				var n = builder.a;
				return A3(_Bytes_write_u8, mb, offset, n);
			case 'U16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F64':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f64,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'Seq':
				var bs = builder.b;
				return A3($elm$bytes$Bytes$Encode$writeSequence, bs, mb, offset);
			case 'Utf8':
				var s = builder.b;
				return A3(_Bytes_write_string, mb, offset, s);
			default:
				var bs = builder.a;
				return A3(_Bytes_write_bytes, mb, offset, bs);
		}
	});
var $elm$bytes$Bytes$Encode$writeSequence = F3(
	function (builders, mb, offset) {
		writeSequence:
		while (true) {
			if (!builders.b) {
				return offset;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$builders = bs,
					$temp$mb = mb,
					$temp$offset = A3($elm$bytes$Bytes$Encode$write, b, mb, offset);
				builders = $temp$builders;
				mb = $temp$mb;
				offset = $temp$offset;
				continue writeSequence;
			}
		}
	});
var $elm$bytes$Bytes$Decode$decode = F2(
	function (_v0, bs) {
		var decoder = _v0.a;
		return A2(_Bytes_decode, decoder, bs);
	});
var $elm$bytes$Bytes$Decode$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$bytes$Bytes$Decode$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $elm$bytes$Bytes$Decode$Decoder = function (a) {
	return {$: 'Decoder', a: a};
};
var $elm$bytes$Bytes$Decode$map = F2(
	function (func, _v0) {
		var decodeA = _v0.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v1 = A2(decodeA, bites, offset);
					var aOffset = _v1.a;
					var a = _v1.b;
					return _Utils_Tuple2(
						aOffset,
						func(a));
				}));
	});
var $elm$bytes$Bytes$Decode$succeed = function (a) {
	return $elm$bytes$Bytes$Decode$Decoder(
		F2(
			function (_v0, offset) {
				return _Utils_Tuple2(offset, a);
			}));
};
var $jxxcarlson$hex$Hex$Convert$listStep = F2(
	function (decoder, _v0) {
		var n = _v0.a;
		var xs = _v0.b;
		return (n <= 0) ? $elm$bytes$Bytes$Decode$succeed(
			$elm$bytes$Bytes$Decode$Done(xs)) : A2(
			$elm$bytes$Bytes$Decode$map,
			function (x) {
				return $elm$bytes$Bytes$Decode$Loop(
					_Utils_Tuple2(
						n - 1,
						A2($elm$core$List$cons, x, xs)));
			},
			decoder);
	});
var $elm$bytes$Bytes$Decode$loopHelp = F4(
	function (state, callback, bites, offset) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var decoder = _v0.a;
			var _v1 = A2(decoder, bites, offset);
			var newOffset = _v1.a;
			var step = _v1.b;
			if (step.$ === 'Loop') {
				var newState = step.a;
				var $temp$state = newState,
					$temp$callback = callback,
					$temp$bites = bites,
					$temp$offset = newOffset;
				state = $temp$state;
				callback = $temp$callback;
				bites = $temp$bites;
				offset = $temp$offset;
				continue loopHelp;
			} else {
				var result = step.a;
				return _Utils_Tuple2(newOffset, result);
			}
		}
	});
var $elm$bytes$Bytes$Decode$loop = F2(
	function (state, callback) {
		return $elm$bytes$Bytes$Decode$Decoder(
			A2($elm$bytes$Bytes$Decode$loopHelp, state, callback));
	});
var $jxxcarlson$hex$Hex$Convert$decodeBytes = F2(
	function (len, decoder) {
		return A2(
			$elm$bytes$Bytes$Decode$loop,
			_Utils_Tuple2(len, _List_Nil),
			$jxxcarlson$hex$Hex$Convert$listStep(decoder));
	});
var $jxxcarlson$hex$Hex$Convert$stringOfHexDigit = function (n) {
	if (n < 10) {
		return $elm$core$String$fromInt(n);
	} else {
		switch (n) {
			case 10:
				return 'A';
			case 11:
				return 'B';
			case 12:
				return 'C';
			case 13:
				return 'D';
			case 14:
				return 'E';
			case 15:
				return 'F';
			default:
				return 'X';
		}
	}
};
var $jxxcarlson$hex$Hex$Convert$hexStringOfInt = function (b) {
	var low = A2($elm$core$Basics$modBy, 16, b);
	var hi = (b / 16) | 0;
	return _Utils_ap(
		$jxxcarlson$hex$Hex$Convert$stringOfHexDigit(hi),
		$jxxcarlson$hex$Hex$Convert$stringOfHexDigit(low));
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$bytes$Bytes$Decode$unsignedInt8 = $elm$bytes$Bytes$Decode$Decoder(_Bytes_read_u8);
var $elm$bytes$Bytes$width = _Bytes_width;
var $jxxcarlson$hex$Hex$Convert$toString = function (bytes_) {
	return A2(
		$elm$core$Maybe$withDefault,
		'Error',
		A2(
			$elm$core$Maybe$map,
			A2(
				$elm$core$Basics$composeR,
				$elm$core$List$reverse,
				A2(
					$elm$core$Basics$composeR,
					$elm$core$List$map($jxxcarlson$hex$Hex$Convert$hexStringOfInt),
					$elm$core$String$join(''))),
			A2(
				$elm$bytes$Bytes$Decode$decode,
				A2(
					$jxxcarlson$hex$Hex$Convert$decodeBytes,
					$elm$bytes$Bytes$width(bytes_),
					$elm$bytes$Bytes$Decode$unsignedInt8),
				bytes_)));
};
var $author$project$Page$Profile$UploadResult = function (a) {
	return {$: 'UploadResult', a: a};
};
var $author$project$Page$Profile$BadStatus = F2(
	function (a, b) {
		return {$: 'BadStatus', a: a, b: b};
	});
var $author$project$Page$Profile$BadUrl = function (a) {
	return {$: 'BadUrl', a: a};
};
var $author$project$Page$Profile$NetworkError = {$: 'NetworkError'};
var $author$project$Page$Profile$Timeout = {$: 'Timeout'};
var $author$project$Page$Profile$convertResponseString = function (httpResponse) {
	switch (httpResponse.$) {
		case 'BadUrl_':
			var url = httpResponse.a;
			return $elm$core$Result$Err(
				$author$project$Page$Profile$BadUrl(url));
		case 'Timeout_':
			return $elm$core$Result$Err($author$project$Page$Profile$Timeout);
		case 'NetworkError_':
			return $elm$core$Result$Err($author$project$Page$Profile$NetworkError);
		case 'BadStatus_':
			var metadata = httpResponse.a;
			var body = httpResponse.b;
			return $elm$core$Result$Err(
				A2($author$project$Page$Profile$BadStatus, metadata, body));
		default:
			var metadata = httpResponse.a;
			var body = httpResponse.b;
			return $elm$core$Result$Ok(
				_Utils_Tuple2(metadata, body));
	}
};
var $author$project$Page$Profile$expectStringDetailed = function (msg) {
	return A2($elm$http$Http$expectStringResponse, msg, $author$project$Page$Profile$convertResponseString);
};
var $elm$http$Http$fileBody = _Http_pair('');
var $author$project$Page$Profile$uploadToS3 = F2(
	function (file, creds) {
		var the_url = 'http://greek.coin.user.images.s3.amazonaws.com' + creds.path;
		var request = $elm$http$Http$request(
			{
				body: $elm$http$Http$fileBody(file),
				expect: $author$project$Page$Profile$expectStringDetailed($author$project$Page$Profile$UploadResult),
				headers: _List_fromArray(
					[
						A2($elm$http$Http$header, 'X-Amz-Content-Sha256', creds.hash),
						A2($elm$http$Http$header, 'X-Amz-Date', creds.date),
						A2($elm$http$Http$header, 'Authorization', creds.auth_header),
						A2($elm$http$Http$header, 'Content-Type', 'application/x-www-form-urlencoded')
					]),
				method: 'PUT',
				timeout: $elm$core$Maybe$Nothing,
				tracker: $elm$core$Maybe$Nothing,
				url: the_url
			});
		var _v0 = A2($elm$core$Debug$log, 'path: ', the_url);
		var _v1 = A2($elm$core$Debug$log, 'hash: ', creds.hash);
		var _v2 = A2($elm$core$Debug$log, 'creds_header: ', creds.auth_header);
		var _v3 = A2($elm$core$Debug$log, 'date', creds.date);
		return request;
	});
var $author$project$Page$Profile$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'GotFiles':
				var files = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							currentFile: $elm$core$List$head(files)
						}),
					$elm$core$Platform$Cmd$none);
			case 'GotFileSha':
				var hash = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{currentFileHash: hash}),
					A2(
						$NoRedInk$http_upgrade_shim$Http$Legacy$send,
						$author$project$Page$Profile$GotUploadCreds,
						A2($author$project$Page$Profile$getUploadCreds, '/users/nikolis/user.jpg', hash)));
			case 'UploadResult':
				if (msg.a.$ === 'Err') {
					var err = msg.a.a;
					var _v1 = A2(
						$elm$core$Debug$log,
						'error while uploading',
						$elm$core$Debug$toString(err));
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				} else {
					var sth = msg.a.a;
					var _v2 = A2(
						$elm$core$Debug$log,
						'success in uplading',
						$elm$core$Debug$toString(sth));
					return _Utils_Tuple2(
						model,
						A2(
							$NoRedInk$http_upgrade_shim$Http$Legacy$send,
							$author$project$Page$Profile$GotViewUrl,
							$author$project$Page$Profile$getViewUrl('users/nikolis/user.jpg')));
				}
			case 'GotUploadCreds':
				if (msg.a.$ === 'Err') {
					var err = msg.a.a;
					var _v3 = A2(
						$elm$core$Debug$log,
						'error in up cred',
						$elm$core$Debug$toString(err));
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				} else {
					var upCreds = msg.a.a;
					var _v4 = A2(
						$elm$core$Debug$log,
						'succees',
						$elm$core$Debug$toString(upCreds));
					var _v5 = model.currentFile;
					if (_v5.$ === 'Just') {
						var file = _v5.a;
						var _v6 = A2(
							$elm$core$Debug$log,
							'the file is: ',
							$elm$file$File$name(file));
						return _Utils_Tuple2(
							model,
							A2($author$project$Page$Profile$uploadToS3, file, upCreds));
					} else {
						return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
					}
				}
			case 'GotViewUrl':
				if (msg.a.$ === 'Err') {
					var err = msg.a.a;
					var _v7 = A2(
						$elm$core$Debug$log,
						'error getint url:',
						$elm$core$Debug$toString(err));
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				} else {
					var okUrl = msg.a.a;
					var _v8 = A2($elm$core$Debug$log, 'the url', okUrl.url);
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{currentFileUrl: okUrl.url}),
						$elm$core$Platform$Cmd$none);
				}
			case 'ClickedDismissErrors':
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{errors: _List_Nil}),
					$elm$core$Platform$Cmd$none);
			case 'GotTimeZone':
				var tz = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{timeZone: tz}),
					$elm$core$Platform$Cmd$none);
			case 'GotSession':
				var session = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{session: session}),
					A2(
						$author$project$Route$replaceUrl,
						$author$project$Session$navKey(session),
						$author$project$Route$Home));
			case 'LoadImmage':
				return _Utils_Tuple2(
					model,
					$author$project$Page$Profile$fileInput(_Utils_Tuple0));
			case 'ImmageLoaded':
				var file = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							currentFile: $elm$core$Maybe$Just(file)
						}),
					A2(
						$elm$core$Task$perform,
						$author$project$Page$Profile$GotImageBytes,
						$elm$file$File$toBytes(file)));
			case 'GotImageBytes':
				var bytes = msg.a;
				var hex_string = $jxxcarlson$hex$Hex$Convert$toString(bytes);
				var hash = $ktonon$elm_crypto$Crypto$Hash$sha256(hex_string);
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{currentFileHash: hash}),
					$elm$core$Platform$Cmd$none);
			default:
				var feed = function () {
					var _v9 = model.feed;
					if (_v9.$ === 'Loading') {
						var username = _v9.a;
						return $author$project$Page$Profile$LoadingSlowly(username);
					} else {
						var other = _v9;
						return other;
					}
				}();
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{feed: feed}),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$Register$CompletedRegister = function (a) {
	return {$: 'CompletedRegister', a: a};
};
var $author$project$Page$Register$ServerError = function (a) {
	return {$: 'ServerError', a: a};
};
var $author$project$Api$Endpoint$users = A2(
	$author$project$Api$Endpoint$url,
	_List_fromArray(
		['users']),
	_List_Nil);
var $author$project$Api$register = F2(
	function (body, decoder) {
		return A4(
			$author$project$Api$post,
			$author$project$Api$Endpoint$users,
			$elm$core$Maybe$Nothing,
			body,
			A2(
				$elm$json$Json$Decode$field,
				'user',
				$author$project$Api$decoderFromCred(decoder)));
	});
var $author$project$Page$Register$register = function (_v0) {
	var form = _v0.a;
	var user = $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'username',
				$elm$json$Json$Encode$string(form.username)),
				_Utils_Tuple2(
				'email',
				$elm$json$Json$Encode$string(form.email)),
				_Utils_Tuple2(
				'password',
				$elm$json$Json$Encode$string(form.password))
			]));
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2('user', user)
				])));
	return A2($author$project$Api$register, body, $author$project$Viewer$decoder);
};
var $author$project$Page$Register$updateForm = F2(
	function (transform, model) {
		return _Utils_Tuple2(
			_Utils_update(
				model,
				{
					form: transform(model.form)
				}),
			$elm$core$Platform$Cmd$none);
	});
var $author$project$Page$Register$Email = {$: 'Email'};
var $author$project$Page$Register$Password = {$: 'Password'};
var $author$project$Page$Register$Username = {$: 'Username'};
var $author$project$Page$Register$fieldsToValidate = _List_fromArray(
	[$author$project$Page$Register$Username, $author$project$Page$Register$Email, $author$project$Page$Register$Password]);
var $author$project$Page$Register$Trimmed = function (a) {
	return {$: 'Trimmed', a: a};
};
var $author$project$Page$Register$trimFields = function (form) {
	return $author$project$Page$Register$Trimmed(
		{
			email: $elm$core$String$trim(form.email),
			password: $elm$core$String$trim(form.password),
			username: $elm$core$String$trim(form.username)
		});
};
var $author$project$Page$Register$InvalidEntry = F2(
	function (a, b) {
		return {$: 'InvalidEntry', a: a, b: b};
	});
var $author$project$Viewer$minPasswordChars = 6;
var $author$project$Page$Register$validateField = F2(
	function (_v0, field) {
		var form = _v0.a;
		return A2(
			$elm$core$List$map,
			$author$project$Page$Register$InvalidEntry(field),
			function () {
				switch (field.$) {
					case 'Username':
						return $elm$core$String$isEmpty(form.username) ? _List_fromArray(
							['username can\'t be blank.']) : _List_Nil;
					case 'Email':
						return $elm$core$String$isEmpty(form.email) ? _List_fromArray(
							['email can\'t be blank.']) : _List_Nil;
					default:
						return $elm$core$String$isEmpty(form.password) ? _List_fromArray(
							['password can\'t be blank.']) : ((_Utils_cmp(
							$elm$core$String$length(form.password),
							$author$project$Viewer$minPasswordChars) < 0) ? _List_fromArray(
							[
								'password must be at least ' + ($elm$core$String$fromInt($author$project$Viewer$minPasswordChars) + ' characters long.')
							]) : _List_Nil);
				}
			}());
	});
var $author$project$Page$Register$validate = function (form) {
	var trimmedForm = $author$project$Page$Register$trimFields(form);
	var _v0 = A2(
		$elm$core$List$concatMap,
		$author$project$Page$Register$validateField(trimmedForm),
		$author$project$Page$Register$fieldsToValidate);
	if (!_v0.b) {
		return $elm$core$Result$Ok(trimmedForm);
	} else {
		var problems = _v0;
		return $elm$core$Result$Err(problems);
	}
};
var $author$project$Page$Register$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'SubmittedForm':
				var _v1 = $author$project$Page$Register$validate(model.form);
				if (_v1.$ === 'Ok') {
					var validForm = _v1.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{problems: _List_Nil}),
						A2(
							$NoRedInk$http_upgrade_shim$Http$Legacy$send,
							$author$project$Page$Register$CompletedRegister,
							$author$project$Page$Register$register(validForm)));
				} else {
					var problems = _v1.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{problems: problems}),
						$elm$core$Platform$Cmd$none);
				}
			case 'EnteredUsername':
				var username = msg.a;
				return A2(
					$author$project$Page$Register$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{username: username});
					},
					model);
			case 'EnteredEmail':
				var email = msg.a;
				return A2(
					$author$project$Page$Register$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{email: email});
					},
					model);
			case 'EnteredPassword':
				var password = msg.a;
				return A2(
					$author$project$Page$Register$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{password: password});
					},
					model);
			case 'CompletedRegister':
				if (msg.a.$ === 'Err') {
					var error = msg.a.a;
					var serverErrors = A2(
						$elm$core$List$map,
						$author$project$Page$Register$ServerError,
						$author$project$Api$decodeErrors(error));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								problems: A2($elm$core$List$append, model.problems, serverErrors)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var viewer = msg.a.a;
					return _Utils_Tuple2(
						model,
						$author$project$Viewer$store(viewer));
				}
			default:
				var session = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{session: session}),
					A2(
						$author$project$Route$replaceUrl,
						$author$project$Session$navKey(session),
						$author$project$Route$Home));
		}
	});
var $author$project$Page$Settings$CompletedSave = function (a) {
	return {$: 'CompletedSave', a: a};
};
var $author$project$Page$Settings$Failed = {$: 'Failed'};
var $author$project$Page$Settings$Loaded = function (a) {
	return {$: 'Loaded', a: a};
};
var $author$project$Page$Settings$LoadingSlowly = {$: 'LoadingSlowly'};
var $author$project$Page$Settings$ServerError = function (a) {
	return {$: 'ServerError', a: a};
};
var $author$project$Api$settings = F3(
	function (cred, body, decoder) {
		return A4(
			$author$project$Api$put,
			$author$project$Api$Endpoint$user,
			cred,
			body,
			A2(
				$elm$json$Json$Decode$field,
				'user',
				$author$project$Api$decoderFromCred(decoder)));
	});
var $author$project$Page$Settings$edit = F2(
	function (cred, _v0) {
		var form = _v0.a;
		var encodedAvatar = function () {
			var _v2 = form.avatar;
			if (_v2 === '') {
				return $elm$json$Json$Encode$null;
			} else {
				var avatar = _v2;
				return $elm$json$Json$Encode$string(avatar);
			}
		}();
		var updates = _List_fromArray(
			[
				_Utils_Tuple2(
				'username',
				$elm$json$Json$Encode$string(form.username)),
				_Utils_Tuple2(
				'email',
				$elm$json$Json$Encode$string(form.email)),
				_Utils_Tuple2(
				'bio',
				$elm$json$Json$Encode$string(form.bio)),
				_Utils_Tuple2('image', encodedAvatar)
			]);
		var encodedUser = $elm$json$Json$Encode$object(
			function () {
				var _v1 = form.password;
				if (_v1 === '') {
					return updates;
				} else {
					var password = _v1;
					return A2(
						$elm$core$List$cons,
						_Utils_Tuple2(
							'password',
							$elm$json$Json$Encode$string(password)),
						updates);
				}
			}());
		var body = $NoRedInk$http_upgrade_shim$Http$Legacy$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2('user', encodedUser)
					])));
		return A3($author$project$Api$settings, cred, body, $author$project$Viewer$decoder);
	});
var $author$project$Page$Settings$updateForm = F2(
	function (transform, model) {
		var _v0 = model.status;
		if (_v0.$ === 'Loaded') {
			var form = _v0.a;
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{
						status: $author$project$Page$Settings$Loaded(
							transform(form))
					}),
				$elm$core$Platform$Cmd$none);
		} else {
			return _Utils_Tuple2(model, $author$project$Log$error);
		}
	});
var $author$project$Page$Settings$Email = {$: 'Email'};
var $author$project$Page$Settings$Password = {$: 'Password'};
var $author$project$Page$Settings$Username = {$: 'Username'};
var $author$project$Page$Settings$fieldsToValidate = _List_fromArray(
	[$author$project$Page$Settings$Username, $author$project$Page$Settings$Email, $author$project$Page$Settings$Password]);
var $author$project$Page$Settings$Trimmed = function (a) {
	return {$: 'Trimmed', a: a};
};
var $author$project$Page$Settings$trimFields = function (form) {
	return $author$project$Page$Settings$Trimmed(
		{
			avatar: $elm$core$String$trim(form.avatar),
			bio: $elm$core$String$trim(form.bio),
			email: $elm$core$String$trim(form.email),
			password: $elm$core$String$trim(form.password),
			username: $elm$core$String$trim(form.username)
		});
};
var $author$project$Page$Settings$InvalidEntry = F2(
	function (a, b) {
		return {$: 'InvalidEntry', a: a, b: b};
	});
var $author$project$Page$Settings$validateField = F2(
	function (_v0, field) {
		var form = _v0.a;
		return A2(
			$elm$core$List$map,
			$author$project$Page$Settings$InvalidEntry(field),
			function () {
				switch (field.$) {
					case 'Username':
						return $elm$core$String$isEmpty(form.username) ? _List_fromArray(
							['username can\'t be blank.']) : _List_Nil;
					case 'Email':
						return $elm$core$String$isEmpty(form.email) ? _List_fromArray(
							['email can\'t be blank.']) : _List_Nil;
					default:
						var passwordLength = $elm$core$String$length(form.password);
						return ((passwordLength > 0) && (_Utils_cmp(passwordLength, $author$project$Viewer$minPasswordChars) < 0)) ? _List_fromArray(
							[
								'password must be at least ' + ($elm$core$String$fromInt($author$project$Viewer$minPasswordChars) + ' characters long.')
							]) : _List_Nil;
				}
			}());
	});
var $author$project$Page$Settings$validate = function (form) {
	var trimmedForm = $author$project$Page$Settings$trimFields(form);
	var _v0 = A2(
		$elm$core$List$concatMap,
		$author$project$Page$Settings$validateField(trimmedForm),
		$author$project$Page$Settings$fieldsToValidate);
	if (!_v0.b) {
		return $elm$core$Result$Ok(trimmedForm);
	} else {
		var problems = _v0;
		return $elm$core$Result$Err(problems);
	}
};
var $author$project$Page$Settings$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'CompletedFormLoad':
				if (msg.a.$ === 'Ok') {
					var form = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								status: $author$project$Page$Settings$Loaded(form)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{status: $author$project$Page$Settings$Failed}),
						$elm$core$Platform$Cmd$none);
				}
			case 'SubmittedForm':
				var cred = msg.a;
				var form = msg.b;
				var _v1 = $author$project$Page$Settings$validate(form);
				if (_v1.$ === 'Ok') {
					var validForm = _v1.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								status: $author$project$Page$Settings$Loaded(form)
							}),
						A2(
							$NoRedInk$http_upgrade_shim$Http$Legacy$send,
							$author$project$Page$Settings$CompletedSave,
							A2($author$project$Page$Settings$edit, cred, validForm)));
				} else {
					var problems = _v1.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{problems: problems}),
						$elm$core$Platform$Cmd$none);
				}
			case 'EnteredEmail':
				var email = msg.a;
				return A2(
					$author$project$Page$Settings$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{email: email});
					},
					model);
			case 'EnteredUsername':
				var username = msg.a;
				return A2(
					$author$project$Page$Settings$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{username: username});
					},
					model);
			case 'EnteredPassword':
				var password = msg.a;
				return A2(
					$author$project$Page$Settings$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{password: password});
					},
					model);
			case 'EnteredBio':
				var bio = msg.a;
				return A2(
					$author$project$Page$Settings$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{bio: bio});
					},
					model);
			case 'EnteredAvatar':
				var avatar = msg.a;
				return A2(
					$author$project$Page$Settings$updateForm,
					function (form) {
						return _Utils_update(
							form,
							{avatar: avatar});
					},
					model);
			case 'CompletedSave':
				if (msg.a.$ === 'Err') {
					var error = msg.a.a;
					var serverErrors = A2(
						$elm$core$List$map,
						$author$project$Page$Settings$ServerError,
						$author$project$Api$decodeErrors(error));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								problems: A2($elm$core$List$append, model.problems, serverErrors)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					var viewer = msg.a.a;
					return _Utils_Tuple2(
						model,
						$author$project$Viewer$store(viewer));
				}
			case 'GotSession':
				var session = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{session: session}),
					A2(
						$author$project$Route$replaceUrl,
						$author$project$Session$navKey(session),
						$author$project$Route$Home));
			default:
				var _v2 = model.status;
				if (_v2.$ === 'Loading') {
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{status: $author$project$Page$Settings$LoadingSlowly}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
		}
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		var _v0 = _Utils_Tuple2(msg, model);
		_v0$12:
		while (true) {
			switch (_v0.a.$) {
				case 'ClickedLink':
					var urlRequest = _v0.a.a;
					if (urlRequest.$ === 'Internal') {
						var url = urlRequest.a;
						var _v2 = url.fragment;
						if (_v2.$ === 'Nothing') {
							return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
						} else {
							return _Utils_Tuple2(
								model,
								A2(
									$elm$browser$Browser$Navigation$pushUrl,
									$author$project$Session$navKey(
										$author$project$Main$toSession(model)),
									$elm$url$Url$toString(url)));
						}
					} else {
						var href = urlRequest.a;
						return _Utils_Tuple2(
							model,
							$elm$browser$Browser$Navigation$load(href));
					}
				case 'ChangedUrl':
					var url = _v0.a.a;
					return A2(
						$author$project$Main$changeRouteTo,
						$author$project$Route$fromUrl(url),
						model);
				case 'ChangedRoute':
					var route = _v0.a.a;
					return A2($author$project$Main$changeRouteTo, route, model);
				case 'GotSettingsMsg':
					if (_v0.b.$ === 'Settings') {
						var subMsg = _v0.a.a;
						var settings = _v0.b.a;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Settings,
							$author$project$Main$GotSettingsMsg,
							model,
							A2($author$project$Page$Settings$update, subMsg, settings));
					} else {
						break _v0$12;
					}
				case 'GotLoginMsg':
					if (_v0.b.$ === 'Login') {
						var subMsg = _v0.a.a;
						var login = _v0.b.a;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Login,
							$author$project$Main$GotLoginMsg,
							model,
							A2($author$project$Page$Login$update, subMsg, login));
					} else {
						break _v0$12;
					}
				case 'GotRegisterMsg':
					if (_v0.b.$ === 'Register') {
						var subMsg = _v0.a.a;
						var register = _v0.b.a;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Register,
							$author$project$Main$GotRegisterMsg,
							model,
							A2($author$project$Page$Register$update, subMsg, register));
					} else {
						break _v0$12;
					}
				case 'GotHomeMsg':
					if (_v0.b.$ === 'Home') {
						var subMsg = _v0.a.a;
						var home = _v0.b.a;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Home,
							$author$project$Main$GotHomeMsg,
							model,
							A2($author$project$Page$Home$update, subMsg, home));
					} else {
						break _v0$12;
					}
				case 'GotPricesMsg':
					if (_v0.b.$ === 'Prices') {
						var subMsg = _v0.a.a;
						var prices = _v0.b.a;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Prices,
							$author$project$Main$GotPricesMsg,
							model,
							A2($author$project$Page$Prices$update, subMsg, prices));
					} else {
						break _v0$12;
					}
				case 'GotProfileMsg':
					if (_v0.b.$ === 'Profile') {
						var subMsg = _v0.a.a;
						var _v3 = _v0.b;
						var username = _v3.a;
						var profile = _v3.b;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Profile(username),
							$author$project$Main$GotProfileMsg,
							model,
							A2($author$project$Page$Profile$update, subMsg, profile));
					} else {
						break _v0$12;
					}
				case 'GotArticleMsg':
					if (_v0.b.$ === 'Article') {
						var subMsg = _v0.a.a;
						var article = _v0.b.a;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Article,
							$author$project$Main$GotArticleMsg,
							model,
							A2($author$project$Page$Article$update, subMsg, article));
					} else {
						break _v0$12;
					}
				case 'GotEditorMsg':
					if (_v0.b.$ === 'Editor') {
						var subMsg = _v0.a.a;
						var _v4 = _v0.b;
						var slug = _v4.a;
						var editor = _v4.b;
						return A4(
							$author$project$Main$updateWith,
							$author$project$Main$Editor(slug),
							$author$project$Main$GotEditorMsg,
							model,
							A2($author$project$Page$Article$Editor$update, subMsg, editor));
					} else {
						break _v0$12;
					}
				default:
					if (_v0.b.$ === 'Redirect') {
						var session = _v0.a.a;
						return _Utils_Tuple2(
							$author$project$Main$Redirect(session),
							A2(
								$author$project$Route$replaceUrl,
								$author$project$Session$navKey(session),
								$author$project$Route$Home));
					} else {
						break _v0$12;
					}
			}
		}
		return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
	});
var $author$project$Page$Home = {$: 'Home'};
var $author$project$Page$NewArticle = {$: 'NewArticle'};
var $author$project$Page$Other = {$: 'Other'};
var $author$project$Page$Prices = {$: 'Prices'};
var $author$project$Page$Profile = function (a) {
	return {$: 'Profile', a: a};
};
var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var $elm$html$Html$map = $elm$virtual_dom$VirtualDom$map;
var $elm$html$Html$a = _VirtualDom_node('a');
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$html$Html$footer = _VirtualDom_node('footer');
var $elm$html$Html$h5 = _VirtualDom_node('h5');
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $author$project$Route$href = function (targetRoute) {
	return $elm$html$Html$Attributes$href(
		$author$project$Route$routeToString(targetRoute));
};
var $elm$html$Html$li = _VirtualDom_node('li');
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $elm$html$Html$ul = _VirtualDom_node('ul');
var $author$project$Page$viewFooter = A2(
	$elm$html$Html$footer,
	_List_Nil,
	_List_fromArray(
		[
			A2(
			$elm$html$Html$footer,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('page-footer font-small blue pt-4')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container text-center text-md-left')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-3 mx-auto')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h5,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('font-weight-bold text-uppercase mt-3 mb-4')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Links 1')
												])),
											A2(
											$elm$html$Html$ul,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('list-unstyled')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$li,
													_List_Nil,
													_List_fromArray(
														[
															A2(
															$elm$html$Html$a,
															_List_fromArray(
																[
																	$author$project$Route$href($author$project$Route$Home)
																]),
															_List_fromArray(
																[
																	$elm$html$Html$text('Home or something')
																]))
														]))
												]))
										]))
								]))
						]))
				]))
		]));
var $elm$html$Html$nav = _VirtualDom_node('nav');
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $elm$html$Html$Attributes$classList = function (classes) {
	return $elm$html$Html$Attributes$class(
		A2(
			$elm$core$String$join,
			' ',
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$first,
				A2($elm$core$List$filter, $elm$core$Tuple$second, classes))));
};
var $author$project$Page$isActive = F2(
	function (page, route) {
		var _v0 = _Utils_Tuple2(page, route);
		_v0$7:
		while (true) {
			switch (_v0.a.$) {
				case 'Home':
					if (_v0.b.$ === 'Home') {
						var _v1 = _v0.a;
						var _v2 = _v0.b;
						return true;
					} else {
						break _v0$7;
					}
				case 'Prices':
					if (_v0.b.$ === 'Prices') {
						var _v3 = _v0.a;
						var _v4 = _v0.b;
						return true;
					} else {
						break _v0$7;
					}
				case 'Login':
					if (_v0.b.$ === 'Login') {
						var _v5 = _v0.a;
						var _v6 = _v0.b;
						return true;
					} else {
						break _v0$7;
					}
				case 'Register':
					if (_v0.b.$ === 'Register') {
						var _v7 = _v0.a;
						var _v8 = _v0.b;
						return true;
					} else {
						break _v0$7;
					}
				case 'Settings':
					if (_v0.b.$ === 'Settings') {
						var _v9 = _v0.a;
						var _v10 = _v0.b;
						return true;
					} else {
						break _v0$7;
					}
				case 'Profile':
					if (_v0.b.$ === 'Profile') {
						var pageUsername = _v0.a.a;
						var routeUsername = _v0.b.a;
						return _Utils_eq(pageUsername, routeUsername);
					} else {
						break _v0$7;
					}
				case 'NewArticle':
					if (_v0.b.$ === 'NewArticle') {
						var _v11 = _v0.a;
						var _v12 = _v0.b;
						return true;
					} else {
						break _v0$7;
					}
				default:
					break _v0$7;
			}
		}
		return false;
	});
var $author$project$Page$navbarLink = F3(
	function (page, route, linkContent) {
		return A2(
			$elm$html$Html$li,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$classList(
					_List_fromArray(
						[
							_Utils_Tuple2('nav-item', true),
							_Utils_Tuple2(
							'active',
							A2($author$project$Page$isActive, page, route))
						]))
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$a,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('nav-link'),
							$author$project$Route$href(route)
						]),
					linkContent)
				]));
	});
var $author$project$Viewer$avatar = function (_v0) {
	var val = _v0.a;
	return val;
};
var $elm$html$Html$i = _VirtualDom_node('i');
var $author$project$Username$toHtml = function (_v0) {
	var username = _v0.a;
	return $elm$html$Html$text(username);
};
var $author$project$Viewer$username = function (_v0) {
	var val = _v0.b;
	return $author$project$Api$username(val);
};
var $author$project$Page$viewMenu = F2(
	function (page, maybeViewer) {
		var linkTo = $author$project$Page$navbarLink(page);
		if (maybeViewer.$ === 'Just') {
			var viewer = maybeViewer.a;
			var username = $author$project$Viewer$username(viewer);
			var avatar = $author$project$Viewer$avatar(viewer);
			return _List_fromArray(
				[
					A2(
					linkTo,
					$author$project$Route$Prices,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$i,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('')
								]),
							_List_Nil),
							$elm$html$Html$text('Prices')
						])),
					A2(
					linkTo,
					$author$project$Route$NewArticle,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$i,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('ion-compose')
								]),
							_List_Nil),
							$elm$html$Html$text('\u00A0New Post')
						])),
					A2(
					linkTo,
					$author$project$Route$Settings,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$i,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('ion-gear-a')
								]),
							_List_Nil),
							$elm$html$Html$text('\u00A0Settings')
						])),
					A2(
					linkTo,
					$author$project$Route$Profile(username),
					_List_fromArray(
						[
							$author$project$Username$toHtml(username)
						])),
					A2(
					linkTo,
					$author$project$Route$Logout,
					_List_fromArray(
						[
							$elm$html$Html$text('Sign out')
						]))
				]);
		} else {
			return _List_fromArray(
				[
					A2(
					linkTo,
					$author$project$Route$Login,
					_List_fromArray(
						[
							$elm$html$Html$text('Sign in')
						])),
					A2(
					linkTo,
					$author$project$Route$Register,
					_List_fromArray(
						[
							$elm$html$Html$text('Sign up')
						]))
				]);
		}
	});
var $author$project$Page$viewHeader = F2(
	function (page, maybeViewer) {
		return A2(
			$elm$html$Html$nav,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('navbar navbar-expand-lg navbar-dark indigo accent-3  navbar_greek')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('navbar-brand'),
									$author$project$Route$href($author$project$Route$Home)
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Greek Coin')
								])),
							A2(
							$elm$html$Html$ul,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('nav navbar-nav pull-xs-right')
								]),
							A2(
								$elm$core$List$cons,
								A3(
									$author$project$Page$navbarLink,
									page,
									$author$project$Route$Home,
									_List_fromArray(
										[
											$elm$html$Html$text('Home')
										])),
								A2($author$project$Page$viewMenu, page, maybeViewer)))
						]))
				]));
	});
var $author$project$Page$view = F3(
	function (maybeViewer, page, _v0) {
		var title = _v0.title;
		var content = _v0.content;
		return {
			body: A2(
				$elm$core$List$cons,
				A2($author$project$Page$viewHeader, page, maybeViewer),
				A2(
					$elm$core$List$cons,
					content,
					_List_fromArray(
						[$author$project$Page$viewFooter]))),
			title: title + ' - Greek Coin'
		};
	});
var $author$project$Page$Article$ClickedDismissErrors = {$: 'ClickedDismissErrors'};
var $author$project$Article$author = function (_v0) {
	var internals = _v0.a;
	return internals.author;
};
var $author$project$Profile$avatar = function (_v0) {
	var info = _v0.a;
	return info.avatar;
};
var $author$project$Loading$error = function (str) {
	return $elm$html$Html$text('Error loading ' + (str + '.'));
};
var $elm$html$Html$h1 = _VirtualDom_node('h1');
var $elm$html$Html$hr = _VirtualDom_node('hr');
var $elm$html$Html$Attributes$alt = $elm$html$Html$Attributes$stringProperty('alt');
var $elm$html$Html$Attributes$height = function (n) {
	return A2(
		_VirtualDom_attribute,
		'height',
		$elm$core$String$fromInt(n));
};
var $elm$html$Html$img = _VirtualDom_node('img');
var $author$project$Asset$Image = function (a) {
	return {$: 'Image', a: a};
};
var $author$project$Asset$image = function (filename) {
	return $author$project$Asset$Image('/images/' + filename);
};
var $author$project$Asset$loading = $author$project$Asset$image('loading.svg');
var $elm$html$Html$Attributes$src = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'src',
		_VirtualDom_noJavaScriptOrHtmlUri(url));
};
var $author$project$Asset$src = function (_v0) {
	var url = _v0.a;
	return $elm$html$Html$Attributes$src(url);
};
var $elm$html$Html$Attributes$width = function (n) {
	return A2(
		_VirtualDom_attribute,
		'width',
		$elm$core$String$fromInt(n));
};
var $author$project$Loading$icon = A2(
	$elm$html$Html$img,
	_List_fromArray(
		[
			$author$project$Asset$src($author$project$Asset$loading),
			$elm$html$Html$Attributes$width(64),
			$elm$html$Html$Attributes$height(64),
			$elm$html$Html$Attributes$alt('Loading...')
		]),
	_List_Nil);
var $author$project$Author$profile = function (author) {
	switch (author.$) {
		case 'IsViewer':
			var val = author.b;
			return val;
		case 'IsFollowing':
			var _v1 = author.a;
			var val = _v1.b;
			return val;
		default:
			var _v2 = author.a;
			var val = _v2.b;
			return val;
	}
};
var $author$project$Asset$defaultAvatar = $author$project$Asset$image('smiley-cyrus.jpg');
var $author$project$Avatar$src = function (_v0) {
	var maybeUrl = _v0.a;
	if (maybeUrl.$ === 'Nothing') {
		return $author$project$Asset$src($author$project$Asset$defaultAvatar);
	} else {
		if (maybeUrl.a === '') {
			return $author$project$Asset$src($author$project$Asset$defaultAvatar);
		} else {
			var url = maybeUrl.a;
			return $elm$html$Html$Attributes$src(url);
		}
	}
};
var $elm_explorations$markdown$Markdown$defaultOptions = {
	defaultHighlighting: $elm$core$Maybe$Nothing,
	githubFlavored: $elm$core$Maybe$Just(
		{breaks: false, tables: false}),
	sanitize: true,
	smartypants: false
};
var $elm_explorations$markdown$Markdown$toHtmlWith = _Markdown_toHtml;
var $elm_explorations$markdown$Markdown$toHtml = $elm_explorations$markdown$Markdown$toHtmlWith($elm_explorations$markdown$Markdown$defaultOptions);
var $author$project$Article$Body$toHtml = F2(
	function (_v0, attributes) {
		var markdown = _v0.a;
		return A2($elm_explorations$markdown$Markdown$toHtml, attributes, markdown);
	});
var $author$project$Author$username = function (author) {
	switch (author.$) {
		case 'IsViewer':
			var cred = author.a;
			return $author$project$Api$username(cred);
		case 'IsFollowing':
			var _v1 = author.a;
			var val = _v1.a;
			return val;
		default:
			var _v2 = author.a;
			var val = _v2.a;
			return val;
	}
};
var $author$project$Author$view = function (uname) {
	return A2(
		$elm$html$Html$a,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('author'),
				$author$project$Route$href(
				$author$project$Route$Profile(uname))
			]),
		_List_fromArray(
			[
				$author$project$Username$toHtml(uname)
			]));
};
var $elm$time$Time$flooredDiv = F2(
	function (numerator, denominator) {
		return $elm$core$Basics$floor(numerator / denominator);
	});
var $elm$time$Time$posixToMillis = function (_v0) {
	var millis = _v0.a;
	return millis;
};
var $elm$time$Time$toAdjustedMinutesHelp = F3(
	function (defaultOffset, posixMinutes, eras) {
		toAdjustedMinutesHelp:
		while (true) {
			if (!eras.b) {
				return posixMinutes + defaultOffset;
			} else {
				var era = eras.a;
				var olderEras = eras.b;
				if (_Utils_cmp(era.start, posixMinutes) < 0) {
					return posixMinutes + era.offset;
				} else {
					var $temp$defaultOffset = defaultOffset,
						$temp$posixMinutes = posixMinutes,
						$temp$eras = olderEras;
					defaultOffset = $temp$defaultOffset;
					posixMinutes = $temp$posixMinutes;
					eras = $temp$eras;
					continue toAdjustedMinutesHelp;
				}
			}
		}
	});
var $elm$time$Time$toAdjustedMinutes = F2(
	function (_v0, time) {
		var defaultOffset = _v0.a;
		var eras = _v0.b;
		return A3(
			$elm$time$Time$toAdjustedMinutesHelp,
			defaultOffset,
			A2(
				$elm$time$Time$flooredDiv,
				$elm$time$Time$posixToMillis(time),
				60000),
			eras);
	});
var $elm$time$Time$toCivil = function (minutes) {
	var rawDay = A2($elm$time$Time$flooredDiv, minutes, 60 * 24) + 719468;
	var era = (((rawDay >= 0) ? rawDay : (rawDay - 146096)) / 146097) | 0;
	var dayOfEra = rawDay - (era * 146097);
	var yearOfEra = ((((dayOfEra - ((dayOfEra / 1460) | 0)) + ((dayOfEra / 36524) | 0)) - ((dayOfEra / 146096) | 0)) / 365) | 0;
	var dayOfYear = dayOfEra - (((365 * yearOfEra) + ((yearOfEra / 4) | 0)) - ((yearOfEra / 100) | 0));
	var mp = (((5 * dayOfYear) + 2) / 153) | 0;
	var month = mp + ((mp < 10) ? 3 : (-9));
	var year = yearOfEra + (era * 400);
	return {
		day: (dayOfYear - ((((153 * mp) + 2) / 5) | 0)) + 1,
		month: month,
		year: year + ((month <= 2) ? 1 : 0)
	};
};
var $elm$time$Time$toDay = F2(
	function (zone, time) {
		return $elm$time$Time$toCivil(
			A2($elm$time$Time$toAdjustedMinutes, zone, time)).day;
	});
var $elm$time$Time$Apr = {$: 'Apr'};
var $elm$time$Time$Aug = {$: 'Aug'};
var $elm$time$Time$Dec = {$: 'Dec'};
var $elm$time$Time$Feb = {$: 'Feb'};
var $elm$time$Time$Jan = {$: 'Jan'};
var $elm$time$Time$Jul = {$: 'Jul'};
var $elm$time$Time$Jun = {$: 'Jun'};
var $elm$time$Time$Mar = {$: 'Mar'};
var $elm$time$Time$May = {$: 'May'};
var $elm$time$Time$Nov = {$: 'Nov'};
var $elm$time$Time$Oct = {$: 'Oct'};
var $elm$time$Time$Sep = {$: 'Sep'};
var $elm$time$Time$toMonth = F2(
	function (zone, time) {
		var _v0 = $elm$time$Time$toCivil(
			A2($elm$time$Time$toAdjustedMinutes, zone, time)).month;
		switch (_v0) {
			case 1:
				return $elm$time$Time$Jan;
			case 2:
				return $elm$time$Time$Feb;
			case 3:
				return $elm$time$Time$Mar;
			case 4:
				return $elm$time$Time$Apr;
			case 5:
				return $elm$time$Time$May;
			case 6:
				return $elm$time$Time$Jun;
			case 7:
				return $elm$time$Time$Jul;
			case 8:
				return $elm$time$Time$Aug;
			case 9:
				return $elm$time$Time$Sep;
			case 10:
				return $elm$time$Time$Oct;
			case 11:
				return $elm$time$Time$Nov;
			default:
				return $elm$time$Time$Dec;
		}
	});
var $elm$time$Time$toYear = F2(
	function (zone, time) {
		return $elm$time$Time$toCivil(
			A2($elm$time$Time$toAdjustedMinutes, zone, time)).year;
	});
var $author$project$Timestamp$format = F2(
	function (zone, time) {
		var year = $elm$core$String$fromInt(
			A2($elm$time$Time$toYear, zone, time));
		var month = function () {
			var _v0 = A2($elm$time$Time$toMonth, zone, time);
			switch (_v0.$) {
				case 'Jan':
					return 'January';
				case 'Feb':
					return 'February';
				case 'Mar':
					return 'March';
				case 'Apr':
					return 'April';
				case 'May':
					return 'May';
				case 'Jun':
					return 'June';
				case 'Jul':
					return 'July';
				case 'Aug':
					return 'August';
				case 'Sep':
					return 'September';
				case 'Oct':
					return 'October';
				case 'Nov':
					return 'November';
				default:
					return 'December';
			}
		}();
		var day = $elm$core$String$fromInt(
			A2($elm$time$Time$toDay, zone, time));
		return month + (' ' + (day + (', ' + year)));
	});
var $elm$html$Html$span = _VirtualDom_node('span');
var $author$project$Timestamp$view = F2(
	function (timeZone, timestamp) {
		return A2(
			$elm$html$Html$span,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('date')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(
					A2($author$project$Timestamp$format, timeZone, timestamp))
				]));
	});
var $author$project$Page$Article$ClickedPostComment = F2(
	function (a, b) {
		return {$: 'ClickedPostComment', a: a, b: b};
	});
var $author$project$Page$Article$EnteredCommentText = function (a) {
	return {$: 'EnteredCommentText', a: a};
};
var $elm$virtual_dom$VirtualDom$attribute = F2(
	function (key, value) {
		return A2(
			_VirtualDom_attribute,
			_VirtualDom_noOnOrFormAction(key),
			_VirtualDom_noJavaScriptOrHtmlUri(value));
	});
var $elm$html$Html$Attributes$attribute = $elm$virtual_dom$VirtualDom$attribute;
var $elm$html$Html$button = _VirtualDom_node('button');
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$disabled = $elm$html$Html$Attributes$boolProperty('disabled');
var $elm$html$Html$form = _VirtualDom_node('form');
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 'MayStopPropagation', a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$Events$alwaysPreventDefault = function (msg) {
	return _Utils_Tuple2(msg, true);
};
var $elm$virtual_dom$VirtualDom$MayPreventDefault = function (a) {
	return {$: 'MayPreventDefault', a: a};
};
var $elm$html$Html$Events$preventDefaultOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayPreventDefault(decoder));
	});
var $elm$html$Html$Events$onSubmit = function (msg) {
	return A2(
		$elm$html$Html$Events$preventDefaultOn,
		'submit',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysPreventDefault,
			$elm$json$Json$Decode$succeed(msg)));
};
var $elm$html$Html$p = _VirtualDom_node('p');
var $elm$html$Html$Attributes$placeholder = $elm$html$Html$Attributes$stringProperty('placeholder');
var $elm$html$Html$textarea = _VirtualDom_node('textarea');
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$Page$Article$viewAddComment = F3(
	function (slug, commentText, maybeViewer) {
		if (maybeViewer.$ === 'Just') {
			var viewer = maybeViewer.a;
			var cred = $author$project$Viewer$cred(viewer);
			var avatar = $author$project$Viewer$avatar(viewer);
			var _v1 = function () {
				if (commentText.$ === 'Editing') {
					var str = commentText.a;
					return _Utils_Tuple2(str, _List_Nil);
				} else {
					var str = commentText.a;
					return _Utils_Tuple2(
						str,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$disabled(true)
							]));
				}
			}();
			var commentStr = _v1.a;
			var buttonAttrs = _v1.b;
			return A2(
				$elm$html$Html$form,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('card comment-form'),
						$elm$html$Html$Events$onSubmit(
						A2($author$project$Page$Article$ClickedPostComment, cred, slug))
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('card-block')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$textarea,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('form-control'),
										$elm$html$Html$Attributes$placeholder('Write a comment...'),
										A2($elm$html$Html$Attributes$attribute, 'rows', '3'),
										$elm$html$Html$Events$onInput($author$project$Page$Article$EnteredCommentText),
										$elm$html$Html$Attributes$value(commentStr)
									]),
								_List_Nil)
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('card-footer')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$img,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('comment-author-img'),
										$author$project$Avatar$src(avatar)
									]),
								_List_Nil),
								A2(
								$elm$html$Html$button,
								A2(
									$elm$core$List$cons,
									$elm$html$Html$Attributes$class('btn btn-sm btn-primary'),
									buttonAttrs),
								_List_fromArray(
									[
										$elm$html$Html$text('Post Comment')
									]))
							]))
					]));
		} else {
			return A2(
				$elm$html$Html$p,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$author$project$Route$href($author$project$Route$Login)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Sign in')
							])),
						$elm$html$Html$text(' or '),
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$author$project$Route$href($author$project$Route$Register)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('sign up')
							])),
						$elm$html$Html$text(' to comment.')
					]));
		}
	});
var $author$project$Page$Article$ClickedFollow = F2(
	function (a, b) {
		return {$: 'ClickedFollow', a: a, b: b};
	});
var $author$project$Page$Article$ClickedUnfollow = F2(
	function (a, b) {
		return {$: 'ClickedUnfollow', a: a, b: b};
	});
var $author$project$Page$Article$ClickedDeleteArticle = F2(
	function (a, b) {
		return {$: 'ClickedDeleteArticle', a: a, b: b};
	});
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 'Normal', a: a};
};
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$Page$Article$deleteButton = F2(
	function (cred, article) {
		var msg = A2(
			$author$project$Page$Article$ClickedDeleteArticle,
			cred,
			$author$project$Article$slug(article));
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('btn btn-outline-danger btn-sm'),
					$elm$html$Html$Events$onClick(msg)
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$i,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ion-trash-a')
						]),
					_List_Nil),
					$elm$html$Html$text(' Delete Article')
				]));
	});
var $author$project$Page$Article$editButton = function (article) {
	return A2(
		$elm$html$Html$a,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('btn btn-outline-secondary btn-sm'),
				$author$project$Route$href(
				$author$project$Route$EditArticle(
					$author$project$Article$slug(article)))
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$i,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ion-edit')
					]),
				_List_Nil),
				$elm$html$Html$text(' Edit Article')
			]));
};
var $author$project$Page$Article$ClickedFavorite = F3(
	function (a, b, c) {
		return {$: 'ClickedFavorite', a: a, b: b, c: c};
	});
var $author$project$Page$Article$ClickedUnfavorite = F3(
	function (a, b, c) {
		return {$: 'ClickedUnfavorite', a: a, b: b, c: c};
	});
var $author$project$Article$onClickStopPropagation = function (msg) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'click',
		$elm$json$Json$Decode$succeed(
			_Utils_Tuple2(msg, true)));
};
var $author$project$Article$toggleFavoriteButton = F4(
	function (classStr, msg, attrs, kids) {
		return A2(
			$elm$html$Html$button,
			A2(
				$elm$core$List$cons,
				$elm$html$Html$Attributes$class(classStr),
				A2(
					$elm$core$List$cons,
					$author$project$Article$onClickStopPropagation(msg),
					attrs)),
			A2(
				$elm$core$List$cons,
				A2(
					$elm$html$Html$i,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ion-heart')
						]),
					_List_Nil),
				kids));
	});
var $author$project$Article$favoriteButton = F4(
	function (_v0, msg, attrs, kids) {
		return A4($author$project$Article$toggleFavoriteButton, 'btn btn-sm btn-outline-primary', msg, attrs, kids);
	});
var $author$project$Article$unfavoriteButton = F4(
	function (_v0, msg, attrs, kids) {
		return A4($author$project$Article$toggleFavoriteButton, 'btn btn-sm btn-primary', msg, attrs, kids);
	});
var $author$project$Page$Article$favoriteButton = F2(
	function (cred, article) {
		var slug = $author$project$Article$slug(article);
		var body = $author$project$Article$body(article);
		var _v0 = $author$project$Article$metadata(article);
		var favoritesCount = _v0.favoritesCount;
		var favorited = _v0.favorited;
		var kids = _List_fromArray(
			[
				$elm$html$Html$text(
				' Favorite Article (' + ($elm$core$String$fromInt(favoritesCount) + ')'))
			]);
		return favorited ? A4(
			$author$project$Article$unfavoriteButton,
			cred,
			A3($author$project$Page$Article$ClickedUnfavorite, cred, slug, body),
			_List_Nil,
			kids) : A4(
			$author$project$Article$favoriteButton,
			cred,
			A3($author$project$Page$Article$ClickedFavorite, cred, slug, body),
			_List_Nil,
			kids);
	});
var $author$project$Author$toggleFollowButton = F4(
	function (txt, extraClasses, msgWhenClicked, uname) {
		var classStr = 'btn btn-sm ' + (A2($elm$core$String$join, ' ', extraClasses) + ' action-btn');
		var caption = '\u00A0' + (txt + (' ' + $author$project$Username$toString(uname)));
		return A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class(classStr),
					$elm$html$Html$Events$onClick(msgWhenClicked)
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$i,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ion-plus-round')
						]),
					_List_Nil),
					$elm$html$Html$text(caption)
				]));
	});
var $author$project$Author$followButton = F3(
	function (toMsg, cred, author) {
		var uname = author.a;
		return A4(
			$author$project$Author$toggleFollowButton,
			'Follow',
			_List_fromArray(
				['btn-outline-secondary']),
			A2(toMsg, cred, author),
			uname);
	});
var $author$project$Author$unfollowButton = F3(
	function (toMsg, cred, author) {
		var uname = author.a;
		return A4(
			$author$project$Author$toggleFollowButton,
			'Unfollow',
			_List_fromArray(
				['btn-secondary']),
			A2(toMsg, cred, author),
			uname);
	});
var $author$project$Page$Article$viewButtons = F3(
	function (cred, article, author) {
		switch (author.$) {
			case 'IsFollowing':
				var followedAuthor = author.a;
				return _List_fromArray(
					[
						A3($author$project$Author$unfollowButton, $author$project$Page$Article$ClickedUnfollow, cred, followedAuthor),
						$elm$html$Html$text(' '),
						A2($author$project$Page$Article$favoriteButton, cred, article)
					]);
			case 'IsNotFollowing':
				var unfollowedAuthor = author.a;
				return _List_fromArray(
					[
						A3($author$project$Author$followButton, $author$project$Page$Article$ClickedFollow, cred, unfollowedAuthor),
						$elm$html$Html$text(' '),
						A2($author$project$Page$Article$favoriteButton, cred, article)
					]);
			default:
				return _List_fromArray(
					[
						$author$project$Page$Article$editButton(article),
						$elm$html$Html$text(' '),
						A2($author$project$Page$Article$deleteButton, cred, article)
					]);
		}
	});
var $author$project$Page$Article$ClickedDeleteComment = F3(
	function (a, b, c) {
		return {$: 'ClickedDeleteComment', a: a, b: b, c: c};
	});
var $author$project$Article$Comment$author = function (_v0) {
	var comment = _v0.a;
	return comment.author;
};
var $author$project$Article$Comment$body = function (_v0) {
	var comment = _v0.a;
	return comment.body;
};
var $author$project$Article$Comment$createdAt = function (_v0) {
	var comment = _v0.a;
	return comment.createdAt;
};
var $author$project$Page$Article$viewComment = F3(
	function (timeZone, slug, comment) {
		var timestamp = A2(
			$author$project$Timestamp$format,
			timeZone,
			$author$project$Article$Comment$createdAt(comment));
		var author = $author$project$Article$Comment$author(comment);
		var authorUsername = $author$project$Author$username(author);
		var deleteCommentButton = function () {
			if (author.$ === 'IsViewer') {
				var cred = author.a;
				var msg = A3(
					$author$project$Page$Article$ClickedDeleteComment,
					cred,
					slug,
					$author$project$Article$Comment$id(comment));
				return A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('mod-options'),
							$elm$html$Html$Events$onClick(msg)
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$i,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('ion-trash-a')
								]),
							_List_Nil)
						]));
			} else {
				return $elm$html$Html$text('');
			}
		}();
		var profile = $author$project$Author$profile(author);
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('card')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('card-block')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$p,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('card-text')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									$author$project$Article$Comment$body(comment))
								]))
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('card-footer')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('comment-author'),
									$elm$html$Html$Attributes$href('')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$img,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('comment-author-img'),
											$author$project$Avatar$src(
											$author$project$Profile$avatar(profile))
										]),
									_List_Nil),
									$elm$html$Html$text(' ')
								])),
							$elm$html$Html$text(' '),
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('comment-author'),
									$author$project$Route$href(
									$author$project$Route$Profile(authorUsername))
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									$author$project$Username$toString(authorUsername))
								])),
							A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('date-posted')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(timestamp)
								])),
							deleteCommentButton
						]))
				]));
	});
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $author$project$Page$viewErrors = F2(
	function (dismissErrors, errors) {
		return $elm$core$List$isEmpty(errors) ? $elm$html$Html$text('') : A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('error-messages'),
					A2($elm$html$Html$Attributes$style, 'position', 'fixed'),
					A2($elm$html$Html$Attributes$style, 'top', '0'),
					A2($elm$html$Html$Attributes$style, 'background', 'rgb(250, 250, 250)'),
					A2($elm$html$Html$Attributes$style, 'padding', '20px'),
					A2($elm$html$Html$Attributes$style, 'border', '1px solid')
				]),
			_Utils_ap(
				A2(
					$elm$core$List$map,
					function (error) {
						return A2(
							$elm$html$Html$p,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(error)
								]));
					},
					errors),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Events$onClick(dismissErrors)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Ok')
							]))
					])));
	});
var $author$project$Session$viewer = function (session) {
	if (session.$ === 'LoggedIn') {
		var val = session.b;
		return $elm$core$Maybe$Just(val);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Page$Article$view = function (model) {
	var _v0 = model.article;
	switch (_v0.$) {
		case 'Loaded':
			var article = _v0.a;
			var slug = $author$project$Article$slug(article);
			var author = $author$project$Article$author(article);
			var avatar = $author$project$Profile$avatar(
				$author$project$Author$profile(author));
			var buttons = function () {
				var _v4 = $author$project$Session$cred(model.session);
				if (_v4.$ === 'Just') {
					var cred = _v4.a;
					return A3($author$project$Page$Article$viewButtons, cred, article, author);
				} else {
					return _List_Nil;
				}
			}();
			var profile = $author$project$Author$profile(author);
			var _v1 = $author$project$Article$metadata(article);
			var title = _v1.title;
			return {
				content: A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('article-page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('banner')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('container')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h1,
											_List_Nil,
											_List_fromArray(
												[
													$elm$html$Html$text(title)
												])),
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('article-meta')
												]),
											A2(
												$elm$core$List$append,
												_List_fromArray(
													[
														A2(
														$elm$html$Html$a,
														_List_fromArray(
															[
																$author$project$Route$href(
																$author$project$Route$Profile(
																	$author$project$Author$username(author)))
															]),
														_List_fromArray(
															[
																A2(
																$elm$html$Html$img,
																_List_fromArray(
																	[
																		$author$project$Avatar$src(
																		$author$project$Profile$avatar(profile))
																	]),
																_List_Nil)
															])),
														A2(
														$elm$html$Html$div,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('info')
															]),
														_List_fromArray(
															[
																$author$project$Author$view(
																$author$project$Author$username(author)),
																A2(
																$author$project$Timestamp$view,
																model.timeZone,
																$author$project$Article$metadata(article).createdAt)
															]))
													]),
												buttons)),
											A2($author$project$Page$viewErrors, $author$project$Page$Article$ClickedDismissErrors, model.errors)
										]))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('container page')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('row article-content')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('col-md-12')
												]),
											_List_fromArray(
												[
													A2(
													$author$project$Article$Body$toHtml,
													$author$project$Article$body(article),
													_List_Nil)
												]))
										])),
									A2($elm$html$Html$hr, _List_Nil, _List_Nil),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('article-actions')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('article-meta')
												]),
											A2(
												$elm$core$List$append,
												_List_fromArray(
													[
														A2(
														$elm$html$Html$a,
														_List_fromArray(
															[
																$author$project$Route$href(
																$author$project$Route$Profile(
																	$author$project$Author$username(author)))
															]),
														_List_fromArray(
															[
																A2(
																$elm$html$Html$img,
																_List_fromArray(
																	[
																		$author$project$Avatar$src(avatar)
																	]),
																_List_Nil)
															])),
														A2(
														$elm$html$Html$div,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('info')
															]),
														_List_fromArray(
															[
																$author$project$Author$view(
																$author$project$Author$username(author)),
																A2(
																$author$project$Timestamp$view,
																model.timeZone,
																$author$project$Article$metadata(article).createdAt)
															]))
													]),
												buttons))
										])),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('row')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('col-xs-12 col-md-8 offset-md-2')
												]),
											function () {
												var _v2 = model.comments;
												switch (_v2.$) {
													case 'Loading':
														return _List_Nil;
													case 'LoadingSlowly':
														return _List_fromArray(
															[$author$project$Loading$icon]);
													case 'Loaded':
														var _v3 = _v2.a;
														var commentText = _v3.a;
														var comments = _v3.b;
														return A2(
															$elm$core$List$cons,
															A3(
																$author$project$Page$Article$viewAddComment,
																slug,
																commentText,
																$author$project$Session$viewer(model.session)),
															A2(
																$elm$core$List$map,
																A2($author$project$Page$Article$viewComment, model.timeZone, slug),
																comments));
													default:
														return _List_fromArray(
															[
																$author$project$Loading$error('comments')
															]);
												}
											}())
										]))
								]))
						])),
				title: title
			};
		case 'Loading':
			return {
				content: $elm$html$Html$text(''),
				title: 'Article'
			};
		case 'LoadingSlowly':
			return {content: $author$project$Loading$icon, title: 'Article'};
		default:
			return {
				content: $author$project$Loading$error('article'),
				title: 'Article'
			};
	}
};
var $author$project$Page$Article$Editor$getSlug = function (status) {
	switch (status.$) {
		case 'Loading':
			var slug = status.a;
			return $elm$core$Maybe$Just(slug);
		case 'LoadingSlowly':
			var slug = status.a;
			return $elm$core$Maybe$Just(slug);
		case 'LoadingFailed':
			var slug = status.a;
			return $elm$core$Maybe$Just(slug);
		case 'Saving':
			var slug = status.a;
			return $elm$core$Maybe$Just(slug);
		case 'Editing':
			var slug = status.a;
			return $elm$core$Maybe$Just(slug);
		case 'EditingNew':
			return $elm$core$Maybe$Nothing;
		default:
			return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Page$Article$Editor$saveArticleButton = F2(
	function (caption, extraAttrs) {
		return A2(
			$elm$html$Html$button,
			A2(
				$elm$core$List$cons,
				$elm$html$Html$Attributes$class('btn btn-lg pull-xs-right btn-primary'),
				extraAttrs),
			_List_fromArray(
				[
					$elm$html$Html$text(caption)
				]));
	});
var $author$project$Page$Article$Editor$editArticleSaveButton = function (extraAttrs) {
	return A2($author$project$Page$Article$Editor$saveArticleButton, 'Update Article', extraAttrs);
};
var $author$project$Page$Article$Editor$newArticleSaveButton = function (extraAttrs) {
	return A2($author$project$Page$Article$Editor$saveArticleButton, 'Publish Article', extraAttrs);
};
var $author$project$Page$Article$Editor$ClickedSave = function (a) {
	return {$: 'ClickedSave', a: a};
};
var $author$project$Page$Article$Editor$EnteredBody = function (a) {
	return {$: 'EnteredBody', a: a};
};
var $author$project$Page$Article$Editor$EnteredDescription = function (a) {
	return {$: 'EnteredDescription', a: a};
};
var $author$project$Page$Article$Editor$EnteredTags = function (a) {
	return {$: 'EnteredTags', a: a};
};
var $author$project$Page$Article$Editor$EnteredTitle = function (a) {
	return {$: 'EnteredTitle', a: a};
};
var $elm$html$Html$fieldset = _VirtualDom_node('fieldset');
var $elm$html$Html$input = _VirtualDom_node('input');
var $author$project$Page$Article$Editor$viewForm = F3(
	function (cred, fields, saveButton) {
		return A2(
			$elm$html$Html$form,
			_List_fromArray(
				[
					$elm$html$Html$Events$onSubmit(
					$author$project$Page$Article$Editor$ClickedSave(cred))
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$fieldset,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$input,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control form-control-lg'),
											$elm$html$Html$Attributes$placeholder('Article Title'),
											$elm$html$Html$Events$onInput($author$project$Page$Article$Editor$EnteredTitle),
											$elm$html$Html$Attributes$value(fields.title)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$input,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control'),
											$elm$html$Html$Attributes$placeholder('What\'s this article about?'),
											$elm$html$Html$Events$onInput($author$project$Page$Article$Editor$EnteredDescription),
											$elm$html$Html$Attributes$value(fields.description)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$textarea,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control'),
											$elm$html$Html$Attributes$placeholder('Write your article (in markdown)'),
											A2($elm$html$Html$Attributes$attribute, 'rows', '8'),
											$elm$html$Html$Events$onInput($author$project$Page$Article$Editor$EnteredBody),
											$elm$html$Html$Attributes$value(fields.body)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$input,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control'),
											$elm$html$Html$Attributes$placeholder('Enter tags'),
											$elm$html$Html$Events$onInput($author$project$Page$Article$Editor$EnteredTags),
											$elm$html$Html$Attributes$value(fields.tags)
										]),
									_List_Nil)
								])),
							saveButton
						]))
				]));
	});
var $author$project$Page$Article$Editor$viewProblem = function (problem) {
	var errorMessage = function () {
		if (problem.$ === 'InvalidEntry') {
			var message = problem.b;
			return message;
		} else {
			var message = problem.a;
			return message;
		}
	}();
	return A2(
		$elm$html$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				$elm$html$Html$text(errorMessage)
			]));
};
var $author$project$Page$Article$Editor$viewProblems = function (problems) {
	return A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('error-messages')
			]),
		A2($elm$core$List$map, $author$project$Page$Article$Editor$viewProblem, problems));
};
var $author$project$Page$Article$Editor$viewAuthenticated = F2(
	function (cred, model) {
		var formHtml = function () {
			var _v0 = model.status;
			switch (_v0.$) {
				case 'Loading':
					return _List_Nil;
				case 'LoadingSlowly':
					return _List_fromArray(
						[$author$project$Loading$icon]);
				case 'Saving':
					var slug = _v0.a;
					var form = _v0.b;
					return _List_fromArray(
						[
							A3(
							$author$project$Page$Article$Editor$viewForm,
							cred,
							form,
							$author$project$Page$Article$Editor$editArticleSaveButton(
								_List_fromArray(
									[
										$elm$html$Html$Attributes$disabled(true)
									])))
						]);
				case 'Creating':
					var form = _v0.a;
					return _List_fromArray(
						[
							A3(
							$author$project$Page$Article$Editor$viewForm,
							cred,
							form,
							$author$project$Page$Article$Editor$newArticleSaveButton(
								_List_fromArray(
									[
										$elm$html$Html$Attributes$disabled(true)
									])))
						]);
				case 'Editing':
					var slug = _v0.a;
					var problems = _v0.b;
					var form = _v0.c;
					return _List_fromArray(
						[
							$author$project$Page$Article$Editor$viewProblems(problems),
							A3(
							$author$project$Page$Article$Editor$viewForm,
							cred,
							form,
							$author$project$Page$Article$Editor$editArticleSaveButton(_List_Nil))
						]);
				case 'EditingNew':
					var problems = _v0.a;
					var form = _v0.b;
					return _List_fromArray(
						[
							$author$project$Page$Article$Editor$viewProblems(problems),
							A3(
							$author$project$Page$Article$Editor$viewForm,
							cred,
							form,
							$author$project$Page$Article$Editor$newArticleSaveButton(_List_Nil))
						]);
				default:
					return _List_fromArray(
						[
							$elm$html$Html$text('Article failed to load.')
						]);
			}
		}();
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('editor-page')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-10 offset-md-1 col-xs-12')
										]),
									formHtml)
								]))
						]))
				]));
	});
var $author$project$Page$Article$Editor$view = function (model) {
	return {
		content: function () {
			var _v0 = $author$project$Session$cred(model.session);
			if (_v0.$ === 'Just') {
				var cred = _v0.a;
				return A2($author$project$Page$Article$Editor$viewAuthenticated, cred, model);
			} else {
				return $elm$html$Html$text('Sign in to edit this article.');
			}
		}(),
		title: function () {
			var _v1 = $author$project$Page$Article$Editor$getSlug(model.status);
			if (_v1.$ === 'Just') {
				var slug = _v1.a;
				return 'Edit Article - ' + $author$project$Article$Slug$toString(slug);
			} else {
				return 'New Article';
			}
		}()
	};
};
var $author$project$Page$Empty$view = {
	content: $elm$html$Html$text(''),
	title: ''
};
var $author$project$Page$Home$ChangeToNumb = function (a) {
	return {$: 'ChangeToNumb', a: a};
};
var $author$project$Page$Home$DropdownChangedFrom = function (a) {
	return {$: 'DropdownChangedFrom', a: a};
};
var $author$project$Page$Home$DropdownChangedTo = function (a) {
	return {$: 'DropdownChangedTo', a: a};
};
var $elm$html$Html$br = _VirtualDom_node('br');
var $elm$html$Html$Attributes$size = function (n) {
	return A2(
		_VirtualDom_attribute,
		'size',
		$elm$core$String$fromInt(n));
};
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $abadi199$elm_input_extra$Dropdown$onChange = F2(
	function (emptyItem, tagger) {
		var textToMaybe = function (string) {
			return A2(
				$elm$core$Maybe$withDefault,
				false,
				A2(
					$elm$core$Maybe$map,
					A2(
						$elm$core$Basics$composeR,
						function ($) {
							return $.value;
						},
						$elm$core$Basics$eq(string)),
					emptyItem)) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(string);
		};
		return A2(
			$elm$html$Html$Events$on,
			'change',
			A2(
				$elm$json$Json$Decode$map,
				A2($elm$core$Basics$composeR, textToMaybe, tagger),
				$elm$html$Html$Events$targetValue));
	});
var $elm$html$Html$option = _VirtualDom_node('option');
var $elm$html$Html$select = _VirtualDom_node('select');
var $elm$html$Html$Attributes$selected = $elm$html$Html$Attributes$boolProperty('selected');
var $abadi199$elm_input_extra$Dropdown$dropdown = F3(
	function (options, attributes, currentValue) {
		var itemsWithEmptyItems = function () {
			var _v1 = options.emptyItem;
			if (_v1.$ === 'Just') {
				var emptyItem = _v1.a;
				return A2($elm$core$List$cons, emptyItem, options.items);
			} else {
				return options.items;
			}
		}();
		var isSelected = function (value) {
			return A2(
				$elm$core$Maybe$withDefault,
				false,
				A2(
					$elm$core$Maybe$map,
					$elm$core$Basics$eq(value),
					currentValue));
		};
		var toOption = function (_v0) {
			var value = _v0.value;
			var text = _v0.text;
			var enabled = _v0.enabled;
			return A2(
				$elm$html$Html$option,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$value(value),
						$elm$html$Html$Attributes$selected(
						isSelected(value)),
						$elm$html$Html$Attributes$disabled(!enabled)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(text)
					]));
		};
		return A2(
			$elm$html$Html$select,
			_Utils_ap(
				attributes,
				_List_fromArray(
					[
						A2($abadi199$elm_input_extra$Dropdown$onChange, options.emptyItem, options.onChange)
					])),
			A2($elm$core$List$map, toOption, itemsWithEmptyItems));
	});
var $author$project$Page$Home$viewDropDown = F2(
	function (model, msg) {
		var dlist = _List_fromArray(
			[
				{enabled: true, text: 'Cardano(ADA)', value: 'ADA'},
				{enabled: true, text: 'Bitcoin(BTC)', value: 'XXBTZ'},
				{enabled: true, text: 'Bitcoin Cash(BCH)', value: 'BCH'},
				{enabled: true, text: 'Dash(DASH)', value: 'DASH'},
				{enabled: true, text: 'Dogecoin(DOGE)', value: 'DOGE'},
				{enabled: true, text: 'Ethereum(ETH)', value: 'ETH'},
				{enabled: true, text: 'Litecoin(LTC)', value: 'LTC'},
				{enabled: true, text: 'Monero(XMR)', value: 'XXMRZ'},
				{enabled: true, text: 'Ripple(XRP)', value: 'XRP'},
				{enabled: true, text: 'Zcash(ZEC)', value: 'ZEC'},
				{enabled: true, text: 'Eos c(EOS)', value: 'EOS'}
			]);
		var options = {emptyItem: $elm$core$Maybe$Nothing, items: dlist, onChange: msg};
		return A3(
			$abadi199$elm_input_extra$Dropdown$dropdown,
			options,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('my-dropdown btn btn-primary dropdown-toggle btn-round')
				]),
			model.selectedDropdownValueFrom);
	});
var $author$project$Page$Home$viewDropDownTo = F2(
	function (model, msg) {
		var dlist = _List_fromArray(
			[
				{enabled: true, text: 'EUR', value: 'EUR'}
			]);
		var options = {emptyItem: $elm$core$Maybe$Nothing, items: dlist, onChange: msg};
		return A3(
			$abadi199$elm_input_extra$Dropdown$dropdown,
			options,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('my-dropdown btn btn-primary dropdown-toggle btn-round')
				]),
			model.selectedDropdownValueFrom);
	});
var $author$project$Page$Home$ChangeText = function (a) {
	return {$: 'ChangeText', a: a};
};
var $author$project$Page$Home$getStyle = F2(
	function (model, index) {
		return _Utils_eq(model.textIndex, index) ? 'btn btn-primary' : 'btn btn-outline-info';
	});
var $author$project$Page$Home$viewParagraph = function (model) {
	var _v0 = model.textIndex;
	switch (_v0) {
		case 1:
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'text-align', '')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Τα Κρυπτονομίσματα είναι μία peer-to-peer αποκεντρωμένη ηλεκτρονική μορφή χρήματος η οποία βασίζεται πάνω στις αρχές της κρυπτογράφησης για την διασφάλιση του δικτύου και την επαλήθευση των συναλλαγών. Τα περισσότερα κρυπτονομίσματα κάνουν χρήση μιας Κατανεμημένης Βάσης Δεδομένων ως τον πυλώνα του συστήματος τους, το επονομαζόμενο Blockchain.')
					]));
		case 2:
			return A2(
				$elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Το bitcoin που δημιουργήθηκε το 2009 απο τον SATOSHI NAKAMOTO, και έγινε το πρώτο επιτυχημένο αποκεντρωμένο κρυπτονόμισμα. Λόγω της ανοικτής φύσης του λογισμικού του, επετράπη σε πολλούς προγραμματιστές να πειραματιστούν με τον κώδικά του και να τον τροποποιήσουν ώστε να βελτιώσουν τις παρεχόμενες υπηρεσίες του.')
					]));
		case 3:
			return A2(
				$elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Τα κρυπτονομίσματα μπορούν να χρησιμοποιηθούν ως νόμισμα εξυπηρετώντας συναλλαγές και ως επενδυτικό προϊόν. \n Το κυριότερο χαρακτηριστικό του κρυπτονομίσματος είναι ο αποκεντρωμένος χαρακτήρας του και η ανθεκτικότητά του σε κάθε μορφής προσπάθεια για έλεγχο και παρέμβαση.')
					]));
		default:
			return A2($elm$html$Html$div, _List_Nil, _List_Nil);
	}
};
var $author$project$Page$Home$viewServices = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('text_services_cont')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'color', 'rgb(8,83,204)'),
								A2($elm$html$Html$Attributes$style, 'font-size', '40px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Our Services')
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'padding', '40px')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Συναλλασσόμαστε τα μεγαλύτερα σε κεφαλαιοποίηση κρυπτονομίσματα της αγοράς. Τα οποία και είναι άμεσα διαθέσιμα. Επιλέξτε τη συναλλαγή που θέλετε με το κρυπτονόμισμα της αρεσκείας σας.Όταν λάβουμε τα χρήματά σας (απο άμεσα έως και 2 εργάσιμες ημέρες ανάλογα με την μέθοδο πληρωμής), σας στέλνουμε τα κρυπτονόμίσματα αμεσα(σύμφωνα με τη συναλλαγματική ισοτιμία τη στιγμή της αποστολής των κρυπτονομίσμάτων στο πορτοφόλι σας). Στέλνουμε κρυπτονομίσματα από τις 10:00 π.μ. έως τις 18:00 μ.μ. (Από Δευτέρα έως Σάββατο) - αν λάβουμε τα χρήματά σας μια άλλη ημέρα ή ώρα, θα στείλουμε τα κρυπτονομίσματα την επόμενη εργάσιμη ημέρα / ώρα. Όλοι οι χρήστες πρέπει να ολοκληρώσουν την επαλήθευση KYC.')
							]))
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('photo_container')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$img,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$src('/images/bitcoin_guy.jpg')
							]),
						_List_Nil),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('text_crypto_cont'),
								A2($elm$html$Html$Attributes$style, 'float', 'right')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$h1,
								_List_Nil,
								_List_fromArray(
									[
										$elm$html$Html$text('Κρυπτονομίσματα ')
									])),
								A2($elm$html$Html$br, _List_Nil, _List_Nil),
								A2(
								$elm$html$Html$p,
								_List_fromArray(
									[
										A2($elm$html$Html$Attributes$style, 'color', 'rgb(76, 87, 79)')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('ΛΙΓΑ ΛΟΓΙΑ ΓΙΑ ΤΑ ΚΡΥΠΤΟΝΟΜΙΣΜΑΤΑ')
									])),
								A2($elm$html$Html$br, _List_Nil, _List_Nil),
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('btn-group btn-group-toggle')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$button,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class(
												A2($author$project$Page$Home$getStyle, model, 1)),
												$elm$html$Html$Events$onClick(
												$author$project$Page$Home$ChangeText(1))
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('τι είναι')
											])),
										A2(
										$elm$html$Html$button,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class(
												A2($author$project$Page$Home$getStyle, model, 2)),
												$elm$html$Html$Events$onClick(
												$author$project$Page$Home$ChangeText(2))
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('πως λειτουργέι')
											])),
										A2(
										$elm$html$Html$button,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class(
												A2($author$project$Page$Home$getStyle, model, 3)),
												$elm$html$Html$Events$onClick(
												$author$project$Page$Home$ChangeText(3))
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Eφαρμογές')
											]))
									])),
								$author$project$Page$Home$viewParagraph(model)
							]))
					]))
			]));
};
var $author$project$Page$Home$view = function (model) {
	return {
		content: A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container232')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('center_exchange')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$p,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text('Exchange'),
											A2($elm$html$Html$br, _List_Nil, _List_Nil),
											$elm$html$Html$text('CryptoCurrency')
										])),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('button_container')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('container_comp')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$input,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('input_fields'),
															$elm$html$Html$Attributes$size(20),
															$elm$html$Html$Attributes$type_(''),
															$elm$html$Html$Attributes$value(model.fromNumber),
															$elm$html$Html$Events$onInput($author$project$Page$Home$ChangeFromNumb)
														]),
													_List_Nil),
													A2($author$project$Page$Home$viewDropDown, model, $author$project$Page$Home$DropdownChangedFrom),
													A2(
													$elm$html$Html$input,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('input_fields'),
															$elm$html$Html$Attributes$size(20),
															$elm$html$Html$Attributes$type_(''),
															$elm$html$Html$Attributes$value(model.toNumber),
															$elm$html$Html$Events$onInput($author$project$Page$Home$ChangeToNumb)
														]),
													_List_Nil),
													A2($author$project$Page$Home$viewDropDownTo, model, $author$project$Page$Home$DropdownChangedTo)
												])),
											A2(
											$elm$html$Html$button,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$type_('button'),
													$elm$html$Html$Attributes$class('btn btn-primary btn-round exch-btn')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('EXCHANGE NOW')
												]))
										]))
								]))
						])),
					$author$project$Page$Home$viewServices(model)
				])),
		title: 'Home'
	};
};
var $author$project$Page$Login$EnteredEmail = function (a) {
	return {$: 'EnteredEmail', a: a};
};
var $author$project$Page$Login$EnteredPassword = function (a) {
	return {$: 'EnteredPassword', a: a};
};
var $author$project$Page$Login$Sub = {$: 'Sub'};
var $author$project$Page$Login$SubmittedForm = {$: 'SubmittedForm'};
var $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty('id');
var $author$project$Page$Login$viewForm = function (form) {
	return A2(
		$elm$html$Html$form,
		_List_fromArray(
			[
				$elm$html$Html$Events$onSubmit($author$project$Page$Login$SubmittedForm)
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$id('recaptcha')
					]),
				_List_Nil),
				A2(
				$elm$html$Html$fieldset,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('form-group')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('form-control form-control-lg'),
								$elm$html$Html$Attributes$placeholder('Email'),
								$elm$html$Html$Events$onInput($author$project$Page$Login$EnteredEmail),
								$elm$html$Html$Attributes$value(form.email)
							]),
						_List_Nil)
					])),
				A2(
				$elm$html$Html$fieldset,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('form-group')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('form-control form-control-lg'),
								$elm$html$Html$Attributes$type_('password'),
								$elm$html$Html$Attributes$placeholder('Password'),
								$elm$html$Html$Events$onInput($author$project$Page$Login$EnteredPassword),
								$elm$html$Html$Attributes$value(form.password)
							]),
						_List_Nil)
					])),
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('btn btn-lg btn-primary pull-xs-right'),
						$elm$html$Html$Events$onClick($author$project$Page$Login$Sub)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Sign in')
					]))
			]));
};
var $author$project$Page$Login$viewProblem = function (problem) {
	var errorMessage = function () {
		if (problem.$ === 'InvalidEntry') {
			var str = problem.b;
			return str;
		} else {
			var str = problem.a;
			return str;
		}
	}();
	return A2(
		$elm$html$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				$elm$html$Html$text(errorMessage)
			]));
};
var $author$project$Page$Login$view = function (model) {
	return {
		content: A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('cred-page')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-6 offset-md-3 col-xs-12')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h1,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Sign in')
												])),
											A2(
											$elm$html$Html$p,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$a,
													_List_fromArray(
														[
															$author$project$Route$href($author$project$Route$Register)
														]),
													_List_fromArray(
														[
															$elm$html$Html$text('Need an account?')
														]))
												])),
											A2(
											$elm$html$Html$ul,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('error-messages')
												]),
											A2($elm$core$List$map, $author$project$Page$Login$viewProblem, model.problems)),
											$author$project$Page$Login$viewForm(model.form)
										]))
								]))
						]))
				])),
		title: 'Login'
	};
};
var $author$project$Asset$error = $author$project$Asset$image('error.jpg');
var $elm$html$Html$main_ = _VirtualDom_node('main');
var $elm$html$Html$Attributes$tabindex = function (n) {
	return A2(
		_VirtualDom_attribute,
		'tabIndex',
		$elm$core$String$fromInt(n));
};
var $author$project$Page$NotFound$view = {
	content: A2(
		$elm$html$Html$main_,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$id('content'),
				$elm$html$Html$Attributes$class('container'),
				$elm$html$Html$Attributes$tabindex(-1)
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$h1,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Not Found')
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('row')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$img,
						_List_fromArray(
							[
								$author$project$Asset$src($author$project$Asset$error)
							]),
						_List_Nil)
					]))
			])),
	title: 'Page Not Found'
};
var $elm$html$Html$h2 = _VirtualDom_node('h2');
var $author$project$Page$Prices$viewBanner = A2(
	$elm$html$Html$div,
	_List_fromArray(
		[
			$elm$html$Html$Attributes$class('banner')
		]),
	_List_fromArray(
		[
			A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('container')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$h2,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('logo-font')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('Prices')
						]))
				]))
		]));
var $author$project$Page$Prices$First = {$: 'First'};
var $author$project$Page$Prices$GoTo = function (a) {
	return {$: 'GoTo', a: a};
};
var $author$project$Page$Prices$Last = {$: 'Last'};
var $author$project$Page$Prices$Next = {$: 'Next'};
var $author$project$Page$Prices$Prev = {$: 'Prev'};
var $jschomay$elm_paginate$Paginate$Custom$currentPage = function (_v0) {
	var currentPage_ = _v0.a.currentPage_;
	return $jschomay$elm_bounded_number$Number$Bounded$value(currentPage_);
};
var $jschomay$elm_paginate$Paginate$currentPage = $jschomay$elm_paginate$Paginate$Custom$currentPage;
var $elm$core$Set$Set_elm_builtin = function (a) {
	return {$: 'Set_elm_builtin', a: a};
};
var $elm$core$Set$empty = $elm$core$Set$Set_elm_builtin($elm$core$Dict$empty);
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0.a;
		return $elm$core$Set$Set_elm_builtin(
			A3($elm$core$Dict$insert, key, _Utils_Tuple0, dict));
	});
var $elm$core$Set$fromList = function (list) {
	return A3($elm$core$List$foldl, $elm$core$Set$insert, $elm$core$Set$empty, list);
};
var $elm$core$Tuple$mapSecond = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var $jschomay$elm_paginate$Paginate$Custom$accumulateWindowGroups = F2(
	function (page_, windows) {
		if (!windows.b) {
			return _List_fromArray(
				[
					_Utils_Tuple2(page_, _List_Nil)
				]);
		} else {
			var currentWindow = windows.a;
			var remainingWindows = windows.b;
			var prevPage = function () {
				var _v1 = $elm$core$List$head(currentWindow.b);
				if (_v1.$ === 'Just') {
					var prevPage_ = _v1.a;
					return prevPage_;
				} else {
					return currentWindow.a;
				}
			}();
			return ((page_ - prevPage) > 1) ? A2(
				$elm$core$List$cons,
				_Utils_Tuple2(page_, _List_Nil),
				windows) : A2(
				$elm$core$List$cons,
				A2(
					$elm$core$Tuple$mapSecond,
					function (list) {
						return A2($elm$core$List$cons, page_, list);
					},
					currentWindow),
				remainingWindows);
		}
	});
var $jschomay$elm_paginate$Paginate$Custom$groupWindows = function (pages) {
	return A2(
		$elm$core$List$map,
		function (_v0) {
			var x = _v0.a;
			var xs = _v0.b;
			return A2($elm$core$List$cons, x, xs);
		},
		$elm$core$List$reverse(
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$mapSecond($elm$core$List$reverse),
				A3($elm$core$List$foldl, $jschomay$elm_paginate$Paginate$Custom$accumulateWindowGroups, _List_Nil, pages))));
};
var $elm$core$List$intersperse = F2(
	function (sep, xs) {
		if (!xs.b) {
			return _List_Nil;
		} else {
			var hd = xs.a;
			var tl = xs.b;
			var step = F2(
				function (x, rest) {
					return A2(
						$elm$core$List$cons,
						sep,
						A2($elm$core$List$cons, x, rest));
				});
			var spersed = A3($elm$core$List$foldr, step, _List_Nil, tl);
			return A2($elm$core$List$cons, hd, spersed);
		}
	});
var $jschomay$elm_bounded_number$Number$Bounded$minBound = function (_v0) {
	var min = _v0.a.min;
	return min;
};
var $jschomay$elm_paginate$Paginate$Custom$elidedPager = F2(
	function (options, _v0) {
		var currentPage_ = _v0.a.currentPage_;
		var rightWindow = (options.outerWindow <= 0) ? _List_Nil : A2(
			$elm$core$List$range,
			$jschomay$elm_bounded_number$Number$Bounded$value(
				A2(
					$jschomay$elm_bounded_number$Number$Bounded$set,
					$jschomay$elm_bounded_number$Number$Bounded$maxBound(currentPage_) - (options.outerWindow - 1),
					currentPage_)),
			$jschomay$elm_bounded_number$Number$Bounded$maxBound(currentPage_));
		var leftWindow = (options.outerWindow <= 0) ? _List_Nil : A2(
			$elm$core$List$range,
			$jschomay$elm_bounded_number$Number$Bounded$minBound(currentPage_),
			$jschomay$elm_bounded_number$Number$Bounded$value(
				A2(
					$jschomay$elm_bounded_number$Number$Bounded$set,
					$jschomay$elm_bounded_number$Number$Bounded$minBound(currentPage_) + (options.outerWindow - 1),
					currentPage_)));
		var currentPageNumber = $jschomay$elm_bounded_number$Number$Bounded$value(currentPage_);
		var innerWindow = A2(
			$elm$core$List$range,
			A3(
				$elm$core$Basics$clamp,
				$jschomay$elm_bounded_number$Number$Bounded$minBound(currentPage_),
				currentPageNumber,
				currentPageNumber - options.innerWindow),
			A3(
				$elm$core$Basics$clamp,
				currentPageNumber,
				$jschomay$elm_bounded_number$Number$Bounded$maxBound(currentPage_),
				currentPageNumber + options.innerWindow));
		return $elm$core$List$concat(
			A2(
				$elm$core$List$intersperse,
				_List_fromArray(
					[options.gapView]),
				A2(
					$elm$core$List$map,
					$elm$core$List$map(
						function (i) {
							return A2(
								options.pageNumberView,
								i,
								_Utils_eq(i, currentPageNumber));
						}),
					$jschomay$elm_paginate$Paginate$Custom$groupWindows(
						$elm$core$Set$toList(
							$elm$core$Set$fromList(
								_Utils_ap(
									leftWindow,
									_Utils_ap(innerWindow, rightWindow))))))));
	});
var $jschomay$elm_paginate$Paginate$elidedPager = $jschomay$elm_paginate$Paginate$Custom$elidedPager;
var $jschomay$elm_paginate$Paginate$Custom$isFirst = function (_v0) {
	var currentPage_ = _v0.a.currentPage_;
	return $jschomay$elm_bounded_number$Number$Bounded$value(currentPage_) === 1;
};
var $jschomay$elm_paginate$Paginate$isFirst = $jschomay$elm_paginate$Paginate$Custom$isFirst;
var $jschomay$elm_paginate$Paginate$Custom$isLast = function (_v0) {
	var currentPage_ = _v0.a.currentPage_;
	return _Utils_eq(
		$jschomay$elm_bounded_number$Number$Bounded$value(currentPage_),
		$jschomay$elm_bounded_number$Number$Bounded$maxBound(currentPage_));
};
var $jschomay$elm_paginate$Paginate$isLast = $jschomay$elm_paginate$Paginate$Custom$isLast;
var $elm$html$Html$Attributes$scope = $elm$html$Html$Attributes$stringProperty('scope');
var $elm$html$Html$table = _VirtualDom_node('table');
var $elm$html$Html$th = _VirtualDom_node('th');
var $elm$html$Html$thead = _VirtualDom_node('thead');
var $elm$html$Html$td = _VirtualDom_node('td');
var $elm$html$Html$tr = _VirtualDom_node('tr');
var $author$project$Page$Prices$toTableRow = F2(
	function (metaInfo, assetPair) {
		var _v0 = A2($elm$core$Dict$get, assetPair.info.alternate_name, metaInfo);
		if (_v0.$ === 'Nothing') {
			var _v1 = A2($elm$core$Dict$get, assetPair.name, metaInfo);
			if (_v1.$ === 'Nothing') {
				return A2(
					$elm$html$Html$tr,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$td,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(assetPair.info.alternate_name)
								])),
							A2(
							$elm$html$Html$td,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(assetPair.info.base)
								]))
						]));
			} else {
				var assetMetaInf = _v1.a;
				return A2(
					$elm$html$Html$tr,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$td,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(assetPair.info.alternate_name)
								])),
							A2(
							$elm$html$Html$td,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(assetPair.info.base)
								])),
							A2(
							$elm$html$Html$td,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(assetMetaInf.o.today)
								])),
							A2(
							$elm$html$Html$td,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(assetMetaInf.a.price)
								])),
							A2(
							$elm$html$Html$td,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(assetMetaInf.b.price)
								]))
						]));
			}
		} else {
			var assetMetaInfo = _v0.a;
			return A2(
				$elm$html$Html$tr,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$td,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(assetPair.info.alternate_name)
							])),
						A2(
						$elm$html$Html$td,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(assetPair.info.base)
							])),
						A2(
						$elm$html$Html$td,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(assetMetaInfo.o.today)
							])),
						A2(
						$elm$html$Html$td,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(assetMetaInfo.a.price)
							])),
						A2(
						$elm$html$Html$td,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(assetMetaInfo.b.price)
							])),
						A2(
						$elm$html$Html$td,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(assetMetaInfo.c.price)
							])),
						A2(
						$elm$html$Html$td,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(
								$elm$core$String$fromInt(assetMetaInfo.t.today))
							]))
					]));
		}
	});
var $jschomay$elm_paginate$Paginate$totalPages = $jschomay$elm_paginate$Paginate$Custom$totalPages;
var $author$project$Page$Prices$viewPaginated = F2(
	function (assetPairs, metaInfo) {
		var prevButtons = _List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('page-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('page-link'),
								$elm$html$Html$Events$onClick($author$project$Page$Prices$First),
								$elm$html$Html$Attributes$disabled(
								$jschomay$elm_paginate$Paginate$isFirst(assetPairs))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('<<')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('page-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('page-link'),
								$elm$html$Html$Events$onClick($author$project$Page$Prices$Prev),
								$elm$html$Html$Attributes$disabled(
								$jschomay$elm_paginate$Paginate$isFirst(assetPairs))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('<')
							]))
					]))
			]);
		var pagerButtonView = F2(
			function (index, isActive) {
				return A2(
					$elm$html$Html$li,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('page-item')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('page-link'),
									A2(
									$elm$html$Html$Attributes$style,
									'font-weight',
									isActive ? 'bold' : 'normal'),
									$elm$html$Html$Events$onClick(
									$author$project$Page$Prices$GoTo(index))
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									$elm$core$String$fromInt(index))
								]))
						]));
			});
		var pagerOptions = {
			gapView: $elm$html$Html$text('...'),
			innerWindow: 2,
			outerWindow: 0,
			pageNumberView: pagerButtonView
		};
		var nextButtons = _List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('page-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('page-link'),
								$elm$html$Html$Events$onClick($author$project$Page$Prices$Next),
								$elm$html$Html$Attributes$disabled(
								$jschomay$elm_paginate$Paginate$isLast(assetPairs))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('>')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('page-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('page-link'),
								$elm$html$Html$Events$onClick($author$project$Page$Prices$Last),
								$elm$html$Html$Attributes$disabled(
								$jschomay$elm_paginate$Paginate$isLast(assetPairs))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('>>')
							]))
					]))
			]);
		var displayInfoView = A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					$elm$html$Html$text(
					A2(
						$elm$core$String$join,
						' ',
						_List_fromArray(
							[
								'page',
								$elm$core$String$fromInt(
								$jschomay$elm_paginate$Paginate$currentPage(assetPairs)),
								'of',
								$elm$core$String$fromInt(
								$jschomay$elm_paginate$Paginate$totalPages(assetPairs))
							]))),
					A2(
					$elm$html$Html$div,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$table,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('table')
								]),
							_Utils_ap(
								_List_fromArray(
									[
										A2(
										$elm$html$Html$thead,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('thead-light')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$th,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$scope('col')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Name')
													])),
												A2(
												$elm$html$Html$th,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$scope('col')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Base')
													])),
												A2(
												$elm$html$Html$th,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$scope('col')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Openning value')
													])),
												A2(
												$elm$html$Html$th,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$scope('col')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Ask price')
													])),
												A2(
												$elm$html$Html$th,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$scope('col')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Bid Price')
													])),
												A2(
												$elm$html$Html$th,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$scope('col')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Last closed Trade price')
													])),
												A2(
												$elm$html$Html$th,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$scope('col')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Number of Trades last 24h')
													]))
											]))
									]),
								A2(
									$elm$core$List$map,
									$author$project$Page$Prices$toTableRow(metaInfo),
									$jschomay$elm_paginate$Paginate$page(assetPairs))))
						]))
				]));
		return A2(
			$elm$html$Html$nav,
			_List_Nil,
			_List_fromArray(
				[
					displayInfoView,
					A2(
					$elm$html$Html$ul,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('pagination pagination-lg')
						]),
					_Utils_ap(
						prevButtons,
						_Utils_ap(
							A2($jschomay$elm_paginate$Paginate$elidedPager, pagerOptions, assetPairs),
							nextButtons)))
				]));
	});
var $author$project$Page$Prices$view = function (model) {
	return {
		content: A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('price-page')
				]),
			_List_fromArray(
				[
					$author$project$Page$Prices$viewBanner,
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-9')
										]),
									function () {
										var _v0 = model.feed;
										switch (_v0.$) {
											case 'Loaded':
												var feed = _v0.a;
												var _v1 = model.feedPair;
												if (_v1.$ === 'Just') {
													var paginat = _v1.a;
													var _v2 = model.feedMeta;
													if (_v2.$ === 'Just') {
														var feedMeta = _v2.a;
														return _List_fromArray(
															[
																A2($author$project$Page$Prices$viewPaginated, paginat.pairs, feedMeta)
															]);
													} else {
														return _List_Nil;
													}
												} else {
													return _List_Nil;
												}
											case 'Loading':
												return _List_fromArray(
													[$author$project$Loading$icon]);
											case 'LoadingSlowly':
												return _List_fromArray(
													[$author$project$Loading$icon]);
											default:
												return _List_fromArray(
													[
														$author$project$Loading$error('feed kokino fws')
													]);
										}
									}()),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-3')
										]),
									function () {
										var _v3 = model.tags;
										switch (_v3.$) {
											case 'Loaded':
												var tags = _v3.a;
												return _List_Nil;
											case 'Loading':
												return _List_Nil;
											case 'LoadingSlowly':
												return _List_fromArray(
													[$author$project$Loading$icon]);
											default:
												return _List_fromArray(
													[
														$author$project$Loading$error('tags')
													]);
										}
									}())
								]))
						]))
				])),
		title: 'Prices'
	};
};
var $author$project$Page$Profile$GotFiles = function (a) {
	return {$: 'GotFiles', a: a};
};
var $author$project$Page$Profile$LoadImmage = {$: 'LoadImmage'};
var $elm$file$File$decoder = _File_decoder;
var $author$project$Page$Profile$filesDecoder = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'files']),
	$elm$json$Json$Decode$list($elm$file$File$decoder));
var $author$project$Page$Profile$myProfileTitle = 'My Profile';
var $elm$html$Html$Attributes$name = $elm$html$Html$Attributes$stringProperty('name');
var $author$project$Page$Profile$defaultTitle = 'Profile';
var $author$project$Page$Profile$titleForMe = F2(
	function (maybeCred, username) {
		if (maybeCred.$ === 'Just') {
			var cred = maybeCred.a;
			return _Utils_eq(
				username,
				$author$project$Api$username(cred)) ? $author$project$Page$Profile$myProfileTitle : $author$project$Page$Profile$defaultTitle;
		} else {
			return $author$project$Page$Profile$defaultTitle;
		}
	});
var $author$project$Page$Profile$titleForOther = function (otherUsername) {
	return 'Profile — ' + $author$project$Username$toString(otherUsername);
};
var $author$project$Page$Profile$view = function (model) {
	var title1 = function () {
		var _v3 = model.author;
		switch (_v3.$) {
			case 'Loaded':
				switch (_v3.a.$) {
					case 'IsViewer':
						var _v4 = _v3.a;
						return $author$project$Page$Profile$myProfileTitle;
					case 'IsFollowing':
						var author = _v3.a;
						var followedAuthor = author.a;
						return $author$project$Page$Profile$titleForOther(
							$author$project$Author$username(author));
					default:
						var author = _v3.a;
						var unfollowedAuthor = author.a;
						return $author$project$Page$Profile$titleForOther(
							$author$project$Author$username(author));
				}
			case 'Loading':
				var username = _v3.a;
				return A2(
					$author$project$Page$Profile$titleForMe,
					$author$project$Session$cred(model.session),
					username);
			case 'LoadingSlowly':
				var username = _v3.a;
				return A2(
					$author$project$Page$Profile$titleForMe,
					$author$project$Session$cred(model.session),
					username);
			default:
				var username = _v3.a;
				return A2(
					$author$project$Page$Profile$titleForMe,
					$author$project$Session$cred(model.session),
					username);
		}
	}();
	var fileName = function () {
		var _v2 = model.currentFile;
		if (_v2.$ === 'Just') {
			var file = _v2.a;
			return 'Selected image: ' + $elm$file$File$name(file);
		} else {
			return 'No image selected';
		}
	}();
	return {
		content: function () {
			var _v0 = model.author;
			switch (_v0.$) {
				case 'Loaded':
					var author = _v0.a;
					var username = $author$project$Author$username(author);
					var profile = $author$project$Author$profile(author);
					return A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('profile-page')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('asdfasf')
							]));
				case 'Loading':
					var author = _v0.a;
					var formExtre = function () {
						var _v1 = model.upCreds;
						if (_v1.$ === 'Nothing') {
							return A2($elm$html$Html$div, _List_Nil, _List_Nil);
						} else {
							var upCreds = _v1.a;
							return A2(
								$elm$html$Html$img,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$src('https://s3.eu-central-1.amazonaws.com/greek.coin.user.images/users/user.jpg')
									]),
								_List_Nil);
						}
					}();
					return A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container bootstrap snippet')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('row')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-sm-10')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$h1,
												_List_Nil,
												_List_fromArray(
													[
														$elm$html$Html$text(
														$author$project$Username$toString(author))
													]))
											])),
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-sm-2')
											]),
										_List_Nil)
									])),
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('row')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-sm-2')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('')
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$img,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$alt('avatar'),
																$elm$html$Html$Attributes$src(model.currentFileUrl),
																$elm$html$Html$Attributes$class('avatar img-circle img-thumbnail')
															]),
														_List_Nil),
														$elm$html$Html$text(fileName),
														A2($elm$html$Html$br, _List_Nil, _List_Nil),
														A2(
														$elm$html$Html$input,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$id('file-input'),
																$elm$html$Html$Attributes$type_('file'),
																$elm$html$Html$Attributes$name('name'),
																A2($elm$html$Html$Attributes$style, 'display', 'none'),
																A2(
																$elm$html$Html$Events$on,
																'change',
																A2($elm$json$Json$Decode$map, $author$project$Page$Profile$GotFiles, $author$project$Page$Profile$filesDecoder))
															]),
														_List_Nil),
														$elm$html$Html$text(' file hash: ' + model.currentFileHash),
														A2(
														$elm$html$Html$button,
														_List_fromArray(
															[
																$elm$html$Html$Events$onClick($author$project$Page$Profile$LoadImmage),
																$elm$html$Html$Attributes$class('btn btn-lg pull-xs-right btn-primary')
															]),
														_List_fromArray(
															[
																$elm$html$Html$text('Load   image')
															]))
													]))
											]))
									])),
								formExtre
							]));
				case 'LoadingSlowly':
					return $author$project$Loading$icon;
				default:
					return $author$project$Loading$error('asdfafdsaprofile');
			}
		}(),
		title: title1
	};
};
var $author$project$Page$Register$EnteredEmail = function (a) {
	return {$: 'EnteredEmail', a: a};
};
var $author$project$Page$Register$EnteredPassword = function (a) {
	return {$: 'EnteredPassword', a: a};
};
var $author$project$Page$Register$EnteredUsername = function (a) {
	return {$: 'EnteredUsername', a: a};
};
var $author$project$Page$Register$SubmittedForm = {$: 'SubmittedForm'};
var $author$project$Page$Register$viewForm = function (form) {
	return A2(
		$elm$html$Html$form,
		_List_fromArray(
			[
				$elm$html$Html$Events$onSubmit($author$project$Page$Register$SubmittedForm)
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$fieldset,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('form-group')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('form-control form-control-lg'),
								$elm$html$Html$Attributes$placeholder('Username'),
								$elm$html$Html$Events$onInput($author$project$Page$Register$EnteredUsername),
								$elm$html$Html$Attributes$value(form.username)
							]),
						_List_Nil)
					])),
				A2(
				$elm$html$Html$fieldset,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('form-group')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('form-control form-control-lg'),
								$elm$html$Html$Attributes$placeholder('Email'),
								$elm$html$Html$Events$onInput($author$project$Page$Register$EnteredEmail),
								$elm$html$Html$Attributes$value(form.email)
							]),
						_List_Nil)
					])),
				A2(
				$elm$html$Html$fieldset,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('form-group')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('form-control form-control-lg'),
								$elm$html$Html$Attributes$type_('password'),
								$elm$html$Html$Attributes$placeholder('Password'),
								$elm$html$Html$Events$onInput($author$project$Page$Register$EnteredPassword),
								$elm$html$Html$Attributes$value(form.password)
							]),
						_List_Nil)
					])),
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('btn btn-lg btn-primary pull-xs-right')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Sign up')
					]))
			]));
};
var $author$project$Page$Register$viewProblem = function (problem) {
	var errorMessage = function () {
		if (problem.$ === 'InvalidEntry') {
			var str = problem.b;
			return str;
		} else {
			var str = problem.a;
			return str;
		}
	}();
	return A2(
		$elm$html$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				$elm$html$Html$text(errorMessage)
			]));
};
var $author$project$Page$Register$view = function (model) {
	return {
		content: A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('cred-page')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-6 offset-md-3 col-xs-12')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h1,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Sign up')
												])),
											A2(
											$elm$html$Html$p,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$a,
													_List_fromArray(
														[
															$author$project$Route$href($author$project$Route$Login)
														]),
													_List_fromArray(
														[
															$elm$html$Html$text('Have an account?')
														]))
												])),
											A2(
											$elm$html$Html$ul,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('error-messages')
												]),
											A2($elm$core$List$map, $author$project$Page$Register$viewProblem, model.problems)),
											$author$project$Page$Register$viewForm(model.form)
										]))
								]))
						]))
				])),
		title: 'Register'
	};
};
var $author$project$Page$Settings$EnteredAvatar = function (a) {
	return {$: 'EnteredAvatar', a: a};
};
var $author$project$Page$Settings$EnteredBio = function (a) {
	return {$: 'EnteredBio', a: a};
};
var $author$project$Page$Settings$EnteredEmail = function (a) {
	return {$: 'EnteredEmail', a: a};
};
var $author$project$Page$Settings$EnteredPassword = function (a) {
	return {$: 'EnteredPassword', a: a};
};
var $author$project$Page$Settings$EnteredUsername = function (a) {
	return {$: 'EnteredUsername', a: a};
};
var $author$project$Page$Settings$SubmittedForm = F2(
	function (a, b) {
		return {$: 'SubmittedForm', a: a, b: b};
	});
var $author$project$Page$Settings$viewForm = F2(
	function (cred, form) {
		return A2(
			$elm$html$Html$form,
			_List_fromArray(
				[
					$elm$html$Html$Events$onSubmit(
					A2($author$project$Page$Settings$SubmittedForm, cred, form))
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$fieldset,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$input,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control'),
											$elm$html$Html$Attributes$placeholder('URL of profile picture'),
											$elm$html$Html$Attributes$value(form.avatar),
											$elm$html$Html$Events$onInput($author$project$Page$Settings$EnteredAvatar)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$input,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control form-control-lg'),
											$elm$html$Html$Attributes$placeholder('Username'),
											$elm$html$Html$Attributes$value(form.username),
											$elm$html$Html$Events$onInput($author$project$Page$Settings$EnteredUsername)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$textarea,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control form-control-lg'),
											$elm$html$Html$Attributes$placeholder('Short bio about you'),
											A2($elm$html$Html$Attributes$attribute, 'rows', '8'),
											$elm$html$Html$Attributes$value(form.bio),
											$elm$html$Html$Events$onInput($author$project$Page$Settings$EnteredBio)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$input,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control form-control-lg'),
											$elm$html$Html$Attributes$placeholder('Email'),
											$elm$html$Html$Attributes$value(form.email),
											$elm$html$Html$Events$onInput($author$project$Page$Settings$EnteredEmail)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$fieldset,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-group')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$input,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('form-control form-control-lg'),
											$elm$html$Html$Attributes$type_('password'),
											$elm$html$Html$Attributes$placeholder('Password'),
											$elm$html$Html$Attributes$value(form.password),
											$elm$html$Html$Events$onInput($author$project$Page$Settings$EnteredPassword)
										]),
									_List_Nil)
								])),
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('btn btn-lg btn-primary pull-xs-right')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Update Settings')
								]))
						]))
				]));
	});
var $author$project$Page$Settings$viewProblem = function (problem) {
	var errorMessage = function () {
		if (problem.$ === 'InvalidEntry') {
			var message = problem.b;
			return message;
		} else {
			var message = problem.a;
			return message;
		}
	}();
	return A2(
		$elm$html$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				$elm$html$Html$text(errorMessage)
			]));
};
var $author$project$Page$Settings$view = function (model) {
	return {
		content: function () {
			var _v0 = $author$project$Session$cred(model.session);
			if (_v0.$ === 'Just') {
				var cred = _v0.a;
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('settings-page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('container page')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('row')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('col-md-6 offset-md-3 col-xs-12')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$h1,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('text-xs-center')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text('Your Settings')
														])),
													A2(
													$elm$html$Html$ul,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('error-messages')
														]),
													A2($elm$core$List$map, $author$project$Page$Settings$viewProblem, model.problems)),
													function () {
													var _v1 = model.status;
													switch (_v1.$) {
														case 'Loaded':
															var form = _v1.a;
															return A2($author$project$Page$Settings$viewForm, cred, form);
														case 'Loading':
															return $elm$html$Html$text('');
														case 'LoadingSlowly':
															return $author$project$Loading$icon;
														default:
															return $elm$html$Html$text('Error loading page.');
													}
												}()
												]))
										]))
								]))
						]));
			} else {
				return $elm$html$Html$text('Sign in to view your settings.');
			}
		}(),
		title: 'Settings'
	};
};
var $author$project$Main$view = function (model) {
	var viewer = $author$project$Session$viewer(
		$author$project$Main$toSession(model));
	var viewPage = F3(
		function (page, toMsg, config) {
			var _v2 = A3($author$project$Page$view, viewer, page, config);
			var title = _v2.title;
			var body = _v2.body;
			return {
				body: A2(
					$elm$core$List$map,
					$elm$html$Html$map(toMsg),
					body),
				title: title
			};
		});
	switch (model.$) {
		case 'Redirect':
			return A3($author$project$Page$view, viewer, $author$project$Page$Other, $author$project$Page$Empty$view);
		case 'NotFound':
			return A3($author$project$Page$view, viewer, $author$project$Page$Other, $author$project$Page$NotFound$view);
		case 'Settings':
			var settings = model.a;
			return A3(
				viewPage,
				$author$project$Page$Other,
				$author$project$Main$GotSettingsMsg,
				$author$project$Page$Settings$view(settings));
		case 'Prices':
			var prices = model.a;
			return A3(
				viewPage,
				$author$project$Page$Prices,
				$author$project$Main$GotPricesMsg,
				$author$project$Page$Prices$view(prices));
		case 'Home':
			var home = model.a;
			return A3(
				viewPage,
				$author$project$Page$Home,
				$author$project$Main$GotHomeMsg,
				$author$project$Page$Home$view(home));
		case 'Login':
			var login = model.a;
			return A3(
				viewPage,
				$author$project$Page$Other,
				$author$project$Main$GotLoginMsg,
				$author$project$Page$Login$view(login));
		case 'Register':
			var register = model.a;
			return A3(
				viewPage,
				$author$project$Page$Other,
				$author$project$Main$GotRegisterMsg,
				$author$project$Page$Register$view(register));
		case 'Profile':
			var username = model.a;
			var profile = model.b;
			return A3(
				viewPage,
				$author$project$Page$Profile(username),
				$author$project$Main$GotProfileMsg,
				$author$project$Page$Profile$view(profile));
		case 'Article':
			var article = model.a;
			return A3(
				viewPage,
				$author$project$Page$Other,
				$author$project$Main$GotArticleMsg,
				$author$project$Page$Article$view(article));
		default:
			if (model.a.$ === 'Nothing') {
				var _v1 = model.a;
				var editor = model.b;
				return A3(
					viewPage,
					$author$project$Page$NewArticle,
					$author$project$Main$GotEditorMsg,
					$author$project$Page$Article$Editor$view(editor));
			} else {
				var editor = model.b;
				return A3(
					viewPage,
					$author$project$Page$Other,
					$author$project$Main$GotEditorMsg,
					$author$project$Page$Article$Editor$view(editor));
			}
	}
};
var $author$project$Main$main = A2(
	$author$project$Api$application,
	$author$project$Viewer$decoder,
	{init: $author$project$Main$init, onUrlChange: $author$project$Main$ChangedUrl, onUrlRequest: $author$project$Main$ClickedLink, subscriptions: $author$project$Main$subscriptions, update: $author$project$Main$update, view: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main($elm$json$Json$Decode$value)(0)}});}(this));