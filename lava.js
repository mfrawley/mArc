(function() {
  "### Copyright 2011 Evan R. Murphy\n###\n### About this code:\n### - No code depends on code below it (see\n###   http://awwx.posterous.com/how-to-future-proof-your-code\n###   for a compelling post on the idea)\n### - Unit tests are inline, i.e. functions\n###   are tested immediately after they're\n###   defined\n### - It's organized into 4 sections:\n###    1) Preliminary,\n###    2) Reader\n###    3) Compiler\n###    4) Interface\n###";
  var ast, atom, bind, contents, each, filename, fs, infixOps, isArray, isAtom, isEmpty, isEqual, isList, jsContents, lava, lc, lcArray, lcArray1, lcArray2, lcDef, lcDo, lcDo1, lcDot, lcFn, lcFn1, lcFn2, lcFn3, lcFn4, lcIf, lcIf1, lcIf2, lcIf3, lcInfix, lcInfix1, lcMac, lcMac1, lcObj, lcObj1, lcObj2, lcObj3, lcProc, lcProc1, lcProc2, lcRef, log, macroExpand, macroExpand1, macros, pair, parse, pr, printInputAndEval, printOutput, read, readFrom, repl, stdin, stdout, test, tokenize, without, _,
    __slice = Array.prototype.slice,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  log = function(str) {
    return console.log(str);
  };

  _ = require('underscore');

  isEqual = _.isEqual;

  test = function(name, actual, expected) {
    if (!isEqual(actual, expected)) return pr("" + name + " test failed");
  };

  isArray = _.isArray;

  isEmpty = _.isEmpty;

  each = _.each;

  without = _.without;

  pr = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log.apply(console, args);
  };

  stdin = process.stdin;

  stdout = process.stdout;

  isList = isArray;

  isAtom = function(x) {
    return !isList(x);
  };

  pair = function(xs) {
    var acc;
    acc = [];
    while (!isEmpty(xs)) {
      acc.push(xs.slice(0, 2));
      xs = xs.slice(2);
    }
    return acc;
  };

  atom = function(t) {
    try {
      if (t.match(/^\d+\.?$/)) {
        return parseInt(t);
      } else if (t.match(/^\d*\.\d+$/)) {
        return parseFloat(t);
      } else {
        return t;
      }
    } catch (e) {
      throw "Unable to parse atom " + t;
    }
  };

  readFrom = function(ts) {
    var acc, t;
    t = ts.shift();
    if (t === '(') {
      acc = [];
      while (ts[0] !== ')') {
        acc.push(readFrom(ts));
      }
      ts.shift();
      return acc;
    } else {
      return atom(t);
    }
  };

  tokenize = function(s) {
    return s.replace(/\(/g, ' ( ').replace(/\)/g, ' ) ').replace(/\s+/g, ' ').replace(/^\s*/, '').replace(/\s*$/, '').split(' ');
  };

  read = function(s) {
    var allRead, tokenized;
    tokenized = tokenize(s);
    pr(tokenized);
    allRead = readFrom(tokenized);
    return allRead;
  };

  parse = read;

  lc = function() {};

  lava = function(s) {
    return lc(parse(s));
  };

  lc = function(s) {
    if (isAtom(s)) return s;
  };

  lcProc2 = function(xs) {
    var acc;
    acc = "";
    each(xs, function(x) {
      return acc += ',' + lc(x);
    });
    return acc;
  };

  lcProc1 = function(xs) {
    if (isEmpty(xs)) {
      return "";
    } else {
      return lc(xs[0]) + lcProc2(xs.slice(1));
    }
  };

  lcProc = function(f, args) {
    return lc(f) + '(' + lcProc1(args) + ')';
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s)) {
        return lcProc(s[0], s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcInfix1 = function(op, xs) {
    var acc;
    acc = "";
    each(xs, function(x) {
      return acc += op + lc(x);
    });
    return acc;
  };

  lcInfix = function(op, xs) {
    if (isEmpty(xs)) {
      return "";
    } else {
      return lc(xs[0]) + lcInfix1(op, xs.slice(1));
    }
  };

  infixOps = ['+', '-', '*', '/', '%', '>=', '<=', '>', '<', '==', '===', '!=', '!==', '=', '+=', '-=', '*=', '/=', '%=', '&&', '||'];

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      var _ref;
      if (isList(s) && (_ref = s[0], __indexOf.call(infixOps, _ref) >= 0)) {
        return lcInfix(s[0], s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcObj3 = function(xs) {
    var acc;
    acc = "";
    each(xs, function(x) {
      var k, v;
      k = x[0], v = x[1];
      return acc += ',' + lc(k) + ':' + lc(v);
    });
    return acc;
  };

  lcObj2 = function(xs) {
    var k, v, _ref;
    if (isEmpty(xs)) {
      return "";
    } else {
      _ref = xs[0], k = _ref[0], v = _ref[1];
      return lc(k) + ':' + lc(v) + lcObj3(xs.slice(1));
    }
  };

  lcObj1 = function(xs) {
    return lcObj2(pair(xs));
  };

  lcObj = function(xs) {
    return '{' + lcObj1(xs) + '}';
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'obj') {
        return lcObj(s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcArray2 = function(xs) {
    var acc;
    acc = "";
    each(xs, function(x) {
      return acc += ',' + lc(x);
    });
    return acc;
  };

  lcArray1 = function(xs) {
    if (isEmpty(xs)) {
      return "";
    } else {
      return lc(xs[0]) + lcArray2(xs.slice(1));
    }
  };

  lcArray = function(xs) {
    return '[' + lcArray1(xs) + ']';
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'array') {
        return lcArray(s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcRef = function(xs) {
    var h, k;
    h = xs[0], k = xs[1];
    return lc(h) + '[' + lc(k) + ']';
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'ref') {
        return lcRef(s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcDot = function(xs) {
    var h, k;
    h = xs[0], k = xs[1];
    return lc(h) + '.' + lc(k);
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'dot') {
        return lcDot(s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcIf3 = function(ps) {
    var acc;
    acc = "";
    each(ps, function(p, i) {
      if (p.length === 1) {
        return acc += lc(p[0]);
      } else if (i === ps.length - 1) {
        return acc += lc(p[0]) + '?' + lc(p[1]) + ':' + 'undefined';
      } else {
        return acc += lc(p[0]) + '?' + lc(p[1]) + ':';
      }
    });
    return acc;
  };

  lcIf2 = function(xs) {
    return lcIf3(pair(xs));
  };

  lcIf1 = function(xs) {
    return '(' + lcIf2(xs) + ')';
  };

  lcIf = function(xs) {
    if (isEmpty(xs)) {
      return "";
    } else if (xs.length === 1) {
      return lc(xs[0]);
    } else {
      return lcIf1(xs);
    }
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'if') {
        return lcIf(s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcDo1 = function(xs) {
    var acc;
    acc = "";
    each(xs, function(x) {
      return acc += ',' + lc(x);
    });
    return acc;
  };

  lcDo = function(xs) {
    if (isEmpty(xs)) {
      return "";
    } else {
      return lc(xs[0]) + lcDo1(xs.slice(1));
    }
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'do') {
        return lcDo(s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lcFn4 = function(xs) {
    if (isEmpty(xs)) {
      return "";
    } else {
      return 'return ' + lcDo(xs) + ';';
    }
  };

  lcFn3 = function(xs) {
    return lcDo(xs);
  };

  lcFn2 = function(args, body) {
    return 'function' + '(' + lcFn3(args) + ')' + '{' + lcFn4(body) + '}';
  };

  lcFn1 = function(xs) {
    return lcFn2(xs[0], xs.slice(1));
  };

  lcFn = function(xs) {
    return '(' + lcFn1(xs) + ')';
  };

  lcDef = function(name, xs) {
    return name + ' = ' + lcFn1(xs) + ';';
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'fn') {
        return lcFn(s.slice(1));
      } else if (isList(s) && s[0] === 'define') {
        return lcDef(s[1], s.slice(2));
      } else {
        return orig(s);
      }
    };
  })();

  macros = {};

  lcMac1 = function(name, definition) {
    return macros[name] = definition;
  };

  lcMac = function(xs) {
    return lcMac1(xs[0], xs.slice(1));
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'mac') {
        return lcMac(s.slice(1));
      } else {
        return orig(s);
      }
    };
  })();

  lc(['mac', 'foo']);

  test('mac #1', macros.foo, []);

  macros = {};

  lc(['mac', 'foo', ['x'], 'x']);

  macros = {};

  lc(['mac', 'foo', ['x', 'y'], 'x']);

  macros = {};

  lc(['mac', 'foo', ['x', 'y'], ['x', 'y']]);

  macros = {};

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && s[0] === 'quote') {
        return s[1];
      } else {
        return orig(s);
      }
    };
  })();

  bind = function(parms, args, env) {
    if (env == null) env = {};
    each(parms, function(parm, i) {
      return env[parm] = args[i];
    });
    return env;
  };

  macroExpand1 = function(x, env) {
    var acc;
    if (isAtom(x)) {
      if (x in env) {
        return env[x];
      } else {
        return x;
      }
    } else {
      acc = [];
      each(x, function(elt) {
        return acc.push(macroExpand1(elt, env));
      });
      return acc;
    }
  };

  macroExpand = function(name, args) {
    var body, env, parms, _ref;
    _ref = macros[name], parms = _ref[0], body = _ref[1];
    env = bind(parms, args);
    return macroExpand1(body, env);
  };

  (function() {
    var orig;
    orig = lc;
    return lc = function(s) {
      if (isList(s) && (s[0] in macros)) {
        return lc(macroExpand(s[0], s.slice(1)));
      } else {
        return orig(s);
      }
    };
  })();

  lc(['mac', 'foo', ['x'], 'x']);

  macros = {};

  lava = function(s) {
    return lc(parse(s));
  };

  lava("(mac let1 (var val body)        ((fn (var) body) val))");

  macros = {};

  if (process.argv.length > 2) {
    fs = require('fs');
    filename = process.argv[2];
    contents = fs.readFileSync(filename, 'utf-8');
    ast = parse(contents);
    jsContents = lava(contents);
    process.exit();
  } else {
    if (!module.parent) {
      printOutput = function(x) {
        return stdout.write(x + '\n' + '=> ' + eval(x) + '\n>');
      };
      printInputAndEval = function(x) {
        return printOutput(lava(x));
      };
      repl = function() {
        stdin.resume();
        stdin.setEncoding('utf8');
        stdout.write('> ');
        return stdin.on('data', printInputAndEval);
      };
      repl();
    }
  }

}).call(this);
