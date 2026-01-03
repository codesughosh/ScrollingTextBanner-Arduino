#include <avr/io.h>

.global asm_main

asm_main:
    cli

    ; -------- Serial init (9600 baud @ 16 MHz) --------
    ldi r16, 103
    sts UBRR0L, r16
    clr r16
    sts UBRR0H, r16

    ldi r16, (1 << TXEN0)
    sts UCSR0B, r16

    ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
    sts UCSR0C, r16

    ; -------- Startup delay --------
    rcall startup_delay

    clr r21                ; scroll index = 0


; ------------------------------------------------
; MAIN SCROLL LOOP (CIRCULAR, FIXED WIDTH)
; ------------------------------------------------
main_loop:
    ldi r20, 16            ; WINDOW WIDTH
    mov r22, r21           ; temp index = scroll index

send_window:
    cpi r22, 20            ; wrap index if >= MSG_LEN
    brlo idx_ok
    clr r22
idx_ok:

    ldi ZL, lo8(message)
    ldi ZH, hi8(message)
    add ZL, r22
    clr r0
    adc ZH, r0

    lpm r16, Z
    rcall serial_send

    inc r22
    dec r20
    brne send_window

    ldi r16, '\r'          ; overwrite same line
    rcall serial_send

    rcall delay

    inc r21
    cpi r21, 20
    brlo main_loop
    clr r21
    rjmp main_loop


; ------------------------------------------------
; Serial send
; ------------------------------------------------
serial_send:
wait_tx:
    lds r17, UCSR0A
    sbrs r17, UDRE0
    rjmp wait_tx
    sts UDR0, r16
    ret


; ------------------------------------------------
; Scroll speed (increase = slower)
; ------------------------------------------------
delay:
    ldi r18, 140
d1:
    ldi r19, 255
d2:
    dec r19
    brne d2
    dec r18
    brne d1
    ret


; ------------------------------------------------
; Startup delay
; ------------------------------------------------
startup_delay:
    ldi r20, 200
sd1:
    rcall delay
    dec r20
    brne sd1
    ret


; ------------------------------------------------
; MESSAGE (20 chars TOTAL, SINGLE LINE ONLY)
; ------------------------------------------------
message:
    .byte ' ',' ',' ',' ','W','E','L','C','O','M','E',' ','T','O',' ','S','H','O','P',' ',' ',' ',' '
