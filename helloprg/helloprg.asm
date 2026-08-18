;----------------------;
; VIC-20 Hello, World! ;
;----------------------;

.include "../vic20.inc"
.segment "PROGRAM"
 
; BASIC upstart
  .word   BasicUpstart
BasicUpstart:  
  .word   @BasicUpstartEnd
  .word   10                ; Line number
  .byte   $9E               ; SYS token
  .byte   <(((Start / 1000) .mod 10) + $30)
  .byte   <(((Start /  100) .mod 10) + $30)
  .byte   <(((Start /   10) .mod 10) + $30)
  .byte   <(((Start /    1) .mod 10) + $30)
  .byte   $00               ; End of BASIC line
@BasicUpstartEnd:   
  .word   0                 ; BASIC end marker

; Start
Start:
  lda #8
  sta VIC_CRF               ; Set background and border to black
  lda #CHR_WHITE
  jsr CHROUT                ; Set text color to white
  lda #CHR_CLEAR            
  jsr CHROUT                ; Clear the screen

  ldy #0
Loop:
  lda Message,y
  beq Done
  jsr CHROUT
  iny
  jmp Loop

Done:
  rts

; Message
Message:
  .asciiz "hello vic-20!"   ; Characters need to be lowercase so they are properly mapped to PETSCII