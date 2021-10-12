; TODO ideas
; random shaking headbob
; scrolling bg1/2

lorom

arch 65816

math pri on

;===================================================================================================
;===================================================================================================
;===================================================================================================

function seconds(s) = 60*s

SEED_X = $7C
SEED_Y = $7E

ChaosTimer = $35

; 0230[0x50]

org $9BB200 : base $7E0230

ChaosEffectTimers: skip 10
ChaosEffectID: skip 5
BlueRupees: skip 1
RupeeFloorValue: skip 2
EnemySpawn: skip 1
BrokenZ: skip 1
LinkZBroken: skip 1
LinkZCache: skip 1
Spritecicles: skip 1
DPad_inv: skip 1
Follower_Cache: skip 1
Follower_Init: skip 1
SpeedChoice: skip 1
MosaicLevel: skip 1
Mosaicdirection: skip 1
Halttimer: skip 1
Longdash: skip 1
BrokenGFX: skip 2
DarkDisplay: skip 1
BGShakeH: skip 2
BGShakeV: skip 2
BGSlideH: skip 2
BGSlideV: skip 2
BG1OffsetH: skip 2
BG1OffsetV: skip 2
BG1MoveH: skip 2
BG1MoveV: skip 2
BG2OffsetH: skip 2
BG2OffsetV: skip 2
BG2MoveH: skip 2
BG2MoveV: skip 2
BG3OffsetH: skip 2
BG3OffsetV: skip 2
BG3MoveH: skip 2
BG3MoveV: skip 2
Musiced: skip 1
warnpc $7E0280
base off

;===================================================================================================

Tagalong_LoadGfx = $00D463
Sprite_SpawnDynamically = $1DF65D

;===================================================================================================

org $80FFD5 ; fast rom
	db $30

org $808056
	JSL NewFrame

org $808174
	JSL DoRegistersWithMosaic
	BRA + : org $8081D1 : +

org $808265
	JSL DoRegisters
	BRA + : org $8082BD : +

org $8CCCCC
	JSL InitializePRNG

org $85DF3A ; so we get the first effect sooner
	JSL UncleSetTimer : BRA + : +

;===================================================================================================
; Effects that need extra work
;===================================================================================================

org $87BB54
;	JSL BlueRupeesEverywhere : NOP

org $87C5E1
;	JSL BlueRupeesEverywhere : NOP

;use an address to clear out rupees tiles instead of more hooks
org $87BB72
;	ADC.w RupeeFloorValue

org $87C5FF
;	ADC.w RupeeFloorValue

;---------------------------------------------------------------------------------------------------

org $8083D9 ; controller input
	JSL InvertDPadMaybe : NOP

org $87B282 ; dash stuff
	JSL IHopePeopleHateThis : NOP

org $86F996
	JML SpawnRandomSprite : NOP

; Z coordinate display
org $8DA193 : JSL CrazyZDisplay
org $8DAAB1 : JSL RestoreLinkZ

org $86EFD6 ; enemy deaths
	JSL FreezeMeMaybe : NOP

org $899FA6 ; sign guy's dialog timer
	dw $012C ; 5 seconds

org $88FFEF ; JSL bounces
Ancilla_ProjectSpeedTowardsPlayerLong:
	JSR $8EED ; Ancilla_ProjectSpeedTowardsPlayer
	RTL

Ancilla_MoveLong:
	JSR $908B ; Ancilla_MoveVert
	RTL

;------------------
; No room to do what I want with a JSL in Bank0D
; but enough room in unused space to JSR
org $8DA478
	JSR BustedLink

org $8DAFDD
BustedLink:
	LDA.w BrokenGFX : BNE ++
	LDA.w #$0E00
++	RTS

;===================================================================================================

ChaosInit:
	LDA.b #$05 : STA.w RupeeFloorValue ; set rupee floors to 5 rupees
	LDA.w #$0E : STA.w BrokenGFX+1 ; set normal graphics
	STZ.w BrokenGFX+1 ; set normal graphics

	LDA.b #$81 : STA.w $420D
	STA.w $4200

	RTL

;===================================================================================================

SetAnEffect:
	SEP #$30

	LDA.b $22 : EOR.w SEED_Y
	STA.w SEED_X ; idk why not

	LDX.b #$04 ; find out if we have any free slots first

.nextindex
	LDA.w ChaosEffectID,X : BEQ .chooserandomeffect
	DEX : BPL .nextindex

.noroom
	LDA.w #seconds(5) : STA.w ChaosTimer ; try again sooner

.done
	RTL

.chooserandomeffect
	LDY.b #$04
	JSL RandomEffectInt
	AND.b #$1F ; we need 32 effects for clean modulo
	INC A ; but we want 33 table entries to ignore 0

.nexteffect ; no repeats allowed
	CMP.w ChaosEffectID,Y : BEQ .chooserandomeffect
	DEY : BPL .nexteffect

	STA.w ChaosEffectID,X
	ASL : ASL

	REP #$30
	AND.w #$00FF
	TAY : TXA : ASL : TYX : TAY
	LDA.l effect_pool+2,X : STA.w ChaosEffectTimers,Y

	LDA.w #seconds(19) : STA.w ChaosTimer

	RTL

warnpc $8DB07F

;===================================================================================================
;===================================================================================================
;===================================================================================================

; more rng calls in menu
org $8DDD36
	JSR CallMenuRNG

org $8DFFE1
CallMenuRNG:
	JSL RandomEffectInt
	INC.w $0206
	RTS

;===================================================================================================
; Custom text
;===================================================================================================
; AW, HELL NO!
org $9C805C ; can't enter with follower text
db $AA, $C0, $C8, $FF, $B1, $AE, $B5, $B5, $FF, $B7, $B8, $C7
db $F8, $FF, $FF, $FF

; 'SUP, [NAME]?
org $9CBEFF ; Sign guy text
db $D8, $BC, $BE, $B9, $C8, $FF, $FE, $6A, $C6, $FF

;  YOU ARE A
;   NUMPTY.
org $9CEF09
db $FF, $FF, $C2, $B8, $BE, $FF, $AA, $BB, $AE, $FF, $AA, $FF, $FF
db $F8
db $FF, $FF, $FF, $B7, $BE, $B6, $B9, $BD, $C2, $CD, $FF, $FF, $FF

;===================================================================================================
;===================================================================================================
;===================================================================================================
org $9BB1D7

NewFrame:
	;JSL $0080B5 ; Module_MainRouting
	JSL RandomEffectInt
	LDA.l $7EF3C5 : BEQ .quit ; no effects until uncle

	REP #$20

	DEC.w ChaosTimer : BMI .stupidgame
	BNE .reapplyeffects
	JSL SetAnEffect

.reapplyeffects
	SEP #$30
	LDY.b #$04

.nexteffect
	LDA.w ChaosEffectID,Y : BEQ .donteffectmk
	PHY : PHP

	ASL : ASL
	TAX

	STZ.b $00

	JSR.w (effect_pool,X)

	PLP : PLY

.donteffectmk
	DEY : BPL .nexteffect

	BRA .done

.stupidgame
	LDA.w #seconds(5) : STA.w ChaosTimer

.done
	SEP #$30

.quit
	JML $0080B5

;===================================================================================================

effect_pool:
	dw EffectDoNothing, $0000 ; 0x00
	dw EffectRandomLift, seconds(30) ; 0x01
	dw EffectBGDrift, seconds(20) ; 0x02
	dw EffectNoSpinning, seconds(40) ; 0x03
	dw EffectNoSword, seconds(45) ; 0x04
	dw EffectInvisibleLink, seconds(30) ; 0x05
	dw EffectInfiniteBonk, seconds(40) ; 0x06
	dw EffectOofMusic, seconds(90) ; 0x07
	dw EffectDropSprites, seconds(30) ; 0x08
	dw EffectLagHard, seconds(2) ; 0x09
	dw EffectRandomHeldItem, seconds(30) ; 0x0A
	dw EffectInsult, seconds(30) ; 0x0B
	dw EffectStupidZCoord, seconds(45) ; 0x0C
	dw EffectGetBusted, seconds(60) ; 0x0D
	dw EffectNoAnim, seconds(40) ; 0x0E
	dw EffectFreezeDeath, seconds(40) ; 0x0F
	dw EffectViolentShake, seconds(30) ; 0x10
	dw EffectCrazyPalettes, seconds(60) ; 0x11
	dw EffectInvertDPad, seconds(30) ; 0x12
	dw EffectDashWindup, seconds(60) ; 0x13
	dw EffectBubbleAttack, seconds(2) ; 0x14
	dw EffectDropBombs, seconds(20) ; 0x15
	dw EffectSignGuy, seconds(30) ; 0x16
	dw EffectBlackout, seconds(30) ; 0x17
	dw EffectRandomSpeed, seconds(60) ; 0x18
	dw EffectMosaic, seconds(40) ; 0x19
	dw EffectWTFHUD, seconds(40) ; 0x1A
	dw EffectRandomHalt, seconds(40) ; 0x1B
	dw EffectRandomMagic, seconds(20) ; 0x1C
	dw EffectAncillaTornado, seconds(40) ; 0x1D
	dw EffectChangeDashDirections, seconds(40) ; 0x1E
	dw EffectCacophony, seconds(30) ; 0x1F
	dw EffectSuperBunny, seconds(30) ; 0x20

;===================================================================================================
; Timers
; Sets $00 to:
;	0 when no decrement happens
;	1 when decrement does happen
;	2 when effect is turned off
; $00 will be in accumulator after routine
; Timer will be in $02[0x02], if decrement happens
; (be careful when it doesn't lol)
; exits with:
;   Z if decrement and continue
;   C if decrement or clear
;   c if no decrement
;===================================================================================================
DecrementTimer:
.UltraSafe
	LDA.b $11 : BNE .done

.Play
	LDA.b $10
.check_play
	CMP.b #$09 : BEQ .decrement
	CMP.b #$0B : BEQ .decrement
	CMP.b #$07 : BNE .done

	BRA .decrement

.PlayAndMenu
	LDA.b $10
	CMP.b #$0E : BNE .check_play

.decrement
	INC.b $00

	REP #$20

	TYA : ASL A : TAX
	LDA.w ChaosEffectTimers,X : DEC
	STA.w ChaosEffectTimers,X
	STA.b $02
	SEP #$20
	BNE .done

	; turn off effect
	INC.b $00 ; this should always be 1 when we reach here
	STA.w ChaosEffectID,Y ; A guaranteed to be 0

.done
	LDA.b $00
	CMP.b #$01

EffectDoNothing:
	RTS

;===================================================================================================
; Effects
;===================================================================================================
EffectLagHard:
	JSR DecrementTimer_decrement
	REP #$20
	LDA.w #$FC40
.LAG
	DEC : BNE .LAG
	RTS

;===================================================================================================

;EffectZappyZap:
;	JSR DecrementTimer_Play : BEQ .done
;	LDA.b #$01 : STA.w $0360
;
;.done
;	RTS

;===================================================================================================

EffectSuperBunny:
	JSR DecrementTimer_Play : BCC .done : BEQ .continue

.clear
	LDA.b $5D : CMP.b #$17 : BNE .notwalking
	LDA.b #$01 : STA.b $5D ; should fix itself immediately to normal walking, or bunny state if dw pearlless
.notwalking
	LDA.w $0FFF : BEQ .inLW
	LDA.l $7EF357 : BEQ .nopearl
.inLW
	STZ.w $02E0
.nopearl
	RTS

.continue
	LDA.b #$01 : STA.w $02E0
	LDA.b $5D : CMP.b #$17 : BNE .done
	STZ.b $5D ; give super bunny
.done
	RTS

;===================================================================================================

EffectNoSpinning:
	JSR DecrementTimer_Play : BCC .done

	STZ.b $79

.done
	RTS

;===================================================================================================

EffectNoAnim:
	JSR DecrementTimer_Play : BCC .done

	STZ.b $2E
	STZ.b $3D
	;STZ.w $030B

.done
	RTS

;===================================================================================================

EffectInfiniteBonk:
	JSR DecrementTimer_Play : BCC .done

	; bonking on > should allow us to skip an STZ at the end
	LDA.b $02 : CMP.b #$A0 : BCS .dobonk
	STZ.w $0372 ; because it will happen here
	RTS

.dobonk
	LDA.b #$FF : STA.w $0372

.done
	RTS

;===================================================================================================

EffectOofMusic:
	JSR DecrementTimer_Play : BCC .done : BEQ .not_done

	LDA.b #$F4 : STA.w $2140 : STA.w $012C
	STZ.w Musiced
	RTS

.not_done
	LDA.w Musiced : BNE .done

	JSL RandomEffectInt : AND.b #$03
	CLC
	ADC.b #$F5 : STA.w $2140 : STA.w $012C
	STA.w Musiced

.done
	RTS

;===================================================================================================

EffectNoSword:
	JSR DecrementTimer_Play : BCC .done

	LDA.b #$04 : STA.w $02E3

.done
	RTS

;===================================================================================================

EffectRandomHeldItem:
	JSR DecrementTimer_PlayAndMenu : BCC .done

	LDA.b $1A : AND.b #$07 : BNE .done
--	JSL RandomEffectInt : AND.b #$0F : STA.b $00 ; number 0-16
	JSL RandomEffectInt : AND.b #$03 ; number 0-4
	ADC.b $00 ; for a number 1-20
	CMP.b #$10 : BEQ -- ; don't select bottles

	STA.w $0202

	LDA.b $11 : BNE .done ; dont update in menu mode
	JSL $0DDB7F ; UpdateEquippedItemLong

.done
	RTS

;===================================================================================================

EffectInsult:
	JSR DecrementTimer_UltraSafe : BCC .done

	REP #$20
	LDA.b $02 : AND.w #$01FF : BNE .done ; every 512 frames (~8.5s)

	LDA.w #$0178 : STA.w $1CF0
	SEP #$20
	JSL $1CFD69

.done
	RTS

;===================================================================================================

EffectChangeDashDirections:
	JSR DecrementTimer_Play : BCC .done

	LDA.b $5D : CMP.b #$11 : BNE .done
	JSL RandomEffectInt : AND.b #$1F : BNE .done
	JSL RandomEffectInt : AND.b #$06 ; AND.b #$03 but shifted left
	STA.b $2F

.done
	RTS

;===================================================================================================

EffectViolentShake:
	JSR DecrementTimer_Play
	CMP.b #$02
	REP #$20
	BNE .shake

	STZ.w BGShakeH
	STZ.w BGShakeV

	RTS

.shake
	LSR.b $02 : BCS ++
	JSL RandomEffectInt : AND.w #$000F : SEC : SBC.w #$0007 : STA.w BGShakeH
	JSL RandomEffectInt : AND.w #$000F : SEC : SBC.w #$0007 : STA.w BGShakeV
++	RTS

;===================================================================================================

EffectCrazyPalettes:
	JSR DecrementTimer_PlayAndMenu : BCC .done
	LDA.b $02 : AND.b #$0F : BNE .done

	REP #$30
	LDY.w #$0008
.loop
	JSL RandomEffectInt : AND.w #$01FE : TAX ; 0-255, but doubled
	JSL RandomEffectInt
	STA.l $7EC500,X
	DEY : BNE .loop

	INC.b $15
.done
	RTS

;===================================================================================================

EffectBubbleAttack:
	JSR DecrementTimer_Play : BCC .done

	LDA.b #$00
	STA.w ChaosEffectID,Y

	LDX.b #$0F
.nextsprite
	LDA.w $0DD0,X : CMP.b #$09 : BCC .skip
	TXY
	LDX.w $0E20,Y : LDA.l EnemyCantBubble,X
	TYX
	CMP.b #$00 : BNE .skip
	
	LDA.b #$40
	STA.b $01
	JSL $06EA20 ; Sprite_ApplySpeedTowardsPlayerLong
	LDA.b $00 : STA.w $0D40,X
	LDA.b $01 : STA.w $0D50,X
	LDA.b #$FF : STA.w $0E50,X ; health
	LDA.b #$15 : STA.w $0E20,X ; anti fairies
	; collision stuff, not alive for puzzles, bounce off screen
	LDA.b #$E0 : STA.w $0F60,X
.skip
	DEX : BPL .nextsprite

#EffectAgainSoon:
	REP #$20
	LDA.w #seconds(3) : STA.w ChaosTimer

.done
	RTS

;===================================================================================================

EffectDropBombs:
	JSR DecrementTimer_UltraSafe : BCC .done

	LDA.b $02 : AND.b #$7F : BNE .done
	STZ.b $0D
	LDA.l $7EF343 : BNE .placebomb
.zerobombs
	INC A : STA.l $7EF343 ; increment bomb count to be able to place
	LDA.b #$01 : STA.b $0D ; to say we had 0
.placebomb
	LDA.b #$07
	JSL $09811F ; AddBlueBomb
	LDA.b #$20 : STA.w $039F,X ; short fuse

	LDA.b $0D : BNE .done
	STA.l $7EF343 ; A already 00, no free bombs

.done
	RTS

;===================================================================================================

EffectSignGuy:
	JSR DecrementTimer_UltraSafe : BCC .done : BEQ .keepactive

	STZ.w Follower_Init ; uninit for next time
	LDA.w Follower_Cache : STA.l $7EF3CC ; restore previous follower
	BEQ .done ; no follower, who cares about graphics
	JSL Tagalong_LoadGfx ; old graphics back, if needed
	RTS

.keepactive
	LDA.w Follower_Init : BNE .alreadyinitted
	LDA.l $7EF3CC : STA.w Follower_Cache ; cache old follower
	LDA.b #$09 : STA.l $7EF3CC ; sign guy
	STA.w Follower_Init ; store sign guy to init var why not
	JSL Tagalong_LoadGfx
	RTS

.alreadyinitted
	LDA.b #$09 : STA.l $7EF3CC ; just keep loading him so he can't be lost

.done
	RTS

;===================================================================================================

EffectBlackout:
	JSR DecrementTimer_PlayAndMenu : BCC .done
	LDA.b $02 : AND.b #$80 : STA.w DarkDisplay
.done
	RTS

;===================================================================================================

EffectRandomHalt:
	LDA.w $02E4 : DEC : BPL .done
	JSR DecrementTimer_UltraSafe : BCC .done : BEQ .stilldo

	STZ.w Halttimer
	STZ.w $02E4
	RTS

.stilldo
	LDA.w Halttimer : BNE .decrementtimer
	STZ.w $02E4
	JSL RandomEffectInt
	DEC : BNE .done
	LDA.b #$5F : STA.w Halttimer
	STA.w $031F
.decrementtimer
	DEC.w Halttimer
	LDA.b #$FF : STA.w $02E4
	STZ.w $0373

.done
	RTS

;===================================================================================================

EffectInvisibleLink:
	JSR DecrementTimer_Play : BCC .done : BEQ .stilldo
	STZ.b $4B
	RTS

.stilldo
	LDA.b #$0C : STA.b $4B

.done
	RTS

;===================================================================================================

SpeedChoices:
	db $06, $0F, $10, $10

EffectRandomSpeed:
	JSR DecrementTimer_UltraSafe : BCC .done

	LDA.b $02 : BNE .keepcurrentspeed
	JSL RandomEffectInt : AND.b #$03
	TAX
	LDA.l SpeedChoices,X : STA.w SpeedChoice

.keepcurrentspeed
	LDA.w SpeedChoice : STA.b $5E

.done
	RTS

;===================================================================================================

EffectRandomMagic:
	JSR DecrementTimer_Play : BCC .done

	LDA.b $02 : AND.b #$03 : BNE .done
	JSL RandomEffectInt : AND.b #$7C
	STA.l $7EF36E

.done
	RTS

;===================================================================================================

EffectAncillaTornado:
	JSR DecrementTimer_UltraSafe : BCC .done

	LDA.b $02 : AND.b #$01 : BNE .done
	LDX.b #$09
.nextancilla
	LDA $0C4A,X : BEQ .skip : CMP.b #$27 : BEQ .skip
	LDA.b #$30
	JSL Ancilla_ProjectSpeedTowardsPlayerLong
	LDA.b $00 : STA $0C22,X
	LDA.b $01 : STA $0C2C,X
	JSL Ancilla_MoveLong
	; so the ancilla horizontal movement routine
	; is literally just the vertical routine
	; but it spoofs X forward 10 indices
	PHX
	TXA : CLC : ADC.b #$0A : TAX
	JSL Ancilla_MoveLong
	PLX
.skip
	DEX : BPL .nextancilla
.done
	RTS

;===================================================================================================

MosaicDirections:
	db $10, $F0

EffectMosaic:
	JSR DecrementTimer_PlayAndMenu : BCC .done : BEQ .keepmosaic
	STZ.w MosaicLevel ; uninit basically, but this also will count for our current distortion
	STZ.w Mosaicdirection
	RTS

.keepmosaic
	LDA.w MosaicLevel : BNE .alreadyinit
	LDA.b #$03 : STA.w MosaicLevel
.alreadyinit
	LDA.w MosaicLevel : PHA
	; always restore mosaic, but don't always increment
	LDA.b $02 : AND.b #$07 : BNE .dontincrement
	LDX.w Mosaicdirection
	PLA : CLC : ADC.l MosaicDirections,X
	PHA
	AND.b #$F0 : BEQ .reversedirection
	CMP.b #$F0 : BNE .dontreversedirection
.reversedirection
	LDA.w Mosaicdirection : EOR.b #$01
	STA.w Mosaicdirection
.dontreversedirection
.dontincrement
	PLA
	STA.w MosaicLevel

.done
	RTS

;===================================================================================================

MenuSpeeds:
	dw $0002, $0003, $0001, $0000
	dw $FFFE, $FFFD, $FFFF, $0000

EffectWTFHUD:
	JSR DecrementTimer_PlayAndMenu
	REP #$20
	BEQ .keepeffect
	BCC .nonewspeed

	STZ.w BG3OffsetV
	STZ.w BG3OffsetH

	RTS

.keepeffect
	LDA.b $02 : AND.w #$002F : BNE .nonewspeed

	JSL RandomEffectInt : AND.w #$0007 : TAX
	LDA.l MenuSpeeds,X : STA.w BG3MoveH
	JSL RandomEffectInt : AND.w #$0007 : TAX
	LDA.l MenuSpeeds,X : STA.w BG3MoveV
	CLC

.nonewspeed
	LDA.w BG3MoveH : ADC.w BG3OffsetH : STA.w BG3OffsetH
	LDA.w BG3MoveV : CLC : ADC.w BG3OffsetV : STA.w BG3OffsetV

	RTS

;===================================================================================================

EffectCacophony:
	JSR DecrementTimer_Play : BCC .done

	LDA.b $02 : AND.b #$1F : BNE .done
	JSL RandomEffectInt : AND.b #$3F
	TAX : CMP.b #$20

	LDA.l Cacophones,X

	BCS .useset2
.useset1
	STA.w $2142
	RTS
.useset2
	STA.w $2143
.done
	RTS

;===================================================================================================

EffectGetBusted:
	JSR DecrementTimer_Play : BCC .done : BEQ .keepactive
	REP #$20
	LDA.w #$0E00 : STA.w BrokenGFX
	RTS

.keepactive
	LDA.w BrokenGFX : BNE .done
	JSL RandomEffectInt : AND.b #$0E ; AND 0x07 but shifted left
	TAX
	REP #$20
	LDA.l gfx_choices,X : STA.w BrokenGFX
	SEP #$20

.done
	RTS

;===================================================================================================
; Blue rupees + tile collision replacement
;===================================================================================================
;EffectBlueRupees:
;	JSR DecrementTimer_Play : BCC .done : BEQ .keepactive
;	STZ.w BlueRupees
;	LDA.b #$05 : STA.w RupeeFloorValue
;	RTS
;
;.keepactive
;	LDA.b #$FF : STA.w BlueRupees
;	STZ.w RupeeFloorValue
;
;.done
;	RTS

;===================================================================================================
; Z-coordinate broken-ness
;===================================================================================================
EffectStupidZCoord:
	JSR DecrementTimer_Play : BCC .done : BEQ .keepactive
	STZ.w BrokenZ
	RTS

.keepactive
	LDA.b #$FF : STA.w BrokenZ

.done
	RTS

;===================================================================================================
; Enemies freeze on death and get tons of HP
;===================================================================================================
EffectFreezeDeath:
	JSR DecrementTimer_Play : BCC .done : BEQ .keepactive
	STZ.w Spritecicles
	RTS

.keepactive
	LDA.b #$FF : STA.w Spritecicles

.done
	RTS

;===================================================================================================
; Inverted DPad inputs
;===================================================================================================
EffectInvertDPad:
	JSR DecrementTimer_PlayAndMenu : BCC .done : BEQ .keepactive
	STZ.w DPad_inv
	RTS

.keepactive
	LDA.b #$FF : STA.w DPad_inv

.done
	RTS

;===================================================================================================
; Long dash windup
;===================================================================================================
EffectDashWindup:
	JSR DecrementTimer_Play : BCC .done : BEQ .keepactive
	STZ.w Longdash
	RTS

.keepactive
	LDA.b #$FF : STA.w Longdash

.done
	RTS

;===================================================================================================

EffectDropSprites:
	JSR DecrementTimer_Play

	; this covers all cases as desired
	; only when the timer flag is 0x02 will this result in 0x00 to clear the spawn flag
	SBC.b #$02
	STA.w EnemySpawn

	RTS

;===================================================================================================

EffectRandomLift:
	JSR DecrementTimer_UltraSafe : BCC .done

	JSL RandomEffectInt : DEC : BNE .done

	LDA.b #$EC
	JSL Sprite_SpawnDynamically
	LDA.b #$04 : STA.w $0DB0,Y
	DEC : TYX
	STA.l $7FFA1C,X
	LDA.b #$0A : STA.w $0DD0,Y
	DEC : STA.l $7FFA2C,X
	LDA.b #$80 : STA.w $0308
	LDA.b #$01 : STA.w $036C

.done
	RTS

;===================================================================================================

EffectBGDrift:
	JSR DecrementTimer_PlayAndMenu
	REP #$20
	BCC .nonewspeed : BEQ .keepeffect

	STZ.w BG1OffsetH : STZ.w BG1OffsetV
	STZ.w BG2OffsetH : STZ.w BG2OffsetV

	RTS

.keepeffect
	LDA.b $02 : AND.w #$002F : BNE .nonewspeed

	JSL RandomEffectInt : AND.w #$0003 : LSR : DEC : ADC.w #$0000
	STA.w BGSlideH

	JSL RandomEffectInt : AND.w #$0003 : LSR : DEC : ADC.w #$0000
	STA.w BGSlideV

.nonewspeed
	LDA.b $02 : AND.w #$0003 : BNE .exit

	LDA.w BG1OffsetH : CLC : ADC.w BGSlideH : STA.w BG1OffsetH
	LDA.w BG1OffsetV : CLC : ADC.w BG1OffsetV : STA.w BG1OffsetV

	LDA.w BG2OffsetH : SEC : SBC.w BGSlideH : STA.w BG2OffsetH
	LDA.w BG2OffsetV : SEC : SBC.w BGSlideV : STA.w BG2OffsetV

.exit
	RTS

;===================================================================================================

warnpc $9BB7F8

;===================================================================================================
;===================================================================================================
;===================================================================================================

org $8EFD7E

FreezeMeMaybe:
	LDA.w Spritecicles : BEQ .vanilla
	LDA.w $0DD0,X : CMP.b #$0B : BNE .freezehim
	LDA.l $7FFA3C,X : BNE .vanilla ; already frozen, so unfreeze and die

.freezehim
	LDA.b #$01 : STA.l $7FFA3C,X
	LDA.b #$0B : STA.w $0DD0,X
	STZ.w $0EF0,X ; no death timer
	LDA.b #$20 : STA.w $0E50,X ; 32 hp when frozen
	RTL

.vanilla
	LDA.b #$06 : STA.w $0DD0,X
	RTL

;===================================================================================================

CrazyZDisplay:
	LDA.b $24 : STA.w LinkZCache
	LDA.w BrokenZ : BEQ .vanilla

	LDA.w LinkZBroken
	INC
	INC
	STA.w LinkZBroken
	STA.b $24

.vanilla
	LDA.b $11 : CMP.b #$12

	RTL

RestoreLinkZ:
	LDA.w LinkZCache : STA.b $24
	LDA.b $11 : CMP.b #$12
	RTL

;===================================================================================================

BlueRupeesEverywhere:
	BIT.w BlueRupees : BPL .vanilla
	LDA.b #$FF
	RTL

.vanilla
	LDA.w $02F7 : AND.b #$22
	RTL

;===================================================================================================

sprite_pool:
	; vulture, stal head, octorok, buzzblob
	db $01, $02, $08, $0D
	; snapdragon, hinox, moblin, mini helma
	db $0E, $11, $12, $13
	; poe, sluggula, bari, bar
	db $19, $20, $23, $24
	; hardhat, maze guy, soldier, soldier
	db $26, $30, $41, $42
	; soldier, soldier, soldier, soldier
	db $43, $44, $46, $47
	; soldier, soldier, soldier, soldier
	db $48, $49, $4A, $4B
	; jazzhands, armos statue, crab, roller
	db $4C, $51, $58, $5D
	; beamos, bnc, bnc, rat
	db $61, $6A, $6A, $6D
	; rat, rope, bat, leever
	db $6D, $6E, $6F, $71
	; Agahnim cutscene, tektite, hover, kodongo
	db $C1, $C9, $81, $86
	; spike, spike, fire bar, fire bar
	db $7D, $7D, $7E, $7F
	; gibdo, turtle, turtle, pengator
	db $8B, $8E, $8E, $99
	; wizzrobe, freezor, zazak, zazak
	db $9B, $A1, $A5, $A6
	; bomber, chain chomp, lynel, fish
	db $A8, $CA, $D0, $D2
	; Kholdstare, falling ice, moldorm, moldorm
	db $A2, $A4, $18, $18
	; moldorm, moldorm, moldorm, moldorm
	db $18, $18, $18, $18

SpawnRandomSprite:
	LDA.w EnemySpawn : BEQ .vanilla

	PHX
	JSL RandomEffectInt : AND.b #$3F : TAX
	LDA.l sprite_pool,X
	PLX

	STA.w $0E20,X
	JSL $0DB818

	LDA.b #$09 : STA.w $0DD0,X
	ASL : STA.w $0E50,X ; just always give it 18 hp, who cares
	LDA.w $0F60,X : ORA.b #$40 : STA.w $0F60,X ; count as dead

	JML $06FA59

.vanilla
	LDA.w $0BE0,X
	AND.b #$0F
	JML $06F99B

;===================================================================================================

IHopePeopleHateThis:
	LDA.w Longdash : BEQ .vanilla
	LDA.b #$6B : STA.w $0374
	RTL

.vanilla
	LDA.b #$1D : STA.w $0374
	RTL

;===================================================================================================

InvertDPadMaybe:
	LDA.w $4219 : BIT.w DPad_inv : BPL .dont
	BIT.b #$0C : BEQ .donty
	EOR.b #$0C
.donty
	BIT.b #$03 : BEQ .dont
	EOR.b #$03
.dont
	STA.b $01
	RTL

;===================================================================================================

Cacophones:
.set1
	db $0A, $0A, $0A, $0A
	db $0B, $0D, $0E, $0F
	db $06, $06, $06, $06
	db $20, $20, $2B, $2B
	db $20, $20, $2B, $2B
	db $30, $30, $30, $30
	db $30, $30, $37, $37
	db $38, $3C, $3C, $3C
.set2
	db $01, $01, $31, $31
	db $04, $04, $07, $07
	db $07, $0C, $0D, $0D
	db $0E, $0E, $0F, $0F
	db $0F, $0F, $10, $11
	db $11, $1A, $1A, $22
	db $22, $22, $22, $2C
	db $2E, $2E, $2E, $31

;===================================================================================================

gfx_choices:
	dw $AC44, $AC46, $A864, $A26E
	dw $9486, $94CB, $94EC, $0824

;===================================================================================================

UncleSetTimer:
	PHP : REP #$20
	LDA.w #seconds(2) : STA.w ChaosTimer
	PLP
	LDA.b #$00 : STA.l $7EF3CC
	RTL

warnpc $8EFF9F

;===================================================================================================
;===================================================================================================
;===================================================================================================

org $9CFD8E
; seed on every pre-file select
; hopefully it's random enough to work well
InitializePRNG:
	SEP #$30
	LDA.w $2137 : STA.w SEED_X
	LDA.l $7003D9 : STA.w SEED_X+1
	LDA.w $7003DA : STA.w SEED_Y
	LDA.b $1A : STA.w SEED_Y+1
	REP #$30 : STZ.b $00
	RTL

; xorshift courtesy of total
RandomEffectInt:
	PHP
	REP #$20
	LDA.w SEED_X
	ASL : ROL : ROL : ROL : ROL
	EOR.w SEED_X
	STA.b $05

	LDA.w SEED_Y
	STA.w SEED_X

	LDA.b $05
	LSR : ROR : ROR
	EOR.b $05
	STA.b $05

	LDA.w SEED_Y
	ROR
	EOR.w SEED_Y
	EOR.b $05
	STA.w SEED_Y

	PLP : RTL

;===================================================================================================

DoRegistersWithMosaic:
	LDA.b $95 : STA.w $2106

DoRegisters:
	ASL.w DarkDisplay

	REP #$20
	LDA.b $1E : STA.w $212E

	LDA.b $1C : BCC ++
	AND.w #$ECEC
++	STA.w $212C

	CLC
	LDA.w $0120 : ADC.w BGShakeH : CLC : ADC.w BG1OffsetH
	SEP #$20
	STA.w $210D : XBA : STA.w $210D

	REP #$21
	LDA.w $0124 : ADC.w BGShakeV : CLC : ADC.w BG1OffsetV
	SEP #$20
	STA.w $210E : XBA : STA.w $210E

	REP #$21
	LDA.w $011E : ADC.w BGShakeH : CLC : ADC.w BG2OffsetH
	SEP #$20
	STA.w $210F : XBA : STA.w $210F

	REP #$21
	LDA.w $0122 : ADC.w BGShakeV : CLC : ADC.w BG2OffsetV
	SEP #$20
	STA.w $2110 : XBA : STA.w $2110

	REP #$21
	LDA.b $E4 : ADC.w BG3OffsetH
	SEP #$20
	STA.w $2111 : XBA : STA.w $2111

	REP #$21
	LDA.b $EA : ADC.w BG3OffsetV
	SEP #$20
	STA.w $2112 : XBA : STA.w $2112

	LDA.w MosaicLevel : BEQ ++
	STA.w $2106

++	RTL

;===================================================================================================
;===================================================================================================
;===================================================================================================

arch SPC700

org $9A8037 : base $0C69
Instruments:
	nop
	nop
	mov Y, A
	bra ++ : nop : nop : nop : nop : ++


base off

org $99FE6B : base $0A9D
	jmp MoreSongCommands
RealSong:
base off

org $9A86B5 : base $12E7
MoreSongCommands:
	cmp.b A, #$F4
	bcs .not_song

--	clrc
	mov.b X, #$00
	jmp RealSong

.not_song
	sbc.b A, #$F4
	cmp.b A, #$05
	bcs --

	asl A
	mov X, A

	jmp SetInstruments

base off

org $9A8129 : base $0D5B
SetInstruments:
	mov.w A, InstrumentChanges+0+X
	mov.w Instruments+0, A
	mov.w A, InstrumentChanges+1+X
	mov.w Instruments+1, A

FixInstruments:
	mov.b X, #$10

--	mov.w A, $0211+X
	call $0C66
	dec X
	dec X
	bpl --

	jmp $0E6B
base off

org $9A8239 : base $0E6B
	mov.b $F2, #$5C
	mov.b $F3, #$FF
	jmp $0B00
base off

org $9A85A9 : base $11DB
InstrumentChanges:
	nop : nop     ; F4
	mov.b A, #$03 ; F5 square
	mov.b A, #$04 ; F6 saw
	mov.b A, #$18 ; F7 piano
	mov.b A, #$17 ; F8 oof

base off

; remove commands we overwrote
org $9A82DA : dw $0EE9 : dw $0EE9 

arch 65816

;===================================================================================================

org $98BAE1
EnemyCantBubble:
	db $00 ; RAVEN
	db $00 ; VULTURE
	db $00 ; STALFOS HEAD
	db $00 ; NULL
	db $01 ; CORRECT PULL SWITCH
	db $01 ; UNUSED CORRECT PULL SWITCH
	db $01 ; WRONG PULL SWITCH
	db $01 ; UNUSED WRONG PULL SWITCH
	db $00 ; OCTOROK
	db $01 ; MOLDORM
	db $00 ; OCTOROK 4WAY
	db $00 ; CUCCO
	db $00 ; OCTOROK STONE
	db $00 ; BUZZBLOB
	db $00 ; SNAPDRAGON
	db $00 ; OCTOBALLOON
	db $00 ; OCTOBALLOON BABY
	db $00 ; HINOX
	db $00 ; MOBLIN
	db $00 ; MINI HELMASAUR
	db $00 ; THIEVES TOWN GRATE
	db $00 ; ANTIFAIRY
	db $01 ; SAHASRAHLA / AGINAH
	db $00 ; HOARDER
	db $00 ; MINI MOLDORM
	db $00 ; POE
	db $00 ; SMITHY
	db $00 ; ARROW
	db $00 ; STATUE
	db $00 ; FLUTEQUEST
	db $01 ; CRYSTAL SWITCH
	db $01 ; SICK KID
	db $00 ; SLUGGULA
	db $01 ; WATER SWITCH
	db $00 ; ROPA
	db $00 ; RED BARI
	db $00 ; BLUE BARI
	db $01 ; TALKING TREE
	db $00 ; HARDHAT BEETLE
	db $00 ; DEADROCK
	db $01 ; DARK WORLD HINT NPC
	db $01 ; ADULT
	db $01 ; SWEEPING LADY
	db $01 ; HOBO
	db $01 ; LUMBERJACKS
	db $00 ; TELEPATHIC TILE
	db $01 ; FLUTE KID
	db $01 ; RACE GAME LADY
	db $01 ; RACE GAME GUY
	db $01 ; FORTUNE TELLER
	db $01 ; ARGUE BROS
	db $00 ; RUPEE PULL
	db $00 ; YOUNG SNITCH
	db $00 ; INNKEEPER
	db $01 ; WITCH
	db $01 ; WATERFALL
	db $01 ; EYE STATUE
	db $00 ; LOCKSMITH
	db $01 ; MAGIC BAT
	db $00 ; BONK ITEM
	db $01 ; KID IN KAK
	db $01 ; OLD SNITCH
	db $00 ; HOARDER
	db $00 ; TUTORIAL GUARD
	db $00 ; LIGHTNING GATE
	db $00 ; BLUE GUARD
	db $00 ; GREEN GUARD
	db $00 ; RED SPEAR GUARD
	db $00 ; BLUESAIN BOLT
	db $00 ; USAIN BOLT
	db $00 ; BLUE ARCHER
	db $00 ; GREEN BUSH GUARD
	db $00 ; RED JAVELIN GUARD
	db $00 ; RED BUSH GUARD
	db $00 ; BOMB GUARD
	db $00 ; GREEN KNIFE GUARD
	db $00 ; GELDMAN
	db $00 ; TOPPO
	db $00 ; POPO
	db $00 ; POPO
	db $00 ; CANNONBALL
	db $00 ; ARMOS STATUE
	db $01 ; KING ZORA
	db $01 ; ARMOS KNIGHT
	db $01 ; LANMOLAS
	db $00 ; ZORA / FIREBALL
	db $00 ; ZORA
	db $01 ; DESERT STATUE
	db $00 ; CRAB
	db $00 ; LOST WOODS BIRD
	db $00 ; LOST WOODS SQUIRREL
	db $00 ; SPARK
	db $00 ; SPARK
	db $00 ; ROLLER VERTICAL UP
	db $00 ; ROLLER VERTICAL DOWN
	db $00 ; ROLLER HORIZONTAL LEFT
	db $00 ; ROLLER HORIZONTAL RIGHT
	db $00 ; BEAMOS
	db $01 ; MASTERSWORD
	db $00 ; DEBIRANDO PIT
	db $00 ; DEBIRANDO
	db $01 ; ARCHERY GUY
	db $00 ; WALL CANNON VERTICAL LEFT
	db $00 ; WALL CANNON VERTICAL RIGHT
	db $00 ; WALL CANNON HORIZONTAL TOP
	db $00 ; WALL CANNON HORIZONTAL BOTTO
	db $00 ; BALL N CHAIN
	db $00 ; CANNONBALL / CANNON TROOPER
	db $00 ; MIRROR PORTAL
	db $00 ; RAT / CRICKET
	db $00 ; SNAKE
	db $00 ; KEESE
	db $00 ; KING HELMASAUR FIREBALL
	db $00 ; LEEVER
	db $01 ; FAERIE POND TRIGGER
	db $01 ; UNCLE / PRIEST / MANTLE
	db $01 ; RUNNING MAN
	db $01 ; BOTTLE MERCHANT
	db $01 ; ZELDA
	db $00 ; ANTIFAIRY
	db $01 ; SAHASRAHLAS WIFE
	db $00 ; BEE
	db $01 ; AGAHNIM
	db $00 ; AGAHNIMS BALLS
	db $00 ; GREEN STALFOS
	db $00 ; BIG SPIKE
	db $00 ; FIREBAR CLOCKWISE
	db $00 ; FIREBAR COUNTERCLOCKWISE
	db $00 ; FIRESNAKE
	db $00 ; HOVER
	db $00 ; ANTIFAIRY CIRCLE
	db $00 ; GREEN EYEGORE / GREEN MIMIC
	db $00 ; RED EYEGORE / RED MIMIC
	db $00 ; YELLOW STALFOS
	db $00 ; KODONGO
	db $00 ; KONDONGO FIRE
	db $01 ; MOTHULA
	db $00 ; MOTHULA BEAM
	db $00 ; SPIKE BLOCK
	db $00 ; GIBDO
	db $01 ; ARRGHUS
	db $01 ; ARRGHI
	db $00 ; TERRORPIN
	db $00 ; BLOB
	db $01 ; WALLMASTER
	db $00 ; STALFOS KNIGHT
	db $01 ; KING HELMASAUR
	db $00 ; BUMPER
	db $00 ; PIROGUSU
	db $00 ; LASER EYE LEFT
	db $00 ; LASER EYE RIGHT
	db $00 ; LASER EYE TOP
	db $00 ; LASER EYE BOTTOM
	db $00 ; PENGATOR
	db $00 ; KYAMERON
	db $00 ; WIZZROBE
	db $00 ; ZORO
	db $00 ; BABASU
	db $00 ; HAUNTED GROVE OSTRITCH
	db $00 ; HAUNTED GROVE RABBIT
	db $00 ; HAUNTED GROVE BIRD
	db $00 ; FREEZOR
	db $01 ; KHOLDSTARE
	db $01 ; KHOLDSTARE SHELL
	db $01 ; FALLING ICE
	db $00 ; BLUE ZAZAK
	db $00 ; RED ZAZAK
	db $00 ; STALFOS
	db $00 ; GREEN ZIRRO
	db $00 ; BLUE ZIRRO
	db $00 ; PIKIT
	db $01 ; CRYSTAL MAIDEN
	db $00 ; APPLE
	db $01 ; OLD MAN
	db $01 ; PIPE DOWN
	db $01 ; PIPE UP
	db $01 ; PIPE RIGHT
	db $01 ; PIPE LEFT
	db $00 ; GOOD BEE
	db $00 ; PEDESTAL PLAQUE
	db $00 ; PURPLE CHEST
	db $01 ; BOMB SHOP GUY
	db $01 ; KIKI
	db $01 ; BLIND MAIDEN
	db $00 ; DIALOGUE TESTER
	db $00 ; BULLY / PINK BALL
	db $01 ; WHIRLPOOL
	db $01 ; SHOPKEEPER / CHEST GAME GUY
	db $01 ; DRUNKARD
	db $01 ; VITREOUS
	db $01 ; VITREOUS SMALL EYE
	db $01 ; LIGHTNING
	db $01 ; CATFISH
	db $01 ; CUTSCENE AGAHNIM
	db $01 ; BOULDER
	db $00 ; GIBO
	db $00 ; THIEF
	db $00 ; MEDUSA
	db $00 ; 4WAY SHOOTER
	db $00 ; POKEY
	db $01 ; BIG FAERIE
	db $00 ; TEKTITE / FIREBAT
	db $00 ; CHAIN CHOMP
	db $01 ; TRINEXX ROCK HEAD
	db $01 ; TRINEXX FIRE HEAD
	db $01 ; TRINEXX ICE HEAD
	db $01 ; BLIND
	db $00 ; SWAMOLA
	db $00 ; LYNEL
	db $00 ; BUNNYBEAM / SMOKE
	db $00 ; FLOPPING FISH
	db $00 ; STAL
	db $00 ; LANDMINE
	db $01 ; DIG GAME GUY
	db $01 ; GANON
	db $01 ; GANON
	db $00 ; HEART
	db $00 ; GREEN RUPEE
	db $00 ; BLUE RUPEE
	db $00 ; RED RUPEE
	db $00 ; BOMB REFILL 1
	db $00 ; BOMB REFILL 4
	db $00 ; BOMB REFILL 8
	db $00 ; SMALL MAGIC DECANTER
	db $00 ; LARGE MAGIC DECANTER
	db $00 ; ARROW REFILL 5
	db $00 ; ARROW REFILL 10
	db $00 ; FAERIE
	db $01 ; SMALL KEY
	db $01 ; BIG KEY
	db $00 ; STOLEN SHIELD
	db $01 ; MUSHROOM
	db $00 ; FAKE MASTER SWORD
	db $01 ; MAGIC SHOP ASSISTANT
	db $01 ; HEART CONTAINER
	db $01 ; HEART PIECE
	db $01 ; THROWN ITEM
	db $01 ; SOMARIA PLATFORM
	db $01 ; CASTLE MANTLE
	db $00 ; UNUSED SOMARIA PLATFORM
	db $00 ; UNUSED SOMARIA PLATFORM
	db $00 ; UNUSED SOMARIA PLATFORM
	db $01 ; MEDALLION TABLET