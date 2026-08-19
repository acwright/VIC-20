;----------------------;
; VIC-20 Hello, World! ;
;----------------------;

.include "../VIC20.inc"
.segment "CART"

; Cart Header
.addr	ColdStart			        ; Cold start vector
.addr	WarmStart		          ; Warm start vector
.byte	$41,$30,$C3,$C2,$CD	  ; Cartridge signature (A0CBM)

; Cold Start
ColdStart:
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
WarmStart:
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
  jmp Done                  ; Loop forever

; Message
Message:
  .asciiz "hello vic-20!"   ; Characters need to be lowercase so they are properly mapped to PETSCII