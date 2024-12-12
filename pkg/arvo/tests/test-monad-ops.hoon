/+  *test
/+  wasm=wasm-lia
/+  parser=wasm-tools-wat-parser-lia
::
=/  lv  lia-value:lia-sur:wasm
=/  cw  coin-wasm:wasm-sur:wasm
=/  import  import:lia-sur:wasm
=/  wasm  ^?(wasm)
=>  |%
    ++  i8neg   ^~((cury sub (bex 8)))
    ++  i16neg  ^~((cury sub (bex 16)))
    ++  i32neg  ^~((cury sub (bex 32)))
    ++  i64neg  ^~((cury sub (bex 64)))
    --
=>
  =/  print-time=?  |
  |%
  ::
  ++  run-once-comp
    =/  m  runnable:wasm
    |=  [sed=[module=octs =import] script=form:m]
    ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ?.  print-time
      =/  nock  ((run-once:wasm (list lv)) sed %none script)
      =/  fast  ((run-once:wasm (list lv)) sed %$ script)
      ?:  =(nock fast)  &+~
      [%| nock+nock fast+fast]
    =/  nock
      ~&  %nock
      ~>  %bout
      ((run-once:wasm (list lv)) sed %none script)
    =/  fast
      ~&  %fast
      ~>  %bout
      ((run-once:wasm (list lv)) sed %$ script)
    ?:  =(nock fast)  &+~
    [%| nock+nock fast+fast]
  ::
  ++  m-inputs
    ^~
    ^-  (map tape (list @))
    %-  malt
    ^-  (list [tape (list @)])
    :~
      :-  "f32"
      ^-  (list @rs)
      :~  .nan
          (con .nan (bex 31))  ::  .-nan
          .inf
          .-inf
          .8.589935e9
          .-8.589935e9
          .3.689349e19
          .-3.689349e19
          .1000.5
          .1000.7
          .1000.3
          .-1000.5
          .-1000.7
          .-1000.3
          .1
          .-1
          .1.1
          .-1.1
          .0.7
          .0.5
          .0.3
          .-0.7
          .-0.5
          .-0.3
          .0
          .-0
      ==
    ::
      :-  "f64"
      ^-  (list @rd)
      :~  .~nan
          (con .nan (bex 63))  ::  .~-nan
          .~inf
          .~-inf
          .~8589934592
          .~-8589934592
          .~3.6893488147419103e19
          .~-3.6893488147419103e19
          .~1000.5
          .~1000.7
          .~1000.3
          .~-1000.5
          .~-1000.7
          .~-1000.3
          .~1
          .~-1
          .~1.1
          .~-1.1
          .~0.7
          .~0.5
          .~0.3
          .~-0.7
          .~-0.5
          .~-0.3
          .~0
          .~-0
      ==
    ::
      :-  "i32"
      ^-  (list @)
      :~
        (dec (bex 32))
        (dec (bex 31))
        0
        1
        2
        1.000
        (bex 16)
        (dec (bex 16))
        (sub (bex 16) 2)
        2
        (i32neg 1.000)
        (i32neg (bex 16))
        (i32neg (dec (bex 16)))
        (i32neg (sub (bex 16) 2))
      ==
    ::
      :-  "i64"
      ^-  (list @)
      :~
        (dec (bex 64))
        (dec (bex 63))
        0
        1
        2
        1.000
        (bex 32)
        (dec (bex 32))
        (sub (bex 32) 2)
        (i64neg 2)
        (i64neg 1.000)
        (i64neg (bex 32))
        (i64neg (dec (bex 32)))
        (i64neg (sub (bex 32) 2))
      ==
    ::
      :-  "i8"
      ^-  (list @)
      :~
        (dec (bex 8))
        (dec (bex 7))
        0
        1
        2
        100
        (bex 4)
        (dec (bex 4))
        (sub (bex 4) 2)
        (i8neg 2)
        (i8neg 100)
        (i8neg (bex 4))
        (i8neg (dec (bex 4)))
        (i8neg (sub (bex 4) 2))
      ==
    ::
      :-  "i16"
      ^-  (list @)
      :~
        (dec (bex 16))
        (dec (bex 15))
        0
        1
        2
        1.000
        (bex 8)
        (dec (bex 8))
        (sub (bex 8) 2)
        (i16neg 2)
        (i16neg 1.000)
        (i16neg (bex 8))
        (i16neg (dec (bex 8)))
        (i16neg (sub (bex 8) 2))
      ==
    ==
  --
|%
++  test-trunc-convert
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  from=(list tape)  ~["f32" "f64"]
    |-  =*  from-loop  $
    ?~  from  &+~
    =/  to=(list tape)  ~["i32" "i64"]
    |-  =*  to-loop  $
    ?~  to  from-loop(from t.from)
    =/  sign=(list tape)  ~["u" "s"]
    |-  =*  sign-loop  $
    ?~  sign  to-loop(to t.to)
    =/  binary=octs  (bin-trunc-convert i.from i.to i.sign)
    =/  input=(list @)  (~(got by m-inputs) i.from)
    |-  =*  input-loop  $
    ?~  input  sign-loop(sign t.sign)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =/  m  runnable:wasm
    ;<  a=@  try:m  (call-1:wasm 'test' i.input ~)
    (return:m ;;(lv [(crip i.to) a]) ~)
    ::
    ++  bin-trunc-convert
      |=  [from=tape to=tape sign=tape]
      ^-  octs
      =/  op=tape  "{to}.trunc_sat_{from}_{sign}"
      %-  parser
      """
      (module
        (func (export "test") (param {from}) (result {to})
          local.get 0
          {op}
      ))
      """
    ::
    --
:: ::
++  test-ceil-floor-trunc-near
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  op=(list tape)  ~["ceil" "floor" "trunc" "nearest"]
    :: =/  op=(list tape)  ~["nearest"]
    |-  =*  op-loop  $
    ?~  op  &+~
    =/  type=(list tape)  ~["f32" "f64"]
    |-  =*  type-loop  $
    ?~  type  op-loop(op t.op)
    =/  binary=octs  (bin i.op i.type)
    =/  input=(list @)  (~(got by m-inputs) i.type)
    |-  =*  input-loop  $
    ?~  input  type-loop(type t.type)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =/  m  runnable:wasm
    ;<  a=@  try:m  (call-1:wasm 'test' i.input ~)
    (return:m ;;(lv [(crip i.type) a]) ~)
    ::
    ++  bin
      |=  [op=tape type=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type}) (result {type})
          local.get 0
          {type}.{op}
      ))
      """
    --
::
++  test-promote
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  input=(list @)  (~(got by m-inputs) "f32")
    |-  =*  input-loop  $
    ?~  input  &+~
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [bin ~]
    =/  m  runnable:wasm
    ;<  a=@  try:m  (call-1:wasm 'test' i.input ~)
    (return:m [%f64 a] ~)
    ::
    ++  bin
      ^~  ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param f32) (result f64)
          local.get 0
          f64.promote_f32
      ))
      """
    --
::
++  test-demote
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  input=(list @)  (~(got by m-inputs) "f64")
    |-  =*  input-loop  $
    ?~  input  &+~
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [bin ~]
    =/  m  runnable:wasm
    ;<  a=@  try:m  (call-1:wasm 'test' i.input ~)
    (return:m [%f32 a] ~)
    ::
    ++  bin
      ^~  ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param f64) (result f32)
          local.get 0
          f32.demote_f64
      ))
      """
    --
::
++  test-convert
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  from=(list tape)  ~["i32" "i64"]
    |-  =*  from-loop  $
    ?~  from  &+~
    =/  to=(list tape)  ~["f32" "f64"]
    |-  =*  to-loop  $
    ?~  to  from-loop(from t.from)
    =/  sign=(list tape)  ~["s" "u"]
    |-  =*  sign-loop  $
    ?~  sign  to-loop(to t.to)
    =/  binary=octs  (bin i.from i.to i.sign)
    =/  input=(list @)  (~(got by m-inputs) i.from)
    |-  =*  input-loop  $
    ?~  input  sign-loop(sign t.sign)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input ~)
    (return:m ;;(lv [(crip i.to) a]) ~)
    ::
    ++  bin
      |=  [from=tape to=tape sign=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {from}) (result {to})
          local.get 0
          {to}.convert_{from}_{sign}
      ))
      """
    --
::
++  test-clz-ctz-popcnt
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  ops=(list tape)  ~["clz" "ctz" "popcnt"]
    |-  =*  ops-loop  $
    ?~  ops  &+~
    =/  type=(list tape)  ~["i32" "i64"]
    |-  =*  type-loop  $
    ?~  type  ops-loop(ops t.ops)
    =/  binary=octs  (bin i.ops i.type)
    =/  input=(list @)  (~(got by m-inputs) i.type)
    |-  =*  input-loop  $
    ?~  input  type-loop(type t.type)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input ~)
    (return:m ;;(lv [(crip i.type) a]) ~)
    ::
    ++  bin
      |=  [op=tape type=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type}) (result {type})
          local.get 0
          {type}.{op}))
      """
    --
::
++  test-abs-neg
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  ops=(list tape)  ~["abs" "neg"]
    |-  =*  ops-loop  $
    ?~  ops  &+~
    =/  type=(list tape)  ~["f32" "f64"]
    |-  =*  type-loop  $
    ?~  type  ops-loop(ops t.ops)
    =/  binary=octs  (bin i.ops i.type)
    =/  input=(list @)  (~(got by m-inputs) i.type)
    |-  =*  input-loop  $
    ?~  input  type-loop(type t.type)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input ~)
    (return:m ;;(lv [(crip i.type) a]) ~)
    ::
    ++  bin
      |=  [op=tape type=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type}) (result {type})
          local.get 0
          {type}.{op}))
      """
    --
::
++  test-extend-convert
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    =/  input=(list @)  (~(got by m-inputs) "i32")
    ::
    =/  sign=(list tape)  ~["u" "s"]
    |-  =*  sign-loop  $
    ?~  sign  &+~
    =/  binary=octs  (bin i.sign)
    |-  =*  input-loop  $
    ?~  input  sign-loop(sign t.sign)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input ~)
    (return:m ;;(lv [%i64 a]) ~)
    ::
    ++  bin
      |=  sign=tape
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param i32) (result i64)
          local.get 0
          i64.extend_i32_{sign}))
      """
    --
::
++  test-extend
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  types=(list tape)  ~["i32" "i64"]
    |-  =*  types-loop  $
    ?~  types  &+~
    =/  width=(list tape)  ~["8" "16" "32"]
    |-  =*  width-loop  $
    ?~  width  types-loop(types t.types)
    ?:  &(=(i.width "32") =(i.types "i32"))
      width-loop(width t.width)
    =/  binary=octs  (bin i.types i.width)
    =/  input=(list @)  (~(got by m-inputs) "i{i.width}")
    |-  =*  input-loop  $
    ?~  input  width-loop(width t.width)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input ~)
    (return:m ;;(lv [(crip i.types) a]) ~)
    ::
    ++  bin
      |=  [type=tape width=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type}) (result {type})
          local.get 0
          {type}.extend{width}_s))
      """
    --
::
++  test-reinterpret
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  from-to=(list (pair tape tape))
      ~["i32"^"f32" "i64"^"f64" "f32"^"i32" "f64"^"i64"]
    |-  =*  from-to-loop  $
    ?~  from-to  &+~
    =/  binary=octs  (bin i.from-to)
    =/  input=(list @)  (~(got by m-inputs) p.i.from-to)
    |-  =*  input-loop  $
    ?~  input  from-to-loop(from-to t.from-to)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input-loop(input t.input)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input ~)
    (return:m ;;(lv [(crip q.i.from-to) a]) ~)
    ::
    ++  bin
      |=  [from=tape to=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {from}) (result {to})
          local.get 0
          {to}.reinterpret_{from}
      ))
      """
    --
::
++  test-rem-div
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  types=(list tape)  ~["i32" "i64"]
    |-  =*  types-loop  $
    ?~  types  &+~
    =/  signs=(list tape)  ~["s" "u"]
    |-  =*  signs-loop  $
    ?~  signs  types-loop(types t.types)
    =/  ops=(list tape)  ~["div" "rem"]
    |-  =*  ops-loop  $
    ?~  ops  signs-loop(signs t.signs)
    =/  binary=octs  (bin i.types i.signs i.ops)
    =/  input0=(list @)  (~(got by m-inputs) i.types)
    =/  input1=(list @)  input0
    |-  =*  input0-loop  $
    ?~  input0  ops-loop(ops t.ops)
    |-  =*  input1-loop  $
    ?~  input1  input0-loop(input0 t.input0)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input1-loop(input1 t.input1)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input0 i.input1 ~)
    (return:m ;;(lv [(crip i.types) a]) ~)
    ::
    ++  bin
      |=  [type=tape sign=tape op=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type} {type}) (result {type})
          local.get 0
          local.get 1
          {type}.{op}_{sign}))
      """
    --
::
++  test-shl-rotl-rotr
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  types=(list tape)  ~["i32" "i64"]
    |-  =*  types-loop  $
    ?~  types  &+~
    =/  ops=(list tape)  ~["shl" "rotl" "rotr"]
    |-  =*  ops-loop  $
    ?~  ops  types-loop(types t.types)
    =/  binary=octs  (bin i.types i.ops)
    =/  input0=(list @)  (~(got by m-inputs) i.types)
    =/  input1=(list @)  input0
    |-  =*  input0-loop  $
    ?~  input0  ops-loop(ops t.ops)
    |-  =*  input1-loop  $
    ?~  input1  input0-loop(input0 t.input0)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input1-loop(input1 t.input1)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input0 i.input1 ~)
    (return:m ;;(lv [(crip i.types) a]) ~)
    ::
    ++  bin
      |=  [type=tape op=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type} {type}) (result {type})
          local.get 0
          local.get 1
          {type}.{op}))
      """
    --
::
++  test-shr
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  types=(list tape)  ~["i32" "i64"]
    |-  =*  types-loop  $
    ?~  types  &+~
    =/  signs=(list tape)  ~["s" "u"]
    |-  =*  signs-loop  $
    ?~  signs  types-loop(types t.types)
    =/  binary=octs  (bin i.types i.signs)
    =/  input0=(list @)  (~(got by m-inputs) i.types)
    =/  input1=(list @)  input0
    |-  =*  input0-loop  $
    ?~  input0  signs-loop(signs t.signs)
    |-  =*  input1-loop  $
    ?~  input1  input0-loop(input0 t.input0)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input1-loop(input1 t.input1)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input0 i.input1 ~)
    (return:m ;;(lv [(crip i.types) a]) ~)
    ::
    ++  bin
      |=  [type=tape sign=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type} {type}) (result {type})
          local.get 0
          local.get 1
          {type}.shr_{sign}))
      """
    --
++  test-min-max-copysign
  %+  expect-eq
    !>  &+~
    !>
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    ::
    =/  types=(list tape)  ~["f32" "f64"]
    |-  =*  types-loop  $
    ?~  types  &+~
    =/  ops=(list tape)  ~["min" "max" "copysign"]
    |-  =*  ops-loop  $
    ?~  ops  types-loop(types t.types)
    =/  binary=octs  (bin i.types i.ops)
    =/  input0=(list @)  (~(got by m-inputs) i.types)
    =/  input1=(list @)  input0
    |-  =*  input0-loop  $
    ?~  input0  ops-loop(ops t.ops)
    |-  =*  input1-loop  $
    ?~  input1  input0-loop(input0 t.input0)
    ::
    =;  res=(each ~ [[%nock yield:m] [%fast yield:m]])
      ?:  ?=(%| -.res)  res
      input1-loop(input1 t.input1)
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (call-1 'test' i.input0 i.input1 ~)
    (return:m ;;(lv [(crip i.types) a]) ~)
    ::
    ++  bin
      |=  [type=tape op=tape]
      ^-  octs
      %-  parser
      """
      (module
        (func (export "test") (param {type} {type}) (result {type})
          local.get 0
          local.get 1
          {type}.{op}))
      """
    --
::  monadic ops
::
++  test-call-ext
  %+  expect-eq
    !>  &+~
    !>
    :: =.  print-time  & 
    =/  m  runnable:wasm
    |^  ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  *  try:m  (call-ext %foo i32+42 octs+3^'foo' ~)
    (return:m ~)
    ::
    ++  binary
      ^-  octs
      (parser "(module)")
    --
::
++  test-global-set-get
  %+  expect-eq
    !>  &+~
    !>
    :: =.  print-time  &
    =/  m  runnable:wasm
    =/  binary
      (parser "(module (global (export \"foo\") (mut i32) i32.const 42))")
    ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  (global-get 'foo')
    ?.  =(a 42)  !!
    ;<  ~    try:m  (global-set 'foo' (i32neg 42))
    ;<  b=@  try:m  (global-get 'foo')
    (return:m i32+b ~)
::
++  test-memsize-grow
  %+  expect-eq
    !>  &+~
    !>
    :: =.  print-time  &
    =/  m  runnable:wasm
    =/  binary=octs
      (parser "(module (memory 3 16))")
    ^-  (each ~ [[%nock yield:m] [%fast yield:m]])
    %+  run-once-comp  [binary ~]
    =,  wasm
    =/  m  runnable
    ;<  a=@  try:m  memory-size
    ?.  =(a 3)  !!
    ;<  b=@    try:m  (memory-grow 13)
    ?.  =(b 3)  !!
    ;<  c=@  try:m  memory-size
    ?.  =(c 16)  !!
    (return:m ~)
--