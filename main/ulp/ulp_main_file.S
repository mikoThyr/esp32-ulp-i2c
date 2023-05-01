#include "soc/rtc_cntl_reg.h"
#include "soc/rtc_io_reg.h"
#include "soc/soc_ulp.h"

#include "macro.S"


// ------ SECTION BSS  ------
.section            .bss

  .global   counter
counter:            .long 0


  .global   wake_sw
wake_sw:            .long 0


// ------ SECTION DATA ------
.section    .data

    .set    ADDRESS_W_COM,  0x80
    .set    ADDRESS_R_COM,  0x81
    .set    TEMP_HOLD_COM,  0xe3
    .set    HUM_HOLD_COM,   0xe5
    .set    READ_REG_COM,   0xe7
    .set    WRITE_REG_COM,  0xe6

    .set    ACK_COM,        0x01
    .set    NO_ACK_COM,     0x00
    .set    START_COM,      0x01
    .set    REP_START_COM,  0x02
    .set    NO_START_COM,   0x00
    .set    STOP_COM,       0x01
    .set    NO_STOP_COM,    0x00
    .set    HOLD_COM,       0x01
    .set    NO_HOLD_COM,    0x00

    .set    REG_COM,        0x0e


// ------ SECTION TEXT ------
.section    .text

    .macro  order_write set_start set_command set_ack set_stop
        move    r2, start
        move    r0, \set_start
        st      r0, r2, 0
        move    r2, command
        move    r0, \set_command
        st      r0, r2, 0
        move    r2, ack
        move    r0, \set_ack
        st      r0, r2, 0
        move    r2, stop
        move    r0, \set_stop
        st      r0, r2, 0
    .endm

    .macro  order_read set_hold set_variable set_ack
        move    r2, hold_mode
        move    r0, \set_hold
        st      r0, r2, 0
        move    r2, ack
        move    r0, \set_ack
        st      r0, r2, 0
        move    r2, \set_variable
    .endm


    .global entry
entry:
    move    r3, stack_start

    move    r2, wake_sw
    move    r1, 0x00
    st      r1, r2, 0
    READ_RTC_REG(RTC_GPIO_IN_REG, RTC_GPIO_IN_NEXT_S + 0x11, 1)
    jumpr   wake_push, 1, eq

    order_write     START_COM       ADDRESS_W_COM   ACK_COM     NO_STOP_COM
    psr
    jump    i2c_write
    order_write     NO_START_COM    TEMP_HOLD_COM   ACK_COM     NO_STOP_COM
    psr
    jump    i2c_write

    order_write     REP_START_COM   ADDRESS_R_COM   ACK_COM     NO_STOP_COM
    psr
    jump    i2c_write
    order_read      HOLD_COM        msb_bits        ACK_COM
    psr
    jump    i2c_read
    order_read      NO_HOLD_COM     lsb_bits        NO_ACK_COM
    psr
    jump    i2c_read

    psr
    jump    stop_con

end_main_loop:
    psr
    jump    delay

    jump    entry

wake_push:
    move    r2, wake_sw
    move    r1, 0x01
    st      r1, r2, 0
wake_up:
    wake
    WRITE_RTC_FIELD(RTC_CNTL_STATE0_REG, RTC_CNTL_ULP_CP_SLP_TIMER_EN, 0)
    halt



/* Count to the 10 sec between measurements */
delay:
  //move    r0, 0x00
// rep_del:
    stage_rst
del_loop:
    wait    40000
    stage_inc 1
    jumps   del_loop, 10, lt //123
    // add     r0, r0, 1
    // jumpr   rep_del, 3, lt //12
    ret
    jump    entry

