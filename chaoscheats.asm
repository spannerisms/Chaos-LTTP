!seconds_2 = #$0078
!seconds_5 = #$012C
!seconds_10 = #$0258
!seconds_15 = #$0384
!seconds_20 = #$04B0
!seconds_30 = #$0708
!seconds_40 = #$0960
!seconds_45 = #$0A8C
!seconds_60 = #$0E10
!seconds_90 = #$1518
!seconds_120 = #$1C20

ChaosInit:
	LDA #$05 : STA !RupeeFloorValue ; set rupee floors to 5 rupees
	JSL FastROM
	RTL

NewFrame:
	JSL $0080B5 ; Module_MainRouting

	LDA $7EF3C5 : BEQ .quit ; no cheats until uncle
	PHB : PHK : PLB
	PHA : PHX : PHY : PHP
	
	REP #$20

	DEC !chaostimer : BMI .stupidgame
	BNE .reapplycheats
	JSR SetACheat

.reapplycheats
	JSR ReapplyAll
	BRA .done

.stupidgame
	LDA !seconds_5 : STA !chaostimer

.done
	PLP : PLY : PLX : PLA : PLB

.quit
	RTL

TryAgainHard:
	SEP #$20
	STZ !chaos_cheat_ids, X
	RTS

DoNothing: RTS

UncleSetTimer:
	PHP : REP #$20
	LDA !seconds_5 : STA !chaostimer
	PLP
	LDA #$00 : STA $7EF3CC
	RTL

cheat_pool:
	dw DoNothing, $0000 ; 0x00
	dw BlueRupees, !seconds_20 ; 0x01
	dw ZappyZap, !seconds_90 ; 0x02
	dw NoSpinning, !seconds_40 ; 0x03
	dw NoSword, !seconds_60 ; 0x04
	dw InvisibleLink, !seconds_30 ; 0x05
	dw InfiniteBonk, !seconds_40 ; 0x06
	dw HealthDrain, !seconds_10 ; 0x07
	dw DropSprites, !seconds_20 ; 0x08
	dw LagHard, !seconds_2 ; 0x09
	dw RandomHeldItem, !seconds_30 ; 0x0A
	dw Numpty, !seconds_30 ; 0x0B
	dw StupidZCoord, !seconds_30 ; 0x0C
	dw GetBusted, !seconds_60 ; 0x0D
	dw NoAnim, !seconds_40 ; 0x0E
	dw FreezeDeath, !seconds_30 ; 0x0F
	dw MirrorRandomly, !seconds_45 ; 0x10
	dw CrazyPalettes, !seconds_60 ; 0x11
	dw InvertDPad, !seconds_30 ; 0x12
	dw DashWindup, !seconds_60 ; 0x13
	dw BubbleAttack, !seconds_120 ; 0x14
	dw DropBombs, !seconds_40 ; 0x15
	dw SignGuy, !seconds_40 ; 0x16
	dw Blackout, !seconds_60 ; 0x17
	dw RandomSpeed, !seconds_60 ; 0x18
	dw Mosaic, !seconds_40 ; 0x19
	dw WTFHUD, !seconds_40 ; 0x1A
	dw RandomHalt, !seconds_40 ; 0x1B
	dw RandomMagic, !seconds_20 ; 0x1C
	dw AncillaTornado, !seconds_40 ; 0x1D
	dw ChangeDashDirections, !seconds_40 ; 0x1E
	dw Cacophony, !seconds_30 ; 0x1F
	dw SuperBunny, !seconds_30 ; 0x20

SetACheat:
	SEP #$30
	LDX #$04 ; find out if we have any free slots first

.nextindex
	LDA !chaos_cheat_ids, X : BEQ .chooserandomcheat
	DEX : BPL .nextindex
	BRA .noroom

.chooserandomcheat
	LDY #$04
	JSL RandomXORInt
	AND #$1F ; we need 32 cheats for clean modulo
	INC A ; but we want 33 table entries to ignore 0

.nextcheat ; no repeats allowed
	CMP !chaos_cheat_ids, Y : BEQ .chooserandomcheat
	DEY : BPL .nextcheat

	STA !chaos_cheat_ids, X
	ASL #2 ; multiply by 4

	REP #$30
	AND #$00FF ; clear high byte of A before continuing
	INC A : INC A ; offset for the timers
	TAY : TXA : ASL : TAX
	LDA cheat_pool, Y : STA !chaos_cheat_timers, X

	LDA !seconds_30 : STA !chaostimer
	RTS

.noroom
	LDA !seconds_5 : STA !chaostimer ; try again sooner

.done
	RTS

JumpToCheatFromIndex:
	ASL #2 ; multiply by 4
	TAY

	REP #$30
	LDA cheat_pool, Y
	STA $03
	SEP #$30
	PHB : PLA : STA $05

	JMP [$0003]

ReapplyAll:
	SEP #$30
	LDX #$04

.nextcheat
	LDA !chaos_cheat_ids, X : BEQ .dontcheatmk
	PHX : PHP
	JSR JumpToCheatFromIndex
	PLP : PLX

.dontcheatmk
	DEX : BPL .nextcheat
	RTS

TurnOffCheat:
	SEP #$20
	INC $00 ; this should always be 1 when we reach here
	STZ !chaos_cheat_ids, X
	RTS

CheatAgainSoon:
	PHP
	REP #$20
	LDA !seconds_5 : STA !chaostimer
	PLP
	RTL

; ========================================================
; Timers
; Sets $00 to:
;		0 when no decrement happens
;		1 when decrement does happen
;		2 when cheat is turned off (via TurnOffCheat)
; $00 will be in accumulator after routine
; Timer will be in $02[0x02], if decrement happens
; (be careful when it doesn't lol)
; ========================================================
DecrementTimer:
.Play
	SEP #$30
	STZ $00

	LDA $11 : BNE .done
	LDA $10 : CMP #$09 : BEQ .decrement
	CMP #$07 : BNE .done

	BRA .decrement

.PlayAndMenu
	SEP #$30
	STZ $00

	LDA $11 : BNE .checkmenu
	LDA $10 : CMP #$09 : BEQ .decrement
	CMP #$07 : BNE .done
	BRA .decrement

.checkmenu
	CMP #$01 : BNE .done
	LDA $10 : CMP #$0E : BNE .done

.decrement
	INC $00
	REP #$20
	PHX : PHY
	TXA : TXY : ASL A : TAX
	DEC !chaos_cheat_timers, X
	LDA !chaos_cheat_timers, X : STA $02
	BNE .donedec
	TYX
	JSR TurnOffCheat

.donedec
	PLY : PLX

.done
	SEP #$30
	LDA $00
	RTS

; ========================================================
; Cheats
; ========================================================
; more complex to allow lag always
; but who cares? we want lag
LagHard:
	SEP #$30 ; don't think I care about $00 in this function
	JSR DecrementTimer_decrement ; just always decrement
	LDA $10 : CMP #$19 : BEQ .killcheat
	CMP #$1A : BNE .letsactuallylag
.killcheat
	JSR TurnOffCheat
	RTS
.letsactuallylag
	REP #$20
	LDA #$FC40
.LAG_MOTHERFUCKER
	DEC A : BNE .LAG_MOTHERFUCKER
.done
	RTS

ZappyZap:
	JSR DecrementTimer_Play : BEQ .done
	LDA #$01 : STA $0360

.done
	RTS

SuperBunny:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .continue
	LDA $5D : CMP #$17 : BNE .notwalking
	LDA #$01 : STA $5D ; should fix itself immediately to normal walking, or bunny state if dw pearlless
.notwalking
	LDA $0FFF : BEQ .inLW
	LDA $7EF357 : BEQ .nopearl
.inLW
	STZ $02E0
.nopearl
	RTS
.continue
	LDA #$01 : STA $02E0
	LDA $5D : CMP #$17 : BNE .done
	STZ $5D ; give super bunny
.done
	RTS

NoSpinning:
	JSR DecrementTimer_Play : BEQ .done
	STZ $79

.done
	RTS

NoAnim:
	JSR DecrementTimer_Play : BEQ .done
	STZ $2E
	STZ $3D
	;STZ $030B

.done
	RTS

InfiniteBonk:
	JSR DecrementTimer_Play : BEQ .done
	; bonking on > should allow us to skip an STZ at the end
	LDA $02 : CMP #$A0 : BCS .dobonk
	STZ $0372 ; because it will happen here
	RTS

.dobonk
	LDA #$FF : STA $0372

.done
	RTS

HealthDrain:
	JSR DecrementTimer_Play : BEQ .done
	LDA $02 : BNE .done ; only want low byte
	; add damage just in case we're hit same frame
	LDA #$04 : !ADD $0373 : STA $0373

.done
	RTS

NoSword:
	JSR DecrementTimer_Play : BEQ .done
	LDA #$04 : STA $02E3

.done
	RTS

RandomHeldItem:
	JSR DecrementTimer_PlayAndMenu : BEQ .done
	LDA $1A : AND #$07 : BNE .done
.chooserandomnumber
	JSL RandomXORInt : AND #$0F : STA $00 ; number 0-16
	JSL RandomXORInt : AND #$03 ; number 0-4
	ADC $00 ; for a number 0-19
	CMP #$10 : BEQ .chooserandomnumber ; avoid bottles
	STA $0202 : LDA #$02 : STA $0303
	LDA $11 : BNE .done ; dont update in menu mode
	JSL $0DDB7F ; UpdateEquippedItemLong

.done
	RTS

Numpty:
	JSR DecrementTimer_Play : BEQ .done
	REP #$20
	LDA $02 : AND.w #$01FF : BNE .done ; numpty every 512 frames (~8.5s)

	LDA.w #$0178 : STA $1CF0
	SEP #$20
	JSL $1CFD69

.done
	RTS

facing:
	db $00, $02, $04, $06

ChangeDashDirections:
	JSR DecrementTimer_Play : BEQ .done
	LDA $5D : CMP #$11 : BNE .done
	JSL RandomXORInt : AND #$1F : BNE .done
	JSL RandomXORInt : AND #$03 : TAX
	LDA facing, X : STA $2F

.done
	RTS

MirrorRandomly:
	JSR DecrementTimer_Play : BEQ .done
	REP #$20
	LDA $02 : CMP !seconds_40 : BEQ .mirror ; mirror once at the start
	CMP !seconds_2 : BNE .done ; only one more mirror, at the end
	JSL RandomXORInt : AND #$0003 : BNE .done ; only mirror a 2nd time 1/4

.mirror
	SEP #$20
	LDA $040C : PHA ; remember current dungeon ID
	STZ $040C ; then set to 0 so we can mirror in caves
	STZ $0FFC ; prevents not warping
	STZ $02E4 ; prevents hardlocks
	STZ $5D ; probably a good idea
	JSL MagicMirrorBounce
	PLA : STA $040C ; back to our original dungeon ID

.done
	RTS

CrazyPalettes:
	JSR DecrementTimer_PlayAndMenu : BEQ .done
	LDA $02 : AND #$0F : BNE .done
	REP #$30
	PHX
	LDY.w #$0008
.loop
	JSL RandomXORInt : AND.w #$00FF ; 0-255
	ASL A : TAX ; since colors are words
	JSL RandomXORInt
	STA $7EC500, X
	DEY : BNE .loop

	INC $15
	PLX
.done
	RTS

DontTransform:
	db $1C ; boss explosions
	db $2C ; don't hide the lumber faces
	db $6C ; mirror portal
	db $AB ; crystal maiden
	db $B6 ; kiki
	db $E4 ; keys
	db $E5 ; big key
	db $ED ; somaria platform, just too cruel
	db $EA ; collectable items (doesn't cover quake but who cares)

BubbleAttack:
	JSR DecrementTimer_Play : BEQ .done
	LDA $02E4 ; if we can't move, don't do anything
	ORA $0B7B ; ditto
	ORA $0FFC : BNE .done ; if we can't use menu, don't do anythng
	PHX ; we only need a push/pull inside the cheat to set it off immediately

	LDX #$0F
.nextsprite
	LDY #$08
	LDA $0E20, X
	; make sure we don't transform certain sprites
	; some are kind of already covered by the above "action checks"
	; but it's better safe than sorry
.nexttranscheck
	CMP DontTransform, Y : BEQ .donttrans
	DEY : BPL .nexttranscheck
.transformable
	LDA $0DD0, X : CMP #$09 : BEQ .activesprite
	; we don't want to compare to $0A or we get a dumb invisible sprite
	CMP #$0B : BNE .notactive
.activesprite
	LDA #$40
	STA $01
	JSL $06EA20 ; Sprite_ApplySpeedTowardsPlayerLong
	LDA $00 : STA $0D40, X
	LDA $01 : STA $0D50, X
	LDA #$15 : STA $0E20, X ; set to anti fairies
	LDA #$FF : STA $0E50, X ; health
	LDA #$09 : STA $0DD0, X ; active
	; collision stuff, not alive for puzzles, bounce off screen
	LDA #$E0 : STA $0F60, X
	STZ $0B6B, X ; tile collision stuff
	STZ $0CAA, X ; deflection stuff
	LDA #$04 : STA $0CD2, X ; bump damage
	STA $0E40 ; happen to also want $04 here
	LDA #$80 : STA $0BE0, X ; more collision type stuff
.donttrans
.notactive
	DEX : BPL .nextsprite

	PLX

	STZ !chaos_cheat_ids, X
	JSL CheatAgainSoon

.done
	RTS

DropBombs:
	JSR DecrementTimer_Play : BEQ .done
	LDA $02 : AND #$7F : BNE .done
	STZ $0D
	LDA $7EF343 : BNE .placebomb
.zerobombs
	INC A : STA $7EF343 ; increment bomb count to be able to place
	LDA #$01 : STA $0D ; to say we had 0
.placebomb
	LDA #$07
	JSL $09811F ; AddBlueBomb, JP1.0 valid
	LDA #$20 : STA $039F, X ; short fuse

	LDA $0D : BNE .done
	LDA #$00 : STA $7EF343 ; no free bombs

.done
	RTS

SignGuy:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .keepactive
	STZ !Follower_Init ; ununit for next time
	LDA !Follower_Cache : STA $7EF3CC ; restore previous follower
	BEQ .done ; no follower, who cares about graphics
	PHX
	JSL Tagalong_LoadGfx ; old graphics back, if needed
	PLX
	RTS

.keepactive
	LDA !Follower_Init : BNE .alreadyinitted
	LDA $7EF3CC : STA !Follower_Cache ; cache old follower
	LDA #$09 : STA $7EF3CC ; sign guy
	STA !Follower_Init ; store sign guy to init var why not
	PHX
	JSL Tagalong_LoadGfx
	PLX
	RTS

.alreadyinitted
	LDA #$09 : STA $7EF3CC ; just keep loading him so he can't be lost

.done
	RTS

Blackout:
	JSR DecrementTimer_PlayAndMenu : BEQ .done
	LDA $02
	AND #$80 : BNE .dark
	LDA $13 : ORA #$0F : STA $13
	RTS

.dark
	LDA $13 : AND #$F0 : STA $13

.done
	RTS

RandomHalt:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .stilldo
	STZ !halttimer
	STZ $02E4
	RTS

.stilldo
	LDA !halttimer : BNE .decrementtimer
	STZ $02E4
	STZ $4D
	JSL RandomXORInt
	CMP #$00 : BNE .done
	LDA #$6F : STA !halttimer
	STA $031F
.decrementtimer
	DEC !halttimer
	LDA #$01 : STA $02E4

.done
	RTS

InvisibleLink:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .stilldo
	STZ $4B
	RTS

.stilldo
	LDA #$0C : STA $4B

.done
	RTS

SpeedChoices:
	db $06, $0F, $10, $10

RandomSpeed:
	JSR DecrementTimer_Play : BEQ .done
	LDA $02 : BNE .keepcurrentspeed
	JSL GetRandomInt : AND #$03
	TAX
	LDA SpeedChoices, X : STA !SpeedChoice
	
.keepcurrentspeed
	LDA !SpeedChoice : STA $5E

.done
	RTS

RandomMagic:
	JSR DecrementTimer_Play : BEQ .done
	LDA $02 : AND #$03 : BNE .keepcurrent
	JSL GetRandomInt : AND #$7C
	STA $7EF36E
	
.keepcurrent
.done
	RTS

AncillaTornado:
	JSR DecrementTimer_Play : BEQ .done
	LDA $02 : AND #$01 : BNE .done
	LDX #$09
.nextancilla
	LDA $0C4A, X : BEQ .skip
	LDA #$30
	JSL Ancilla_ProjectSpeedTowardsPlayerLong
	LDA $00 : STA $0C22, X
	LDA $01 : STA $0C2C, X
	JSL Ancilla_MoveLong
	; so the ancilla horizontal movement routine
	; is literally just the vertical routine
	; but it spoofs X forward 10 indices
	PHX
	TXA : CLC : ADC #$0A : TAX
	JSL Ancilla_MoveLong
	PLX
.skip
	DEX : BPL .nextancilla
.done
	RTS

MosaicDirections:
	db $10, $F0

Mosaic:
	JSR DecrementTimer_PlayAndMenu : BEQ .done
	CMP #$02 : BNE .keepmosaic
	STZ !mosaiclevel ; uninit basically, but this also will count for our current distortion
	STZ !mosaicdirection
	STZ $95
	RTS

.keepmosaic
	LDA !mosaiclevel : BNE .alreadyinit
	LDA #$03 : STA !mosaiclevel
.alreadyinit
	LDA !mosaiclevel : PHA
	; always restore mosaic, but don't always increment
	LDA $02 : AND #$07 : BNE .dontincrement
	LDX !mosaicdirection
	PLA : CLC : ADC MosaicDirections, X
	PHA
	AND #$F0 : BEQ .reversedirection
	CMP #$F0 : BNE .dontreversedirection
.reversedirection
	LDA !mosaicdirection : EOR #$01
	STA !mosaicdirection
.dontreversedirection
.dontincrement
	PLA
	STA !mosaiclevel
	STA $95

.done
	RTS

MenuSpeeds:
	dw $0002, $0003, $0004, $0005
	dw $FFFE, $FFFD, $FFFC, $FFFB

WTFHUD:
	JSR DecrementTimer_PlayAndMenu : BEQ .shouldbefine
	CMP #$02 : BNE .keepcheat
	STZ $E4
	STZ $E5
	LDA $10 : CMP #$0E : BNE .notinmenu
	LDA $11 : CMP #$01 : BNE .notinmenu
	LDA $0200 : CMP #$04 : BEQ .setmenuposition
	CMP #$07 : BCC .shouldbefine
.setmenuposition
	REP #$20
	LDA #$FF18 : STA $EA
	RTS
.shouldbefine
	RTS
.notinmenu
	REP #$20
	LDA #$0000 : STA $EA
	RTS

.keepcheat
	REP #$30
	LDA $02 : AND #$002F : BNE .nonewspeed
	JSL RandomXORInt : AND #$0007 : TAX
	LDA MenuSpeeds, X : STA !menuhorz
	JSL RandomXORInt : AND #$0007 : TAX
	LDA MenuSpeeds, X : STA !menuvert

.nonewspeed
	LDA $E4 : ADC !menuhorz : STA $E4
	LDA $10 : CMP #$010E : BNE .scrollvert ; see if we're in menu
	SEP #$30 : LDA $0200
	CMP #$01 : BEQ .temprestoremenupositiondown
	CMP #$05 : BEQ .temprestoremenupositionup
	CMP #$04 : BEQ .scrollvert
	RTS
.temprestoremenupositionup
	REP #$20
	LDA #$FF18 : STA $EA
	RTS
.temprestoremenupositiondown
	REP #$20
	LDA #$0000 : STA $EA
	RTS
.scrollvert
	REP #$20
	LDA $EA : ADC !menuvert : STA $EA
.dontdovert
.done
	RTS

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

Cacophony:
	JSR DecrementTimer_Play : BEQ .done
	LDA $02 : AND #$1F : BNE .done
	JSL RandomXORInt : AND #$3F
	CMP #$20 : BCS .useset2
.useset1
	AND #$1F : TAX
	LDA Cacophones_set1, X : STA $012E
	RTS
.useset2
	AND #$1F : TAX
	LDA Cacophones_set2, X : STA $012F
.done
	RTS

gfx_choices:
	dw $AC44, $AC46, $A864, $A26E
	dw $9486, $94CB, $94EC, $0824

; Coded as a JSR in Bank0D, via hooks
GetBusted:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .keepactive
	STZ !brokengraphics
	REP #$20
	LDA #$0000 : STA !brokengfx
	RTS

.keepactive
	LDA !brokengraphics : BNE .alreadyinit
	JSL RandomXORInt : AND #$07
	ASL : TAX
	REP #$20
	LDA gfx_choices, X : STA !brokengfx
	SEP #$20

.alreadyinit
	LDA #$01 : STA !brokengraphics

.done
	RTS

; ========================================================
; Blue rupees + tile collision replacement
; ========================================================
BlueRupees:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .keepactive
	STZ !BlueRupees
	LDA #$05 : STA !RupeeFloorValue
	RTS

.keepactive
	LDA #$01 : STA !BlueRupees
	STZ !RupeeFloorValue

.done
	RTS

BlueRupeesEverywhere:
	LDA !BlueRupees : BEQ .vanilla
	LDA #$FF
	RTL

.vanilla
	LDA $02F7 : AND.b #$22
	RTL

; ========================================================
; Z-coordinate broken-ness
; ========================================================
StupidZCoord:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .keepactive
	STZ !BrokenZ
	RTS

.keepactive
	LDA #$01 : STA !BrokenZ

.done
	RTS

DoCrazyZStuff:
	LDA !BrokenZ : BEQ .vanilla
	INC $24 : INC $24
	RTL

.vanilla
	LDA.b #$FF
	STA $24 : STA $25 : STA $29
	RTL

OtherZStuff:
	LDA !BrokenZ : BEQ .vanilla
	RTL

.vanilla
	LDA.b #$FF
	STA $24 : STA $25 : STA $29
	RTL

; ========================================================
; Enemies freeze on death and get tons of HP
; ========================================================
FreezeDeath:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .keepactive
	STZ !Spritecicles
	RTS

.keepactive
	LDA #$01 : STA !Spritecicles

.done
	RTS

FreezeMeMaybe:
	LDA !Spritecicles : BEQ .vanilla
	LDA $0DD0, X : CMP #$0B : BNE .freezehim
	LDA $7FFA3C, X : BNE .vanilla ; already frozen, so unfreeze and die

.freezehim
	LDA #$01 : STA $7FFA3C, X
	LDA #$0B : STA $0DD0, X
	STZ $0EF0, X ; no death timer
	LDA #$20 : STA $0E50, X ; 32 hp when frozen
	RTL

.vanilla
	LDA.b #$06 : STA $0DD0, X
	RTL

; ========================================================
; Inverted DPad inputs
; ========================================================
InvertDPad:
	JSR DecrementTimer_PlayAndMenu : BEQ .done
	CMP #$02 : BNE .keepactive
	STZ !DPad_inv
	RTS

.keepactive
	LDA #$80 : STA !DPad_inv

.done
	RTS

InvertDPadMaybe:
	LDA $4219 : BIT !DPad_inv : BPL .dont
	BIT.b #$0C : BEQ .donty
	EOR.b #$0C
.donty
	BIT.b #$03 : BEQ .dont
	EOR.b #$03
.dont
	STA $01
	RTL

.vanilla
	LDA $4219 : STA $01
	RTL

; ========================================================
; Long dash windup
; ========================================================
DashWindup:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .keepactive
	STZ !longdash
	RTS

.keepactive
	LDA #$01 : STA !longdash

.done
	RTS

IHopePeopleHateThis:
	LDA !longdash : BEQ .vanilla
	LDA #$6B : STA $0374
	RTL

.vanilla
	LDA #$1D : STA $0374
	RTL

; ========================================================
; Spawn random shit
; ========================================================
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

DropSprites:
	JSR DecrementTimer_Play : BEQ .done
	CMP #$02 : BNE .keepactive

	STZ !EnemySpawn
	STZ $0CF9 ; reset luck, and who cares about the luck pre cheat
	STZ $0CFA
	RTS

.keepactive
	LDA #$01 : STA !EnemySpawn
	STA $0CF9 ; luck status
	STA $0CFA ; luck kill counter (just in case)

.done
	RTS

SpawnRandomSprite:
	PHA
	LDA !EnemySpawn : BEQ .vanilla
	PLA ; clear the A we pushed now, we don't care about it
	PHX ; remember sprite index
	JSL RandomXORInt : AND #$3F : TAX
	LDA.l sprite_pool, X ; load sprite ID
	PLX ; bring X back
	PHA ; push sprite ID chosen

	LDA #$10 : STA $0E50, X ; just always give it 16 hp, who cares
	LDA #$09 : STA $0DD0, X ; set active
	LDA $0F60, X : ORA #$40 : STA $0F60, X ; count as dead

.vanilla
	PLA ; bring back sprite ID
.setspawn
	STA $0E20, X
	CMP #$E5
	RTL
