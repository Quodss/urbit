::  Create a private key-file for a random (or specified) moon
::
::::  /hoon/moon/hood/gen
  ::
/-  *sole
/+  *generators
::
::::
  ::
:-  %say
|=  $:  [now=@da eny=@uvJ bec=beak]
        [mon=@p ~]
        =life
        public-key=pass
    ==
:-  %helm-moon
^-  (unit [=ship =udiff:point:jael])
=*  our  p.bec
=/  ran  (clan:title our)
?:  ?=([?(%earl %pawn)] ran)
  %-  %-  slog  :_  ~
      leaf+"can't manage a moon from a {?:(?=(%earl ran) "moon" "comet")}"
  ~
=/  seg=ship  (sein:title our now mon)
?.  =(our seg)
  %-  %-  slog  :_  ~
      :-  %leaf
      "can't create keys for {(scow %p mon)}, which belongs to {(scow %p seg)}"
  ~
=/  =^life
  ?.  =(*^life life)
    life
  +(.^(^life j+/(scot %p our)/life/(scot %da now)/(scot %p mon)))
=/  ryf=(unit rift)
  .^((unit rift) %j /(scot %p p.bec)/ryft/(scot %da now)/(scot %p mon))
?~  ryf
  %.  ~
  %-  slog
  [leaf+"can't cycle keys for {(scow %p mon)}, it doesn't exists."]~
=/  =pass
  ?.  =(*pass public-key)
    public-key
  =/  cub  (pit:nu:crub:crypto 512 (shaz (jam mon life eny)))
  =/  =feed:jael
    [[%2 ~] mon u.ryf [life sec:ex:cub]~]
  %-  %-  slog
      :~  leaf+"moon: {(scow %p mon)}"
          leaf+(scow %uw (jam feed))
      ==
  pub:ex:cub
`[mon *id:block:jael %keys [life 1 pass] %.n]