/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<(~ arg)
;<  ~              bind:m  send-mass-request:strandio
;<  report=(unit)  bind:m  take-mass:strandio
(pure:m !>(report))
