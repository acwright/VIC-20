;----------------------;
; VIC-20 Input Demo    ;
;----------------------;

.include "../vic20.inc"
.segment "CART"

JOY_PREV = $FA              ; 1 byte, which directions were held last check
CHAR_PTR = $FB              ; 2 bytes, screen RAM pointer
PLAYER_X = $FD              ; 1 byte, player X (0-21)
PLAYER_Y = $FE              ; 1 byte, player Y (0-22)
PREV_X   = $F8              ; 1 byte, player X last drawn (for erase)
PREV_Y   = $F9              ; 1 byte, player Y last drawn (for erase)

; Cart Header
.addr ColdStart              ; Cold start vector
.addr ColdStart              ; Warm start vector (RESTORE = full restart)
.byte $41,$30,$C3,$C2,$CD    ; Cartridge signature (A0CBM)

; Cold Start
ColdStart:
  sei                        ; Disable interrupts
  cld                        ; Clear decimal mode
  ldx #$FF                   ; Set stack pointer to $FF
  txs
  jsr RAMTAS                 ; Initialize RAM, set BASIC pointers
  jsr RESTOR                 ; Restore default I/O vectors
  jsr IOINIT                 ; Initialize I/O chips
  jsr CINT                   ; Initialize screen editor
  cli                        ; NMI warm entry arrives with I set
  
  lda #0
  sta CHAR_PTR
  sta CHAR_PTR+1              ; Zero the char pointer

  lda #8
  sta VIC_CRF                 ; Set background and border to black
  lda #$FF
  sta VIC_CR5                 ; Set character set to $1C00

  jsr LoadCharacters          ; Load our character set
  jsr ClearScreen             ; Clear the screen
  jsr ClearColors             ; Clear the screen colors

  lda #10
  sta PLAYER_X
  lda #11
  sta PLAYER_Y                ; Initialize player pos to 10,11
  sta PREV_X
  sta PREV_Y                  ; Erase pass starts at the same cell (no-op)
  lda #0
  sta JOY_PREV                ; No directions held yet

  ldx PLAYER_X
  ldy PLAYER_Y
  jsr CalcScreenPtr
  ldy #0
  lda #1
  sta (CHAR_PTR),y            ; Draw the smiley at the starting cell

Loop:
  jsr CheckInput               ; Read the joystick, move the player
  jsr UpdatePosition           ; Redraw if the position changed
  jmp Loop                     ; Loop forever

; Moves the player one cell per direction press. CheckPress compares each
; direction's current state against JOY_PREV (what was held last check)
; and only signals a move on the release-to-press edge, so holding the
; stick doesn't repeat the move every time through the loop.
CheckInput:
  lda VIA1_PA1                ; Read up/down/left/fire (0 = pressed)
  and #JOY_UP
  ldx #JOY_UP
  jsr CheckPress
  bcc @UpDone
  lda PLAYER_Y
  beq @UpDone                 ; already at top row
  dec PLAYER_Y
@UpDone:

  lda VIA1_PA1
  and #JOY_DOWN
  ldx #JOY_DOWN
  jsr CheckPress
  bcc @DownDone
  lda PLAYER_Y
  cmp #SCREEN_ROWS-1
  beq @DownDone                ; already at bottom row
  inc PLAYER_Y
@DownDone:

  lda VIA1_PA1
  and #JOY_LEFT
  ldx #JOY_LEFT
  jsr CheckPress
  bcc @LeftDone
  lda PLAYER_X
  beq @LeftDone                ; already at leftmost column
  dec PLAYER_X
@LeftDone:

  ; Right lives on VIA2 and needs its DDR flipped to input first: VIA2's
  ; port B defaults to all-output (it also drives keyboard columns), so
  ; reading it normally just returns the last value we wrote, not the
  ; switch state. Flip bit 7 to input, read, then put it straight back
  ; or keyboard scanning breaks.
  sei
  lda #%01111111
  sta VIA2_DDRB
  lda VIA2_PB
  and #JOY_RIGHT
  pha
  lda #%11111111
  sta VIA2_DDRB
  cli
  pla
  ldx #JOY_RIGHT
  jsr CheckPress
  bcc @RightDone
  lda PLAYER_X
  cmp #SCREEN_COLS-1
  beq @RightDone                ; already at rightmost column
  inc PLAYER_X
@RightDone:
  rts

; Determines whether a direction just transitioned from released to
; pressed, and keeps JOY_PREV in sync either way.
; In:  A = port byte AND'd with the direction's mask (0 = pressed)
;      X = the same direction mask, matching its JOY_PREV bit
; Out: Carry set if this is a new press (caller should move);
;      clear if it's still held or was already released.
CheckPress:
  cmp #0
  bne @Released
  txa
  and JOY_PREV
  bne @StillHeld                ; bit already set, nothing to do
  txa
  ora JOY_PREV
  sta JOY_PREV
  sec
  rts
@StillHeld:
  clc
  rts
@Released:
  txa
  eor #$FF
  and JOY_PREV
  sta JOY_PREV
  clc
  rts

UpdatePosition:
  lda PLAYER_X
  cmp PREV_X
  bne @Moved
  lda PLAYER_Y
  cmp PREV_Y
  beq @Done                   ; position unchanged, don't touch screen RAM
@Moved:
  ldx PREV_X
  ldy PREV_Y
  jsr CalcScreenPtr
  ldy #0
  lda #0
  sta (CHAR_PTR),y            ; erase the cell the player left

  ldx PLAYER_X
  ldy PLAYER_Y
  jsr CalcScreenPtr
  ldy #0
  lda #1
  sta (CHAR_PTR),y            ; draw the smiley at the current cell

  lda PLAYER_X
  sta PREV_X
  lda PLAYER_Y
  sta PREV_Y
@Done:
  rts

; Computes a screen RAM pointer for a given cell into CHAR_PTR. Row
; offsets are added SCREEN_COLS at a time since the screen (506 cells)
; is too big to reach with a single 8-bit index register.
; In: X = column (0-21), Y = row (0-22)
CalcScreenPtr:
  lda #$00
  sta CHAR_PTR
  lda #$1E
  sta CHAR_PTR+1              ; CHAR_PTR = $1E00 (screen RAM)
@RowLoop:
  cpy #0
  beq @AddColumn
  lda CHAR_PTR
  clc
  adc #SCREEN_COLS
  sta CHAR_PTR
  bcc @NoCarry
  inc CHAR_PTR+1              ; carry into the high byte
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

ClearScreen:
  lda #$00
  sta CHAR_PTR
  lda #$1E
  sta CHAR_PTR+1              ; CHAR_PTR = $1E00 (screen RAM)

  ldx #$02                    ; 2 passes of 253 = 506 cells (22x23 screen)
  ldy #$FD                    ; 253 cells per pass
@ClearScreenLoop:
  lda #0                      ; character 0 (clear)
  dey
  sta (CHAR_PTR),y            ; store character to screen RAM
  bne @ClearScreenLoop
  lda CHAR_PTR
  clc
  adc #$FD                    ; advance pointer 253 bytes to the next pass
  sta CHAR_PTR
  bcc @ClearScreenSkipInc
  inc CHAR_PTR+1              ; carry into the high byte
@ClearScreenSkipInc:
  dex
  bne @ClearScreenLoop
  rts

ClearColors:
  ldy #$00
@ClearColorsLoop:
  lda #YELLOW
  sta $9600,y
  sta $96FD,y                 ; second block, offset 253 bytes ($96FD = $9600+$FD)
  iny
  cpy #$FD
  bne @ClearColorsLoop
  rts

LoadCharacters:
  ldx #CHAR_LEN-1
@LoadCharactersLoop:
  lda Characters,x
  sta $1C00,x                 ; copy into the character set at $1C00
  dex
  bpl @LoadCharactersLoop
  rts

Characters:
  ; 0 - Empty
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000

  ; 1 - Smiley
  .byte %00111100
  .byte %01111110
  .byte %11011011
  .byte %11111111
  .byte %11011011
  .byte %11100111
  .byte %01111110
  .byte %00111100
CHAR_LEN = * - Characters
