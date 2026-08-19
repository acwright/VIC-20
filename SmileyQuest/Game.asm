;--------------------------------------------------------------------;
; STATE_GAME - move the smiley, don't touch an X                      ;
;--------------------------------------------------------------------;

; Sets up a fresh game: draws the playfield, puts the player back at
; the spawn point.
GameEnter:
  jsr ClearScreen
  lda #YELLOW
  jsr ClearColors

  PrintAt GameTitleText, 5, 0

  lda #START_X
  sta PLAYER_X
  sta PREV_X
  lda #START_Y
  sta PLAYER_Y
  sta PREV_Y                ; nothing drawn yet, so "previous" is here too

  jsr DrawHazards
  jsr DrawPlayer
  rts

; One pass of the game: read the stick, redraw, then see if we died.
GameUpdate:
  jsr MovePlayer            ; joystick edges -> PLAYER_X / PLAYER_Y
  jsr UpdatePlayer          ; blank the old cell, draw the new one
  jsr CheckHazards          ; standing on an X? then it's game over
  rts

; Moves the player one cell per direction press. JOY_EDGE only has a
; bit set on the pass where a switch goes from released to pressed, so
; holding the stick doesn't run the player off the screen.
MovePlayer:
  lda JOY_EDGE
  and #JOY_UP
  beq @NotUp
  lda PLAYER_Y
  cmp #PLAY_TOP
  beq @NotUp                ; already on the top row
  dec PLAYER_Y
@NotUp:

  lda JOY_EDGE
  and #JOY_DOWN
  beq @NotDown
  lda PLAYER_Y
  cmp #PLAY_BOTTOM
  beq @NotDown              ; already on the bottom row
  inc PLAYER_Y
@NotDown:

  lda JOY_EDGE
  and #JOY_LEFT
  beq @NotLeft
  lda PLAYER_X
  cmp #PLAY_LEFT
  beq @NotLeft              ; already in the leftmost column
  dec PLAYER_X
@NotLeft:

  lda JOY_EDGE
  and #JOY_RIGHT
  beq @NotRight
  lda PLAYER_X
  cmp #PLAY_RIGHT
  beq @NotRight             ; already in the rightmost column
  inc PLAYER_X
@NotRight:
  rts

; Draws the player at their current cell.
DrawPlayer:
  lda #YELLOW
  sta DRAW_COLOR
  ldx PLAYER_X
  ldy PLAYER_Y
  lda #CHAR_PLAYER
  jmp DrawCell              ; DrawCell's rts returns for us

; Redraws the player, but only if they actually moved - otherwise we'd
; be rewriting the same two cells thousands of times a second.
UpdatePlayer:
  lda PLAYER_X
  cmp PREV_X
  bne @Moved
  lda PLAYER_Y
  cmp PREV_Y
  beq @Done                 ; same cell as last pass, leave the screen alone
@Moved:
  lda #BLACK
  sta DRAW_COLOR
  ldx PREV_X
  ldy PREV_Y
  lda #CHAR_BLANK
  jsr DrawCell              ; blank the cell the player left

  jsr DrawPlayer            ; draw them at the cell they moved to

  lda PLAYER_X
  sta PREV_X
  lda PLAYER_Y
  sta PREV_Y                ; remember where we drew them
@Done:
  rts

; Paints every hazard in the table.
DrawHazards:
  lda #RED
  sta DRAW_COLOR
  ldx #0
@Loop:
  stx HAZ_INDEX             ; DrawCell needs X for the column, so stash it
  ldy HazardTable+1,x       ; row
  lda HazardTable,x         ; column
  tax
  lda #CHAR_HAZARD
  jsr DrawCell

  ldx HAZ_INDEX
  inx
  inx                       ; two bytes per hazard
  cpx #HAZARD_COUNT*2
  bne @Loop
  rts

; Compares the player's cell against every hazard, and ends the game on
; a match.
CheckHazards:
  ldx #0
@Loop:
  lda HazardTable,x
  cmp PLAYER_X
  bne @Next                 ; different column, can't be a hit
  lda HazardTable+1,x
  cmp PLAYER_Y
  beq @Hit
@Next:
  inx
  inx
  cpx #HAZARD_COUNT*2
  bne @Loop
  rts                       ; walked the whole table, still alive

@Hit:
  lda #STATE_GAMEOVER
  jmp ChangeState           ; ChangeState's rts returns for us

; Where the deadly X's sit, as column/row pairs.
HazardTable:
  .byte  4,  5
  .byte 17,  6
  .byte  9,  9
  .byte 15, 11
  .byte  2, 14
  .byte 13, 15
  .byte 19, 18
  .byte  7, 20
HAZARD_COUNT = (* - HazardTable) / 2

GameTitleText:
  .byte "AVOID THE ", CHAR_HAZARD, 0
