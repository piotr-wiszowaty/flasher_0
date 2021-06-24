0 variable tick0

: tim14-handler
  TIM_SR_UIF TIM14_SR hbic!
  tick0 @ if tick0 @ 1- tick0 ! then ;

: tim14-init
  RCC_APB1ENR_TIM14EN RCC_APB1ENR bis!
  TIM_DIER_UIE TIM14_DIER h!
  [ 480 1 - literal, ] TIM14_PSC !
  [ 100 1 - literal, ] TIM14_ARR !
  ['] tim14-handler irq-tim14 !
  NVIC_IPR4 @ $0FFFFFFF and $40000000 or NVIC_IPR4 !
  $00080000 NVIC_ISER !
  TIM_CR1_CEN TIM14_CR1 h! ;

: ms ( u -- )
  tick0 !
  begin tick0 @ while repeat ;
