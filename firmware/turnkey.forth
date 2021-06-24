compiletoflash

\ #include io.forth
#include main.forth

: INIT
  setup
  main ;

compiletoram
