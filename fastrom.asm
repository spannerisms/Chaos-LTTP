; Using karkat's solution
; org $00802F
FastROM:
LDA #$01 : STA $420D
LDA.b #$81 : STA $4200 ; thing we wrote over, turn on NMI & gamepad
RTL
