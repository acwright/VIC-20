;--------------------------------------------------------------------;
; STATE_GAMEOVER - the "you touched an X" screen                      ;
;--------------------------------------------------------------------;

; Draws the game over screen.
GameOverEnter:
  jsr ClearScreen
  lda #RED
  jsr ClearColors

  PrintAt GameOverTitleText,  6,  9
  PrintAt GameOverPromptText, 6, 12
  PrintAt GameOverBackText,   6, 14
  rts

; Waits for the fire button, then goes back to the title screen.
GameOverUpdate:
  lda JOY_EDGE
  and #JOY_FIRE
  beq @Done                 ; fire not newly pressed, keep waiting

  lda #STATE_START
  jsr ChangeState
@Done:
  rts

GameOverTitleText:
  .byte "GAME OVER", 0
GameOverPromptText:
  .byte "PRESS FIRE", 0
GameOverBackText:
  .byte "TO RETURN", 0
