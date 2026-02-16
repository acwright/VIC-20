; 
; A simple VIC-20 Hello, World!
;

.include "../vic20.inc"

.segment "HEADER"

; VIC-20 Cart Header (9 bytes)
.addr	main			            ; Cartridge load address
.addr	main		              ; Address of start-up code
.byte	$41,$30,$C3,$C2,$CD	  ; ROM present signature

.segment "CODE"

main:
  sei                       ; Disable interrupts
  cld                       ; Clear decimal mode
  ldx	#$FF                  ; Set stack pointer to $FF
  txs
  jsr	RAMTAS
  jsr	RESTOR
  jsr	IOINIT
  jsr	CINT
  cli
  
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
  jmp done

message:
  .asciiz "hello vic-20!"   ; Characters need to be lowercase so they are properly mapped to PETSCII