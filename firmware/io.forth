\ D0..D7  - PA0..PA7
\ A0..A15 - PB0..PA15
\ A16     - PA11
\ A17     - PA12
\ A18     - PA15
\ #OE     - PC13
\ #WE     - PA8
\ #CE     - PF6
\ #VDD    - PF7

\ 00: Input mode (reset state)
\ 01: General purpose output mode
\ 10: Alternate function mode
\ 11: Analog mode

: setup-io ( -- )
  GPIOA_MODER @ $3C3CFFFF and $41410000 or GPIOA_MODER !
  $55555555 GPIOB_MODER !
  GPIOC_MODER @ $F3FFFFFF and $04000000 or GPIOC_MODER !
  GPIOF_MODER @ $FFFF0FFF and $00005000 or GPIOF_MODER ! ;

: vdd-on ( -- )
  $00800000 GPIOF_BSRR ! ;

: vdd-off ( -- )
  $00000080 GPIOF_BSRR ! ;

: ce-low ( -- )
  $00400000 GPIOF_BSRR ! ;

: ce-high ( -- )
  $00000040 GPIOF_BSRR ! ;

: oe-low ( -- )
  $20000000 GPIOC_BSRR ! ;

: oe-high ( -- )
  $00002000 GPIOC_BSRR ! ;

: we-low ( -- )
  $01000000 GPIOA_BSRR ! ;
 
: we-high ( -- )
  $00000100 GPIOA_BSRR ! ;

\ set data bus to output
: data-out ( -- )
  $5555 GPIOA_MODER bis! ;

\ set data bus to input
: data-in ( -- )
  GPIOA_MODER @ $FFFF0000 and GPIOA_MODER ! ;

: set-address ( a -- )
  dup
  $FFFF and GPIOB_ODR !                            \ A0..A15
  dup  $10000 and if $0800 else $08000000 then     \ A16
  over $20000 and if $1000 else $10000000 then or  \ A17
  swap $40000 and if $8000 else $80000000 then or  \ A18
  GPIOA_BSRR ! ;

: set-data ( c -- )
  $FF and
  GPIOA_ODR @ $FFFFFF00 and or GPIOA_ODR ! ;

: get-data ( -- c )
  oe-low
  GPIOA_IDR @ $FF and
  oe-high ;
