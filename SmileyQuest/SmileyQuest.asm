;--------------------------------------------------------------------;
; VIC-20 Smiley Quest                                                ;
;--------------------------------------------------------------------;
; A tiny three-state game:
;
;   STATE_START    -> press fire to begin
;   STATE_GAME     -> steer the smiley, don't touch a red X
;   STATE_GAMEOVER -> press fire to go back to the title screen
;
; Everything below the main loop lives in the included files. The loop
; itself never mentions a state by name - it just samples the joystick
; and asks the state machine to run whatever state we're currently in.

.include "../VIC20.inc"

.segment "CART"

.include "Defs.asm"          ; memory map, constants, macros

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

  lda #8
  sta VIC_CRF                ; Set background and border to black

  jsr LoadCharacters         ; Build our character set in RAM

  lda #0
  sta JOY_NOW                ; No switches held yet

  lda #STATE_START
  jsr ChangeState            ; Enter the title screen

;--------------------------------------------------------------------;
; The main loop                                                       ;
;--------------------------------------------------------------------;
MainLoop:
  jsr ReadJoystick           ; Sample the stick into JOY_NOW / JOY_EDGE
  jsr UpdateState            ; Run the current state's update routine
  jmp MainLoop

;--------------------------------------------------------------------;
; Everything else                                                     ;
;--------------------------------------------------------------------;
.include "State.asm"         ; ChangeState / UpdateState and the tables
.include "Start.asm"         ; STATE_START handlers
.include "Game.asm"          ; STATE_GAME handlers
.include "GameOver.asm"      ; STATE_GAMEOVER handlers
.include "Input.asm"         ; ReadJoystick
.include "Screen.asm"        ; ClearScreen, DrawCell, PrintString, ...
.include "Chars.asm"         ; LoadCharacters and the glyph data
