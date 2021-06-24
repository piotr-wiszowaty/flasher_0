: phex2. ( c -- )
  hex 0 <# # # #> type space ;

: main ( -- )
  vdd-on
  50 ms
  data-in
  16 0 do
    cr
    16 0 do
      j 4 lshift i + set-address
      ce-low oe-low
      get-data phex2.
      oe-high ce-high
    loop
  loop
  vdd-off ;

: setup ( -- )
  setup-io
  vdd-off
  0 set-address
  data-in
  ce-low
  oe-low
  we-low
  tim14-init ;

: m setup main ;
