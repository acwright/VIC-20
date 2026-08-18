;--------------------------------------------------------------------;
; Definitions - memory map, shared constants, helper macros           ;
;--------------------------------------------------------------------;

;=====================================================================;
; Zero page                                                           ;
;=====================================================================;
; Only pointers really need to live down here: the 6502 can only do
; indirect addressing - lda (PTR),y - through zero page. $F7-$FE are
; free on the VIC-20 as long as we don't use the RS-232 port.

TBL_PTR   = $F7             ; 2 bytes, address of a state dispatch table
TXT_PTR   = $F9             ; 2 bytes, address of a string to print
CHAR_PTR  = $FB             ; 2 bytes, screen/colour RAM pointer
JMP_PTR   = $FD             ; 2 bytes, address of the handler to jump to

;=====================================================================;
; Game variables                                                      ;
;=====================================================================;
; The cassette buffer at $033C is 192 bytes of RAM nothing else wants
; (we never touch the tape), so it makes a tidy home for game state.

GAME_STATE = $033C          ; 1 byte, which state we're currently in
PLAYER_X   = $033D          ; 1 byte, player column (0-21)
PLAYER_Y   = $033E          ; 1 byte, player row (0-22)
PREV_X     = $033F          ; 1 byte, column the player was last drawn at
PREV_Y     = $0340          ; 1 byte, row the player was last drawn at
JOY_NOW    = $0341          ; 1 byte, switches held this pass (1 = pressed)
JOY_PREV   = $0342          ; 1 byte, switches held on the previous pass
JOY_EDGE   = $0343          ; 1 byte, switches newly pressed this pass
DRAW_COLOR = $0344          ; 1 byte, colour DrawCell paints with
HAZ_INDEX  = $0345          ; 1 byte, loop counter for walking the hazards

;=====================================================================;
; Characters                                                          ;
;=====================================================================;
; Screen codes. 0-63 come from the ROM font we copy into RAM (1-26 are
; the letters, 32 is a blank, 48-57 the digits); 60 and 61 are slots we
; overwrite with our own glyphs since we never print "<" or "=".

CHAR_BLANK  = 32
CHAR_PLAYER = 60            ; smiley
CHAR_HAZARD = 61            ; the deadly X

;=====================================================================;
; Playfield                                                           ;
;=====================================================================;
; Row 0 and 1 are reserved for the status line, so the player is
; fenced out of them.

PLAY_TOP    = 2
PLAY_BOTTOM = SCREEN_ROWS-1 ; 22
PLAY_LEFT   = 0
PLAY_RIGHT  = SCREEN_COLS-1 ; 21

START_X     = 10            ; where the player spawns
START_Y     = 12

;=====================================================================;
; Text encoding                                                       ;
;=====================================================================;
; Screen RAM doesn't hold ASCII, it holds screen codes: "A" is 1, not
; 65. .charmap tells the assembler how to translate the characters in
; a .byte "..." string, so we can write text normally in the source and
; still get bytes we can poke straight into screen RAM.

.repeat 32, i
  .charmap $20+i, $20+i     ; space, digits and punctuation pass through
.endrepeat

.repeat 26, i
  .charmap $41+i, $01+i     ; "A".."Z" -> 1..26
  .charmap $61+i, $01+i     ; lower case lands on the same glyphs
.endrepeat

;=====================================================================;
; Macros                                                              ;
;=====================================================================;

; Prints a null-terminated string at a cell. Just sugar over
; PrintString so the screen-drawing code reads like a list of lines.
.macro PrintAt Text, Col, Row
  lda #<Text
  sta TXT_PTR
  lda #>Text
  sta TXT_PTR+1
  ldx #Col
  ldy #Row
  jsr PrintString
.endmacro
