;--------------------------------------------------------------------;
; Characters - the character set                                      ;
;--------------------------------------------------------------------;

; Points the VIC at $1C00 for its character set and fills it in.
;
; Pointing it away from ROM means the built-in font is gone, and we'd
; have no letters to print with - so the first thing we do is copy the
; ROM font's first 64 characters (screen codes 0-63: the letters, the
; digits and punctuation) into RAM. Then we drop our own two glyphs
; into slots 60 and 61, which would have been "<" and "=" - characters
; no screen in this game ever prints.
LoadCharacters:
  lda #$FF
  sta VIC_CR5               ; screen stays at $1E00, characters -> $1C00

  lda #<CHARROM
  sta TXT_PTR
  lda #>CHARROM
  sta TXT_PTR+1             ; source: character ROM at $8000
  lda #$00
  sta CHAR_PTR
  lda #$1C
  sta CHAR_PTR+1            ; destination: character RAM at $1C00

  ldx #2                    ; two 256-byte pages = 64 characters
@PageLoop:
  ldy #0
@ByteLoop:
  lda (TXT_PTR),y
  sta (CHAR_PTR),y
  iny
  bne @ByteLoop
  inc TXT_PTR+1
  inc CHAR_PTR+1            ; on to the next page of each
  dex
  bne @PageLoop

  ldx #CUSTOM_LEN-1
@CustomLoop:
  lda CustomChars,x
  sta $1C00+CHAR_PLAYER*8,x ; overwrite slots 60 and 61
  dex
  bpl @CustomLoop
  rts

; Eight bytes per character, one byte per row, one bit per pixel.
CustomChars:
  ; 60 - CHAR_PLAYER, the smiley
  .byte %00111100
  .byte %01111110
  .byte %11011011
  .byte %11111111
  .byte %11011011
  .byte %11100111
  .byte %01111110
  .byte %00111100

  ; 61 - CHAR_HAZARD, the deadly X
  .byte %11111111
  .byte %10111101
  .byte %11011011
  .byte %11100111
  .byte %11100111
  .byte %11011011
  .byte %10111101
  .byte %11111111
CUSTOM_LEN = * - CustomChars
