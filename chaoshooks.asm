org $008056
JSL NewFrame

org $00802F
JSL ChaosInit : NOP

org $05DF3A ; so we get the first cheat sooner
JSL UncleSetTimer : NOP #2

; ========================================================
; Cheats that need extra work
; ========================================================

; long bank07 shit
org $07BB54
JSL BlueRupeesEverywhere : NOP

org $07C5E1
JSL BlueRupeesEverywhere : NOP

;use an address to clear out rupees tiles instead of more hooks
org $07BB72
ADC !RupeeFloorValue

org $07C5FF
ADC !RupeeFloorValue

org $0083D9 ; controller input
JSL InvertDPadMaybe : NOP

org $07B282 ; dash stuff
JSL IHopePeopleHateThis : NOP

org $06F9D7 ; sprite drops
JSL SpawnRandomSprite : NOP

org $0781A0 ; link's normal mode stuff
JSL DoCrazyZStuff : NOP #4

org $07E34F ; dumb other stuff (velocity?)
JSL OtherZStuff : NOP #4

org $06EFD6 ; enemy deaths
JSL FreezeMeMaybe : NOP

org $099FA6 ; sign guy's dialog timer
dw $012C ; 5 seconds

org $07F87F ; JSL bounce to a branch in bank07
MagicMirrorBounce:
	PHB : PHK : PLB
	JSR $A94C ; magic mirror code
	PLB : RTL

org $08FFEF ; JSL bounces
Ancilla_ProjectSpeedTowardsPlayerLong:
	PHB : PHK : PLB
	JSR $8EED ; Ancilla_ProjectSpeedTowardsPlayer
	PLB : RTL

Ancilla_MoveLong:
	PHB : PHK : PLB
	JSR $908B ; Ancilla_MoveVert
	PLB : RTL

; No room to do what I want with a JSL in Bank0D
; but enough room in unused space to JSR
org $0DA478
JSR BustedLink

org $0DAFF0
BustedLink:
	LDA !brokengfx : BEQ .vanilla
	RTS

	.vanilla
	LDA #$0E00
	RTS

SwagDuckLink2:
	LDA !brokengfx : BEQ .vanilla
	PHP : SEP #$30
	LDA #$0E : STA $0346
	PLP : RTS

	.vanilla
	STZ $0346
	RTS

; ========================================================
; Custom text
; ========================================================

; AW, HELL NO!
org $1C805C ; can't enter with follower text
db $AA, $C0, $C8, $FF, $B1, $AE, $B5, $B5, $FF, $B7, $B8, $C7
db $F8, $FF, $FF, $FF

; 'SUP, [NAME]?
org $1CBEFF ; Sign guy text
db $D8, $BC, $BE, $B9, $C8, $FF, $FE, $6A, $C6, $FF

; YOU ARE A
;  NUMPTY.
org $1CEF09
db $FF, $FF, $C2, $B8, $BE, $FF, $AA, $BB, $AE, $FF, $AA, $FF, $FF
db $F8
db $FF, $FF, $FF, $B7, $BE, $B6, $B9, $BD, $C2, $CD, $FF, $FF, $FF
