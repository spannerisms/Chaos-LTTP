lorom

!ADD = "CLC : ADC"
!SUB = "SEC : SBC"
!BLT = "BCC"
!BGE = "BCS"

org $FFD5
db $30

incsrc chaosvarlist.asm
incsrc function_hooks.asm
incsrc chaoshooks.asm

org $A08000
incsrc chaoscheats.asm
incsrc fastrom.asm

org $3FFFFF
db $00
