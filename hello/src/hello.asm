.segment "STARTUP"
.segment "INIT"
.segment "CODE"

CHROUT = $FFD2

main:
  lda #147
  jsr CHROUT
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
  .asciiz "hello vic-20!"