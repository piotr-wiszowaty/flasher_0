#include io.forth

: main ( -- )
  vdd-on
  begin
  key? until
  vdd-off ;

: setup ( -- )
  setup-io
  vdd-off
  0 set-address
  data-in
  ce-low
  oe-low
  we-low
  \ TODO: timer
  ;
