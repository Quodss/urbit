!:
=,  mesa
=/  packet-size  13
::  helper core
::
=>  |%
    +|  %helpers
    ::
    :: +get-forward-lanes: get all lanes to send to when forwarding to peer
    ::
    ++  get-forward-lanes
      |=  [our=@p peer=peer-state peers=(map ship ship-state)]
      ^-  (list lane)
      =;  zar=(trap (list lane))
        ?~  route.peer  $:zar
        =*  rot  u.route.peer
        ?:(direct.rot [lane.rot ~] [lane.rot $:zar])
      ::
      |.  ^-  (list lane)
      ?:  ?=(%czar (clan:title sponsor.peer))
        ?:  =(our sponsor.peer)
          ~
        [%& sponsor.peer]~
      =/  next  (~(get by peers) sponsor.peer)
      ?.  ?=([~ %known *] next)
        ~
      $(peer +.u.next)
    ::  +trace: print if .verb is set and we're tracking .ship
    :: ++  trace
    ::   |=  [verb=? =ship ships=(set ship) print=(trap tape)]
    ::   ^+  same
    ::   ?.  verb
    ::     same
    ::   ?.  =>  [ship=ship ships=ships in=in]
    ::       ~+  |(=(~ ships) (~(has in ships) ship))
    ::     same
    ::   (slog leaf/"{mesa: {(scow %p ship)}: {(print)}" ~)

    ::  +qos-update-text: notice text for if connection state changes
    ::
    :: ++  qos-update-text
    ::   |=  [=ship old=qos:ames new=qos:ames k=? ships=(set ship)]
    ::   ^-  (unit tape)
    ::   ::
    ::   ?+  [-.old -.new]  ~
    ::     [%unborn %live]  `"; {(scow %p ship)} is your neighbor"
    ::     [%dead %live]    (trace k ship ships |.("is ok"))
    ::     [%live %dead]    (trace k ship ships |.("not responding still trying"))
    ::     [%unborn %dead]  (trace k ship ships |.("not responding still trying"))
    ::     [%live %unborn]  `"; {(scow %p ship)} has sunk"
    ::     [%dead %unborn]  `"; {(scow %p ship)} has sunk"
    ::   ==
    ::
    ++  parse-inner-path
      |=  [our=ship p=path]
      ^-  (unit [[@tas @tas] beam])
      ?.  ?=([@ @ @ @ *] p)  ~
      ?~  des=?~(i.t.t.p (some %$) (slaw %tas i.t.t.p))
        ~
      ?~  ved=(de-case i.t.t.t.p)  ~
      `[[i.p i.t.p] [[our u.des u.ved] t.t.t.t.p]]
    ::
    ++  key-chain  ((on ,@ ,[key=@ =path]) lte)
    ++  check-fine-key
      |=  [c=chain:ames =balk key-idx=@]
      ^-  ?
      ?~  link=(get:key-chain c key-idx)
        |
      =/  gol  path.u.link
      =/  =path  [van.balk car.balk spr.balk]
      |-  ^-  ?
      ?~  gol   &
      ?~  path  |
      ?.  =(i.path i.gol)
        |
      $(path t.path, gol t.gol)
    ::
    ++  derive-symmetric-key
      |=  [public-key=@uw private-key=@uw]
      ^-  symmetric-key
      ::
      ?>  =('b' (end 3 public-key))
      =.  public-key  (rsh 8 (rsh 3 public-key))
      ::
      ?>  =('B' (end 3 private-key))
      =.  private-key  (rsh 8 (rsh 3 private-key))
      ::
      `@`(shar:ed:crypto public-key private-key)
    ::
    ++  parse-packet  |=(a=@ -:($:de:pact a))
    ++  inner-path-to-beam
      |=  [her=ship pat=(pole knot)]
      ^-  (unit [vew=view bem=beam])
      ::  /vane/care/case/desk/[spur]
      ::
      ?.  ?=([van=@ car=@ cas=@ des=@ pur=*] pat)
        ~
      ?~  cas=(de-case cas.pat)
        ~
      `[[van car]:pat [her des.pat u.cas] pur.pat]  :: XX
    ::
    ++  get-key-for        |=  [=ship =life]  *@
    ++  get-group-key-for  |=(@ud `(unit @uxI)`(some `@uxI`0))
    +$  binding            [=path root=@uxI]
    ++  crypt
      |%
      ::
      ++  const-cmp
        |=  [a=@ b=@]
        ^-  ?
        =(0 (~(dif fe 7) a b))  :: XX jet for constant-time
      ::
      ++  sign
        |=  [sek=@uxI =binding]
        ^-  @uxJ
        (sigh:as:(nol:nu:crub:crypto sek) (jam binding))
      ::
      ++  verify-sig
        |=  [pub=@uxI sig=@uxJ =binding]
        ^-  ?
        (veri:ed:crypto sig (jam binding) pub)
      ::
      ++  mac
        |=  [key=@uxI =binding]
        ^-  @uxH
        =/  msg  (jam binding)
        ((keyed:blake3:blake:crypto 32^key) 16 (met 3 msg)^msg)
      ::
      ++  verify-mac
        |=  [key=@uxI tag=@uxI =binding]  ::  [key=@uxI tag=@uxH =binding]
        ^-  ?
        (const-cmp tag (mac key binding))
      ::
      ++  encrypt
        |=  [key=@uxI iv=@ msg=@]
        ^+  msg
        (~(en ctrc:aes:crypto key 7 (met 3 msg) iv) msg) :: TODO: chacha8
      ++  decrypt  encrypt
      ::
      ++  seal-path
        |=  [key=@uxI =path]
        ^-  @
        =/  pat  (jam path)
        =/  tag  ((keyed:blake3:blake:crypto 32^key) 16 (met 3 pat)^pat)
        =/  cyf  (encrypt (mix key tag) tag pat)
        (jam [tag cyf])
      ++  open-path
        |=  [key=@uxI sealed=@]
        ^-  path
        =+  ;;([tag=@ cyf=@] (cue sealed))
        =/  pat  (decrypt (mix key tag) tag cyf)
        ?>  (const-cmp tag ((keyed:blake3:blake:crypto 32^key) 16 (met 3 pat)^pat))
        ;;(path (cue pat))
      --
    ::
    ++  jim  |=(n=* ~>(%memo./mesa/jam (jam n)))
    --
::  vane types
::
=>  |%
    +|  %types
    ::  $channel: combined sender and receiver identifying data
    ::
    +$  channel
      $:  [our=ship her=ship]
          now=@da
          =our=life
          ::  her data, specific to this dyad
          ::
          $:  =symmetric-key
              =her=life
              =her=rift
              =her=public-key
              her-sponsor=ship
      ==  ==
    ::
    ::  $move: output effect; either request (to other vane) or response
    ::
    +$  move  [=duct card=(wite note gift)]
    ::
    +$  note
      $~  [%b %wait *@da]
      $%  $:  %m
              $>(?(%make-peek %make-poke %mess-ser %make-page) task:mesa)
          ==
          $:  %b
              $>(?(%wait %rest) task:behn)
          ==
          $:  %c
              $>(%warp task:clay)
          ==
          $:  %d
              $>(%flog task:dill)
          ==
          $:  %g
              $>(%deal task:gall)
          ==
          $:  %j
              $>  $?  %private-keys
                      %public-keys
                      %turf
                      %ruin
                  ==
              task:jael
          ==
          $:  @tas
              $>(%plea vane-task)
      ==  ==
    ::
    +$  lope
      $~  [%wake ~]
      $%  $>(%wake gift:behn)
          $>(?(%flub %unto) gift:gall)
          $>(?(%private-keys %public-keys %turf) gift:jael)
          $>(?(%mess-response %boon %done) gift)
      ==
    ::
    +$  sign
      $~  [%behn *$>(%wake lope)]
      $%  [%behn $>(%wake lope)]
          [%gall $>(?(%flub %unto) lope)]
          [%jael $>(?(%private-keys %public-keys %turf) lope)]
          [%mesa $>(%mess-response lope)]  :: produce a response message
          [@tas $>(?(%boon %done) lope)]
      ==
    +$  flow-sign
      $%  $>(%done lope)  ::  hear (n)ack for %poke, can trigger %peek for naxplanation
          [%mess-response seq=@ud sage:mess] :: added seq number to $>(%response lope)
      ==
    --
::
::  vane gate
::
|=  our=ship
=|  ax=axle
::
|=  [now=@da eny=@uvJ rof=roof]
=*  mesa-gate  .
=>  ::  inner event-handling
    ::
    =|  moves=(list move)
    ::
    |_  [hen=duct per=[=ship sat=ship-state]]
    ::
    +|  %helpers
    ::
    ++  ev-core  .
    ++  ev-abet  moves^ax
    ++  ev-abed  |=(=duct ev-core(hen duct))
    ++  ev-emit  |=(=move ev-core(moves [move moves]))
    ++  ev-emil  |=(mos=(list move) ev-core(moves (weld mos moves)))
    :: ++  ev-abort    ev-core  :: keeps moves, discards state changes
    ++  ev-chan  [[our ship.per] now life.ax ?>(?=(%known -.sat.per) +<.sat.per)]
    ::
    +|  %flow-wires
    ::
    +$  ev-flow-wire
      $:  %flow
          were=?(%van %ext %int %cor %pok)  ::  XX revisit names
          =dire
          [%p her=@p]
          [%ud rift=@ud]
          [%ud bone=@ud]
          [%ud seq=@ud]
          ~
      ==
    ::
    +$  ev-timer-wire  :: XX revisit
      $:  :: ?(%poke %dead %alien ...)  :: XX add tag for each timer flow
          [%p her=@p]
          [%ud bone=@ud]
          [%ud rift=@ud]
          ~
      ==
    ::
    ++  ev-pave
      |=  =path
      ^-  pith
      %+  turn  path
      |=  i=@ta
      (fall (rush i spot:stip) i)
    ::
    +|  %top-level-paths
    ::
    ::  /ax/~ship//ver=1/mess/rift=1//[...]
    ::
    ::  /ax/~ship//ver=1/mess/rift=1/pact/bloq=13/ init/[...]
    ::
    ::  /ax/~ship//ver=1/mess/rift=1/pact/bloq=13/pure/auth/frag=1/[...]
    ::  /ax/~ship//ver=1/mess/rift=1/pact/bloq=13/pure/data/frag=1/[...]
    ::
    +$  res-scry-head  [%ax [%p her=@p] %'1' res=*]
    +$  res-mess-head  [%mess [%ud ryf=@ud] res=*]
    +$  res-pact-head  [%pact [%ud boq=@ud] ser=?(%etch %pure) pat=*]
    +$  res-pure-pith  [typ=?(%auth %data) [%ud fag=@ud] pat=*]
    ::
    +|  %namespace-paths
    ::
    ::  /[..]/publ/life=1/[...]
    ::  /[..]/chum/life=1/her=@p/hyf=@ud/encrypted-path=@uv
    ::  /[..]/shut/key=1/encrypted-path=@uv
    ::
    +$  publ-pith  [%publ [%ud lyf=@ud] pat=*]
    +$  chum-pith  [%chum [%ud lyf=@ud] [%p her=@p] [%ud hyf=@ud] [%uv cyf=@uv] ~]
    +$  shut-pith  [%shut [%ud kid=@ud] [%uv cyf=@uv] ~]
    ::
    +|  %message-flow-paths
    ::
    +$  res-mess-pith
      $:  %flow
          [%ud bone=@ud]
          [%p sndr=@p]   ::  XX drop this
          =load
          [%p rcvr=@p]
          =dire          ::  XX revisit; could be inferred by entry-point + flow
          [%ud mess=@ud]
          ~
      ==
    ::
    ++  ev-validate-wire
      |=  =wire
      ^-  (unit ev-flow-wire)
      =>  .(wire `(pole iota)`(ev-pave wire))
      ?.   ?=(ev-flow-wire wire)
        ~>  %slog.0^leaf/"mesa: malformed wire: {(spud (pout wire))}"  ~
      `wire
    ::
    ++  ev-validate-flow-path
      |=  =path
      ^-  (pole iota)
      ~|  path
      %-  ev-pave
      ?~  inn=(inner-path-to-beam *@p path)  ~
      ~|  u.inn
      ?>  =([[%m %x] *@p %$ ud+1] [vew -.bem]:u.inn)
      s.bem.u.inn
    ::
    ++  ev-decrypt-load
      |=  [[=ship =path] cyf=@]
      ^-  @
      =/  tyl=(pole knot)  path
      ?+    tyl  !!
          [%publ *]  :: unencrypted
        cyf
      ::
          [%chum lyf=@ her=@ hyf=@ pyf=@ ~]  :: encrypted with eddh key
        =/  lyf  (slaw %ud lyf.tyl)
        =/  her  (slaw %p her.tyl)
        =/  hyf  (slaw %ud hyf.tyl)
        =/  pyf  (slaw %uv pyf.tyl)
        ?>  &(?=(^ lyf) ?=(^ her) ?=(^ hyf) ?=(^ pyf))
        =/  key  ::  (get-key-for u.her u.hyf)
          =/  her=@p  ?:(=(u.her our) ship u.her)  :: %poke payload are for us
          =+  per=(ev-got-per her)        :: XX ev-get-per
          ?>  ?=(%known -.sat.per)        :: XX wat if %alien?
          ?.  =(u.hyf life.sat.per)   !!  :: XX
          symmetric-key.sat.per
        =*  iv  u.pyf  :: XX
        (decrypt:crypt `@`key iv cyf)
      ::
          [%shut kid=@ pyf=@ ~]  :: encrypted with group key
        =/  kid  (slaw %ud kid.tyl)
        =/  pyf  (slaw %uv pyf.tyl)
        ?>  &(?=(^ kid) ?=(^ pyf))
        ?>  ?=(%known -.sat.per)
        ?~  key=(get:key-chain client-chain.sat.per u.kid)
          !!  ::  XX handle
        =*  iv  u.pyf  :: XX
        (decrypt:crypt -.u.key iv cyf)
      ==
    ::
    ++  ev-decrypt-path
      |=  [=path =ship]
      ^+  [path path]
      =/  tyl=(pole knot)  path
      ?+    tyl  !!
          [%publ lyf=@ pat=*]  :: unencrypted
        [pat.tyl tyl]
      ::
          [%chum lyf=@ her=@ hyf=@ pat=[cyf=@ ~]]  :: encrypted with eddh key
        =/  lyf  (slaw %ud lyf.tyl)
        =/  her  (slaw %p her.tyl)
        =/  hyf  (slaw %ud hyf.tyl)
        =/  cyf  (slaw %uv cyf.pat.tyl)
        ?>  &(?=(^ lyf) ?=(^ her) ?=(^ hyf) ?=(^ cyf))
        =/  key  ::  (get-key-for u.her u.hyf)
          ::  XX check =(ship u.her)
          =/  her=@p  ?:(=(u.her our) ship u.her)  :: %poke payload are for us
          =+  per=(ev-got-per her)        :: XX ev-get-per
          ?>  ?=(%known -.sat.per)        :: XX wat if %alien?
          ?.  =(u.hyf life.sat.per)   !!  :: XX
          symmetric-key.sat.per
        =+  pat=(open-path:crypt `@`key u.cyf)
        [pat tyl(pat pat)]
      ::
          [%shut kid=@ pat=[cyf=@ ~]]  :: encrypted with group key
        =/  kid  (slaw %ud kid.tyl)
        =/  cyf  (slaw %uv cyf.pat.tyl)
        ?>  &(?=(^ kid) ?=(^ cyf))
        =+  per=(ev-got-per ship)      :: XX ev-get-per
        ?>  ?=(%known -.sat.per)       :: XX wat if %alien?
        ?~  key=(get:key-chain client-chain.sat.per u.kid)
          !!  :: XX handle
        =+  pat=(open-path:crypt -.u.key u.cyf)
        [pat tyl(pat pat)]
      ==
    ::
    ++  ev-authenticate
      |=  [rut=@uxI aut=auth:pact =name:pact]
      ^-  ?
      ?>  ?=([%0 *] aut)
      =*  auth  p.aut
      =/  =beak  [her.name %$ ud+1]  :: XX where do we get this?
      =/  ful  (en-beam [beak pat.name])
      ?-  -.auth
        %&
          =/  pub  (puck:ed:crypto 0)  :: XX get from jael?
          (verify-sig:crypt pub p.auth ful rut)
        %|
          =/  key
            :: XX is there an easier way to get this?
            =/  tyl=(pole knot)  pat.name
            ?>  ?=([%chum lyf=@ her=@ hyf=@ *] tyl)
            =/  her  (slaw %p her.tyl)
            =/  hyf  (slaw %ud hyf.tyl)
            ?>  &(?=(^ her) ?=(^ hyf))
            :: (get-key-for u.her u.hyf)
            =+  per=(ev-got-per u.her)      :: XX ev-get-per
            ?>  ?=(%known -.sat.per)        :: XX wat if %alien?
            ?.  =(u.hyf life.sat.per)   !!  :: XX
            symmetric-key.sat.per
          (verify-mac:crypt `@`key p.auth ful rut)
      ==
    ::
    +|  %entry-points
    ::
    ++  ev-call
      =>  |%  +$  req-task
                $%  $<(%mess $>(?(%plea %keen %cork %heer %mess-ser) task))
                    [%mess (unit lane:pact) =mess dud=(unit goof)]
                ==
          --
      ::
      |=  task=req-task
      ^+  ev-core
      ?-  -.task
      ::  %request-entry-points
      ::
        %plea  (ev-req-plea [ship plea]:task)
        %keen  (ev-req-peek +.task)
        %cork  (ev-req-plea ship.task %$ /cork %cork ~)
      ::  %packet-response-entry-point
      ::
          %heer
        =/  =pact:pact  (parse-packet q.task)
        ?-  -.pact
          %page  (ev-pact-page +.pact)
          %peek  (ev-pact-peek +.pact)
          %poke  (ev-pact-poke +.pact)
        ==
      ::  %message-response-entry-point
      ::
          %mess
        ?-  -.mess.task
          %page  (ev-mess-page +.mess.task)
          %peek  (ev-mess-peek +.mess.task)
          %poke  (ev-mess-poke [dud +.mess]:task)
        ==
      ::  XX completed, serialized, and encrypted response from the packet layer
          %mess-ser
        =*  her  ship.p.+.load.task
        =.  per  (ev-got-per her)
        %-  ev-mess-page
        +.load.task(r (ev-decrypt-load her^path.task r.+.load.task))
      ==
    ::
    ++  ev-take
      |=  task=[=wire lope=$>(?(%done %mess-response %boon %wake) lope)]
      |^  ^+  ev-core
      ?-  -.lope.task
        %wake           (take-wake +.lope.task)
        %boon           take-boon
        %done           (ev-poke-done wire.task +.lope.task)
        %mess-response  (ev-response wire.task +.lope.task)
      ==
      ::
      ++  take-boon
        ^+  ev-core
        ?~  flow-wire=(ev-validate-wire wire.task)
          ev-core
        =,  u.flow-wire
        =.  per  (ev-got-per her)
        ?>  ?=(%known -.sat.per)
        ?:  (lth rift rift.sat.per)
          :: XX log
          ev-core  ::  ignore events from an old rift
        ?>  ?=([%van %bak] [were dire])  ::  vane acks happen on backward flows
        ~!  task
        (ev-req-boon bone ev-chan +.lope.task)
      ::
      ++  take-wake
        |=  error=(unit tang)
        ^+  ev-core
        =>  .(wire.task `(pole iota)`(ev-pave wire.task))
        ?.  ?|  ?=(ev-timer-wire wire.task)
                ?=([%dead-flow ~] wire.task)
            ==
          ~|  %evil-behn-timer^wire.task  !!
        ::  XX log if error
        ::  XX if we wake up too early, no-op, otherwise set new timer
        ::  XX if timed-out, update qos
        ::  XX expire direct route if the peer is not responding (%nail)
        ::  XX re-send comet attestation?
        ::  XX only timed-out (dead) outgoing %poke requests
        ::
        =.  flow.dead.ax  flow/`[~[/mesa] /dead-flow `@da`(add now ~s20)]
        =.  ev-core
          (ev-emit ~[/mesa] %pass /dead-flow %b %wait `@da`(add now ~s20))
        %-  ~(rep by peers.ax)
        |=  [[=ship =ship-state] core=_ev-core]
        ^+  core
        =+  per-sat=(ev-get-per ship)
        ?.  ?=([~ ~ *] per-sat)
          core  ::  %alien or missing
        =.  per  [ship u.u.per-sat]
        ?>  ?=(%known -.sat.per)
        =/  =space  chum/[life.sat.per our life.ax symmetric-key.sat.per]
        %-  ~(rep by pit.sat.per)
        |=  [[=path req=request-state] core=_core]
        ~&  re-sending/path
        ::  XX if =(~ pay.req); %naxplanation, %cork or external $peek request
        =/  =pact:pact
          (ev-make-pact ship.per^path pay.req rift.sat.per `space)  :: XX memoize?
        %+  ev-emit:core   unix-duct.ax
        [%give %send ~[`@ux`ship.per] p:(fax:plot (en:^pact pact))]
      --
    ::
    +|  %request-flow
    ::
    ++  ev-req-plea
      |=  [=ship vane=@tas =wire payload=*]
      ^+  ev-core
      =/  ship-state  (~(get by peers.ax) ship)
      ::
      ?.  ?=([~ %known *] ship-state)
        %^  ev-enqueue-alien-todo  ship  ship-state
        |=  todos=ovni-state
        todos(pokes [[hen plea/vane^wire^payload] pokes.todos])
      ::
      =.  per  ship^u.ship-state
      ?>  ?=(%known -.sat.per)
      =^  bone  ossuary.sat.per  ::  XX  to arm?
        =,  ossuary.sat.per
        ?^  bone=(~(get by by-duct) hen)
          [u.bone ossuary.sat.per]
        :-  next-bone  ^+  ossuary.sat.per
        :+  +(next-bone)
          (~(put by by-duct) hen next-bone)
        (~(put by by-bone) next-bone hen)
      ::
      ::  handle cork
      ::
      =/  cork=?  =([%$ /flow %cork ~] vane^wire^payload)
      ?.  (~(has by by-bone.ossuary.sat.per) bone)
        ~&  "trying to cork {<bone=bone>}, not in the ossuary, ignoring"
        ev-core
      =^  moves  ax
        =<  fo-abet
        %.  plea/[vane wire payload]
        fo-call:(fo-abed:fo hen bone^dire=%for ev-chan `cork)
      (ev-emil moves)
    ::
    ++  ev-req-boon
      |=  [=bone =channel load=*]
      ::  XX handle corked/closing bones
      ::
      =^  moves  ax
        fo-abet:(fo-call:(fo-abed:fo hen bone^dire=%bak channel ~) boon/load)
      (ev-emil moves)
    ::
    ++  ev-req-peek
      |=  [sec=(unit [kid=@ key=@]) spar]
      ^+  ev-core
      =/  ship-state  (~(get by peers.ax) ship)
      ::
      ?.  ?=([~ %known *] ship-state)
        %^  ev-enqueue-alien-todo  ship  ship-state
        |=  todos=ovni-state
        todos(peeks (~(put ju peeks.todos) path hen))
      =.  per  ship^u.ship-state
      ?>  ?=(%known -.sat.per)
      ::  +sy-plug should have already stored [kid key path] in chain.ax
      ::  on the server, and the client would have retrieved the key via
      ::  the %ames key exchange. here we store it in their peer state
      ::
      =/  =space  ?~(sec publ/life.sat.per shut/[kid key]:u.sec)
      ::
      =?  peers.ax  ?=(%shut -.space)
        %+  ~(put by peers.ax)  ship
        %_    sat.per
            client-chain
          (put:key-chain client-chain.sat.per kid.space key.space path)
        ==
      (ev-make-peek space ship^(ev-mess-spac space path))
    ::
    +|  %packet-entry-points
    ::
    ++  ev-pact-poke
      |=  [=ack=name:pact =poke=name:pact =data:pact]
      ~&  ev-pact-poke++6
      ^+  ev-core
      ::  XX dispatch/hairpin &c
      ::
      ::  - pre-check that we want to process this poke (recognize ack path, ship not blacklisted, &c)
      ::  - initialize our own outbound request for the poke payload
      ::  - start processing the part of the poke payload we already have
      ::    - validation should crash event or ensure that no state is changed
      ::  XX  parse path to get: requester, rift, bone, message
      ::
      =/  ship-state  (~(get by peers.ax) her.poke-name)
      ::
      ?.  ?=([~ %known *] ship-state)
        ::  request public keys from %jael and drop the packet; it'll be re-send
        ::
        ::  XX TODO
        (ev-enqueue-alien-todo her.poke-name ship-state |=(ovni-state +<))
      ::
      ::  path validation/decryption
      ::
      ~|  path-decryption-failed/pat.ack-name^pat.poke-name
      =/  ack=(pole iota)
        =^  path  pat.ack-name
         (ev-decrypt-path [pat.ack-name her.poke-name])
        (ev-validate-flow-path path)
      =/  pok=(pole iota)
        =^  path  pat.poke-name
         (ev-decrypt-path [pat her]:poke-name)
        (ev-validate-flow-path path)
      ::
      ~|  path-validation-failed/ack^pok
      ?>  &(?=(res-mess-pith ack) ?=(res-mess-pith pok))
      ::
      ?.  =(sndr.ack our)  ::  do we need to respond to this ack?
        ~&  >>  %not-our-ack^sndr.ack^our
        ev-core  :: XX TODO
      ?.  =(rcvr.pok our)  ::  are we the receiver of the poke?
        ~&  >  %poke-for-other^[rcvr.pok our]
        ev-core  :: XX TODO
      ::
      =.  per  sndr.pok^u.ship-state
      ?>  ?=(%known -.sat.per)
      ?.  =(1 tot.data)
        =/  =wire
          %.  [%pok mess.pok]
          fo-wire:(fo-abed:fo hen [bone dire]:pok ev-chan ~)
        =/  =space  chum/[life.sat.per our life.ax symmetric-key.sat.per]
        %+  ev-emit  hen
        [%pass wire %m make-peek/[space [her pat]:poke-name]]
      ::
      =/  res  (ev-decrypt-load [[her pat]:poke-name] dat.data)
      %:  ev-mess-poke
        ~   :: XX refactor function signature
        rcvr.ack^(pout ack)  ::  XX not used
        sndr.pok^(pout pok)
        ;;(gage:mess (cue res))
      ==
    ::
    ++  ev-pact-peek
      |=  =name:pact
      ?.  =(our her.name)
        ev-core
      =/  res=(unit (unit cage))  (rof ~ /mesa %mx (name-to-beam name))
      ?.  ?=([~ ~ ^] res)
        ev-core
      (ev-emit hen %give %send ~ !<(@ q.u.u.res))
    ::
    ++  ev-pact-page
      |=  [=name:pact =data:pact =next:pact]
      ^+  ev-core
      ::  check for pending request (peek|poke)
      ::
      =*  ship  her.name
      ?~  per=(~(get by peers.ax) ship)
        ev-core
      ?>  ?=([~ %known *] per)  ::  XX alien agenda
      ::  decrypt path
      ::
      =^   *   pat.name  (ev-decrypt-path pat.name ship)
      =*  pat  pat.name
      ?~  res=(~(get by pit.u.per) pat)
        ev-core
      ::
      =/  [typ=?(%auth %data) fag=@ud]
        ?~  wan.name
          [?:((gth tot.data 4) %auth %data) 0]
        [typ fag]:wan.name
      ::
      ?-    typ
          %auth
        ?.  ?|  ?=(~ ps.u.res)
                =(0 fag)
                (gth tot.data 4)
            ==
          ev-core
        =/  proof=(list @ux)  (rip 8 dat.data)
        ?>  (ev-authenticate (recover-root:lss proof) aut.data name)
        ?~  state=(init:verifier:lss tot.data proof)
          ev-core
        =.  peers.ax
          %+  ~(put by peers.ax)  her.name
          =-  u.per(pit -)
          %+  ~(put by pit.u.per)  pat.name
          u.res(ps `[u.state ~])
        ::
        ::  request next fragment
        ::
        =/  =pact:pact  [%peek name(wan [%data 0])]
        (ev-emit unix-duct.ax %give %send ~ p:(fax:plot (en:^pact pact)))
      ::
          %data
        ?>  =(13 boq.name)  :: non-standard
        ::  do we have packet state already?
        ::
        ?~  ps.u.res
          ::  no; then this should be the first fragment, and auth should be present
          ::
          ?>  =(0 fag)
          ?>  ?=([%0 *] aut.data)
          ::  is this a standalone message?
          ::
          ?:  =(1 tot.data)
            ?>  (ev-authenticate (root:lss dat.data) aut.data name)
            =/  =spar:ames  [her.name pat]
            =/  =auth:mess  p.aut.data
            %+  ev-emit  [/ames]~
            [%pass /message %m %mess-ser pat.name %page spar auth dat.data]
          ::  no; then the proof should be inlined; verify it
          ::  (otherwise, we should have received an %auth packet already)
          ::
          ?>  (lte tot.data 4)
          =/  proof=(list @ux)
            =>  aut.data
            ?>  ?=([%0 *] .)
            ?~(q ~ ?@(u.q [u.q ~] [p q ~]:u.q))
          =.  proof  [(leaf-hash:lss fag dat.data) proof]
          ?>  (ev-authenticate (recover-root:lss proof) aut.data name)
          ?~  state=(init:verifier:lss tot.data proof)
            ev-core
          ?~  state=(verify-msg:verifier:lss u.state dat.data ~)
            ev-core
          ::  initialize packet state and request next fragment
          ::
          =.  peers.ax
            %+  ~(put by peers.ax)  her.name
            =-  u.per(pit -)
            %+  ~(put by pit.u.per)  pat.name
            u.res(ps `[u.state ~[dat.data]])
          =/  =pact:pact  [%peek name(wan [%data leaf.u.state])]
          %+  ev-emit  unix-duct.ax
          [%give %send ~[`@ux`her.name] p:(fax:plot (en:^pact pact))]
        ::  yes, we do have packet state already
        ::
        =*  ps  u.ps.u.res
        ?.  =(leaf.los.ps fag)
          ev-core
        ::  extract the pair (if present) and verify
        ::
        =/  pair=(unit [l=@ux r=@ux])
          ?~  aut.data  ~
          `?>(?=([%1 *] .) p):aut.data
        ?~  state=(verify-msg:verifier:lss los.ps dat.data pair)
          ev-core
        ::  update packet state
        ::
        =.  los.ps  u.state
        =.  fags.ps  [dat.data fags.ps]
        =.  peers.ax
          %+  ~(put by peers.ax)  her.name
          =-  u.per(pit -)
          %+  ~(put by pit.u.per)  pat.name
          u.res
        ::  is the message incomplete?
        ::
        ?.  =(+(fag) leaves.los.ps)
          ::  request next fragment
          ::
          =/  =pact:pact  [%peek name(wan [%data leaf.u.state])]
          (ev-emit unix-duct.ax %give %send ~[`@ux`her.name] p:(fax:plot (en:^pact pact)))
        ::  yield complete message
        ::
        =/  =spar:ames  [her.name pat]
        =/  =auth:mess  [%| *@uxH] :: XX should be stored in ps?
        =/  res         (rep 13 (flop fags.ps))
        %+  ev-emit  [/ames]~
        [%pass /message %m %mess-ser pat.name %page spar auth res]
      ==
    ::
    +|  %messages-entry-point
    ::
    ++  ev-mess-page
      |=  [=spar =auth:mess res=@]  :: XX res has been decrypted
      ^+  ev-core
      =*  ship  ship.spar
      ?~  rs=(~(get by peers.ax) ship)
        ev-core
      ?>  ?=([~ %known *] rs)  ::  XX alien agenda
      ?~  ms=(~(get by pit.u.rs) path.spar)
        ev-core
      =.  per  ship^u.rs
      ?>  ?=(%known -.sat.per)
      ::
      ::  XX validate response
      ::
      =/  res       (ev-decrypt-load spar res)  :: XX should have happened before
                                                :: XX breaks non-encrypted %keen tasks
      =.  pit.u.rs  (~(del by pit.u.rs) path.spar)
      =.  peers.ax  (~(put by peers.ax) ship.spar u.rs)
      =/  gift      [%give %mess-response spar ;;(gage:mess (cue res))]
      %-  ~(rep in for.u.ms)
      |=  [hen=duct c=_ev-core]
      (ev-emit:c hen gift)
    ::
    ++  ev-mess-poke  :: XX refactor function signature
      |=  [dud=(unit goof) =ack=spar =pok=spar =gage:mess]
      ^+  ev-core
      =+  ?~  dud  ~
          %-  %+  slog  leaf+"mesa: message crashed {<mote.u.dud>}"
              tang.u.dud
          ::  XX what if the crash is due to path validation
          ::  and we can't infer the sequence number?
          ~
      =/  pok=(pole iota)  (ev-pave path.pok-spar)
      ~|  poke-path-failed/path.pok-spar
      ?>  ?=(res-mess-pith pok)
      ::
      ::  the packet layer has already validated that this is a valid %poke
      ::
      ::  XX ev-got-per; assumes that %aliens are checked in the packet layer
      =.  per  (ev-got-per sndr.pok)
      ?>  ?=(%known -.sat.per)
      ::
      =/  =dire  :: flow swtiching
        ?:  =(%for dire.pok)  %bak
        ?>  =(%bak dire.pok)  %for
      ::
      =/  req=mesa-message
        ~|  gage-parsing-failed/gage
        ?>  ?=([%message *] gage)  :: XX [%message %mark *] ??
        ?:  =(%for dire)  ::  %boon(s) sink forward (reversed %plea direction)
          ?>(?=([%boon *] +.gage) +.gage)
        ?>  =(%bak dire)  ::  %pleas(s) and %corks sink backward
        ?>  ?=([%plea *] +.gage)
        plea/;;(plea +>.gage)
      ::
      :: =/  already-closing=?  closing.flow.sat.per  :: XX
      =/  fo-core
        %.  [%sink mess.pok req ?=(~ dud)]
        fo-call:(fo-abed:fo hen bone.pok^dire ev-chan ~)
      =^  moves  ax
        ?.  closing.state.fo-core
          fo-abet:fo-core
        :: ?.  already-closing
        ::   ::  XX log?
        ::   [moves:fo-core ax]
        :: if the flow changed to closing, we received a %cork;
        :: remove the flow and publish %cork %ack in the namespace
        ::
        =.  corked.sat.per  (~(put in corked.sat.per) bone.pok^dire)
        [moves:fo-core ax(peers (~(put by peers.ax) [ship sat]:per))]
      (ev-emil moves)
    ::
    ++  ev-mess-peek
      |=  =spar
      ?.  =(our ship.spar)
        ev-core
      =/  res=(unit (unit cage))
        !!  :: scry for path
      ?.  ?=([~ ~ ^] res)
        ev-core
      ::  XX [%give %response %page p.mess [p q.q]:u.u.res]
      ev-core
    ::
    +|  %responses
    ::
    ::  +ev-response: network responses
    ::
    ++  ev-response
      |=  [=wire =sage:mess]
      ^+  ev-core
      ?~  flow-wire=(ev-validate-wire wire)
        ev-core
      =,  u.flow-wire
      =.  per  (ev-got-per her)
      ?>  ?=(%known -.sat.per)  :: XX
      ?:  (lth rift rift.sat.per)
        :: XX log
        ev-core  ::  ignore events from an old rift
      ::  XX replaced by the flow "dire"ction ?(%for %bak)
      ::  based on the bone we can know if this payload is an ack?
      ::  bone=0                                   bone=1
      ::  response   <=  ack payloads        =>       response
      ::             <=  boon/poke payloads  =>
      ::
      ::  bones for acks are "internal", -- triggered by internal requests
      ::  for %poke payloads "external" -- triggered by hearing a request
      ::
      ?:  =(%pok were)
        =/  pok=(pole iota)
          =^  path  path.p.sage
            (ev-decrypt-path [path ship]:p.sage)
          (ev-validate-flow-path path)
        ?>  ?=(res-mess-pith pok)
        (ev-mess-poke ~ ack-path=our^/ her^(pout pok) q.sage)
      ::  wires are tagged ?(%int %ext) so we can diferentiate if we are
      ::  proessing an ack or a naxplanation payload
      ::
      =/  fo-core
        ::  XX parse $ack payload in here, and call task instead?
        %.  [were mess-response/[seq sage]]
        fo-take:(fo-abed:fo hen bone^dire ev-chan ~)
      =^  moves  ax
        ?:  &(=(were %cor) =(dire %bak) (~(has in corked.sat.per) bone^dire))
          ::  if the bone is corked, we have received the ack;
          ::  we can safely delete the flow
          ::
          =.  flows.sat.per  (~(del by flows.sat.per) bone^dire)
          [moves:fo-core ax(peers (~(put by peers.ax) [ship sat]:per))]
        ?.  closing.state.fo-core  :: XX check that it was not closing before
          fo-abet:fo-core
        ?>  =(were %int)
        :: if the flow changed to closing, we received an %ack for a %cork;
        :: remove the flow and it's associated bone in the ossuary
        ::
        ::  XX to arm
        =.  sat.per
          =,  sat.per
          %_  sat.per
            flows            (~(del by flows) bone^dire)
            corked           (~(put in corked) bone^dire)
            by-duct.ossuary  (~(del by by-duct.ossuary) (ev-got-duct bone))  ::  XX bone^side=%for
            by-bone.ossuary  (~(del by by-bone.ossuary) bone)                ::  XX bone^side=%for
          ==
        [moves.fo-core ax(peers (~(put by peers.ax) [ship sat]:per))]
      (ev-emil moves)
    ::  +ev-poke-done: vane responses
    ::
    ++  ev-poke-done
      |=  [=wire error=(unit error)]
      ^+  ev-core
      ?~  flow-wire=(ev-validate-wire wire)
        ev-core
      =,  u.flow-wire
      =.  per  (ev-got-per her)
      ?>  ?=(%known -.sat.per)
      ?:  (lth rift rift.sat.per)
        :: XX log
        ev-core  ::  ignore events from an old rift
      ?>  ?=([%van %bak] [were dire])  ::  vane acks happen on backward flows
      ::
      ::  relay the vane ack to the foreign peer
      ::
      =^  moves  ax
        =<  fo-abet
        ::  XX since we ack one message at at time, seq is not needed?
        ::  XX use it as an assurance check?
        ::
        %.  [%van done/error]
        fo-take:(fo-abed:fo hen bone^dire=%bak ev-chan ~)
      (ev-emil moves)
    ::
    +|  %message-constructor
    ::
    ++  ev-make-mess
      |=  [p=spar q=(unit path) spac=(unit space)]
      ^+  ev-core
      =/  her  (~(gut by peers.ax) ship.p *ship-state)
      ?>  ?=([%known *] her)  ::  XX alien agenda
      ?^  res=(~(get by pit.her) path.p)
        ?>  =(q pay.u.res)  ::  prevent overriding payload
        =-  ev-core(peers.ax -)
        %+  ~(put by peers.ax)  ship.p
        =-  her(pit -)
        %+  ~(put by pit.her)  path.p
        u.res(for (~(put in for.u.res) hen))
      ::
      ?:  ?&  ?=(^ q)
              =;  res=(unit (unit cage))
                !?=([~ ~ %message *] res)
              ?~  inn=(inner-path-to-beam our u.q)
                ~
              (rof ~ /mesa/make/mess [%mx bem]:u.inn)
          ==
        ~|  q
        !! :: XX wat do?
      =|  new=request-state
      =.  for.new   (~(put in for.new) hen)
      =.  pay.new   q
      =.  peers.ax
        (~(put by peers.ax) ship.p her(pit (~(put by pit.her) path.p new)))
      ::
      =/  =pact:pact  (ev-make-pact p q rift.her spac)
      (ev-emit unix-duct.ax %give %send ~[`@ux`ship.p] p:(fax:plot (en:^pact pact)))
    ::
    ++  ev-make-peek
      |=  [=space p=spar]
      (ev-make-mess p ~ `space)
    ::
    ++  ev-make-poke
      |=  [=space =ack=spar =poke=path]
      =.  path.ack-spar   (ev-mess-spac space path.ack-spar)
      (ev-make-mess ack-spar `poke-path `space)
    ::
    ++  ev-make-page
      |=  [=space spar]
      ^+  ev-core
      =/  =name:pact  [[our rift.ax] [13 ~] (ev-mess-spac space path)]
      ?~  page=(ev-get-page name)
        ev-core
      =/  =pact:pact  page/[name u.page ~]
      %+  ev-emit  unix-duct.ax
      [%give %send ~[`@ux`ship] p:(fax:plot (en:^pact pact))]
    ::
    ++  ev-make-pact
      |=  [p=spar q=(unit path) =per=rift spac=(unit space)]
      ^-  pact:pact
      =/  nam  [[ship.p per-rift] [13 ~] path.p]
      ?~  q
        [%peek nam]
      ::  XX if path will be too long, put in [tmp] and use that path
      :: (mes:plot:d (en:name:d [[her=~nec rif=40] [boq=0 wan=~] pat=['c~_h' ~]]))
      :: [bloq=q=3 step=r=12]
      ::  =/  has  (shax u.u.res)
      ::  =.  tmpeers.ax  (~(put by tmpeers.ax) has [%some-envelope original-path u.u.res])
      ::  //ax/[$ship]//1/temp/[hash]
      ::  switch life(s) for payloads
      ::  XX  test that these lifes are correctly checked in the +scry handler
      ::
      ?>  ?=(^ spac)
      =?  u.spac  ?=(?(%publ %chum) -.u.spac)
        ?:  ?=(%publ -.u.spac)
          u.spac(life life.ax)
        u.spac(our-life her-life.u.spac, her-life our-life.u.spac, her ship.p)
      ::
      =/  man=name:pact  [[our rift.ax] [13 ~] (ev-mess-spac u.spac u.q)]
      ::
      [%poke nam man (need (ev-get-page man))]
    ::
    ++  ev-mess-spac
      |=  [=space =path]
      ^+  path
      ?-    -.space
          %publ  `^path`[%publ (scot %ud life.space) path]  :: unencrypted
      ::
          %chum  :: encrypted with eddh key
        :-  %chum
        ^+  path  =,  space
        :~  (scot %ud our-life)  (scot %p her)  (scot %ud her-life)
            (scot %uv (seal-path:crypt `@`key path))
        ==
      ::
          %shut  :: encrypted with group key
        :: key provided by the %keen task, or retrieved from client-chain.per.sat
        ::
        =/  cyf  (seal-path:crypt key.space path)
        /shut/[(scot %ud kid.space)]/[(scot %uv cyf)]
      ==
    ::
    ++  ev-get-page
      |=  =name:pact
      ^-  (unit data:pact)
      =/  res=(unit (unit cage))  (rof ~ /mesa %mx (name-to-beam name))
      ?.  ?=([~ ~ *] res)  ~
      =;  page=pact:pact
        ?>(?=(%page -.page) `q.page)
      (parse-packet ;;(@ q.q.u.u.res))
    ::
    +|  %peer-helpers
    ::
    ++  ev-gut-per
      |=  =ship
      ^+  per
      :-  ship
      =/  ship-state  (~(get by peers.ax) ship)
      :-  %known
      ?.(?=([~ %known *] ship-state) *peer-state +.u.ship-state)
    ::
    ++  ev-got-per
      |=  =ship
      ^+  per
      :-  ship
      ~|  %freaky-alien^ship
      =-  ?>(?=([%known *] -) -)
      (~(got by peers.ax) ship)
    ::  +get-her-state: lookup .her state, ~ if missing, [~ ~] if %alien
    ::
    ++  ev-get-per
      |=  her=ship
      ^-  (unit (unit ship-state))
      ::
      ?~  per=(~(get by peers.ax) her)  ~
      `per
    ::
    ++  ev-put-per
      |=  =ship
      ^+  ax
      ax(peers (~(put by peers.ax) ship known/*peer-state))
    ::
    ++  ev-got-duct
      |=  =bone
      ^-  duct
      ?>  ?=(%known -.sat.per)
      ~|(%dangling-bone^ship.per^bone (~(got by by-bone.ossuary.sat.per) bone))
    ::
    +|  %flows
    ::
    ++  fo
      ::  flows exist only for known peers
      ::
      =>  .(sat.per ?>(?=(%known -.sat.per) sat.per))
      ::
      |_  [[hen=duct =side =channel] state=flow-state]  :: XX remove channel
      ::
      +*  veb   veb.bug.channel
          her   her.channel
          bone  bone.side
          dire  dire.side
      ::
      +|  %helpers
      ::
      ++  fo-core  .
      ++  fo-abed
        |=  [=duct =^side =^channel cork=(unit ?)]  :: XX remove channel
        ::  XX use got by in another arm to assert when the flow should exist
        =.  state  (~(gut by flows.sat.per) side *flow-state)
        =?  closing.state  ?=(^ cork)  u.cork
        fo-core(hen duct, side side, channel channel)
      ::
      ++  fo-abet
        ^+  [moves ax]
        ::
        =.  flows.sat.per  (~(put by flows.sat.per) bone^dire state)
        [moves ax(peers (~(put by peers.ax) her sat.per))]
      ::
      ++  fo-emit      |=(=move fo-core(moves [move moves]))
      ++  fo-emil      |=(mos=(list move) fo-core(moves (weld mos moves)))
      ++  fo-ack-path  |=([seq=@ud =dyad] (fo-path seq %ack dyad))
      ++  fo-pok-path  |=([seq=@ud =dyad] (fo-path seq %poke dyad))
      ++  fo-nax-path  |=([seq=@ud =dyad] (fo-path seq %nax dyad))
      ++  fo-cor-path  |=([seq=@ud =dyad] (fo-path seq %cork dyad))
      ++  fo-corked    (~(has in corked.sat.per) side)
      ++  fo-closing   closing.state
      ++  fo-is-naxed  |=(seq=@ud (~(has by nax.state) seq))
      ++  fo-to-close
        ::  if the flow is in closing, only allow sending the %cork %plea
        ::
        |=(poke=mesa-message ?&(fo-closing !=(poke [%plea %$ /flow %cork ~])))
      ::
      ++  fo-flip-dire  ?:(=(dire %for) %bak %for)
      ::
      +|  %builders
      ::
      ++  fo-mop  ((on ,@ud mesa-message) lte)
      ++  fo-cac  ((on ,@ud ?) lte)
      ++  fo-path
        |=  [seq=@ud path=?(%ack %poke %nax %cork) dyad]
        ^-  ^path
        %-  fo-view-beam
        :~  %flow  (scot %ud bone)
            reqr=(scot %p sndr)  path  rcvr=(scot %p rcvr)
        ::  %ack(s), %naxplanation(s) and %cork(s) are on the other side,
        ::  and not bounded on our namespace
            ?:(=(%poke path) dire fo-flip-dire)
            (scot %ud seq)
        ==
      ::
      ++  fo-view-beam  |=(=path `^path`[vane=%m care=%x case='1' desk=%$ path])
      ::
      ++  fo-wire
        ::  XX better names
        ::  $?  for-acks=%int
        ::      for-nax-payloads=%ext
        ::      to/from-vane=%van
        ::      for-corks=%cor
        ::      for-poke-payloads=%pok
        ::  ==
        ::
        |=  [were=?(%int %ext %van %cor %pok) seq=@ud]
        ^-  wire
        ::  %for: %plea(s) are always sent forward, %boon(s) %bak
        ::  both .to-vane and .dire are asserted when receiving the vane %ack
        ::  since they will always be %van and %bak
        ::
        :~  %flow  were  dire
            rcvr=[(scot %p her)]
          :: add rift to avoid dangling bones from previous eras
          ::
            rift=[(scot %ud rift.sat.per)]
            bone=[(scot %ud bone)]
            seq=[(scot %ud seq)]
          ==
      ::
      +|  %entry-points
      ::
      ++  fo-call
        =>  |%
            +$  poke-task
              $%  [%sink seq=@ud mess=mesa-message ok=?]
                  ::  XX remove %fo-planation from lull
                  mesa-message
              ==
            --
        ::
        |=  poke=poke-task
        ^+  fo-core
        ::
        ?-    -.poke
            ?(%plea %boon %cork)
          ?:  |((fo-to-close poke) fo-corked)
            ::  XX log
            fo-core
          fo-send(loads.state (put:fo-mop loads.state next-load.state poke))
          ::
            %sink
          ~|  mess.poke
          ::  a %plea sinks on the backward receiver (from a forward flow)
          ::  a %boon sinks on the forward receiver (from a backward flow)
          ::
          ?-  dire
            %bak  ?>(?=(%plea -.mess.poke) (fo-sink-plea [seq +.mess ok]:poke))
            %for  ?>(?=(%boon -.mess.poke) (fo-sink-boon [seq +.mess ok]:poke))
          ==
        ==
      ::
      ++  fo-take
        |=  [were=?(%ext %int %van %cor %pok) sign=flow-sign]
        ^+  fo-core
        ?-  -.sign
             %done   ?>(?=(%van were) (fo-take-done +.sign))  :: ack from client vane
        ::
            %mess-response
          ?+  were  !!  :: %pok is handle outside
            :: XX payload given by the packet layer
            :: via the wire used when %pass %a peek-for-poke
            :: and only handled there?
            %ext  (fo-take-naxplanation +.sign)
            %int  (fo-take-ack +.sign)
            %cor  (fo-take-client-cork +.sign)
          ==
        ==
      ::
      ++  fo-peek
        |=  [=load mess=@ud]
        ^-  (unit page)
        ::  XX assert flow direction?
        ::  %ack and %nax can be both %for (%plea) and %bak (%boon)
        ::
        ?+  load  !!  ::  XX
          ::  if mess > gth 10, no-op ?
          %ack   ?.(=(mess last-acked.state) ~ `ack/(fo-is-naxed mess))
          %nax   ?~(nax=(~(get by nax.state) mess) ~ `nax/u.nax)
          %poke  ?~  v=(get:fo-mop loads.state mess)  ~
                 ?+  -.u.v  ~  :: XX cork?
                     %plea  `plea/[vane path payload]:u.v
                     %boon  `boon/payload.u.v
        ==       ==
      ::
      +|  %request
      ::
      ++  fo-send
        ^+  fo-core
        =+  loads=loads.state ::  cache
        |-  ^+  fo-core
        =*  loop  $
        =+  num=(wyt:fo-mop loads)
        ?:  =(0 num)
          fo-core
        ?.  (lte num send-window.state)
          fo-core
        ::
        =^  [seq=@ud request=mesa-message]  loads  (pop:fo-mop loads)
        =:  send-window.state  (dec send-window.state)
            next-load.state    +(next-load.state)
          ==
        ::  XX %ames call itself with a %make-poke task
        ::  on a wire used to infer the listener (the %poke %plea request; this)
        ::  when getting the %response $page with the %ack (tagged with %int)
        ::  and similarly for %naxplanation payloads (tagged with %ext)
        ::
        ::  XX  namespace encoding here, on inside the +make-poke?
        :: =/  paths=[spar path]
        ::   :-  =/  =ack=space
        ::         chum/[life.sat.per our life.ax symmetric-key.sat.per]
        ::       her^(ev-mess-spac ack-space (fo-ack-path seq her our))
        ::   =/  =poke=space
        ::     chum/[life.ax ship.per [life symmetric-key]:sat:per]
        ::   (ev-mess-spac poke-space (fo-pok-path seq our her))
        =/  paths=[spar path]
          [her^(fo-ack-path seq her our) (fo-pok-path seq our her)]
        =/  =space   chum/[life.sat.per our life.ax symmetric-key.sat.per]
        =/  =wire    (fo-wire %int seq)
        =.  fo-core  (fo-emit hen %pass wire %m make-poke/[space paths])
        loop
      ::
      +|  %response
      ::
      ++  fo-sink-boon
        |=  [seq=@ud message=* ok=?]
        ^+  fo-core
        =.  fo-core  (fo-emit (ev-got-duct bone) %give %boon message)
        ::  XX handle a previous crash
        :: =?  moves  !ok
        ::   ::  we previously crashed on this message; notify client vane
        ::   ::
        ::   %+  turn  moves
        ::   |=  =move
        ::   ?.  ?=([* %give %boon *] move)  move
        ::   [duct.move %give %lost ~]
        ::  XX emit ack to unix
        ::  ack unconditionally
        ::
        =.  last-acked.state  +(last-acked.state)
        fo-core
      ::
      ++  fo-sink-plea
        |=  [seq=@ud =plea ok=?]
        ^+  fo-core
        ::  receiver of a %plea request
        ::
        ::  XX check that the message can be acked (not in future, or far back past)
        ::
        ?:  (gth seq +(last-acked.state))
          ::  no-op if future message
          ~&  %future-ack
          fo-core
        ?:  ::  (lte (sub +(last-acked.state) seq) 10)  :: XX TODO
            =(seq last-acked.state)
          ~&  %already-acked
          (fo-send-ack seq)
        ?.  ok
          %.  `*error
          fo-take-done:fo-core(pending-ack.state %.y)
        ::
        =/  =wire  (fo-wire %van seq)
        ?:  &(=(vane %$) ?=([%cork ~] payload) ?=([%flow ~] path)):plea
          ::  publisher receives %cork
          ::  mark flow as closing
          ::  publish %cork %ack (in +ev-mess-poke) in corked.sat.per
          ::
          =.  fo-core
            %-  fo-emit
            ::  start %peek request to check if they have corked the flow
            ::  after reading the ack from our namespace
            ::
            =/  =space  chum/[life.sat.per our life.ax symmetric-key.sat.per]
            =/  =path   (ev-mess-spac space (fo-cor-path seq her^our))
            [hen %pass wire=(fo-wire %cor seq) %m make-peek/space^her^path]
          ::  XX just fo-core(closing.state %.y)?
          (fo-take-done:fo-core(closing.state %.y, pending-ack.state %.y) ~)
        =.  fo-core
          ?+  vane.plea  ~|  %mesa-evil-vane^our^her^vane.plea  !!
            ?(%c %e %g %j)  (fo-emit hen %pass wire vane.plea plea/her^plea)
          ==
        ::
        fo-core(pending-ack.state %.y)
      ::
      +|  %from-vane
      ::
      ++  fo-take-done
        |=  error=(unit error)
        ^+  fo-core
        ::  if there's a pending-vane ack, is always +(last-acked)
        ::
        ?>  =(%.y pending-ack.state)
        =/  seq=@ud  +(last-acked.state)
        =:  last-acked.state   seq
            pending-ack.state  %.n
          ==
        =?  nax.state  ?=(^ error)
          =?  nax.state  (gth seq 10)
            ::  only keep the last 10 nacks
            ::
            (~(del by nax.state) (sub seq 10))
          (~(put by nax.state) seq u.error)
        (fo-send-ack seq)
      ::
      +|  %from-network
      ::
      ++  fo-take-ack
        |=  [seq=@ud =spar =gage:mess]
        ^+  fo-core
        ::  only handle acks for %pokes that have been sent
        ::
        ?.  (lth seq next-load.state)
          :: XX log?
          fo-core
        ::  if all pokes have been processed no-op
        ::
        ?~  first=(pry:fo-mop loads.state)
          fo-core
        ?>  ?=([%message *] gage)
        =+  ;;([%ack error=?] +.gage)  ::  XX
        ?.  =(key.u.first seq)
          :: if the ack we receive is not for the first, save it
          ::  XX if error, start +peeking right away?
          ::
          fo-core(cache.state (put:fo-cac cache.state seq error))
        |-  ^+  fo-core
        ?:  error
          ::  if error start %peek for naxplanation
          ::
          =/  =wire  (fo-wire %ext seq)
          ::  XX %ames call itself with a %make-peek task
          ::  on a wire used to infer the listener (the %poke %nax request; us)
          ::  when getting the %response $page with or %naxplanation payloads
          ::  (tagged with %ext)
          ::
          =/  =space  chum/[life.sat.per our life.ax symmetric-key.sat.per]
          =/  =path   (ev-mess-spac space (fo-nax-path seq her^our))
          (fo-emit hen %pass wire %m make-peek/[space her^path])
        ::  ack is for the first, oldest pending-ack sent message;
        ::  remove it and XX start processing cached acks
        ::
        =^  *  loads.state  (del:fo-mop loads.state seq)
        ::  increase the send-window so we can send the next message
        ::
        =.  send-window.state  +(send-window.state)
        =.  fo-core
          ?:  ?|  ?=(%bak dire)          ::  %boon %ack; assumed %acked from vane
                  ?&  closing.state      ::  %cork %ack; implicit ack
                      ?=(~ loads.state)  ::  nothing else is pending
              ==  ==
            fo-core
          ::  don't give %done for %boon and %cork; implicit %ack
          ::
          (fo-emit (ev-got-duct bone) %give %done ~)
        ::  are there any cached acks?
        ::
        ?~  cack=(pry:fo-cac cache.state)  fo-core
        ?.  =(key.u.cack +(seq))           fo-core
        ::  first ack in the cache is the next sent %poke; process
        ::
        =^  *  cache.state  (del:fo-cac cache.state key.u.cack)
        $(error val.u.cack, seq key.u.cack)
      ::
      ++  fo-take-naxplanation
        |=  [seq=@ud =spar =gage:mess]
        ^+  fo-core
        ::  XX same as fo-take-ack refactor
        ::
        =/  next-load=@ud  ?~(next=(ram:fo-mop loads.state) 1 key.u.next)
        ?:  (gth seq next-load)
          :: XX log?
          fo-core
        ::  if all pokes have been processed no-op
        ::
        ?~  first=(pry:fo-mop loads.state)
          fo-core
        :: XX  if the ack we receive is not for the first, no-op
        :: XX as currently implemented we only hear for the naxplanation of the
        ::  oldest message
        ::
        ?.  =(key.u.first seq)
          fo-core
        ::  ack is for the first, oldest pending-ack set message, remove it
        ::
        =^  *  loads.state  (del:fo-mop loads.state seq)
        ::  increase the send-window so we can send the next message
        ::
        =.  send-window.state  +(send-window.state)
        ::  XX check path.spar
        ::  XX path.spar will be the full namespace path, peel off before?
        ::  XX clear timer for the failed %poke
        ::
        ?>  ?=([%message %nax *] gage)
        =+  ;;(=error +>.gage)  ::  XX
        (fo-emit (ev-got-duct bone) %give %done `error)
      ::
      ++  fo-take-client-cork
        |=  [seq=@ud =spar =gage:mess]
        ^+  fo-core
        ::  sanity checks on the state of the flow
        ::
        ?>  ?&  ?=([%message *] gage)
                ;;(ack=? +.gage)            ::  client has corked the flow
                =(seq last-acked.state)     ::  %cork is the higest acked seq
                !pending-ack.state          ::  there are no pending acks
                closing.state               ::  the flow is in closing
                !(~(has by nax.state) seq)  ::  the %cork was not nacked
            ==
        fo-core
      ::
      +|  %internals
      ::
      ++  fo-send-ack
        |=  seq=@ud
        ::  emit ack to unix
        ::
        =/  =path
          ::  we flip the direction of the flow since this is an ack we produce
          ::
          (%*(fo-ack-path fo-core dire.side fo-flip-dire) seq our her)
        =/  =space  chum/[life.ax her [life symmetric-key]:sat.per]
        (fo-emit hen %pass /make-page %m make-page/[space her^path])
      ::
      --
    ::
    +|  %aliens
    ::  +ev-enqueue-alien-todo: helper to enqueue a pending request
    ::
    ::    Also requests key and life from Jael on first request.
    ::    If talking to a comet, requests attestation packet.
    ::
    ++  ev-enqueue-alien-todo
      |=  $:  =ship
              ship-state=(unit ship-state)
              mutate=$-(ovni-state ovni-state)
          ==
      ^+  ev-core
      ::  create a default $ovni-state on first contact
      ::
      =/  [already-pending=? todos=ovni-state]
        ?~  ship-state
          [%.n *ovni-state]
        [%.y ?>(?=(%alien -.u.ship-state) +.u.ship-state)]
      ::  mutate .todos and apply to permanent state
      ::
      =.  todos     (mutate todos)
      =.  peers.ax  (~(put by peers.ax) ship %alien todos)
      ?:  already-pending  ev-core
      ::
      ?:  =(%pawn (clan:title ship))
        ::  XX  (request-attestation ship)
        ev-core
      ::  NB: we specifically look for this wire in +public-keys-give in
      ::  Jael.  if you change it here, you must change it there.
      ::
      (ev-emit hen %pass /public-keys %j %public-keys [n=ship ~ ~])
    ::
    +|  %system
    ::
    ++  sy  ::  system/internal: %born, %heed, %kroc, %prod...
      |_  hen=duct
      ::
      +|  %helpers
      ::
      ++  sy-core  .
      ++  sy-abet  ev-core
      ::
      +|  %entry-points
      ::
      ++  sy-born
        ::  XX
        ~&  flow.dead.ax
        =?  ev-core  ?=(~ +.flow.dead.ax)
          (ev-emit ~[/mesa] %pass /dead-flow %b %wait `@da`(add now ~s1))
        =?  flow.dead.ax  ?=(~ +.flow.dead.ax)
          flow/`[~[/mesa] /dead-flow `@da`(add now ~s1)]
        =.  ev-core  (ev-emit hen %pass /private-keys %j %private-keys ~)
        sy-core(ax ax(unix-duct hen))
      ++  sy-init
        ^+  sy-core
        =.  ev-core
          %-  ev-emil
          :~  [hen %pass /turf %j %turf ~]
              [hen %pass /private-keys %j %private-keys ~]
              [hen %pass /public-keys %j %public-keys [n=our ~ ~]]
              [~[/mesa] %pass /dead-flow %b %wait `@da`(add now ~m2)]
          ==
        sy-core
      ::  +sy-plug: handle key reservation
      ::
      ++  sy-plug
        |=  =path
        ^+  sy-core
        =/  key=@
          sec:ex:(pit:nu:crub:crypto 512 (shaz eny))
        =/  kid=@ud
          ?~  latest=(ram:key-chain server-chain.ax)
            1
          .+(key.u.latest)
        =.  server-chain.ax
          (put:key-chain server-chain.ax kid [key path])
        ~&  >  plug/[kid key path]
        ::  kid^key kill be used by remote %keen task when sending $peek
        ::
        :: sy-core(ev-core (ev-emit hen %give %stub kid key))
        sy-core
      ::
      ++  sy-publ
        |=  [=wire =public-keys-result:jael]
        |^  ^+  sy-core
        ::
        ?-    public-keys-result
            [%diff @ %rift *]
          (on-publ-rift [who to.diff]:public-keys-result)
        ::
            [%diff @ %keys *]
          (on-publ-rekey [who to.diff]:public-keys-result)
        ::
            [%diff @ %spon *]
          (on-publ-sponsor [who to.diff]:public-keys-result)
        ::
            [%full *]
          (on-publ-full points.public-keys-result)
        ::
            [%breach *]
          (on-publ-breach who.public-keys-result)
        ==
        ::  +on-publ-breach: handle continuity breach of .ship; wipe its state
        ::
        ::    Abandon all pretense of continuity and delete all messaging state
        ::    associated with .ship, including sent and unsent messages.
        ::    Also cancel all timers related to .ship.
        ::
        ++  on-publ-breach
          |=  =ship
          ^+  sy-core
          ?:  =(our ship)
            sy-core
          ::
          =/  ship-state  (~(get by peers.ax) ship)
          ::  we shouldn't be hearing about ships we don't care about
          ::
          ?~  ship-state
            ~>  %slog.0^leaf/"ames: breach unknown {<our ship>}"
            sy-core
          ::  if an alien breached, this doesn't affect us
          ::
          ?:  ?=([~ %alien *] ship-state)
            ~>  %slog.0^leaf/"ames: breach alien {<our ship>}"
            sy-core
          ~>  %slog.0^leaf/"ames: breach peer {<our ship>}"
          ::  a peer breached; drop messaging state
          ::
          =/  =peer-state       +.u.ship-state
          =/  old-qos=qos:ames  qos.peer-state
          ::  reset all peer state other than pki data
          ::
          =.  +.peer-state  +:*^peer-state
          ::  print change to quality of service, if any
          ::
          :: =/  text=(unit tape)
          ::   %^  qos-update-text  ship  %ames
          ::   [old-qos qos.peer-state kay.veb ships.bug.ax]
          ::
          :: =?  sy-core  ?=(^ text)
          ::   (ev-emit duct %pass /qos %d %flog %text u.text)
          ::  reinitialize galaxy route if applicable
          ::
          =?  route.peer-state  =(%czar (clan:title ship))
            `[direct=%.y lane=[%& ship]]
          ::
          =.  peers.ax
            (~(put by peers.ax) ship [%known peer-state])
          ::
          :: =.  ev-core
          ::   %-  ev-emit
          ::   :*  unix-duct.ax  %give  %nail  ship
          ::       (get-forward-lanes our peer-state peers.ax)
          ::   ==
          ::  if one of our sponsors breached, give the updated list to vere
          ::
          =/  sponsors  (~(gas in *(set ^ship)) sy-get-sponsors)
          =?  ev-core  (~(has in sponsors) ship)
            (ev-emit unix-duct.ax %give %saxo ~(tap in sponsors))
          :: ::
          sy-core
        ::  +on-publ-rekey: handle new key for peer
        ::
        ::    TODO: assert .crypto-suite compatibility
        ::
        ++  on-publ-rekey
          |=  $:  =ship
                  =life
                  crypto-suite=@ud
                  =public-key
              ==
          ^+  sy-core
          ?:  =(our ship)
            sy-core
          ::
          =/  ship-state  (~(get by peers.ax) ship)
          ?.  ?=([~ %known *] ship-state)
            =|  =point:jael
            =.  life.point     life
            =.  keys.point     (my [life crypto-suite public-key]~)
            =.  sponsor.point  `(^^sein:title rof /mesa our now ship)
            ::
            (on-publ-full (my [ship point]~))
          ::
          =/  =peer-state   +.u.ship-state
          =/  crypto-core   (nol:nu:crub:crypto priv.ax)
          =/  =private-key  sec:ex:crypto-core
          =.  symmetric-key.peer-state
            (derive-symmetric-key public-key private-key)
          ::
          =.  life.peer-state        life
          =.  public-key.peer-state  public-key
          ::
          =.  peers.ax
           (~(put by peers.ax) ship %known peer-state)
          sy-core
        ::  +on-publ-sponsor: handle new or lost sponsor for peer
        ::
        ::    TODO: really handle sponsor loss
        ::
        ++  on-publ-sponsor
          |=  [=ship sponsor=(unit ship)]
          ^+  sy-core
          ::
          ?:  =(our ship)
            sy-core(ev-core (ev-emit unix-duct.ax %give %saxo sy-get-sponsors))
          ?~  sponsor
            %-  (slog leaf+"ames: {(scow %p ship)} lost sponsor, ignoring" ~)
            sy-core
          ::
          =/  state=(unit ship-state)  (~(get by peers.ax) ship)
          ?.  ?=([~ %known *] state)
            %-  (slog leaf+"ames: missing peer-state, ignoring" ~)
            sy-core
          =.  sponsor.+.u.state   u.sponsor
          =.  peers.ax  (~(put by peers.ax) ship %known +.u.state)
          :: =.  ev-core
          ::   %-  ev-emit
          ::   :*  unix-duct.ax  %give  %nail  ship
          ::       (get-forward-lanes our +.u.state peers.ax)
          ::   ==
          ::
          sy-core
        ::  +on-publ-full: handle new pki data for peer(s)
        ::
        ++  on-publ-full
          |=  points=(map ship point:jael)
          ^+  sy-core
          ::
          =>  .(points ~(tap by points))
          |^  ^+  sy-core
              ?~  points  sy-core
              ::
              =+  ^-  [=ship =point:jael]  i.points
              ::
              =?  rift.ax  =(our ship)
                rift.point
              ::
              ::  XX not needed?
              :: =?  sy-core  =(our ship)
              ::   (ev-emit unix-duct.ax %give %saxo get-sponsors)
              ?.  (~(has by keys.point) life.point)
                $(points t.points)
              ::
              =/  old-ship-state  (~(get by peers.ax) ship)
              ::
              =.  sy-core  (insert-peer-state ship point)
              ::
              =?  sy-core  ?=([~ %alien *] old-ship-state)
                (meet-alien ship point +.u.old-ship-state)
              ::
              $(points t.points)
          ::
          ++  meet-alien
            |=  [=ship =point:jael todos=ovni-state]
            |^  ^+  sy-core
            ::  if we're a comet, send self-attestation packet first
            ::
            :: =?  sy-core  =(%pawn (clan:title our))
            ::   =/  blob=@  (attestation-packet ship life.point)
            ::   (send-blob for=| ship blob (~(get by peers.ax) ship))
            ::  apply heeds
            ::
            :: =.  sy-core
            ::   %+  roll  ~(tap in heeds.todos)
            ::   |=  [=duct core=_sy-core]
            ::   (on-heed:core(duct duct) ship)
            ::
            =.  ev-core
              =~  .(ev-core meet-alien-poke)  ::  apply outgoing messages
                  meet-alien-peek             ::  apply remote scry requests
              ==
            ::
            sy-core
            ::
            ++  meet-alien-peek
              ^+  ev-core
              %-  ~(rep by peeks.todos)
              |=  [[=path ducts=(set duct)] core=_ev-core]
              %-  ~(rep in ducts)
              |=([=duct c=_core] (ev-req-peek:(ev-abed:c duct) ~ ship path))
            ::
            ++  meet-alien-poke
              ^+  ev-core
              %+  reel  pokes.todos  ::  reversing for FIFO order
              |=  [[=duct mess=mesa-message] core=_ev-core]
              ?+  -.mess  !!  :: XX log alien peer %boon?
                %plea  (ev-req-plea:(ev-abed:core duct) ship +.mess)
                %cork  (ev-req-plea:(ev-abed:core duct) ship %$ /cork %cork ~)
              ==
            ::
            --
          ::
          --
        ::  on-publ-rift: XX
        ::
        ++  on-publ-rift
          |=  [=ship =rift]
          ^+  sy-core
          =?  rift.ax  =(our ship)
            rift
          ?~  ship-state=(~(get by peers.ax) ship)
            ::  print error here? %rift was probably called before %keys
            ::
            ~>  %slog.1^leaf/"ames: missing peer-state on-publ-rift"
            sy-core
          ?:  ?=([%alien *] u.ship-state)
            ::  ignore aliens
            ::
            sy-core
          =/  =peer-state      +.u.ship-state
          =.  rift.peer-state  rift
          =.  peers.ax
            (~(put by peers.ax) ship %known peer-state)
          sy-core
        ::
        ++  insert-peer-state
          |=  [=ship =point:jael]
          ^+  sy-core
          ::
          =/  =ship-state      sat:(ev-gut-per ship)
          =/  =public-key      pass:(~(got by keys.point) life.point)
          =/  crypto-core      (nol:nu:crub:crypto priv.ax)
          =/  =private-key     sec:ex:crypto-core
          =/  =symmetric-key   (derive-symmetric-key public-key private-key)
          ::
          ?>  ?=(%known -.ship-state)
          =.  qos.ship-state            [%unborn now]
          =.  life.ship-state           life.point
          =.  rift.ship-state           rift.point
          =.  public-key.ship-state     public-key
          =.  symmetric-key.ship-state  symmetric-key
          =.  sponsor.ship-state
            ?^  sponsor.point
              u.sponsor.point
            (^^sein:title rof /mesa our now ship)
          ::  automatically set galaxy route, since unix handles lookup
          ::
          =?  route.ship-state  ?=(%czar (clan:title ship))
            `[direct=%.y lane=[%& ship]]
          ::
          =.  peers.ax
            (~(put by peers.ax) ship ship-state)
          ::
          :: =?  ev-core  ?=(%czar (clan:title ship))
          ::   %-  ev-emit
          ::   :*  unix-duct.ax  %give  %nail  ship
          ::       (get-forward-lanes our +.ship-state peers.ax)
          ::   ==
          sy-core
        --
      ::
      ++  sy-priv
        |=  [=life vein=(map life private-key)]
        ^+  sy-core
        ::
        =.  priv.ax      (~(got by vein) life)
        ~&  >>  mesa/priv.ax
        =.  life.ax      life
        =/  crypto-core  (nol:nu:crub:crypto priv.ax)
        ::  recalculate each peer's symmetric key
        ::
        =.  peers.ax
          %-  ~(run by peers.ax)
          |=  =ship-state
          ^+  ship-state
          ::
          ?.  ?=(%known -.ship-state)
            ship-state
          =/  =peer-state  +.ship-state
          =.  symmetric-key.peer-state
            (derive-symmetric-key public-key.+.ship-state sec:ex:crypto-core)
          ::
          known/peer-state
        ::
        sy-core
      ::
      +|  %internals
      ::
      ++  sy-get-sponsors
        ;;  (list ship)
        =<  q.q  %-  need  %-  need
        (rof [~ ~] /ames %j `beam`[[our %saxo %da now] /(scot %p our)])
      --
    ::
--
::
|%
::
++  call
  |=  [hen=duct dud=(unit goof) wrapped-task=(hobo task)]
  ^-  [(list move) _mesa-gate]
  =/  =task  ((harden task) wrapped-task)
  =+  ev-core=(ev-abed:ev-core hen)
  ::
  =^  moves  ax
    ::  handle error notification
    ::
    ?^  dud
      ?+  -.task  !!
          :: (on-crud:event-core -.task tang.u.dud)
        %heer   %-  %-  slog
                    :_  tang.u.dud
                    leaf+"mesa: %heer crashed {<mote.u.dud>}"
               `ax
        %mess  ev-abet:(ev-call:ev-core %mess p.task q.task dud)
      ==
    ::
    =<  ev-abet
    ?+  -.task  !!
      %vega  ev-core
      %init  sy-abet:~(sy-init sy hen)
      %born  sy-abet:~(sy-born sy hen)
      %plug  sy-abet:(~(sy-plug sy hen) path.task)
    ::
      %plea  (ev-call:ev-core %plea [ship plea]:task)
      %keen  (ev-call:ev-core %keen +.task)
    ::  from internal %ames request
    ::
      %make-peek  (ev-make-peek:ev-core +.task)
      %make-poke  (ev-make-poke:ev-core +.task)
      %make-page  (ev-make-page:ev-core +.task)
    ::  XX
    ::
      %heer      (ev-call:ev-core task)  ::  XX dud
      %mess      (ev-call:ev-core %mess p.task q.task ~)  ::  XX acks go direclty here
      %mess-ser  (ev-call:ev-core task)
    ==
    ::
  [moves mesa-gate]
::
++  take
  |=  [=wire hen=duct dud=(unit goof) =sign]
  ^-  [(list move) _mesa-gate]
  ?^  dud
    ~|(%mesa-take-dud (mean tang.u.dud))
  ::
  =+  ev-core=(ev-abed:ev-core hen)
  =^  moves  ax
    ?:  ?=([%gall %unto *] sign)  :: XX from poking %ping app
      `ax
    ::
    =<  ev-abet
    ?+  sign  !!
      [%behn %wake *]  (ev-take:ev-core [wire %wake error.sign])
    ::
      [%jael %turf *]          ev-core  ::sy-abet:(~(on-take-turf sy hen) turf.sign)
      [%jael %private-keys *]  sy-abet:(~(sy-priv sy hen) [life vein]:sign)
      [%jael %public-keys *]   sy-abet:(~(sy-publ sy hen) wire +>.sign)
    ::  vane (n)ack
    ::
      [@ %done *]  (ev-take:ev-core [wire %done error.sign])
    ::
    ::  vane gifts
    ::
      [@ %boon *]  (ev-take:ev-core [wire %boon payload.sign])
    ::
    ::  network responses: acks/naxplanation payloads
    ::                     reentrant from %ames (either message or packet layer)
    ::
      [%mesa %mess-response *]
    ::
      =/  response-pith  `(pole iota)`(ev-pave wire)
      %.  [wire %mess-response +>.sign]
      ?+    response-pith   ~|  %mesa-evil-response-wire^wire  !!
          ::  %acks come directly into the message layer since they are always one
          ::  packet, and then given back to the flow layer that called them
          ::
          ?([%keen ~] ev-flow-wire)
        ev-take:ev-core  ::  %ack and %naxplanation payload
      ==
    ::
    ==
  [moves mesa-gate]
::
++  stay  `axle`ax
::
++  load
  |=  old=axle
  ^+  mesa-gate
  =.  peers.old
    %-  ~(run by peers.old)
    |=  =ship-state
    ?:  ?=(%alien -.ship-state)  ship-state
    %_  ship-state
      flows  ~
      pit    ~
    ==
  mesa-gate(ax old)
::
++  scry
  ^-  roon
  |=  [lyc=gang pov=path car=term bem=beam]
  ^-  (unit (unit cage))
  ?:  ?&  =(our p.bem)
          =(%$ q.bem)
          =([%ud 1] r.bem)
          =(%x car)
      ==
    =/  tyl=(pole knot)  s.bem
    ?+    tyl  ~
    ::
    ::  publisher-side, protocol-level
    ::
        [%mess ryf=@ res=*]
      =/  ryf  (slaw %ud ryf.tyl)
      ?~  ryf  [~ ~]
      ?.  =(rift.ax u.ryf)      ::  XX unauthenticated
        ~
      =*  rif  u.ryf
      =/  nex
        ^-  $@  ~
            $:  pat=path
                $=  pac       ::  XX control packet serialization
                $@  ~
                $:  boq=bloq
                    ser=?
                    wan=$@(~ [typ=?(%auth %data) fag=@ud])
            ==  ==
        ?+    res.tyl  ~
            [%$ pat=*]  [pat.res.tyl ~]
        ::
            [%pact boq=@ ser=?(%etch %pure) %init pat=*]
          ?~  boq=(slaw %ud boq.res.tyl)
            ~
          [pat.res.tyl u.boq ?=(%etch ser.res.tyl) ~]
        ::
            [%pact boq=@ ser=?(%etch %pure) typ=?(%auth %data) fag=@ pat=*]
          =/  boq  (slaw %ud boq.res.tyl)
          =/  fag  (slaw %ud fag.res.tyl)
          ?:  |(?=(~ boq) ?=(~ fag))
            ~
          [pat.res.tyl u.boq ?=(%etch ser.res.tyl) typ.res.tyl u.fag]
        ==
      ::
      ?~  nex
        [~ ~]
      =*  pat  pat.nex
      =/  res  $(lyc ~, pov /mesa/mess, s.bem pat)
      ?.  ?&  ?=([~ ~ %message *] res)
        :: ...validate that it's really a message
        :: =>  [%message tag=?(sig hmac) ser=@]
          ==
        ~
      ?~  pac.nex  res
      ::
      ::  packets
      ::
      =*  boq  boq.pac.nex
      ?.  ?=(%13 boq)
        ~ :: non-standard fragments for later
      =/  msg  ;;([typ=?(%sign %hmac) aut=@ ser=@] q.q.u.u.res)  :: XX types
      =/  mes=auth:mess  ?:(?=(%sign typ.msg) &+aut.msg |+aut.msg)
      =*  ser  ser.msg
      =/  wid  (met boq ser)
      ?<  ?=(%0 wid)  :: XX is this true?
      =/  nit=?  |    :: XX refactor
      |-  ^-  (unit (unit cage))
      ?~  wan.pac.nex
        $(nit &, wan.pac.nex [?:((gth wid 4) %auth %data) 0])
      ::
      =*  fag  fag.wan.pac.nex
      ?.  (gth wid fag)
        [~ ~]
      ?:  ?&  ?=(%auth typ.wan.pac.nex)
              !=(0 fag)
          ==
        ~  :: non-standard proofs for later
      =;  [nam=name:pact dat=data:pact]
        =/  pac=pact:pact  [%page nam dat ~]
        ?.  ser.pac.nex
          ``[%packet !>(pac)]
        ``[%atom !>(p:(fax:plot (en:pact pac)))]
      ::
      ?-    typ.wan.pac.nex
          %auth
        =/  nam  [[our rif] [boq ?:(nit ~ [%auth fag])] pat]
        ::  NB: root excluded as it can be recalculated by the client
        ::
        =/  aut  [%0 mes ~]
        =/  lss-proof  (build:lss (met 3 ser)^ser) ::  XX cache this
        =/  dat  [wid aut (rep 8 proof.lss-proof)]  :: XX types
        [nam dat]
      ::
          %data
        =/  lss-proof  (build:lss (met 3 ser)^ser)  :: XX cache this
        =/  nam  [[our rif] [boq ?:(nit ~ [%data fag])] pat]
        =/  aut=auth:pact
          ?:  &((lte wid 4) =(0 fag))
            :: inline (or absent) proof
            ::
            :+  %0  mes
            ?:  =(1 wid)  ~
            =/  tal  (tail proof.lss-proof)
            ?:  ?=(?(%1 %2) wid)
              ?>  ?=([* ~] tal)
              `i.tal
            ?>  ?=([* * ~] tal)
            `[i i.t]:tal
          ::
          :: full proof; provide a pair of sibling hashes
          ::
          ?:  (gte fag (lent pairs.lss-proof))  ~
          [%1 (snag fag pairs.lss-proof)]
        ::
        =/  dat  [wid aut (cut boq [fag 1] ser)]
        [nam dat]
      ==
    ::
    ::  XX need a single namespace entrypoint to validate
    ::     generically any authentication tag for a message
    ::
    ::    /ax/[$ship]//1/validate-message/[auth-string]/[blake3-hash]/[path]
    ::
    ::  publisher-side, message-level
    ::
        [%publ lyf=@ pat=*]
      =/  lyf  (slaw %ud lyf.tyl)
      ?~  lyf  [~ ~]
      ::  XX uncomment
      :: ?.  =(u.lyf life.ax)
      ::   ~&  1/[u.lyf life.ax]
      ::   ~
      ?~  inn=(inner-path-to-beam our pat.tyl)
        [~ ~]
      =/  view  ?@(vew.u.inn vew.u.inn (cat 3 [way car]:vew.u.inn))
      ?~  res=(rof ~ /mesa/publ view bem.u.inn)
        ~
      =/  gag  ?~(u.res ~ [p q.q]:u.u.res)  :: XX how does receiver distinguish these?
      =/  ful  (en-beam bem)
      =/  ryf  rift.ax
      =/  ser  (jam gag)  :: unencrypted
      ``[%message !>([%sign (sign:crypt `@`priv.ax ful (root:lss ser)) ser])]
    ::
        [%chum lyf=@ her=@ hyf=@ cyf=@ ~]
      =/  lyf  (slaw %ud lyf.tyl)
      =/  her  (slaw %p her.tyl)
      =/  hyf  (slaw %ud hyf.tyl)
      =/  cyf  (slaw %uv cyf.tyl)
      ?:  |(?=(~ lyf) ?=(~ her) ?=(~ hyf) ?=(~ cyf))
        [~ ~]
      ?.  =(u.lyf life.ax)
        ~
      :: =/  key  (get-key-for u.her u.hyf)  :: eddh with our key
      =/  key=@
        =+  per=(ev-got-per u.her)      :: XX ev-get-per
        ?>  ?=(%known -.sat.per)        :: XX no-op if %alien?
                                        :: fall back to %jael, do eddh on the side?
        ?.  =(u.hyf life.sat.per)   !!  :: XX
        symmetric-key.sat.per
      =/  pat  (open-path:crypt key u.cyf)
      ?~  inn=(inner-path-to-beam our pat)  ~
      ?~  res=(rof `[u.her ~ ~] /mesa/chum vew.u.inn bem.u.inn)
        ~
      =/  gag  ?~(u.res ~ [p q.q]:u.u.res)
      =/  ful  (en-beam bem)
      =*  iv   u.cyf  :: XX
      =/  ser  (encrypt:crypt key iv (jam gag))
      =/  ryf  rift.ax  ::  XX
      ``[%message !>([%hmac (mac:crypt key ful (root:lss ser)) ser])]
    ::
        [%shut kid=@ cyf=@ ~]
      =/  kid  (slaw %ud kid.tyl)
      =/  cyf  (slaw %uv cyf.tyl)
      ?:  |(?=(~ kid) ?=(~ cyf))
        [~ ~]
      :: ?~  key=(get-group-key-for u.kid)
      ?~  key=(get:key-chain server-chain.ax u.kid)
        ~
      =/  pat  (open-path:crypt -.u.key u.cyf)
      ::  XX check path prefix
      ?~  inn=(inner-path-to-beam our pat)
        ~
      ?~  res=(rof [~ ~] /mesa/shut vew.u.inn bem.u.inn)
        ~
      =/  gag  ?~(u.res ~ [p q.q]:u.u.res)
      =/  ful  (en-beam bem)
      =*  iv   u.cyf
      =/  ser  (encrypt:crypt -.u.key iv (jam gag))
      =/  ryf  rift.ax  :: XX
      ``[%message !>([%sign (sign:crypt -.u.key ful (root:lss ser)) ser])]
    ::  publisher-side, flow-level
    ::
        ::res-mess-pith:ev-res  ::  /[~sndr]/[load]/[~rcvr]/flow/[bone]/[dire]/[mess]
        ::  XX drop sndr, it's always our
        [%flow bone=@ sndr=@ load=@ rcvr=@ dire=@ mess=@ ~]
      ::  XX remove typed-paths
      =>  .(tyl `(pole iota)`(ev-pave tyl))
      ?>  ?=(res-mess-pith tyl)
      ?.  =(our sndr.tyl)
        ~  :: we didn't send this poke
      ::  XX refactor block when +rof arms goes back into +scry
      ::     to get all arms from ev-core
      ::
      =+  per-sat=(ev-get-per rcvr.tyl)
      ?.  ?=([~ ~ *] per-sat)
        ~  ::  %alien or missing
      =.  per  [rcvr.tyl u.u.per-sat]
      ?>  ?=(%known -.sat.per)
      ?:  ?&  (~(has in corked.sat.per) [bone dire]:tyl)
              ?=(?(%cork %ack) load.tyl)
          ==
          ::  if %ack for a %corked flow (for both client and server),
          ::  produce %ack
          ::  XX when are corked bones evicted?
          ::
          ``[%message !>(`ack/%.n)]
      ::
      =/  res=(unit page)
        %.  [load mess]:tyl
        fo-peek:(fo-abed:fo ~[//scry] [bone dire]:tyl ev-chan ~)
      ?~(res ~ ``[%message !>(u.res)])
    ==
  ::  only respond for the local identity, %$ desk, current timestamp
  ::
  ?.  ?&  =(our p.bem)
          =([%da now] r.bem)
          =(%$ q.bem)
      ==
    ~
  ::
  ::  /ax/peers/[ship]               ship-state
  ::
  ?.  ?=(%x car)  ~
  =/  tyl=(pole knot)  s.bem
  ::  private endpoints
  ::
  ?.  =([~ ~] lyc)  ~
  ?+    tyl  ~
        [%peers her=@ ~]
      =/  who  (slaw %p her.tyl)
      ?~  who  [~ ~]
      ?~  peer=(~(get by peers.ax) u.who)
        [~ ~]
      ``noun+!>(u.peer)
  ==
::
--
