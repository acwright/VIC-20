;----------------------;
; VIC-20 Hello, World! ;
;----------------------;

.include "../vic20.inc"
.segment "PROGRAM"
 
; BASIC upstart
  .word   basic_upstart
basic_upstart:  
  .word   @basic_upstart_end
  .word   10                ; Line number
  .byte   $9E               ; SYS token
  .byte   <(((start / 1000) .mod 10) + $30)
  .byte   <(((start /  100) .mod 10) + $30)
  .byte   <(((start /   10) .mod 10) + $30)
  .byte   <(((start /    1) .mod 10) + $30)
  .byte   $00               ; End of BASIC line
@basic_upstart_end:   
  .word   0                 ; BASIC end marker

; Start
start:
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

; Message
message:
  .asciiz "hello vic-20!"   ; Characters need to be lowercase so they are properly mapped to PETSCII