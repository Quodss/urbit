/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<(~ arg)
;<  ~  bind:m  send-mass-request:strandio
(pure:m !>(~))
::
::  ;<  (unit)  bind:m  send-mass-request:strandio
::  take-mass:strandio
