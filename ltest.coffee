l = require('./lava')
allTests = ->
  test('atom #1', lava('x'), 'x')
  test('isList #1', isList([]), true)
  test('isList #2', isList([1]), true)
  test('isList #3', isList('foo'), false)

  test('isAtom #1', isAtom('x'), true)
  test('isAtom #2', isAtom(['x']), false)

  test('pair #1', pair(['a', '1']), [['a', '1']])
  test('pair #2', pair(['a', '1', 'b']), [['a', '1'], ['b']])
  test('pair #3', pair(['a', '1', 'b', '2']), [['a', '1'], ['b', '2']])

  test('parse #1', parse('x'), 'x')
  test('parse #2', parse('(x)'), ['x'])
  test('parse #3', parse('(x y)'), ['x', 'y'])
  test('parse #4', parse('((x) y)'), [['x'], 'y'])


  test('proc #1', lava('(foo)'), 'foo()')
  test('proc #2', lava('(foo x)'), 'foo(x)')
  test('proc #3', lava('(foo x y)'), 'foo(x,y)')

  test('infix #1', lava('(+ x y)'), "x+y")
  test('infix #2', lava('(+ x y z)'), "x+y+z")
  test('infix #3', lava('(- x y)'), "x-y")
  test('infix #4', lava('(* x y)'), "x*y")
  test('infix #5', lava('(% x y)'), "x%y")

  test('infix #6', lava('(>= x y)'), "x>=y")
  test('infix #7', lava('(<= x y)'), "x<=y")
  test('infix #8', lava('(> x y)'), "x>y")
  test('infix #9', lava('(< x y)'), "x<y")
  test('infix #10', lava('(== x y)'), "x==y")
  test('infix #11', lava('(=== x y)'), "x===y")
  test('infix #12', lava('(!= x y)'), "x!=y")
  test('infix #13', lava('(!== x y)'), "x!==y")

  test('infix #14', lava('(= x y)'), "x=y")
  test('infix #15', lava('(+= x y)'), "x+=y")
  test('infix #16', lava('(-= x y)'), "x-=y")
  test('infix #17', lava('(*= x y)'), "x*=y")
  test('infix #18', lava('(/= x y)'), "x/=y")
  test('infix #19', lava('(%= x y)'), "x%=y")

  test('infix #20', lava('(&& x y)'), "x&&y")
  test('infix #21', lava('(|| x y)'), "x||y")

  test('obj #1', lava('(obj)'), "{}")
  test('obj #2', lava('(obj x y)'), "{x:y}")
  test('obj #3', lava('(obj x y z a)'), "{x:y,z:a}")
  test('obj #4', lava('(obj x y z (+ x y))'), "{x:y,z:x+y}")


  test('array #1', lava('(array)'), "[]")
  test('array #2', lava('(array x)'), "[x]")
  test('array #3', lava('(array x y)'), "[x,y]")
  test('array #4', lava('(array x (array y))'), "[x,[y]]")

  test('ref #1', lava('(ref x y)'), "x[y]")
  test('dot #1', lava('(dot x y)'), "x.y")

  test('if #1', lava('(if)'), "")
  test('if #2', lava('(if x)'), "x")
  test('if #3', lava('(if x y)'), "(x?y:undefined)")
  test('if #4', lava('(if x y z)'), "(x?y:z)")
  test('if #5', lava('(if x y z a)'), "(x?y:z?a:undefined)")


  test('do #1', lava('(do)'), "")
  test('do #2', lava('(do x)'), "x")
  test('do #3', lava('(do x y)'), "x,y")
  test('do #4', lava('(do x y z)'), "x,y,z")

  test('fn #1', lava('(fn ())'), "(function(){})")
  test('fn #2', lava('(fn (x))'), "(function(x){})")
  test('fn #3', lava('(fn (x) x)'), "(function(x){return x;})")
  test('fn #4', lava('(fn (x y) x)'), "(function(x,y){return x;})")

  test('mac #2', macros.foo, [['x'], 'x'])
  test('mac #3', macros.foo, [['x', 'y'], 'x'])
  test('mac #4', macros.foo, [['x', 'y'], ['x', 'y']])

  test('quote #1', lc(['quote', 'x']), 'x')
  test('quote #2', lc(['quote', ['x']]), ['x'])
  test('quote #3', lc(['quote', ['x', 'y']]), ['x', 'y'])

  test('bind #1', bind([], []), {})
  test('bind #2', bind(['x'], ['y']), {'x':'y'})
  test('bind #3', bind(['x', 'z'], ['y', 'a']), {'x':'y', 'z':'a'})

  test('macroExpand1 #1', macroExpand1('x', {}), 'x')
  test('macroExpand1 #2', macroExpand1('x', {'x':'y'}), 'y')
  test('macroExpand1 #3', macroExpand1('x', {'x': ['a','b'] }), ['a','b'])
  test('macroExpand1 #4', macroExpand1(['x', 'y'], {}), ['x','y'])
  test('macroExpand1 #5', macroExpand1(['x', 'y'], {'x':'y'}), ['y','y'])
  test('macroExpand1 #6', macroExpand1(['x', ['y', 'z']], {'z':'a'}), ['x', ['y', 'a']])

  test('macro-expand #1', lc(['foo', 'y']), 'y')

  test('lava #1', lava('x'), 'x')
  test('lava #2', lava('(+ x y)'), 'x+y')
  test('lava #3', lava('(do x y)'), 'x,y')

  test('lava #5', lava('(let1 x 5 x)'), '(function(x){return x;})(5)')
  
  lc(['mac', 'foo'])
  test('mac #1', macros.foo, [])
allTests()