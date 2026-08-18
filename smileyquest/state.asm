;--------------------------------------------------------------------;
; State machine                                                       ;
;--------------------------------------------------------------------;
; The game is always in exactly one state, and GAME_STATE holds which.
;
; Every state supplies two routines:
;
;   enter  - runs once, the moment we switch into the state. Draws the
;            state's screen and sets up whatever it needs.
;   update - runs once per pass of the main loop, for as long as we
;            stay in the state.
;
; The two tables below list those routines in state-id order, so the
; id doubles as an index into them. Switching states is then just
; "store the new id, then call its enter routine", and the main loop
; never has to know which state it's running.

STATE_START    = 0
STATE_GAME     = 1
STATE_GAMEOVER = 2

StateEnterTable:
  .addr StartEnter          ; STATE_START
  .addr GameEnter           ; STATE_GAME
  .addr GameOverEnter       ; STATE_GAMEOVER

StateUpdateTable:
  .addr StartUpdate         ; STATE_START
  .addr GameUpdate          ; STATE_GAME
  .addr GameOverUpdate      ; STATE_GAMEOVER

; Switches to a new state and immediately runs its enter routine.
; In: A = state id
ChangeState:
  sta GAME_STATE
  ldx #<StateEnterTable
  ldy #>StateEnterTable
  jmp CallHandler

; Runs the current state's update routine. The main loop calls this
; once per pass and nothing else.
UpdateState:
  ldx #<StateUpdateTable
  ldy #>StateUpdateTable
  jmp CallHandler

; Looks the current state's handler up in a table of addresses and
; jumps to it. Because we jump rather than jsr, the handler's own rts
; returns straight to whoever called ChangeState/UpdateState.
; In: X/Y = low/high byte of the table address
CallHandler:
  stx TBL_PTR
  sty TBL_PTR+1
  lda GAME_STATE
  asl a                     ; two bytes per entry, so id*2 is the offset
  tay
  lda (TBL_PTR),y
  sta JMP_PTR               ; low byte of the handler address
  iny
  lda (TBL_PTR),y
  sta JMP_PTR+1             ; high byte
  jmp (JMP_PTR)
