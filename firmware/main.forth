64 buffer: pad

: phex2. ( c -- )
  base @ >r
  hex 0 <# # # #> type space
  r> base ! ;

: parse-num ( u -- c )
  base @ >r
  1 lshift pad + 2 hex number drop
  r> base ! ;

: mem-on ( -- )
  vdd-on 5 ms
  data-in
  ce-high we-high oe-high
  45 ms ;

: mem-off ( -- )
  data-out 0 set-data
  0 set-address
  we-low oe-low ce-low
  vdd-off 50 ms ;

: write ( c a -- )
  set-address set-data we-low we-high ;

: prog ( a -- )
  mem-on data-out ce-low
  \ erase sector
  $AA $5555 write
  $55 $2AAA write
  $80 $5555 write
  $AA $5555 write
  $55 $2AAA write
  $30 over write
  data-in
  26 ms
  $2E emit
  \ program bytes
  4096 0 do
    pad 64 accept drop
    32 0 do
      data-out
      $AA $5555 write
      $55 $2AAA write
      $A0 $5555 write
      i parse-num                      \ a c
      2dup swap                        \ a c c a
      write                            \ a c
      data-in
      begin dup get-data = until drop  \ a
      ce-high ce-low
      1+                               \ (a+1)
    loop
    cr
  32 +loop
  drop
  mem-off ;

: show-address ( a -- a )
  base @ >r
  hex
  dup 0 <# 32 hold [char] ] hold # # # # # [char] [ hold #> type
  r> base ! ;

: dump ( a u -- )
  mem-on
  ce-low
  0 do
    cr show-address
    32 0 do
      dup set-address
      get-data
      base @ >r
      hex 0 <# # # #> pad i 2* + swap move
      r> base !
      1+
    loop
    pad 64 type
  32 +loop
  drop
  ce-high
  mem-off ;

: id ( -- )
  mem-on
  data-out
  ce-low
  $AA $5555 write
  $55 $2AAA write
  $90 $5555 write
  data-in
  ce-high ce-low
  0 set-address get-data phex2.
  1 set-address get-data phex2.
  data-out
  $AA $5555 write
  $55 $2AAA write
  $F0 $5555 write
  mem-off ;

: erase ( -- )
  mem-on
  data-out
  ce-low
  $AA $5555 write
  $55 $2AAA write
  $80 $5555 write
  $AA $5555 write
  $55 $2AAA write
  $10 $5555 write
  data-in
  100 ms
  mem-off ;

: setup ( -- )
  setup-io
  vdd-off
  0 set-address
  0 set-data
  data-out
  ce-low
  oe-low
  we-low
  tim14-init ;

setup
