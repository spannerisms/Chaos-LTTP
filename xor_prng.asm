; xorshift courtesy of total
RandomXORInt:
	PHP : REP #$20

	LDA !SEED_X : ASL #5 : EOR !SEED_X : STA $05
	LDA !SEED_Y : STA !SEED_X
	LDA $05 : LSR #3 : EOR $05 : STA $05
	LDA !SEED_Y : LSR : EOR !SEED_Y : EOR $05 : STA !SEED_Y

	PLP : RTL

; seed on file select
InitializePRNG: ; already in SEP #$30 from bank0C
	LDA !PRNG_init : BNE .alreadyinit
	LDX #$01
	LDA $7003D9 : EOR $7008D9 : STA !SEED_X
	LDA $7003D9 : EOR $700DD9 : STA !SEED_X, X
	LDA $7008D9 : EOR $700DD9 : STA !SEED_Y
	LDA $1A : STA !SEED_Y, X

	REP #$30
	; avoid accidental 0 seeding
	LDA !SEED_X : EOR !SEED_Y : BNE .done
	LDA #$8927 : STA !SEED_X
	LDA #$66A5 : STA !SEED_Y
.alreadyinit
.done
	SEP #$30
	LDA #$01 : STA !PRNG_init
	STZ $11 : STA $010E
	RTL

;--------------------------------------------------
; Advance PRNG in certain places
; to reduce deterministic behavior
; since it only runs at specific times otherwise
;--------------------------------------------------
AdvancePRNG_FileSelect:
	STZ $E4 : STZ $E5
	LDA !PRNG_init : BEQ .skipadvancement
	JML RandomXORInt
.skipadvancement
	RTL

; advance PRNG every other frame in menu/textboxes
AdvancePRNG_MessageModuleIndoors:
	LDA $1A : AND #$01 : BNE .skip
	JSL RandomXORInt
.skip
	LDA $11 : CMP #$03
	RTL

AdvancePRNG_MessageModuleOutdoors:
	LDA $1A : AND #$01 : BNE .skip
	JSL RandomXORInt
.skip
	LDA $11 : CMP #$07
	RTL

; this one might not be the best idea?
AdvancePRNG_Movement:
	LDA $20 : STA $0FC4 ; what we overwrote
	EOR $22 : AND #$000F ; some random thing to test for
	BNE .done
	JSL RandomXORInt
.done
	RTL
