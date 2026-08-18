;--------------------------------------------------------------------;
; Input - joystick sampling                                           ;
;--------------------------------------------------------------------;

; Samples the joystick once per main loop pass and boils it down to two
; bytes the states can just AND against:
;
;   JOY_NOW  - switches held right now  (1 = pressed)
;   JOY_EDGE - switches that went from released to pressed this pass
;
; The hardware reports switches active-low (0 = pressed) and spreads
; them over two chips, so this routine flips the sense and merges them
; into one byte using the JOY_* masks from vic20.inc. The masks don't
; overlap - up/down/left/fire are bits 2-5 of VIA1, right is bit 7 of
; VIA2 - so they coexist happily in a single byte.
ReadJoystick:
  lda JOY_NOW
  sta JOY_PREV              ; this pass's "now" is next pass's "previous"

  lda VIA1_PA1              ; up, down, left and fire
  eor #$FF                  ; flip active-low, so 1 now means pressed
  and #(JOY_UP | JOY_DOWN | JOY_LEFT | JOY_FIRE)
  sta JOY_NOW

  ; Right lives on VIA2 and needs its DDR flipped to input first: VIA2's
  ; port B defaults to all-output (it also drives keyboard columns), so
  ; reading it normally just returns the last value we wrote, not the
  ; switch state. Flip bit 7 to input, read, then put it straight back
  ; or keyboard scanning breaks.
  sei
  lda #%01111111
  sta VIA2_DDRB
  lda VIA2_PB
  pha
  lda #%11111111
  sta VIA2_DDRB
  cli
  pla
  eor #$FF
  and #JOY_RIGHT
  ora JOY_NOW
  sta JOY_NOW               ; all five switches now live in one byte

  ; A switch is "newly pressed" when it's held now but wasn't before.
  lda JOY_PREV
  eor #$FF                  ; NOT previously held
  and JOY_NOW               ; AND held now
  sta JOY_EDGE
  rts
