;--------------------------------------------------------------------;
; Screen - drawing primitives                                         ;
;--------------------------------------------------------------------;
; Screen RAM is 22x23 = 506 bytes at $1E00, and colour RAM shadows it
; cell for cell at $9600. Same offset in both, so one address
; calculation serves for both writes.

; Fills the whole screen with blanks. Two overlapping 256-byte passes
; cover all 506 cells without needing a 16-bit counter.
ClearScreen:
  lda #CHAR_BLANK
  ldx #0
@Loop:
  sta SCREEN,x
  sta SCREEN+250,x
  inx
  bne @Loop
  rts

; Paints every cell's colour, same trick.
; In: A = colour
ClearColors:
  ldx #0
@Loop:
  sta COLRAM,x
  sta COLRAM+250,x
  inx
  bne @Loop
  rts

; Draws one character, in one colour, at one cell.
; In: A = character code, X = column, Y = row, DRAW_COLOR = colour
DrawCell:
  pha                       ; CalcScreenPtr needs X and Y, so park the char
  jsr CalcScreenPtr
  pla
  ldy #0
  sta (CHAR_PTR),y          ; screen RAM

  lda CHAR_PTR+1
  clc
  adc #$78                  ; $1E00 (screen) + $7800 = $9600 (colour)
  sta CHAR_PTR+1
  lda DRAW_COLOR
  sta (CHAR_PTR),y          ; colour RAM
  rts

; Writes a null-terminated string across a row. Strings are stored as
; screen codes (see the .charmap block in defs.asm), so the bytes go
; straight into screen RAM. Colour comes from whatever ClearColors
; last laid down.
; In: TXT_PTR = string address, X = column, Y = row
PrintString:
  jsr CalcScreenPtr
  ldy #0                    ; Y indexes the string and the screen alike
@Loop:
  lda (TXT_PTR),y
  beq @Done                 ; 0 terminates
  sta (CHAR_PTR),y
  iny
  bne @Loop
@Done:
  rts

; Computes a screen RAM pointer for a given cell into CHAR_PTR. Row
; offsets are added SCREEN_COLS at a time since the screen (506 cells)
; is too big to reach with a single 8-bit index register.
; In: X = column (0-21), Y = row (0-22)
CalcScreenPtr:
  lda #<SCREEN
  sta CHAR_PTR
  lda #>SCREEN
  sta CHAR_PTR+1            ; CHAR_PTR = $1E00 (screen RAM)
@RowLoop:
  cpy #0
  beq @AddColumn
  lda CHAR_PTR
  clc
  adc #SCREEN_COLS
  sta CHAR_PTR
  bcc @NoCarry
  inc CHAR_PTR+1            ; carry into the high byte
@NoCarry:
  dey
  jmp @RowLoop
@AddColumn:
  txa
  clc
  adc CHAR_PTR
  sta CHAR_PTR
  bcc @Done
  inc CHAR_PTR+1
@Done:
  rts
