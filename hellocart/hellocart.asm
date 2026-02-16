;----------------------;
; VIC-20 Hello, World! ;
;----------------------;

.include "../vic20.inc"
.segment "CART"

; Cart Header
.addr	cold_start			      ; Cold start vector
.addr	warm_start		        ; Warm start vector
.byte	$41,$30,$C3,$C2,$CD	  ; Cartridge signature (A0CBM)

; Cold Start
cold_start:
  sei                       ; Disable interrupts
  cld                       ; Clear decimal mode
  ldx	#$FF                  ; Set stack pointer to $FF
  txs
  jsr	RAMTAS
  jsr	RESTOR
  jsr	IOINIT
  jsr	CINT
  cli

; Warm Start
warm_start:
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
  jmp done                  ; Loop forever

; Message
message:
  .asciiz "hello vic-20!"   ; Characters need to be lowercase so they are properly mapped to PETSCII