@ ================================================
@ DE1-SoC Two-Digit Up/Down Counter
@ ================================================

.equ  KEY_BASE,        0xFF200050
.equ  SW_BASE,         0xFF200040
.equ  HEX3_HEX0_BASE,  0xFF200020
.equ  LED_BASE,        0xFF200000

.equ  DEBOUNCE_DELAY,  10
.equ  TIMER_DELAY,     1000
.equ  DIRECTION_MASK,  0x01

.data
counter_value:  .word  0
is_running:     .word  0
direction:      .word  0

key0_state:     .word  0
key1_state:     .word  0
key0_last:      .word  0
key1_last:      .word  0

timer_count:    .word  0

hex_digits:
    .byte 0x3F,0x06,0x5B,0x4F,0x66
    .byte 0x6D,0x7D,0x07,0x7F,0x67

.text
.global _start

_start:
    BL    init_system

main_loop:
    BL    debounce_keys
    BL    update_state
    BL    update_timer
    BL    update_display
    MOV   R0, #1
    BL    delay_ms
    B     main_loop

@ ================================================
@ Initialization
@ ================================================
init_system:
    PUSH  {LR}
    MOV   R0, #0
    LDR   R1, =counter_value
    STR   R0, [R1]
    LDR   R1, =is_running
    STR   R0, [R1]
    LDR   R1, =direction
    STR   R0, [R1]
    LDR   R1, =key0_state
    STR   R0, [R1]
    LDR   R1, =key1_state
    STR   R0, [R1]
    LDR   R1, =key0_last
    STR   R0, [R1]
    LDR   R1, =key1_last
    STR   R0, [R1]
    LDR   R1, =timer_count
    STR   R0, [R1]
    BL    update_display
    POP   {PC}

@ ================================================
@ Debounce Keys
@ ================================================
debounce_keys:
    PUSH  {R4-R8, LR}
    LDR   R4, =KEY_BASE
    LDR   R5, =key0_state
    LDR   R6, =key1_state
    LDR   R7, =key0_last
    LDR   R8, =key1_last

    LDR   R0, [R4]
    AND   R1, R0, #1
    AND   R2, R0, #2
    LSR   R2, R2, #1

    LDR   R3, [R5]
    STR   R3, [R7]
    LDR   R3, [R6]
    STR   R3, [R8]

    LDR   R3, [R7]
    CMP   R1, R3
    BEQ   check_key1
    MOV   R0, #DEBOUNCE_DELAY
    BL    delay_ms
    LDR   R0, [R4]
    AND   R1, R0, #1
    STR   R1, [R5]

check_key1:
    LDR   R3, [R8]
    CMP   R2, R3
    BEQ   debounce_done
    MOV   R0, #DEBOUNCE_DELAY
    BL    delay_ms
    LDR   R0, [R4]
    AND   R2, R0, #2
    LSR   R2, R2, #1
    STR   R2, [R6]

debounce_done:
    POP   {R4-R8, PC}

@ ================================================
@ Update State
@ ================================================
update_state:
    PUSH  {R4-R6, LR}

    LDR   R4, =key0_state
    LDR   R5, =key1_state
    LDR   R6, =key0_last

    LDR   R0, [R4]
    LDR   R2, [R6]
    CMP   R0, #0
    BNE   check_key1_action
    CMP   R2, #1
    BNE   check_key1_action
    LDR   R3, =is_running
    LDR   R4, [R3]
    EOR   R4, R4, #1
    STR   R4, [R3]

check_key1_action:
    LDR   R4, =key1_state
    LDR   R5, =key1_last
    LDR   R0, [R4]
    LDR   R1, [R5]
    CMP   R0, #0
    BNE   check_direction
    CMP   R1, #1
    BNE   check_direction
    MOV   R0, #0
    LDR   R1, =counter_value
    STR   R0, [R1]

check_direction:
    LDR   R0, =SW_BASE
    LDR   R0, [R0]
    AND   R0, R0, #DIRECTION_MASK
    LDR   R1, =direction
    STR   R0, [R1]

    POP   {R4-R6, PC}

@ ================================================
@ Timer and Counter
@ ================================================
update_timer:
    PUSH  {R4, LR}
    LDR   R4, =is_running
    LDR   R0, [R4]
    CMP   R0, #0
    BEQ   timer_done
    LDR   R4, =timer_count
    LDR   R0, [R4]
    ADD   R0, R0, #1
    STR   R0, [R4]
    CMP   R0, #TIMER_DELAY
    BLT   timer_done
    MOV   R0, #0
    STR   R0, [R4]
    BL    update_counter
timer_done:
    POP   {R4, PC}

update_counter:
    PUSH  {R4-R6, LR}
    LDR   R4, =counter_value
    LDR   R5, =direction
    LDR   R0, [R4]
    LDR   R1, [R5]
    CMP   R1, #0
    BEQ   count_up
    SUBS  R0, R0, #1
    BPL   store_count
    MOV   R0, #59
    B     store_count
count_up:
    ADD   R0, R0, #1
    CMP   R0, #60
    BLT   store_count
    MOV   R0, #0
store_count:
    STR   R0, [R4]
    POP   {R4-R6, PC}

@ ================================================
@ Display and Utilities
@ ================================================
update_display:
    PUSH  {R4-R8, LR}
    LDR   R4, =counter_value
    LDR   R0, [R4]
    MOV   R1, #10
    BL    divide
    LDR   R4, =hex_digits
    ADD   R5, R4, R0
    LDRB  R2, [R5]
    ADD   R5, R4, R1
    LDRB  R3, [R5]
    LSL   R2, R2, #8
    ORR   R0, R2, R3
    LDR   R1, =HEX3_HEX0_BASE
    STR   R0, [R1]
    POP   {R4-R8, PC}

divide:
    MOV   R2, R0
    MOV   R0, #0
div_loop:
    CMP   R2, R1
    BLT   div_done
    SUB   R2, R2, R1
    ADD   R0, R0, #1
    B     div_loop
div_done:
    MOV   R1, R2
    BX    LR

delay_ms:
    PUSH  {R4, R5, LR}
    MOV   R4, R0
ms_loop:
    MOV   R5, #10000
inner_loop:
    SUBS  R5, R5, #1
    BNE   inner_loop
    SUBS  R4, R4, #1
    BNE   ms_loop
    POP   {R4, R5, PC}

.end
