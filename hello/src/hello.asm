; 
; A simple VIC-20 Hello, World!
;

.segment "STARTUP"
.segment "INIT"
.segment "CODE"

.include "../../VIC-20.inc"

main:
  lda #8
  sta VIC_CRF               ; Set background and border to black
  lda #CHR_WHITE
  jsr CHROUT                ; Set text color to white
  lda #CHR_CLEAR            
  jsr CHROUT                ; Clear the screen

  ldy #0
loop:
  lda message,y
  beq done
  jsr CHROUT
  iny
  jmp loop
done:
  rts

message:
  .asciiz "hello vic-20!"   ; Characters need to be lowercase so they are properly mapped to PETSCII