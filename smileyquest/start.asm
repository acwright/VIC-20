;--------------------------------------------------------------------;
; STATE_START - the title screen                                      ;
;--------------------------------------------------------------------;

; Draws the title screen.
StartEnter:
  jsr ClearScreen
  lda #WHITE
  jsr ClearColors

  PrintAt StartTitleText,  5,  8
  PrintAt StartPromptText, 6, 12
  PrintAt StartStartText,  7, 14
  rts

; Waits for the fire button, then hands over to the game.
StartUpdate:
  lda JOY_EDGE
  and #JOY_FIRE
  beq @Done                 ; fire not newly pressed, keep waiting

  lda #STATE_GAME
  jsr ChangeState
@Done:
  rts

StartTitleText:
  .byte "SMILEY QUEST", 0
StartPromptText:
  .byte "PRESS FIRE", 0
StartStartText:
  .byte "TO START", 0
