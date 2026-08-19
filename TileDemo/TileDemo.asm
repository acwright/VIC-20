;----------------------;
; VIC-20 Tile Demo     ;
;----------------------;

.include "../VIC20.inc"
.segment "CART"

CHAR_PTR = $FB              ; 2 bytes, screen RAM pointer
CLR_PTR  = $FD              ; 2 bytes, color RAM pointer
Color    = $033C            ; 1 byte, free RAM (cassette buffer #2) - color cycle counter

; Cart Header
.addr ColdStart             ; Cold start vector
.addr ColdStart             ; Warm start vector (RESTORE = full restart)
.byte $41,$30,$C3,$C2,$CD   ; Cartridge signature (A0CBM)

; Cold Start
ColdStart:
  sei                       ; Disable interrupts
  cld                       ; Clear decimal mode
  ldx #$FF                  ; Set stack pointer to $FF
  txs
  jsr	RAMTAS
  jsr	RESTOR
  jsr	IOINIT
  jsr	CINT
  cli                       ; NMI warm entry arrives with I set

; Main
Main:
  lda #0
  sta CHAR_PTR
  sta CHAR_PTR+1            ; Zero the char pointer
  sta CLR_PTR
  sta CLR_PTR+1             ; Zero the color pointer

  lda #8
  sta VIC_CRF               ; Set background and border to black
  lda #CHR_CLEAR            
  jsr CHROUT                ; Clear the screen

  lda #$FF
  sta VIC_CR5               ; Set character set to $1C00
  jsr LoadCharacters        ; Load our character set

  jsr FillScreen            ; Fill the screen with our character
  jsr FillColors            ; Fill the screen with colors
  
Done:
  jmp Done                  ; Loop forever

FillScreen:
  lda #$00
  sta CHAR_PTR
  lda #$1E
  sta CHAR_PTR+1            ; CHAR_PTR = $1E00 (screen RAM)

  ldx #$02                  ; 2 passes of 253 = 506 cells (22x23 screen)
  ldy #$FD                  ; 253 cells per pass
@FillScreenLoop:
  lda #0                    ; Character 0 (smiley)
  dey
  sta (CHAR_PTR),y          ; Store character to screen RAM
  bne @FillScreenLoop
  lda CHAR_PTR
  clc
  adc #$FD                  ; Advance pointer 253 bytes to the next pass
  sta CHAR_PTR
  bcc @FillScreenSkipInc
  inc CHAR_PTR+1            ; Carry into the high byte
@FillScreenSkipInc:
  dex
  bne @FillScreenLoop
  rts

FillColors:
  lda #$00
  sta CLR_PTR
  lda #$96
  sta CLR_PTR+1             ; CLR_PTR = $9600 (color RAM)

  lda #1
  sta Color                 ; Start the color cycle at 1 (0 = black, invisible on our black background)

  ldx #$02                  ; 2 passes of 253 = 506 cells (22x23 screen)
  ldy #$FD                  ; 253 cells per pass
@FillColorsLoop:
  lda Color                 ; A = color for this cell
  pha                       ; Save it - still needed after Color is advanced below
  inc Color                 ; Advance to the next color
  lda Color
  cmp #8
  bne @FillColorsNoWrap
  lda #1
  sta Color                 ; Wrap 8 back around to 1
@FillColorsNoWrap:
  pla                       ; A = color for this cell, restored
  dey
  sta (CLR_PTR),y           ; Store color to color RAM
  bne @FillColorsLoop
  lda CLR_PTR
  clc
  adc #$FD                  ; Advance pointer 253 bytes to the next pass
  sta CLR_PTR
  bcc @FillColorsSkipInc
  inc CLR_PTR+1             ; Carry into the high byte
@FillColorsSkipInc:
  dex
  bne @FillColorsLoop
  rts
  
LoadCharacters:
  ldx #CHAR_LEN-1
@LoadCharactersLoop:
  lda Characters,x
  sta $1C00,x               ; Copy into the character set at $1C00
  dex
  bpl @LoadCharactersLoop
  rts

Characters:
  ; 0 - Smiley
  .byte %00111100
  .byte %01000010
  .byte %10100101
  .byte %10000001
  .byte %10100101
  .byte %10011001
  .byte %01000010
  .byte %00111100
CHAR_LEN = * - Characters