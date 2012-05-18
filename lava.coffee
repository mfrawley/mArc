"""
### Copyright 2011 Evan R. Murphy
###
### About this code:
### - No code depends on code below it (see
###   http://awwx.posterous.com/how-to-future-proof-your-code
###   for a compelling post on the idea)
### - Unit tests are inline, i.e. functions
###   are tested immediately after they're
###   defined
### - It's organized into 4 sections:
###    1) Preliminary,
###    2) Reader
###    3) Compiler
###    4) Interface
###
"""
log = (str)->
  console.log str
    
## Preliminary
_ = require('underscore')

isEqual = _.isEqual

test = (name, actual, expected) ->
  unless isEqual(actual, expected)
    pr "#{name} test failed"
  else
    pr "#{name} test passed"
    
#global methods
isArray = _.isArray
isEmpty = _.isEmpty
each    = _.each
without = _.without
first   = _.first
rest    = _.rest
min     = _.min
max     = _.max
len     = _.size

pr = (args...) -> console.log args...

stdin = process.stdin
stdout = process.stdout

isList = isArray

isAtom = (x) ->  not isList(x)

pair = (xs) ->
  acc = []
  while(not isEmpty(xs))
    acc.push(xs[0..1])
    xs = xs[2..]
  acc

## Reader

# t stands for token
atom = (t) ->
  try
    if t.match /^\d+\.?$/
      parseInt t
    else if t.match /^\d*\.\d+$/
      parseFloat t
    else
      t
  catch e
    throw "Unable to parse atom " + t

readFrom = (ts) ->
  t = ts.shift()
  if t == '('
    acc = []
    while ts[0] != ')'
      acc.push readFrom(ts)
    ts.shift() # pop off ')'
    acc
  else
    atom t

#tokenize = (s) ->
#  spaced = s.replace( /\(/g , ' ( ')
#            .replace( /\)/g , ' ) ')
#            .split ' '
#  without spaced, ''  # purge of empty string tokens
tokenize = (s) ->
  s.replace(/\(/g, ' ( ') \
   .replace(/\)/g, ' ) ') \
   .replace(/\s+/g, ' ')  \
   .replace(/^\s*/, '')   \
   .replace(/\s*$/, '')   \
   .split(' ')

read = (s) ->
  #pr 's'+s
  tokenized = tokenize(s)
  #pr 'tokenized'
  pr tokenized
  allRead = readFrom tokenized
  
  allRead

parse = read

## Compiler (lc)

# lc is built up iteratively here, one
# conditional at a time. lc is defined
# with a single conditional, tested, and
# then redefined with a second conditional.
# Each redefinition extends upon the previous
# definition, essentially by hand-generating
# the macro-expansion of the arc macro,
# extend (http://awwx.ws/extend).
lc = ->

lava = (s) -> lc parse(s)

# atom
lc = (s) ->
  if isAtom(s) then s

# proc

lcProc2 = (xs) ->
  acc = ""
  each xs, (x) ->
    acc += ',' + lc(x)
  acc

lcProc1 = (xs) ->
  if isEmpty(xs)
    ""
  else lc(xs[0]) + lcProc2(xs[1..])


lcProc = (f, args) ->
  lc(f) + '(' + lcProc1(args) + ')'

(->
  orig = lc
  lc = (s) ->
    if isList(s)
      lcProc(s[0], s[1..])
    else orig(s)
)()

# infix
lcInfix1 = (op, xs) ->
  acc = ""
  each xs, (x) ->
    acc += op + lc(x)
  acc

lcInfix = (op, xs) ->
  if isEmpty(xs)
    ""
  else lc(xs[0]) + lcInfix1(op, xs[1..])

infixOps = ['+','-','*','/','%',
            '>=','<=','>','<','==','===','!=','!==',
            '=','+=','-=','*=','/=','%=',
            '&&','||']

(->
  orig = lc
  lc = (s) ->
    if isList(s) and (s[0] in infixOps)
      lcInfix(s[0], s[1..])
    else orig(s)
)()

# obj
lcObj3 = (xs) ->
  acc = ""
  each xs, (x) ->
    [k, v] = x
    if k[0] == ':'
      k = k[1..]    
    acc += ',' + lc(k) + ':' + lc(v)
  acc

lcObj2 = (xs) ->
  if isEmpty(xs)
    ""
  else
    [k, v] = xs[0]
    if k[0] == ':'
      k = k[1..]
    lc(k) + ':' + lc(v) + lcObj3(xs[1..])

lcObj1 = (xs) ->
  lcObj2 pair(xs)

lcObj = (xs) ->
  '{' + lcObj1(xs) + '}'

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'obj'
      lcObj(s[1..])
    else orig(s)
)()

# array
lcArray2 = (xs) ->
  acc = ""
  each xs, (x) ->
    acc += ',' + lc(x)
  acc

lcArray1 = (xs) ->
  if isEmpty(xs)
    ""
  else lc(xs[0]) + lcArray2(xs[1..])

lcArray = (xs) ->
  '[' + lcArray1(xs) + ']'

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'array'
      lcArray(s[1..])
    else orig(s)
)()

# ref
lcRef = (xs) ->
  [h, k] = xs
  lc(h) + '[' + lc(k) + ']'

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'ref'
      lcRef(s[1..])
    else orig(s)
)()

# dot
lcDot = (xs) ->
  [h, k] = xs
  lc(h) + '.' + lc(k)

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'dot'
      lcDot(s[1..])
    else orig(s)
)()

# if
lcIf3 = (ps) ->
  acc = ""
  each ps, (p, i) ->
    if p.length == 1
      acc += lc(p[0])
    else if i == ps.length-1
      acc += lc(p[0]) + '?' + lc(p[1]) + ':' + 'undefined'
    else
      acc += lc(p[0]) + '?' + lc(p[1]) + ':'
  acc

lcIf2 = (xs) ->
  lcIf3 pair(xs)

lcIf1 = (xs) ->
  '(' + lcIf2(xs) + ')'

lcIf = (xs) ->
  if isEmpty(xs)
    ""
  else if xs.length == 1
    lc(xs[0])
  else
    lcIf1(xs)

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'if'
      lcIf(s[1..])
    else orig(s)
)()

# do
lcDo1 = (xs) ->
  acc = ""
  each xs, (x) ->
    acc += ', ' + lc(x)
  acc

lcDo = (xs) ->
  if isEmpty(xs)
    ""
  else lc(xs[0]) + lcDo1(xs[1..])

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'do'
      lcDo(s[1..])
    else orig(s)
)()

# fn
lcFn4 = (xs) ->
  if isEmpty(xs)
    ""
  else 'return ' + lcDo(xs) + ';'

lcFn3 = (xs) -> lcDo(xs)

lcFn2 = (args, body) ->
  'function' + '(' + lcFn3(args) + ')' + '{' + lcFn4(body) + '}'

lcFn1 = (xs) ->
  lcFn2(xs[0], xs[1..])

lcFn = (xs) ->
  '(' + lcFn1(xs) + ')'

lcDef = (xs) ->
  if isList(xs[0])
    args = xs[0][1..]
    fnName = xs[0][0]
  else
    args = []
    fnName = xs[0]
  #name + ' = '+ lcFn1(xs) + ';'
  expr = 'function ' +  fnName + '(' + lcFn3(args) + ')' + ' { ' + lcFn4(xs[1..]) + ' }'  
  console.log expr
  return expr
  
(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'fn'
      lcFn(s[1..])
    else if isList(s) and s[0] is 'define'
      lcDef(s[1..])
    else orig(s)
)()

# mac
macros = {}

lcMac1 = (name, definition) ->
  macros[name] = definition

lcMac = (xs) ->
  lcMac1 xs[0], xs[1..] # xs[1..]

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'mac'
      lcMac(s[1..])
    else orig(s)
)()

macros = {}

# quote

(->
  orig = lc
  lc = (s) ->
    if isList(s) and s[0] is 'quote'
      s[1]
    else orig(s)
)()

# macro-expand

bind = (parms, args, env={}) ->
  each parms, (parm, i) ->
    env[parm] = args[i]
  env

macroExpand1 = (x, env) ->
  if isAtom x
    if (x of env) then env[x] else x
  else
    acc = []
    each x, (elt) ->
      acc.push macroExpand1(elt, env)
    acc

macroExpand = (name, args) ->
  [parms, body] = macros[name]
  env = bind(parms, args)
  macroExpand1 body, env

(->
  orig = lc
  lc = (s) ->
    if isList(s) and (s[0] of macros)
      lc macroExpand(s[0], s[1..])
    else orig(s)
)()

#lc(['mac', 'foo', ['x'], 'x'])

#macros = {}

## Interface
lava = (s) -> lc parse(s)

#lava("(mac let1 (var val body)
#        ((fn (var) body) val))")

macros = {}

if process.argv.length > 2
  fs = require('fs')
  filename = process.argv[2]
  contents = fs.readFileSync(filename, 'utf-8')

  ast = parse(contents)

  jsContents = lava contents
  process.exit()
else
  if not module.parent
    printOutput = (output) ->
      try
        evilRes = eval(output)
        stdout.write output + '\n' + '=> ' + evilRes + '\n>'
      catch e
        log e
        stdout.write '\n>'
      

    printInputAndEval = (x) ->
      printOutput lava(x)

    repl = ->
      # stdin is paused by default, so this resumes it
      stdin.resume()
      # makes return a string instead of a stream (?)
      stdin.setEncoding('utf8')
      stdout.write '> '
      stdin.on 'data', printInputAndEval
  
    repl()